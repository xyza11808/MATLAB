% different from BP_test_scripts.m, using minibatch method for large data
% set

clear
clc
[X,T] = simpleclass_dataset;
xData = X;
yData = T;
%%
xData = [1,0,0,0;0,1,0,0;0,0,0,1;0,0,0,1;1,1,0,0;0,0,1,1];
xData = xData';
yData = [1,0,0;0,1,0;0,0,1;0,1,0;1,0,0;0,1,0];
yData = yData';
xData = xData(:,1:3);
yData = yData(:,1:3);
% %%
% xData = ([1,1,0,0])';
% yData = ([1,0])';
%%
clear
clc
cd('P:\THBI\DataSet');
TestIm = loadMNISTImages('t10k-images.idx3-ubyte');
TestLabel = loadMNISTLabels('t10k-labels.idx1-ubyte');
TrainIM = loadMNISTImages('train-images.idx3-ubyte');
TrainLabel = loadMNISTLabels('train-labels.idx1-ubyte');
xData = TrainIM;
yLabelData = TrainLabel';

yData = double(repmat((0:9)',1,size(yLabelData,2)) == repmat(yLabelData,10,1));

% xData = xData(:,1:10000);
% yData = yData(:,1:10000);

%%
HidNodesNum = [21];
nHiddenLayer = length(HidNodesNum); % hidden layers
nLearnRate = 0.7;
InputData = xData; % rows as number of observation, columns as number of samples

Inputvariables = sum(InputData,2);
RawInputData = InputData;
EmptyInputData = Inputvariables < 1e-16;
InputData = InputData(~EmptyInputData,:);
% InputData = rand(10,1);
% InputData = (TrainData(1,:))';
nInputNodes = size(InputData,1); % input nodes
% OutputData = TrainOutPutData(:,1);
% OutputData = [1,0];
OutputData = yData;
nOutputNodes = size(OutputData,1);
nSamples = size(InputData,2);  % samples to be trained
nHidNodesNum = [HidNodesNum,nOutputNodes];
nNetNodes = [nInputNodes,HidNodesNum,nOutputNodes];

OutFun = @(x) 1./(1+exp(-1*x)); % so that (OutFun)' = OutFun*(1-OutFun);
deltaFun = @(k,t) (OutFun(k) - t) .* OutFun(k) .*(1 - OutFun(k)); % used for weight derivative calculation

%%
IterErrorAll = [];
nIters = 1;
IterError = 1;
IterTime = tic;
LearnRate = [];
%
nSamples = size(InputData,2); 
nTotalSample = nSamples;
MiniBatchNums = nSamples;
IsMiniBatch = 0;
if nSamples > 500 && IsMiniBatch
    MiniRatio = 0.005;
%     MiniBatchNums = round(nSamples*MiniRatio);
    MiniBatchNums = 80;
    IsMiniBatch = 1;
    nSamples = MiniBatchNums;
end

%%
% initial weights for each hidden layer nodes
InputLayerW = rand(nInputNodes,nHidNodesNum(1));
HiddenLayerNodeW = cell(nHiddenLayer+1,1);
LayerActValue = cell(nHiddenLayer+1,1);
LayerOutValue = cell(nHiddenLayer+1,1);
DeltaJNodesData = cell(nHiddenLayer+1,1);
HiddenLBias = cell(nHiddenLayer+1,1);
WeightsMtxSize = cell(nHiddenLayer+1,1);
BiasMtxSize = cell(nHiddenLayer+1,1);
TotalElementNum = 0;
for nHl = 1 : nHiddenLayer+1
    if nHl == nHiddenLayer+1
        HiddenLayerNodeW{nHl} = 0.04*(rand(nOutputNodes,nHidNodesNum(nHl-1))-0.5); % should be the size of nNodes(l+1) by nNodes(l)
        HiddenLBias{nHl} = 0.04*(rand(nHidNodesNum(nHl),1)-0.5);
    elseif nHl == 1
        HiddenLayerNodeW{nHl} = 0.04*(rand(nHidNodesNum(nHl),nInputNodes)-0.5);
        HiddenLBias{nHl} = 0.04*(rand(nHidNodesNum(nHl),1)-0.5);
    else
        HiddenLayerNodeW{nHl} = 0.04*(rand(nHidNodesNum(nHl),nHidNodesNum(nHl-1))-0.5);
        HiddenLBias{nHl} = 0.04*(rand(nHidNodesNum(nHl),1)-0.5);
    end
    WeightsMtxSize{nHl} = size(HiddenLayerNodeW{nHl});
    BiasMtxSize{nHl} = size(HiddenLBias{nHl});
    TotalElementNum = TotalElementNum + numel(HiddenLayerNodeW{nHl}) + numel(HiddenLBias{nHl});
    
    LayerActValue{nHl} = zeros(nHidNodesNum(nHl),nSamples); % store the activation function for each layer
    LayerOutValue{nHl} = zeros(nHidNodesNum(nHl),nSamples); % store the output value for each layer
    
    DeltaJNodesData{nHl} = zeros(nHidNodesNum(nHl),nSamples); 
end
LayerSizeStrc.Weights_size = WeightsMtxSize;
LayerSizeStrc.Bias_size = BiasMtxSize;
LayerParaValuesStrc.Weights_Mtx = HiddenLayerNodeW;
LayerParaValuesStrc.Bias_Mtx = HiddenLBias;
% HiddenLBias = rand(length(nHidNodesNum),1);
% OutputNetInData = zeros(nOutputNodes,nSamples);
% OutputNetOutData = zeros(nOutputNodes,nSamples);
SampleWChange = cell(nHiddenLayer+1,1);
SampleBiasChange = cell(nHiddenLayer+1,1);
[AllVecs,ParaInds] = FeedfowardWB2Vec(LayerSizeStrc,LayerParaValuesStrc,TotalElementNum);
% % NewWBDataStrc = FeedfowardVec2WB(LayerSizeStrc,AllVecs,ParaInds);

%%

% parameters for adam optimization
AdamParam.LearnAlpha = 0.001;
AdamParam.Beta_1 = 0.9;
AdamParam.Beta_2 = 0.999;
AdamParam.Beta_1Updates = AdamParam.Beta_1;
AdamParam.Beta_2Updates = AdamParam.Beta_2;
AdamParam.ThresMargin = 1e-8; % to avoid zeros diveision
AdamParam.FirstMomentVec_W = cellfun(@(x) zeros(size(x)),HiddenLayerNodeW,'uniformOutput',false); % first moment vector
AdamParam.FirstMomentVec_B = cellfun(@(x) zeros(size(x)),HiddenLBias,'uniformOutput',false); % first moment vector
AdamParam.SecondMomentVec_W = cellfun(@(x) zeros(size(x)),HiddenLayerNodeW,'uniformOutput',false);  % second moment vector
AdamParam.SecondMomentVec_B = cellfun(@(x) zeros(size(x)),HiddenLBias,'uniformOutput',false); % second moment vector
IsShuffle = 1;

%% set up network parameters
NetParaSum = struct();
NetParaSum.InputData = [];
NetParaSum.TargetData = [];
NetParaSum.HiddenLayerNum = HidNodesNum;
NetParaSum.LayerConnWeights = HiddenLayerNodeW;
NetParaSum.LayerConnBias = HiddenLBias;
NetParaSum.LayerSizeStrc = LayerSizeStrc;
NetParaSum.AllParaVec = AllVecs;
NetParaSum.ParaVecInds = ParaInds;
NetParaSum.TotalParaNum = TotalElementNum;
NetParaSum.LayerActV = LayerActValue;
NetParaSum.LayerOutV = LayerOutValue;
NetParaSum.OutFun = 'Sigmoid';
% NetParaSum.OutFun = 'LeakyReLU';
NetParaSum.IsSoftMax = 0;
NetParaSum.DeltaJNodesDatas = DeltaJNodesData;
NetParaSum.FullLayerNodeNums = nNetNodes;
NetParaSum.gradParaVec = zeros(numel(AllVecs),1);

%% SampleLayerInOutData = cell(nInputNodes,1); % s

cBatchStartInds = 1;
while (nIters < 1e6) && (IterError > 1e-3)
    %
    if IsMiniBatch
        if (cBatchStartInds+MiniBatchNums) > nTotalSample
            Start2EndIndsNum = nTotalSample - cBatchStartInds;
            ExtraStartInds = MiniBatchNums - Start2EndIndsNum;
            
            MiniInds = [1:ExtraStartInds,cBatchStartInds+1:nTotalSample];
            cBatchStartInds = ExtraStartInds + 1;
            
            % Performing shuffle is given option
            if IsShuffle
                TotalInds = 1 : nTotalSample;
                ShufTotalInds = Vshuffle(TotalInds);
                InputData = InputData(:,ShufTotalInds);
                OutputData = OutputData(:,ShufTotalInds);
            end
%         elseif (cBatchStartInds+MiniBatchNums) == nTotalSample
%             MiniInds = cBatchStartInds + (0:MiniBatchNums-1);
%             cBatchStartInds 
        else
            MiniInds = cBatchStartInds + (0:MiniBatchNums-1);
        end
        MiniInputData = InputData(:,MiniInds);
        MiniOutPutData = OutputData(:,MiniInds);
        cMiniSample = MiniBatchNums;
%         if nIters == 1
%             SampleWChange = cellfun(@(x) repmat(x,1,1,cMiniSample),HiddenLayerNodeW,'UniformOutput',false);
%             SampleBiasChange = cellfun(@(x) repmat(x,1,cMiniSample),HiddenLBias,'UniformOutput',false);
%         end
    else
        MiniInputData = InputData;
        MiniOutPutData = OutputData;
        cMiniSample = nTotalSample;
%         if nIters == 1
%             SampleWChange = cellfun(@(x) repmat(x,1,1,cMiniSample),HiddenLayerNodeW,'UniformOutput',false);
%             SampleBiasChange = cellfun(@(x) repmat(x,1,cMiniSample),HiddenLBias,'UniformOutput',false);
%         end
    end
    
    NetParaSum.InputData = MiniInputData;
    NetParaSum.TargetData = MiniOutPutData;
    
    [IterError,NetParaSum] = NetWorkCalAndGrad(NetParaSum);
    if ~mod(nIters,50)
        fprintf(sprintf('cIterError = %.6f, Iter number %d.\n',IterError,nIters));
    end
    NewWBDataStrc = FeedfowardVec2WB(NetParaSum.LayerSizeStrc,NetParaSum.gradParaVec,NetParaSum.ParaVecInds);
    AvgWChange = NewWBDataStrc.Weights_Mtx;
    AvgBiasChange = NewWBDataStrc.Bias_Mtx;
%
    for nHls = 1 : nHiddenLayer+1
        AdamParam.FirstMomentVec_W{nHls} = AdamParam.Beta_1 * AdamParam.FirstMomentVec_W{nHls} + (1-AdamParam.Beta_1)*AvgWChange{nHls};
        AdamParam.SecondMomentVec_W{nHls} = AdamParam.Beta_2 * AdamParam.SecondMomentVec_W{nHls} + (1-AdamParam.Beta_2)*((AvgWChange{nHls}).^2);
        
        AdamParam.FirstMomentVec_B{nHls} =AdamParam.Beta_1 * AdamParam.FirstMomentVec_B{nHls} + (1-AdamParam.Beta_1)*AvgBiasChange{nHls};
        AdamParam.SecondMomentVec_B{nHls} = AdamParam.Beta_2 * AdamParam.SecondMomentVec_B{nHls} + (1-AdamParam.Beta_2)*((AvgBiasChange{nHls}).^2);
        
        m_hat_W = AdamParam.FirstMomentVec_W{nHls}/(1 - AdamParam.Beta_1Updates);
        v_hat_W = AdamParam.SecondMomentVec_W{nHls}/(1 - AdamParam.Beta_2Updates);
        m_hat_B = AdamParam.FirstMomentVec_B{nHls}/(1 - AdamParam.Beta_1Updates);
        v_hat_B = AdamParam.SecondMomentVec_B{nHls}/(1 - AdamParam.Beta_2Updates);
        
        TempHidenW = NetParaSum.LayerConnWeights{nHls} - AdamParam.LearnAlpha.*m_hat_W./(sqrt(v_hat_W)+AdamParam.ThresMargin);
        NetParaSum.LayerConnWeights{nHls} = TempHidenW;
        NetParaSum.LayerConnBias{nHls} = NetParaSum.LayerConnBias{nHls} - AdamParam.LearnAlpha.*m_hat_B./(sqrt(v_hat_B)+AdamParam.ThresMargin);
    end
    if mod(nIters,nTotalSample/MiniBatchNums)
        AdamParam.Beta_1Updates = AdamParam.Beta_1Updates * AdamParam.Beta_1;
        AdamParam.Beta_2Updates = AdamParam.Beta_2Updates * AdamParam.Beta_2;
    end
    LayerParaValuesStrc.Weights_Mtx = NetParaSum.LayerConnWeights;
    LayerParaValuesStrc.Bias_Mtx = NetParaSum.LayerConnBias;
    [NewAllVecs,~] = FeedfowardWB2Vec(LayerSizeStrc,LayerParaValuesStrc,NetParaSum.TotalParaNum);
    NetParaSum.AllParaVec = NewAllVecs;
    %
    IterErrorAll(nIters) = IterError;
    nIters = nIters + 1;
%     nLearnRate = nLearnRate * 0.9;
%     if nLearnRate < 0.001
%         nLearnRate = 0.6;
%     end
%     LearnRate(nIters) = nLearnRate;
    cBatchStartInds = cBatchStartInds + MiniBatchNums;
end

%%
TrainTime = toc(IterTime);
RealIter = nIters - 1;
fprintf('BP stops after %d iterations, with ErrorRate = %.2e, time used is %d seconds.\n',RealIter,IterError,TrainTime);
figure;
plot(1:RealIter,IterErrorAll,'k-o','LineWidth',1.6);
xlabel('Itrerations');
ylabel('Eror');
