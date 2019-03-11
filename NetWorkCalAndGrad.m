function [IterError,NetParaStrc] = NetWorkCalAndGrad(NetParaStrc,varargin)
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
%
% currently varargin used for function calculation control
% add support for other methods in future
% XY, 2019-03-05

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
    NetParaStrc.OutFun =  @(x) 1./(1+exp(-1*x)); 
end
OutFun = NetParaStrc.OutFun;

% NetParaStrc.FullLayerNodeNums = [size(NetParaStrc.InputData,1),NetParaStrc.HiddenLayerNum,...
%     size(NetParaStrc.TargetData,1)];

SampleNum = size(NetParaStrc.InputData,2);
nHiddenLayer = length(NetParaStrc.HiddenLayerNum);
SampleWChange = cell(nHiddenLayer+1,1);
SampleBiasChange = cell(nHiddenLayer+1,1);

LayerActValue = NetParaStrc.LayerActV;
LayerOutValue = NetParaStrc.LayerOutV;
DeltaJNodesData = NetParaStrc.DeltaJNodesDatas;
% start the forward calculation
for nHLs = 1 : nHiddenLayer
    if nHLs == 1
        FormerLayerData = NetParaStrc.InputData;
    else
        FormerLayerData = LayerOutValue{nHLs - 1};
    end
    % LayerActValue  LayerOutValue
    cLayerWeights = NetParaStrc.LayerConnWeights{nHLs};
    cLayerActData = cLayerWeights * FormerLayerData + repmat(NetParaStrc.LayerConnBias{nHLs},1,SampleNum);
    LayerActValue{nHLs} = cLayerActData;
    LayerOutValue{nHLs} = OutFun(cLayerActData);

end
% calculate the output error
OutputNetInData = NetParaStrc.LayerConnWeights{nHiddenLayer + 1} * ...
    LayerOutValue{nHiddenLayer} + repmat(NetParaStrc.LayerConnBias{nHiddenLayer + 1},1,SampleNum);
OutputNetOutData = OutFun(OutputNetInData);
LayerOutValue{nHiddenLayer+1} = OutputNetOutData;
NetParaStrc.NetOutputValue = OutputNetOutData;

%
IterErroAll = (OutputNetOutData - NetParaStrc.TargetData).^2;
% IterError = sum(IterErroAll(:))/(SampleNum*NetParaStrc.FullLayerNodeNums(end)); % using MSE as error data
IterError = 0.5 * mean(sum(IterErroAll));
NetParaStrc.NetPerf = IterError;

deltaOutNodesData = OutputNetOutData .* (1 - OutputNetOutData) .* (OutputNetOutData - NetParaStrc.TargetData);  % Delta K
DeltaJNodesData{nHiddenLayer + 1} = deltaOutNodesData;

% calculate the gradient
for nHls = nHiddenLayer : -1 : 1
    if nHls == nHiddenLayer
        LatterPart = (NetParaStrc.LayerConnWeights{nHls + 1})' * deltaOutNodesData;
        DeltaJNodesData{nHls} = LayerOutValue{nHls} .* (1 - LayerOutValue{nHls}) .* LatterPart;
%             DeltaJNodesData{nHls}(:,cSample) = cLayerOutData .* (1 - cLayerOutData) .* LatterPart;
    else
        LatterPart = (NetParaStrc.LayerConnWeights{nHls + 1})' * (DeltaJNodesData{nHls+1});
        DeltaJNodesData{nHls} = LayerOutValue{nHls} .* (1 - LayerOutValue{nHls}) .* LatterPart;
%             DeltaJNodesData{nHls}(:,cSample) = cLayerOutData .* (1 - cLayerOutData) .* LatterPart;

    end
end

NetParaStrc.LayerActV = LayerActValue;
NetParaStrc.LayerOutV = LayerOutValue;
NetParaStrc.DeltaJNodesDatas = DeltaJNodesData;

for nHls = 1 : nHiddenLayer+1
    if nHls == 1
        cWeightsChange = DeltaJNodesData{nHls} * (NetParaStrc.InputData)';
    else
        cWeightsChange = DeltaJNodesData{nHls} * (LayerOutValue{nHls-1})';
    end

    SampleWChange{nHls} = cWeightsChange;
    SampleBiasChange{nHls} = DeltaJNodesData{nHls};
end

AvgWChange = cellfun(@(x) x/SampleNum,SampleWChange,'UniformOutput',false);
AvgBiasChange = cellfun(@(x) squeeze(mean(x,2)),SampleBiasChange,'UniformOutput',false);

% convert the cell vector into single numeric vector
gradLayerParaVStrc.Weights_Mtx = AvgWChange;
gradLayerParaVStrc.Bias_Mtx = AvgBiasChange;
[gradAllVecs,~] = FeedfowardWB2Vec(NetParaStrc.LayerSizeStrc,...
        gradLayerParaVStrc,NetParaStrc.TotalParaNum);

NetParaStrc.gradParaVec = gradAllVecs;


