function [Avg,SEM] = AvgSemCal(Data,varargin)
% used for mean and sem calculation
% is nan or empty data exists, using empty output
if isempty(varargin)
    Calculators = 1; % calculate SEM
else
    if ~isempty(varargin{1})
        Calculators = varargin{1}; % calculate SEM for value 1, calculate std for value 0;
    end
end

Avg = [];
SEM = [];
if sum(isnan(Data)) || isempty(Data)
    warning('Nan or empty data exists, using empty output');
    return;
end
Avg = mean(Data);
switch Calculators
    case 1
        SEM = std(Data)/sqrt(numel(Data));
    case 0
        SEM = std(Data);
    otherwise
        error('Undefined calculation type.');
end
