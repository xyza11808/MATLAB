function [LayerSizeStrc,LayerParaValuesStrc,FBLayerSizeStrc,FBLayerParaValuesStrc,...
    LayerInOutDatas,TotalElementNum,DeltaJNodesData] ...
    = netLayerWeightsZeros(FullNetNodes,nSamples)
% function takes Input layer as h0
% take output layer as h(N+1)
% Hidden layer have N layers
% Input nodes num is the full network layer, with N+2 number of layers
LayerNums = length(FullNetNodes);
HiddenLayerNodeW = cell(LayerNums-1,1); % hidden layer weights
HiddenLayerFBW = cell(LayerNums-1,1);% hidden layer feedback weights
HiddenLBias = cell(LayerNums-1,1);
HiddenLFBBias  = cell(LayerNums-1,1);
WeightsMtxSize = cell(LayerNums-1,1);
BiasMtxSize = cell(LayerNums-1,1);
FBWeightsMtxSize = cell(LayerNums-1,1);
FBBiasMtxSize = cell(LayerNums-1,1);
TotalElementNum = 0;

LayerActValue = cell(LayerNums-1,1);
LayerOutValue = cell(LayerNums-1,1);

FB_LayerActValue = cell(LayerNums-1,1);
FB_LayerOutValue = cell(LayerNums-1,1);

DeltaJNodesData = cell(LayerNums-1,2);

for cLayer = 1 : LayerNums-1
    
    HiddenLayerNodeW{cLayer} = 0.04*(rand(FullNetNodes(cLayer+1),FullNetNodes(cLayer))-0.5); % forward weights
    HiddenLayerFBW{cLayer} = 0.04*(rand(FullNetNodes(cLayer),FullNetNodes(cLayer+1))-0.5); % backward weights
    
    HiddenLBias{cLayer} = 0.04*(rand(FullNetNodes(cLayer+1),1)-0.5); % forward bias
    HiddenLFBBias{cLayer} = 0.04*(rand(FullNetNodes(cLayer),1)-0.5); % backward bias
    
    WeightsMtxSize{cLayer} = [FullNetNodes(cLayer+1),FullNetNodes(cLayer)];
    BiasMtxSize{cLayer} = [FullNetNodes(cLayer+1),1];
    
    FBWeightsMtxSize{cLayer} = [FullNetNodes(cLayer),FullNetNodes(cLayer+1)];
    FBBiasMtxSize{cLayer} = [FullNetNodes(cLayer),1];
    
    TotalElementNum = TotalElementNum + numel(HiddenLayerNodeW{cLayer}) + numel(HiddenLBias{cLayer});
    
    LayerActValue{cLayer} = zeros(FullNetNodes(cLayer+1),nSamples); % store the activation value for each layer
    LayerOutValue{cLayer} = zeros(FullNetNodes(cLayer+1),nSamples); % store the output value for each layer
    FB_LayerActValue{cLayer} = zeros(FullNetNodes(cLayer),nSamples); % store the feedback activation value for each layer
    FB_LayerOutValue{cLayer} = zeros(FullNetNodes(cLayer),nSamples); % Feedback output value
    
    DeltaJNodesData{cLayer,1} = zeros(FullNetNodes(cLayer+1),nSamples); 
    DeltaJNodesData{cLayer,2} = zeros(FullNetNodes(cLayer),nSamples); 
end

LayerSizeStrc.Weights_size = WeightsMtxSize;
LayerSizeStrc.Bias_size = BiasMtxSize;
FBLayerSizeStrc.Weights_size = FBWeightsMtxSize(2:end);
FBLayerSizeStrc.Bias_size = FBBiasMtxSize(2:end);

LayerParaValuesStrc.Weights_Mtx = HiddenLayerNodeW;
LayerParaValuesStrc.Bias_Mtx = HiddenLBias;
FBLayerParaValuesStrc.Weights_Mtx = HiddenLayerFBW(2:end);
FBLayerParaValuesStrc.Bias_Mtx = HiddenLFBBias(2:end);

LayerInOutDatas = {LayerActValue,LayerOutValue;FB_LayerActValue(2:end),FB_LayerOutValue(2:end)};
    

