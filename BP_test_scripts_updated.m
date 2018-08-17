clear
clc

xData = [1,0,0,0;0,1,0,0;0,0,1,0;0,0,0,1;1,1,0,0;0,0,1,1];
xData = xData';
yData = [1,0,1;1,0,1;0,1,1;0,1,0;1,0,0;0,1,0];
yData = yData';
% %%
% xData = ([1,1,0,0])';
% yData = ([1,0])';
%%
clear
clc
cd('S:\THBI\DataSet');
TestIm = loadMNISTImages('t10k-images.idx3-ubyte');
TestLabel = loadMNISTLabels('t10k-labels.idx1-ubyte');
TrainIM = loadMNISTImages('train-images.idx3-ubyte');
TrainLabel = loadMNISTLabels('train-labels.idx1-ubyte');
xData = TrainIM;
yData = TrainLabel';

%%
HidNodesNum = [4,10,6];
nHiddenLayer = length(HidNodesNum); % 3 hidden layers
nLearnRate = 0.2;

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
SampleWChange = HiddenLayerNodeW;
SampleBiasChange = HiddenLBias;
% HiddenLBias = rand(length(nHidNodesNum),1);
OutputNetInData = zeros(nOutputNodes,nSamples);
OutputNetOutData = zeros(nOutputNodes,nSamples);

%%
IterErrorAll = [];
nIters = 1;
IterError = 1;
IterTime = tic;

%% SampleLayerInOutData = cell(nInputNodes,1); % s
%
while (nIters < 1e6) && (IterError > 1e-4)
    % start the forward calculation
    for nHLs = 1 : nHiddenLayer
        if nHLs == 1
            FormerLayerNodes = nInputNodes;
            FormerLayerData = InputData;
        else
            FormerLayerNodes = nHidNodesNum(nHLs - 1);
            FormerLayerData = LayerOutValue{nHLs - 1};
        end
        % LayerActValue  LayerOutValue
        cLayerWeights = HiddenLayerNodeW{nHLs};
        cLayerActData = cLayerWeights * FormerLayerData + repmat(HiddenLBias{nHLs},1,nSamples);
        LayerActValue{nHLs} = cLayerActData;
        LayerOutValue{nHLs} = OutFun(cLayerActData);
        
        %
%         for ncNodes = 1 : cNodes  % calculate the value for each hidden layer nodes
%             if nHLs == 1
%                 LayerInOutValue{nHLs}(ncNodes,1) = FormerLayerData' * InputLayerW(:,ncNodes);
%             else
%                  LayerInOutValue{nHLs}(ncNodes,1) = FormerLayerData' * HiddenLayerNodeW{nHLs-1}(:,cNodes) + HiddenLBias{nHLs-1}(ncNodes);
%             end
%             LayerInOutValue{nHLs}(ncNodes,2) = OutFun(LayerInOutValue{nHLs}(ncNodes,1));
%         end
        %
    end

    %
%     %calculate the output node value
%     cInputData = LayerInOutValue{nHiddenLayer}(:,2);
%     for nOnodes = 1 : nOutputNodes
%         cNodeInputV = cInputData' * HiddenLayerNodeW{nHiddenLayer}(:,nOnodes) + HiddenLBias{nHiddenLayer}(nOnodes);
%         OutputInOutData(nOnodes,1) = cNodeInputV;
%         OutputInOutData(nOnodes,2) = OutFun(cNodeInputV);
%     end
%     
    OutputNetInData = HiddenLayerNodeW{nHiddenLayer + 1} * LayerOutValue{nHiddenLayer} + repmat(HiddenLBias{nHiddenLayer + 1},1,nSamples);
    OutputNetOutData = OutFun(OutputNetInData);
    %
    IterErroAll = (OutputNetOutData - OutputData).^2;
    IterError = 0.5 * sum(IterErroAll(:))/nSamples;
    if ~mod(nIters,50)
        fprintf(sprintf('cIterError = %.3f.\n',IterError));
    end
    %
    % backpropagate the errors
    % deltaOutNodesData = zeros(nOutputNodes,1);
    deltaOutNodesData = OutFun(OutputNetOutData) .* (1 - OutFun(OutputNetOutData)) .* (OutFun(OutputNetOutData) - OutputData);  % Delta K
    DeltaJNodesData{nHiddenLayer + 1} = deltaOutNodesData;
    % DeltaJNodesData
    %
%     SampleWChange = cell(nHiddenLayer+1,nSamples);
%     SampleBiasChange = cell(nHiddenLayer+1,nSamples);
    for cSample = 1 : nSamples
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
                cWeightsChange = DeltaJNodesData{nHls}(:,cSample) * (InputData(:,cSample))';
                cSampleWChange =  (-1) * (cWeightsChange * nLearnRate);
            else
                cWeightsChange = DeltaJNodesData{nHls}(:,cSample) .* (LayerOutValue{nHls-1}(:,cSample))';
                cSampleWChange =  (-1) * (cWeightsChange * nLearnRate);
            end
            if cSample == 1
                SampleWChange{nHls} = cSampleWChange;
                SampleBiasChange{nHls} = DeltaJNodesData{nHls}(:,cSample) * (-1) * nLearnRate;
            else
                SampleWChange{nHls} = SampleWChange{nHls} + cSampleWChange;
                SampleBiasChange{nHls} = SampleBiasChange{nHls} - DeltaJNodesData{nHls}(:,cSample) * nLearnRate;
            end
            
        end
        %
    end
    AvgWChange = cellfun(@(x) x/nSamples,SampleWChange,'UniformOutput',false);
    AvgBiasChange = cellfun(@(x) x/nSamples,SampleBiasChange,'UniformOutput',false);
   %
    for nHls = 1 : nHiddenLayer+1
        HiddenLayerNodeW{nHls} = HiddenLayerNodeW{nHls} + AvgWChange{nHls};
        HiddenLBias{nHls} = HiddenLBias{nHls} + AvgBiasChange{nHls};
    end
    %
    IterErrorAll(nIters) = IterError;
    nIters = nIters + 1;
    nLearnRate = nLearnRate * 0.9;
    if nLearnRate < 0.001
        nLearnRate = 0.2;
    end
%     if nIters > 1000
%         if IterError - mean(IterErrorAll(end-100)) < 1e-6
%             break;
%         end
%     end
end
TrainTime = toc(IterTime);
RealIter = nIters - 1;
%%
fprintf('BP stops after %d iterations, with ErrorRate = %.2e, time used is %d seconds.\n',RealIter,IterError,TrainTime);
figure;
plot(1:RealIter,IterErrorAll,'k-o','LineWidth',1.6);
xlabel('Itrerations');
ylabel('Eror');
