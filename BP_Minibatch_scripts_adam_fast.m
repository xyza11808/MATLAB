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

Inputvariables = sum(xData,2);
RawInputData = xData;
EmptyInputData = Inputvariables < 1e-16;
xData = xData(~EmptyInputData,:);

xData = xData(:,1:10000);
yData = yData(:,1:10000);

%%
% clearvars -except xData yData
HidNodesNum = [21];
nHiddenLayer = length(HidNodesNum); % hidden layers
nLearnRate = 0.7;
InputData = xData; % rows as number of observation, columns as number of samples


% InputData = rand(10,1);
% InputData = (TrainData(1,:))';
nInputNodes = size(InputData,1); % input nodes
% OutputData = TrainOutPutData(:,1);
% OutputData = [1,0];
OutputData = yData;
nOutputNodes = size(OutputData,1);
nHidNodesNum = [HidNodesNum,nOutputNodes];
nNetNodes = [nInputNodes,HidNodesNum,nOutputNodes];

OutFun = @(x) 1./(1+exp(-1*x)); % so that (OutFun)' = OutFun*(1-OutFun);
deltaFun = @(k,t) (OutFun(k) - t) .* OutFun(k) .*(1 - OutFun(k)); % used for weight derivative calculation

nSamples = size(InputData,2); 
nTotalSample = nSamples;
MiniBatchNums = nSamples;
%%
IterErrorAll = [];
nIters = 1;
IterError = 1;
IterTime = tic;
LearnRate = [];
%

IsMiniBatch = 0;
if nSamples > 500 && IsMiniBatch
    MiniRatio = 0.005;
%     MiniBatchNums = round(nSamples*MiniRatio);
    MiniBatchNums = 100;
%     IsMiniBatch = 1;
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
% % % [AllVecs,ParaInds] = FeedfowardWB2Vec(LayerSizeStrc,LayerParaValuesStrc,TotalElementNum);
% % % NewWBDataStrc = FeedfowardVec2WB(LayerSizeStrc,AllVecs,ParaInds);

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

 %% SampleLayerInOutData = cell(nInputNodes,1); % s

cBatchStartInds = 1;
LastErr = 1;
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
    % start the forward calculation
    for nHLs = 1 : nHiddenLayer
        if nHLs == 1
            FormerLayerNodes = nInputNodes;
            FormerLayerData = MiniInputData;
        else
            FormerLayerNodes = nHidNodesNum(nHLs - 1);
            FormerLayerData = LayerOutValue{nHLs - 1};
        end
        % LayerActValue  LayerOutValue
        cLayerWeights = HiddenLayerNodeW{nHLs};
        cLayerActData = cLayerWeights * FormerLayerData + repmat(HiddenLBias{nHLs},1,cMiniSample);
        LayerActValue{nHLs} = cLayerActData;
        LayerOutValue{nHLs} = OutFun(cLayerActData);
        
    end

    OutputNetInData = HiddenLayerNodeW{nHiddenLayer + 1} * LayerOutValue{nHiddenLayer} + repmat(HiddenLBias{nHiddenLayer + 1},1,cMiniSample);
    OutputNetOutData = OutFun(OutputNetInData);
    LayerOutValue{nHiddenLayer+1} = OutputNetOutData;
    %
    IterErroAll = (OutputNetOutData - MiniOutPutData).^2;
    IterError = 0.5 * sum(IterErroAll(:))/cMiniSample;
    if ~mod(nIters,50)
        fprintf(sprintf('cIterError = %.5f, Iter number %d.\n',IterError,nIters));
    end
    %
    % backpropagate the errors
    % deltaOutNodesData = zeros(nOutputNodes,1);
    deltaOutNodesData = OutputNetOutData .* (1 - OutputNetOutData) .* (OutputNetOutData - MiniOutPutData);  % Delta K
    DeltaJNodesData{nHiddenLayer + 1} = deltaOutNodesData;

    for nHls = nHiddenLayer : -1 : 1
        if nHls == nHiddenLayer
%             cLayerOutData = LayerOutValue{nHls}(:,cSample);
%             cLayerCWeight = HiddenLayerNodeW{nHls + 1};
%             DeepLayerDelta = cSamdeltaOutPutData;
%             LatterPart = cLayerCWeight' * DeepLayerDelta;
            LatterPart = (HiddenLayerNodeW{nHls + 1})' * deltaOutNodesData;
            DeltaJNodesData{nHls} = LayerOutValue{nHls} .* (1 - LayerOutValue{nHls}) .* LatterPart;
%             DeltaJNodesData{nHls}(:,cSample) = cLayerOutData .* (1 - cLayerOutData) .* LatterPart;
        else
%             cLayerOutData = LayerOutValue{nHls}(:,cSample);
%             cLayerCWeight = HiddenLayerNodeW{nHls + 1};
%             DeepLayerDelta = DeltaJNodesData{nHls+1}(:,cSample);
%             LatterPart = cLayerCWeight' * DeepLayerDelta;
            LatterPart = (HiddenLayerNodeW{nHls + 1})' * (DeltaJNodesData{nHls+1});
            DeltaJNodesData{nHls} = LayerOutValue{nHls} .* (1 - LayerOutValue{nHls}) .* LatterPart;
%             DeltaJNodesData{nHls}(:,cSample) = cLayerOutData .* (1 - cLayerOutData) .* LatterPart;
            
        end
    end
    %
    % updates the weights
    for nHls = 1 : nHiddenLayer+1
        %             cnNodes = nHidNodesNum(nHls);
        if nHls == 1
            cWeightsChange = DeltaJNodesData{nHls} * MiniInputData';
            %                 cSampleWChange =  (cWeightsChange * nLearnRate);
        else
            cWeightsChange = DeltaJNodesData{nHls} * (LayerOutValue{nHls-1})';
            %                 cSampleWChange =  (cWeightsChange * nLearnRate);
        end
        
        SampleWChange{nHls} = cWeightsChange;
        SampleBiasChange{nHls} = DeltaJNodesData{nHls};
    end
    %
    
    AvgWChange = cellfun(@(x) x/cMiniSample,SampleWChange,'UniformOutput',false);
    AvgBiasChange = cellfun(@(x) squeeze(mean(x,2)),SampleBiasChange,'UniformOutput',false);
    
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
        
        TempHidenW = HiddenLayerNodeW{nHls} - AdamParam.LearnAlpha.*m_hat_W./(sqrt(v_hat_W)+AdamParam.ThresMargin);
        HiddenLayerNodeW{nHls} = TempHidenW;
        HiddenLBias{nHls} = HiddenLBias{nHls} - AdamParam.LearnAlpha.*m_hat_B./(sqrt(v_hat_B)+AdamParam.ThresMargin);
    end
    if mod(nIters,nTotalSample/MiniBatchNums)
        AdamParam.Beta_1Updates = AdamParam.Beta_1Updates * AdamParam.Beta_1;
        AdamParam.Beta_2Updates = AdamParam.Beta_2Updates * AdamParam.Beta_2;
    end
    %
    IterErrorAll(nIters) = IterError;
    nIters = nIters + 1;
    if nIters > 4
        LastErr = mean(IterErrorAll(end-3:end));
    end
    if mean(abs(diff(IterErrorAll(end-500:end))) < 1e-3) > 0.9
        break;
    end
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

%% calculate the test data output
TestInput = TestOnOffData;
TestOutput = TestOnOffLabel;
LayerOutValue = cell(nHiddenLayer+1,1);
cMiniSample = size(TestInput, 2);
%%
% start the forward calculation
    for nHLs = 1 : nHiddenLayer
        if nHLs == 1
            FormerLayerNodes = nInputNodes;
            FormerLayerData = TestInput;
        else
            FormerLayerNodes = nHidNodesNum(nHLs - 1);
            FormerLayerData = LayerOutValue{nHLs - 1};
        end
        % LayerActValue  LayerOutValue
        cLayerWeights = HiddenLayerNodeW{nHLs};
        cLayerActData = cLayerWeights * FormerLayerData + repmat(HiddenLBias{nHLs},1,cMiniSample);
        LayerActValue{nHLs} = cLayerActData;
        LayerOutValue{nHLs} = OutFun(cLayerActData);
        
    end

    OutputNetInData = HiddenLayerNodeW{nHiddenLayer + 1} * LayerOutValue{nHiddenLayer} + repmat(HiddenLBias{nHiddenLayer + 1},1,cMiniSample);
    OutputNetOutData = OutFun(OutputNetInData);
    LayerOutValue{nHiddenLayer+1} = OutputNetOutData;

TestErroAll = (OutputNetOutData - TestOutput).^2;
AvgTestError = 0.5 * sum(TestErroAll(:))/cMiniSample;
fprintf('Test Dataset error is %.4f.\n', AvgTestError);

