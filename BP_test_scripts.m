
nHiddenLayer = 3; % 3 hidden layers
nHidNodesNum = [20,10,20];
nLearnRate = 0.2;

InputData = rand(10,1);
% InputData = (TrainData(1,:))';
% InputData = InputData(:);
nInputNodes = length(InputData); % input nodes
% OutputData = TrainOutPutData(:,1);
OutputData = [1,0];
% OutputData = OutputData(:);
nOutputNodes = length(OutputData);

OutFun = @(x) 1./(1+exp(-1*x)); % so that (OutFun)' = OutFun*(1-OutFun);
deltaFun = @(k,t) (OutFun(k) - t) .* OutFun(k) .*(1 - OutFun(k)); % used for weight derivative calculation
%%
% initial weights for each hidden layer nodes
InputLayerW = rand(nInputNodes,nHidNodesNum(1));
HiddenLayerNodeW = cell(nHiddenLayer,1);
LayerInOutValue = cell(nHiddenLayer,1);
DeltaJNodesData = cell(nHiddenLayer,1);
HiddenLBias = cell(nHiddenLayer,1);
for nHl = 1 : nHiddenLayer
    if nHl ~= nHiddenLayer
        HiddenLayerNodeW{nHl} = rand(nHidNodesNum(nHl),nHidNodesNum(nHl+1));
        HiddenLBias{nHl} = rand(1,nHidNodesNum(nHl+1));
    else
        HiddenLayerNodeW{nHl} = rand(nHidNodesNum(nHl),nOutputNodes);
        HiddenLBias{nHl} = rand(1,nOutputNodes);
    end
    LayerInOutValue{nHl} = zeros(nHidNodesNum(nHl),2); % the first column is input, and the second column is output value
    DeltaJNodesData{nHl} = zeros(nHidNodesNum(nHl),1); 
end
% HiddenLBias = rand(length(nHidNodesNum),1);
OutputInOutData = zeros(nOutputNodes,2);


%%
IterErrorAll = [];
nIters = 1;
IterError = 1;
IterTime = tic;
while (nIters < 1000) && (IterError > 1e-4)
    % start the forward calculation
    cHiddenInputSum = cell(nHiddenLayer,1);
    cHiddenoutput = cell(nHiddenLayer,1);
    for nHLs = 1 : nHiddenLayer
        %
        cNodes = nHidNodesNum(nHLs);
        if nHLs == 1
            FormerLayerNodes = nInputNodes;
            FormerLayerData = InputData;
        else
            FormerLayerNodes = nHidNodesNum(nHLs - 1);
            FormerLayerData = LayerInOutValue{nHLs - 1}(:,2);
        end
        %
        for ncNodes = 1 : cNodes  % calculate the value for each hidden layer nodes
            if nHLs == 1
                LayerInOutValue{nHLs}(ncNodes,1) = FormerLayerData' * InputLayerW(:,ncNodes);
            else
                 LayerInOutValue{nHLs}(ncNodes,1) = FormerLayerData' * HiddenLayerNodeW{nHLs-1}(:,cNodes) + HiddenLBias{nHLs-1}(ncNodes);
            end
            LayerInOutValue{nHLs}(ncNodes,2) = OutFun(LayerInOutValue{nHLs}(ncNodes,1));
        end
        %
    end

    %
    %calculate the output node value
    cInputData = LayerInOutValue{nHiddenLayer}(:,2);
    for nOnodes = 1 : nOutputNodes
        cNodeInputV = cInputData' * HiddenLayerNodeW{nHiddenLayer}(:,nOnodes) + HiddenLBias{nHiddenLayer}(nOnodes);
        OutputInOutData(nOnodes,1) = cNodeInputV;
        OutputInOutData(nOnodes,2) = OutFun(cNodeInputV);
    end

    IterError = 0.5 * sum((OutputInOutData(:,2) - OutputData(:)).^2);
    fprintf(sprintf('cIterError = %.3f.\n',IterError));
    %
    % backpropagate the errors
    % deltaOutNodesData = zeros(nOutputNodes,1);
    deltaOutNodesData = OutFun(OutputInOutData(:,2)) .* (1 - OutFun(OutputInOutData(:,2))) .* (OutFun(OutputInOutData(:,2)) - OutputData(:));
    % DeltaJNodesData
    %
    for nHls = nHiddenLayer : -1 : 1
        cHlNodes = nHidNodesNum(nHls);
        if nHls == nHiddenLayer
            for nNodes = 1 : cHlNodes
                cNodesOutput = LayerInOutValue{nHls}(nNodes,2);
    %             cNodesWeights = HiddenLayerNodeW{}
                DeltaJNodesData{nHls}(nNodes) = cNodesOutput*(1-cNodesOutput)...
                    *sum(deltaOutNodesData' .* HiddenLayerNodeW{nHls}(nNodes,:));
            end
        else
            for nNodes = 1 : cHlNodes
                cNodesOutput = LayerInOutValue{nHls}(nNodes,2);
                cNodesWeights = HiddenLayerNodeW{nHls}(nNodes,:);
                DeltaJNodesData{nHls}(nNodes) = cNodesOutput*(1-cNodesOutput)...
                    *sum((DeltaJNodesData{nHls+1}(:))' .* HiddenLayerNodeW{nHls}(nNodes,:));
            end
        end
    end
    %
    % updates the weights
    for nHls = 1 : nHiddenLayer
        cnNodes = nHidNodesNum(nHls);
        if nHls == 1
            cWeightsChange = (DeltaJNodesData{nHls}(:))' .* (InputData(:));
            InputLayerW = InputLayerW - (cWeightsChange * nLearnRate);
        else
            cWeightsChange = (DeltaJNodesData{nHls}(:))' .* (LayerInOutValue{nHls - 1}(:,2));
            HiddenLayerNodeW{nHls-1} = HiddenLayerNodeW{nHls-1} - (cWeightsChange * nLearnRate);
        end
    end
    OutWeightsChange = (deltaOutNodesData)' .* (LayerInOutValue{nHiddenLayer}(:,2)) * nLearnRate;
    HiddenLayerNodeW{nHiddenLayer} = HiddenLayerNodeW{nHiddenLayer} - OutWeightsChange;
    %
    % updates the bias
    for nHls = 1 : nHiddenLayer
        if nHls~= nHiddenLayer
            cBiasChange = DeltaJNodesData{nHls+1}(:) * (-1) * nLearnRate;
            HiddenLBias{nHls} = HiddenLBias{nHls} + cBiasChange';
        else
            cBiasChange = deltaOutNodesData * (-1) * nLearnRate;
            HiddenLBias{nHls} = HiddenLBias{nHls} + cBiasChange';
        end
    end
    IterErrorAll(nIters) = IterError;
    nIters = nIters + 1;
end
TrainTime = toc(IterTime);
RealIter = nIters - 1;
fprintf('BP stops after %d iterations, with ErrorRate = %.2e, time used is %d seconds.\n',RealIter,IterError,TrainTime);
figure;
plot(1:RealIter,IterErrorAll,'k-o','LineWidth',1.6);
xlabel('Itrerations');
ylabel('Eror');
