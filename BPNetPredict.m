function PredData = BPNetPredict(HiddenLayerNodeW,HiddenLBias,HidNodesNum,TestData)
% PredData

nHiddenLayer = length(HidNodesNum); % 3 hidden layers
LayerActValue = cell(nHiddenLayer+1,1);
LayerOutValue = cell(nHiddenLayer+1,1);
OutFun = @(x) 1./(1+exp(-1*x)); 

for nHLs = 1 : nHiddenLayer
    if nHLs == 1
        FormerLayerData = TestData;
    else
        FormerLayerData = LayerOutValue{nHLs - 1};
    end
    % LayerActValue  LayerOutValue
    cLayerWeights = HiddenLayerNodeW{nHLs};
    cLayerActData = cLayerWeights * FormerLayerData + repmat(HiddenLBias{nHLs},1,nSamples);
    LayerActValue{nHLs} = cLayerActData;
    LayerOutValue{nHLs} = OutFun(cLayerActData);

end

OutputNetInData = HiddenLayerNodeW{nHiddenLayer + 1} * LayerOutValue{nHiddenLayer} + repmat(HiddenLBias{nHiddenLayer + 1},1,nSamples);
PredData = OutFun(OutputNetInData);