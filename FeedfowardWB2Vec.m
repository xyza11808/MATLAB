function [AllParaVec,VecIndsAll] = FeedfowardWB2Vec(LayerSizeStrc,LayerDataStrc,TotalEleNum)
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
if ~isstruct(LayerSizeStrc) || ~isstruct(LayerDataStrc)
    error('First two variables should be struct arrays.');
end

NumLayers = length(LayerSizeStrc.Weights_size);

AllParaVec = zeros(TotalEleNum,1);
VecIndsAll = cell(2,NumLayers); % store index for each para matrix
IndsStartV = 0;
for cLayer = 1 : NumLayers
    % including bias values
    cLayerBiasSize = LayerSizeStrc.Bias_size{cLayer};
    cLayerBiasValues = LayerDataStrc.Bias_Mtx{cLayer};
    VecIndsAll{1,cLayer} = IndsStartV + (1:(cLayerBiasSize(1)*cLayerBiasSize(2)));
    AllParaVec(VecIndsAll{1,cLayer}) = cLayerBiasValues(:);
    
    IndsStartV = IndsStartV + (cLayerBiasSize(1)*cLayerBiasSize(2));
    % including weight values
    cLayerWeightSize = LayerSizeStrc.Weights_size{cLayer};
    cLayerWeightValues = LayerDataStrc.Weights_Mtx{cLayer};
    VecIndsAll{2,cLayer} = IndsStartV + (1 : (cLayerWeightSize(1)*cLayerWeightSize(2)));
    AllParaVec(VecIndsAll{2,cLayer}) = cLayerWeightValues(:);
    
    IndsStartV = IndsStartV + (cLayerWeightSize(1)*cLayerWeightSize(2));
end



