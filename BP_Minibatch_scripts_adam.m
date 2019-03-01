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

xData = xData(:,1:1000);
yData = yData(:,1:1000);

%%
HidNodesNum = [20];
nHiddenLayer = length(HidNodesNum); % 3 hidden layers
nLearnRate = 0.7;

% InputData = rand(10,1);
% InputData = (TrainData(1,:))';
InputData = xData; % rows as number of observation, columns as number of samples
nInputNodes = size(InputData,1); % input nodes
% OutputData = TrainOutPutData(:,1);
% OutputData = [1,0];
OutputData = yData;
nOutputNodes = size(OutputData,1);
nSamples = size(InputData,2);  % samples to be trained
nHidNodesNum = [HidNodesNum,nOutputNodes];

OutFun = @(x) 1./(1+exp(-1*x)); % so that (OutFun)' = OutFun*(1-OutFun);
deltaFun = @(k,t) (OutFun(k) - t) .* OutFun(k) .*(1 - OutFun(k)); % used for weight derivative calculation
%%
% initial weights for each hidden layer nodes
InputLayerW = rand(nInputNodes,nHidNodesNum(1));
HiddenLayerNodeW = cell(nHiddenLayer+1,1);
LayerActValue = cell(nHiddenLayer+1,1);
LayerOutValue = cell(nHiddenLayer+1,1);
DeltaJNodesData = cell(nHiddenLayer+1,1);
HiddenLBias = cell(nHiddenLayer,1);
for nHl = 1 : nHiddenLayer+1
    if nHl == nHiddenLayer+1
        HiddenLayerNodeW{nHl} = rand(nOutputNodes,nHidNodesNum(nHl-1)); % should be the size of nNodes(l+1) by nNodes(l)
        HiddenLBias{nHl} = rand(nHidNodesNum(nHl),1);
    elseif nHl == 1
        HiddenLayerNodeW{nHl} = rand(nHidNodesNum(nHl),nInputNodes);
        HiddenLBias{nHl} = rand(nHidNodesNum(nHl),1);
    else
        HiddenLayerNodeW{nHl} = rand(nHidNodesNum(nHl),nHidNodesNum(nHl-1));
        HiddenLBias{nHl} = rand(nHidNodesNum(nHl),1);
    end
    LayerActValue{nHl} = zeros(nHidNodesNum(nHl),nSamples); % store the activation function for each layer
    LayerOutValue{nHl} = zeros(nHidNodesNum(nHl),nSamples); % store the output value for each layer
    
    DeltaJNodesData{nHl} = zeros(nHidNodesNum(nHl),nSamples); 
end

% HiddenLBias = rand(length(nHidNodesNum),1);
OutputNetInData = zeros(nOutputNodes,nSamples);
OutputNetOutData = zeros(nOutputNodes,nSamples);

%%
IterErrorAll = [];
nIters = 1;
IterError = 1;
IterTime = tic;
LearnRate = [];

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

%% SampleLayerInOutData = cell(nInputNodes,1); % s
%
nSamples = size(InputData,2); 
IsMiniBatch = 0;
if nSamples > 500
    MiniRatio = 0.005;
%     MiniBatchNums = round(nSamples*MiniRatio);
    MiniBatchNums = 50;
    IsMiniBatch = 1;
    nTotalSample = nSamples;
end

MiniInputData = InputData;
MiniOutPutData = OutputData;
cMiniSample = nTotalSample;
cBatchStartInds = 1;
while (nIters < 1e6) && (IterError > 1e-3)
    
    if IsMiniBatch
        if (cBatchStartInds+MiniBatchNums) > nTotalSample
            Start2EndIndsNum = nTotalSample - cBatchStartInds;
            ExtraStartInds = MiniBatchNums - Start2EndIndsNum;
            
            MiniInds = [1:ExtraStartInds,cBatchStartInds+1:nTotalSample];
            cBatchStartInds = ExtraStartInds + 1;
%         elseif (cBatchStartInds+MiniBatchNums) == nTotalSample
%             MiniInds = cBatchStartInds + (0:MiniBatchNums-1);
%             cBatchStartInds 
        else
            MiniInds = cBatchStartInds + (0:MiniBatchNums-1);
        end
        MiniInputData = InputData(:,MiniInds);
        MiniOutPutData = OutputData(:,MiniInds);
        cMiniSample = MiniBatchNums;
        if nIters == 1
            SampleWChange = cellfun(@(x) repmat(x,1,1,cMiniSample),HiddenLayerNodeW,'UniformOutput',false);
            SampleBiasChange = cellfun(@(x) repmat(x,1,cMiniSample),HiddenLBias,'UniformOutput',false);
        end
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
    %
    IterErroAll = (OutputNetOutData - MiniOutPutData).^2;
    IterError = 0.5 * sum(IterErroAll(:))/cMiniSample;
    if ~mod(nIters,50)
        fprintf(sprintf('cIterError = %.3f, Iter number %d.\n',IterError,nIters));
    end
    %
    % backpropagate the errors
    % deltaOutNodesData = zeros(nOutputNodes,1);
    deltaOutNodesData = OutputNetOutData .* (1 - OutputNetOutData) .* (OutputNetOutData - MiniOutPutData);  % Delta K
    DeltaJNodesData{nHiddenLayer + 1} = deltaOutNodesData;
    % DeltaJNodesData
    %
%     SampleWChange = cell(nHiddenLayer+1,nSamples);
%     SampleBiasChange = cell(nHiddenLayer+1,nSamples);
    for cSample = 1 : cMiniSample
        %
        cSamdeltaOutPutData = deltaOutNodesData(:,cSample);
        for nHls = nHiddenLayer : -1 : 1
    %         cHlNodes = nHidNodesNum(nHls);
            if nHls == nHiddenLayer
                cLayerOutData = LayerOutValue{nHls}(:,cSample);
                cLayerCWeight = HiddenLayerNodeW{nHls + 1};
                DeepLayerDelta = cSamdeltaOutPutData;
                LatterPart = cLayerCWeight' * DeepLayerDelta;
                
                DeltaJNodesData{nHls}(:,cSample) = cLayerOutData .* (1 - cLayerOutData) .* LatterPart;
            else
                cLayerOutData = LayerOutValue{nHls}(:,cSample);
                cLayerCWeight = HiddenLayerNodeW{nHls + 1};
                DeepLayerDelta = DeltaJNodesData{nHls+1}(:,cSample);
                LatterPart = cLayerCWeight' * DeepLayerDelta;
                
                DeltaJNodesData{nHls}(:,cSample) = cLayerOutData .* (1 - cLayerOutData) .* LatterPart;
                
%                 for nNodes = 1 : cHlNodes
%                     cNodesOutput = LayerInOutValue{nHls}(nNodes,2);
%                     cNodesWeights = HiddenLayerNodeW{nHls}(nNodes,:);
%                     DeltaJNodesData{nHls}(nNodes) = cNodesOutput*(1-cNodesOutput)...
%                         *sum((DeltaJNodesData{nHls+1}(:))' .* HiddenLayerNodeW{nHls}(nNodes,:));
%                 end
            end
        end
        %
        % updates the weights
        for nHls = 1 : nHiddenLayer+1
%             cnNodes = nHidNodesNum(nHls);
            if nHls == 1
                cWeightsChange = DeltaJNodesData{nHls}(:,cSample) * (MiniInputData(:,cSample))';
%                 cSampleWChange =  (cWeightsChange * nLearnRate);
            else
                cWeightsChange = DeltaJNodesData{nHls}(:,cSample) .* (LayerOutValue{nHls-1}(:,cSample))';
%                 cSampleWChange =  (cWeightsChange * nLearnRate);
            end
%             if cSample == 1
%                 SampleWChange{nHls} = cSampleWChange;
%                 SampleBiasChange{nHls} = DeltaJNodesData{nHls}(:,cSample) * (-1) * nLearnRate;
%             else
%                 SampleWChange{nHls} = SampleWChange{nHls} + cSampleWChange;
%                 SampleBiasChange{nHls} = SampleBiasChange{nHls} - DeltaJNodesData{nHls}(:,cSample) * nLearnRate;
%             end
            
            SampleWChange{nHls}(:,:,cSample) = cWeightsChange;
            SampleBiasChange{nHls}(:,cSample) = DeltaJNodesData{nHls}(:,cSample);
        end
        %
    end
    AvgWChange = cellfun(@(x) squeeze(mean(x,3)),SampleWChange,'UniformOutput',false);
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
