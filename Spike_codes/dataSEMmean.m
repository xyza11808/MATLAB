function varargout = dataSEMmean(data, CalType)
% function used to calculate the mean and SEM for given datas
if ~exist('CalType','var') || isempty(CalType)
    CalType = 'AllasOne';
end

switch CalType
    case 'AllasOne'
        data = data(:);
        Datanum = numel(data);
    case 'Trace'
%         data = data;
        Datanum = size(data, 1); % only performing average at the first dimension
    otherwise
        warning('Unknowed calculation type, used default calculation.\n');
        data = data(:);
        Datanum = numel(data);
end
if isvector(data)
    if any(isnan(data))
        warning('There are some nan datas in input, ignoring them.\n');
        data(isnan(data)) = [];
    end
end

% Datanum = numel(data);
if isempty(data)
    [Avg, SEM, Datanum] = deal(nan);
elseif Datanum < 5
    Avg = mean(data,'omitnan');
    if isvector(data)
        SEM = nan;
    else
        SEM = zeros(1, size(data,2));
    end
else
    Avg = mean(data,'omitnan');
    SEM = std(data,'omitnan')/sqrt(Datanum);
end

if nargout == 1
    varargout{1} = [Avg; SEM; Datanum];
elseif nargout == 3
    varargout = {Avg, SEM, Datanum};
else
    varargout = {Avg, SEM, Datanum};
end