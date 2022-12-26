function varargout = dataSEMmean(data, CalType)
% function used to calculate the mean and SEM for given datas
if ~exist('CalType','var') || isempty(CalType)
    CalType = 'AllasOne';
end
IsOutlierCue = 0;
switch CalType
    case 'AllasOne'
        data = data(:);
        Datanum = numel(data);
        IsOutlierCue = 1;
    case 'Trace'
%         data = data;
        Datanum = size(data, 1); % only performing average at the first dimension
        IsOutlierCue = 0;
    otherwise
        warning('Unknowed calculation type, used default calculation.\n');
        data = data(:);
        Datanum = numel(data);
end
if isvector(data)
    if any(isnan(data))
        warning('There are some nan datas in input, ignoring them.\n');
        data(isnan(data)) = [];
        Datanum = numel(data);
    end
else
    if any(isnan(data))
        warning('Trials have nan datas in input was ignored.\n');
        data(sum(isnan(data),2) > 0,:) = [];
        Datanum = size(data, 1);
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
    % exclude some outliers is the data num is large enough
%     data(isnan(data)) = [];
%     Datanum = numel(data);
    if numel(data) < 10
        Avg = mean(data);
        SEM = std(data)/sqrt(Datanum);
    else
        if IsOutlierCue
            EVarThresData = CorrectOutlierPoints(data,3);
            UsedDataInds = data >= EVarThresData(1) & data <= EVarThresData(2);
            if any(~UsedDataInds)
                warning('Excluded some outliers.\n');
            end
            Avg = mean(data(UsedDataInds));
            SEM = std(data(UsedDataInds))/sqrt(Datanum);
        else
            Avg = mean(data);
            SEM = std(data)/sqrt(Datanum);
        end
    end
end

if nargout == 1
    if numel(Avg) == 1
        varargout{1} = [Avg; SEM; Datanum];
    else
        varargout{1} = [Avg; SEM];
    end
elseif nargout == 2
    varargout = {[Avg; SEM], Datanum};
elseif nargout == 3
    varargout = {Avg, SEM, Datanum};
else
    varargout = {Avg, SEM, Datanum};
end