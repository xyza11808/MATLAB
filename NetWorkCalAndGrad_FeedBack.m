function [IterError,NetParaStrc] = NetWorkCalAndGrad_FeedBack(NetParaStrc,varargin)
% for feedforward network calculation, also calculate the gradient if asked
% NetParaStrc: should at least contains following fields for calculation
%           InputData: N * M matrix, N indicates the observer number, M
%                      indicates sample number
%           TargetData: Q * M matrix, Q indicates the target class number
%           HiddenLayerNum: The number of nodes for each hidden layer
%           LayerConnWeights: The connection weights for each layer
%           LayerConnBias: The connection bias for each layer
%           LayerSizeStrc: parameter size for each layer
%           AllParaVec: Single vector contains all network parameters
%           ParaVecInds: Inds used for separate all parameter vec
%           TotalParaNum: The number of parameters in network
%           LayerActV: cell array data, the input data for
%                       each layer
%           LayerOutV: cell array data, the ouutput data for
%                       each layer
%           OutFun: The activation function for each nodes
%           DeltaJNodesDatas: the delta function value for each layer
% 
%           FullLayerNodeNums: The nodes number for each layer, includes
%                        input and output layer
%           gradParaVec: parameter's Gradient vector 
%           NetPerf: The output error for current calculation
% 
%           NetOutputValue: Layer Output values
%
%           IsSoftMax: whether using softmax for output
%           SoftMaxOut: default is [], if Softmax method is used, this is the
%                   softmax output value
%
%
% currently varargin used for function calculation control
% add support for other methods in future
% XY, 2020-04-30
% ref:  Geoffrey Hinton et al, 2020, 'Backpropagation and the brain'; nn

if ~isfield(NetParaStrc,'IsSoftMax')
    NetParaStrc.IsSoftMax = 0;
end
NetParaStrc.SoftMaxOut = [];

if ~(isfield(NetParaStrc,'LayerConnWeights') || isfield(NetParaStrc,'AllParaVec'))
    error('The weights parameters should at least have one input.');
elseif isfield(NetParaStrc,'AllParaVec')
    % if all exists, considering the vector format data first
    % currently not doing anything
    % converting vector into cell matrix
    NewWBDataStrc = FeedfowardVec2WB(NetParaStrc.LayerSizeStrc,NetParaStrc.AllParaVec,...
        NetParaStrc.ParaVecInds);
    NetParaStrc.LayerConnWeights = NewWBDataStrc.Weights_Mtx;
    NetParaStrc.LayerConnBias = NewWBDataStrc.Bias_Mtx;
elseif isfield(NetParaStrc,'LayerConnWeights')
    % converting cell weights into vector
    LayerParaValuesStrc.Weights_Mtx = NetParaStrc.LayerConnWeights;
    LayerParaValuesStrc.Bias_Mtx = NetParaStrc.LayerConnBias;
    [AllVecs,ParaInds] = FeedfowardWB2Vec(NetParaStrc.LayerSizeStrc,...
        LayerParaValuesStrc,NetParaStrc.TotalParaNum);
    NetParaStrc.AllParaVec = AllVecs;
    NetParaStrc.ParaVecInds = ParaInds;
end

if isempty(NetParaStrc.OutFun)
    NetParaStrc.OutFun =  'Sigmoid';
%     NetParaStrc.OutFun =  @(x) 1./(1+exp(-1*x)); 
end
[OutFun,DerivOutFun] = ActFunCheck(NetParaStrc.OutFun);
[FBOutFun,FBDerivOutFun] = ActFunCheck(NetParaStrc.FBOutFun);
% OutFun = NetParaStrc.OutFun;

% NetParaStrc.FullLayerNodeNums = [size(NetParaStrc.InputData,1),NetParaStrc.HiddenLayerNum,...
%     size(NetParaStrc.TargetData,1)];
%%
SampleNum = size(NetParaStrc.InputData,2);
nHiddenLayer = length(NetParaStrc.FullLayerNodeNums) - 2;

AllInOutDatas = NetParaStrc.Layer_IO_Datas;
LayerActValue = AllInOutDatas{1,1};
LayerOutValue = AllInOutDatas{1,2};

FB_LayerOutValue = AllInOutDatas{2,2};

%%
% start the forward calculation
for cL = 1 : nHiddenLayer+1
    if cL == 1
        FormerLayerData = NetParaStrc.InputData;
    else
        FormerLayerData = LayerOutValue{cL - 1};
    end
    
    cLayerWeights = NetParaStrc.LayerConnWeights{cL};
    cLayerActData = cLayerWeights * FormerLayerData;% + repmat(NetParaStrc.LayerConnBias{cL},1,SampleNum);
    LayerActValue{cL} = cLayerActData;
    LayerOutValue{cL} = OutFun(cLayerActData);
end

IterError = 0.5*sum(mean(LayerOutValue{end} - NetParaStrc.TargetData).^2,2);
%% perform feedback calculation
% FBh_tildesAll = cell(nHiddenLayer+1,1);
for cL = (nHiddenLayer+1):-1:1
    
    if cL == nHiddenLayer+1
        FB_LayerOutValue{cL} = NetParaStrc.TargetData; % target output 
    else
        cFB_lateL_layerW = NetParaStrc.FBLayerConnWeights{cL};
        cLtilde_Data = LayerOutValue{cL} - FBOutFun(cFB_lateL_layerW*LayerOutValue{cL+1})...
            + FBOutFun(cFB_lateL_layerW * FB_LayerOutValue{cL+1}); 
        FB_LayerOutValue{cL} = FBOutFun(cLtilde_Data);
    end
    
%     cFB_layerActData = cFB_layerW * cLtilde_Data + repmat(NetParaStrc.FBLayerConnBias{cL},1,SampleNum);
%   FB_LayerActValue{cL} = cFB_layerActData;
    
end
%% ################################################################################################
% calculate forward weight gradient
Forward_DeltaValue = cell(nHiddenLayer+1,1);
Forward_WeichangeData = cell(nHiddenLayer+1,1);
for cL = (nHiddenLayer+1):-1:1
    
    Layer_e = FB_LayerOutValue{cL} - LayerOutValue{cL};
    Layer_DeltaValue = Layer_e .* DerivOutFun(LayerOutValue{cL});
    Forward_DeltaValue{cL} = Layer_DeltaValue;
    if cL == 1
        cWeightsDelta = Layer_DeltaValue * NetParaStrc.InputData';
    else
        cWeightsDelta = Layer_DeltaValue * LayerOutValue{cL-1}';
    end
    Forward_WeichangeData{cL} = cWeightsDelta;
end
%% calculate the feedback weight gradient
Feedback_DeltaValue = cell(nHiddenLayer,1);
Feedback_WeichangeData = cell(nHiddenLayer,1);
for cL = nHiddenLayer:-1:1
    FB_e = LayerOutValue{cL} - FBOutFun(NetParaStrc.FBLayerConnWeights{cL}* LayerOutValue{cL+1});
    cFBL_deltaValue = FB_e .* FBDerivOutFun(NetParaStrc.FBLayerConnWeights{cL}*LayerOutValue{cL+1});
    Feedback_DeltaValue{cL} = cFBL_deltaValue;
    DeltaFB_weights = cFBL_deltaValue * (LayerOutValue{cL+1})';
    Feedback_WeichangeData{cL} = DeltaFB_weights;
end
%%
% update forward weights
for cL = 1 : nHiddenLayer+1
    NetParaStrc.LayerConnWeights{cL} = NetParaStrc.LayerConnWeights{cL} - NetParaStrc.LearnRate * Forward_WeichangeData{cL};
end
% update feedback weights
for cL = 1 : nHiddenLayer
    NetParaStrc.FBLayerConnWeights{cL} = NetParaStrc.FBLayerConnWeights{cL} - NetParaStrc.LearnRate * Feedback_WeichangeData{cL};
end

figure;
%%
% AvgWChange = cellfun(@(x) x/SampleNum,SampleWChange,'UniformOutput',false);
% AvgBiasChange = cellfun(@(x) squeeze(mean(x,2)),SampleBiasChange,'UniformOutput',false);
% 
% IterError = 1;
% 
% % convert the cell vector into single numeric vector
% gradLayerParaVStrc.Weights_Mtx = AvgWChange;
% gradLayerParaVStrc.Bias_Mtx = AvgBiasChange;
% [gradAllVecs,~] = FeedfowardWB2Vec(NetParaStrc.LayerSizeStrc,...
%         gradLayerParaVStrc,NetParaStrc.TotalParaNum);
% 
% NetParaStrc.gradParaVec = gradAllVecs;
        
        
        
