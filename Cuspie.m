function p = Cuspie(X,Labels,varargin)
% this function is same with built-in function pie, but added some
% capability to handle some bad datasets
if isempty(Labels) || isempty(X)
    error('Emptydata Input');
end

if length(Labels) < length(X)
    error('Labels length should be larger than data categories');
else
    Labels = Labels(1:length(X));
end

if sum(isnan(X))
    NanInds = isnan(X);
    X(NanInds) = [];
    Labels(NanInds) = [];
end

ZerosInds = X == 0;
if sum(ZerosInds)
    warning('Zeros value find in Data, exlcuded from analysis');
    X(ZerosInds) = [];
    Labels(ZerosInds) = [];
end

p = pie(X,Labels,varargin{:});