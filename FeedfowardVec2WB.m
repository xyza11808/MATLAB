function LayerDataStrc = FeedfowardVec2WB(LayerSizeStrc,AllParaVec,VecIndsAll)
% convert the weight and bias matrix into vector format for a 
% NumLayer+1 layer full neural network (hidden layer number is NumLayer-1) 
% LayerSizeStrc: struct array contains at least two fields
%       Weights_size: NumLayer*1 cell array, includes the weights matrix 
%                     size between layer L and L-1
%       Bias_size: NumLayer*1 cell array, includes the bias matrix 
%                     size for layer L
%
% LayerDataStrc: struct array contains at least two fields
%       Weights_Mtx: NumLayer*1 cell array, includes the weights matrix 
%                     values between layer L and L-1
%       Bias_Mtx: NumLayer*1 cell array, includes the bias matrix 
%                     values for layer L
%
% TotalEleNum: total number of values needed to be updated, includes all
% weight values and bias values
%
% For BP network training only for now
% XY, 2019-03-03
if ~isstruct(LayerSizeStrc)
    error('First input variables should be struct arrays.');
end

NumLayers = length(LayerSizeStrc.Weights_size);

WBDataStrc = cell(2,NumLayers); % store index for each para matrix

for cLayer = 1 : NumLayers
    % separate bias values
    cLayerBiasSize = LayerSizeStrc.Bias_size{cLayer};
    WBDataStrc{1,cLayer} = reshape(AllParaVec(VecIndsAll{1,cLayer}),max(cLayerBiasSize),1);
    
    % separate weight values
    cLayerWeightSize = LayerSizeStrc.Weights_size{cLayer};
    WBDataStrc{2,cLayer} = reshape(AllParaVec(VecIndsAll{2,cLayer}),cLayerWeightSize);
end

LayerDataStrc.Weights_Mtx = (WBDataStrc(2,:))';
LayerDataStrc.Bias_Mtx = (WBDataStrc(1,:))';