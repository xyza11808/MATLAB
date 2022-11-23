function varargout = dataSEMmean(data)
% function used to calculate the mean and SEM for given datas
data = data(:);

if any(isnan(data))
    warning('There are some nan datas in input, ignoring them.\n');
    data(isnan(data)) = [];
end

Datanum = numel(data);
if isempty(data)
    [Avg, SEM, Datanum] = deal(nan);
elseif Datanum < 5
    Avg = mean(data);
    SEM = nan;
else
    Avg = mean(data);
    SEM = std(data)/sqrt(numel(data));
end

if nargout == 1
    varargout{1} = [Avg; SEM; Datanum];
elseif nargout == 3
    varargout = {Avg, SEM, Datanum};
else
    varargout = {Avg, SEM, Datanum};
end