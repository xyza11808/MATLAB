% different from BP_test_scripts.m, using minibatch method for large data
% set

clear
clc

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
[X,T] = simpleclass_dataset;
xData = X;
yData = T;

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

xData = xData(:,1:10000);
yData = yData(:,1:10000);
%%
HidNodesNum = [20];
nHiddenLayer = length(HidNodesNum); % 3 hidden layers
nLearnRate = 0.7;

InputData = xData; % rows as number of observation, columns as number of samples

Inputvariables = sum(InputData,2);
RawInputData = InputData;
EmptyInputData = Inputvariables < 1e-16;
InputData = InputData(~EmptyInputData,:);

nInputNodes = size(InputData,1); % input nodes
% OutputData = TrainOutPutData(:,1);
% OutputData = [1,0];
OutputData = yData;
nOutputNodes = size(OutputData,1);

nHidNodesNum = [HidNodesNum,nOutputNodes];

OutFun = @(x) 1./(1+exp(-1*x)); % so that (OutFun)' = OutFun*(1-OutFun);
deltaFun = @(k,t) (OutFun(k) - t) .* OutFun(k) .*(1 - OutFun(k)); % used for weight derivative calculation
%%
IterErrorAll = [];
nIters = 1;
IterError = 1;
IterTime = tic;
LearnRate = [];
%% SampleLayerInOutData = cell(nInputNodes,1); % s
%
nSamples = size(InputData,2);  % samples to be trained
IsMiniBatch = 0;
if nSamples > 500
    MiniRatio = 0.01;
    MiniBatchNums = round(nSamples*MiniRatio);
    IsMiniBatch = 1;
    nTotalSample = nSamples;
    
    nSamples = MiniBatchNums;
end

cBatchStartInds = 1;


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
SampleWChange = cell(nHiddenLayer+1,1);
SampleBiasChange = cell(nHiddenLayer+1,1);
% HiddenLBias = rand(length(nHidNodesNum),1);
%%

while (nIters < 1e6) && (IterError > 1e-3)
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
        
    else

        MiniInputData = InputData;
        MiniOutPutData = OutputData; 
        cMiniSample = nSamples;
        
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
    
    % updates the weights
    for nHls = 1 : nHiddenLayer+1
        TempHidenW = HiddenLayerNodeW{nHls} - nLearnRate*AvgWChange{nHls};
%         TempHidenW = (TempHidenW - min(TempHidenW(:)))/(max(TempHidenW(:)) - min(TempHidenW(:)));
        HiddenLayerNodeW{nHls} = TempHidenW;
        HiddenLBias{nHls} = HiddenLBias{nHls} - nLearnRate*AvgBiasChange{nHls};
    end
    
    %
    IterErrorAll(nIters) = IterError;
    nIters = nIters + 1;
    nLearnRate = nLearnRate * 0.9;
    if nLearnRate < 0.001
        nLearnRate = 0.6;
    end
    LearnRate(nIters) = nLearnRate;
%     if nIters > 1000
%         if IterError - mean(IterErrorAll(end-100)) < 1e-6
%             break;
%         end
%     end
end

%%
TrainTime = toc(IterTime);
RealIter = nIters - 1;
fprintf('BP stops after %d iterations, with ErrorRate = %.2e, time used is %d seconds.\n',RealIter,IterError,TrainTime);
figure;
plot(1:RealIter,IterErrorAll,'k-o','LineWidth',1.6);
xlabel('Itrerations'); 
ylabel('Eror');
