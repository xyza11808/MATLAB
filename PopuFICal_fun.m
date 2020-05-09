function [dd_raw, dd_shuffle, dd_diag, LoadingWights] = PopuFICal_fun(DataMtx,DataTypes,varargin)
if length(DataTypes) ~= numel(DataTypes)
    error('Data Type should be a row or vector.');
end
DataTypes = DataTypes(:);

TrTypes = unique(DataTypes);
if length(TrTypes) > 2
    error('Data type should only have two types.');
end
GivenWeight = 0;
if nargin > 2
    if ~isempty(varargin{1})
        FI_Weights = varargin{1};
        GivenWeight = 1;
    end
end
    
LoadingWights = [];
dd_raw=0;
dd_shuffle=0;
dd_diag=0;

Type0_Inds = DataTypes == TrTypes(1);
Type1_Inds = DataTypes == TrTypes(2);

Type0_vectorMean = mean(DataMtx(Type0_Inds,:));
Type1_vectorMean = mean(DataMtx(Type1_Inds,:));
Type_mu_diff = (Type0_vectorMean - Type1_vectorMean)';
Type0_covMtx = cov(DataMtx(Type0_Inds,:));
Type1_covMtx = cov(DataMtx(Type1_Inds,:));

% calculate the real data information, d^2
Q = (Type0_covMtx+Type1_covMtx)/2;
%         Avg_cov_mtxInv = inv(Q);
if ~GivenWeight
    LoadingWights = inv(Q) * Type_mu_diff;
    dd_raw = Type_mu_diff' * LoadingWights;
    % calculate the correlation-free population information,
    % d_shuffle^2
    Qd = diag(diag(Q));
    dd_shuffle = Type_mu_diff' * inv(Qd) * Type_mu_diff;

    % calculate the diagnal population info, d_diag^2

    dd_diag = dd_shuffle.^2 / (Type_mu_diff' * inv(Qd) * Q * inv(Qd) * Type_mu_diff);
else
    dd_raw = Type_mu_diff' * FI_Weights;
    LoadingWights = FI_Weights;
end