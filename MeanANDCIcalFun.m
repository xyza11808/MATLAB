function [DataMean, Data_CI] = MeanANDCIcalFun(data,varargin)
% this function is specifically used for calculate the mean
% and CI value for given data, and output those values
% if data was a matrix, calculate the values column-wise
IsDataTrans = 0;
if nargin > 2
    if ~isempty(varargin{2})
        IsDataTrans = varargin{2};
    end
end
if IsDataTrans
    data = data';
end
CIlevel = 0.05;
if nargin > 1
    if ~isempty(varargin{1})
        CIlevel = varargin{1};
    end
end
if length(data) == numel(data)
    data = data(:);
end

DataMean = mean(data);
DataSEM = std(data)./sqrt(size(data,1));
Data_ts = tinv([CIlevel/2 (1 - CIlevel/2)],(size(data,1) - 1));
% Data_CI = repmat(DataMean',1,2) + DataSEM' * Data_ts;
Data_CI = DataSEM' * Data_ts;  % for SEM plot, used as upper and lower limit