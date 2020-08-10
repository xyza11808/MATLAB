function ESize = CoheneffectSizeFun(ExpData, ControlData, varargin)
% function used for calculation of effect size
% Ref: https://www.simplypsychology.org/effect-size.html
% 2020.08.10

% % A effect size less than 0.2 indicates small change size
% % A effect size less than 0.5 but large than 0.2 indicates medium change size
% % A effect size less than 0.8 but large than 0.5 indicates large change size
% % A effect size less than 1.4 but large than 0.8 indicates quiet large change size

% pearson correlation is kind of effect size measurement
% % Coefficient value from 0.1 to 0.3 indicates small strength of association
% % Coefficient value from 0.3 to 0.5 indicates medium strength of association
% % Coefficient value from 0.5 to 1.0 indicates large strength of association

ExpData = ExpData(:);
ControlData = ControlData(:);
ESize = [];

if sum(isnan(ExpData)) || sum(isnan(ControlData))
    warning('nan data exists, excluded those values');
    ExpData(isnan(ExpData)) = [];
    ControlData(isnan(ControlData)) = [];
end
Methodstr = 'Cohen'; % 'Cohen' or 'Hedges'
if nargin > 2
    if ~isempty(varargin{1})
        Methodstr = varargin{1};
    end
end

switch lower(Methodstr)
    case 'cohen'
        n1 = numel(ExpData);
        n2 = numel(ControlData);
        stds = sqrt(((n1-1)*var(ExpData) + (n2 - 1)*var(ControlData))/(n1 + n2));
        ESize = (mean(ExpData) - mean(ControlData))/stds;
    case 'hedges'
        n1 = numel(ExpData);
        n2 = numel(ControlData);
        stds = sqrt(((n1-1)*var(ExpData) + (n2 - 1)*var(ControlData))/(n1 + n2 - 2));
        ESize = (mean(ExpData) - mean(ControlData))/stds;
    case 'oddratio'
        a = ExpData(1); % exp group, success count
        b = ExpData(2); % exp group, failure count
        c = ControlData(1); % control group, success count
        d = ControlData(2); % control group, failure count
        ESize = (a * d) / (b * c);
    otherwise
        error('unsupported effect size calculation method.');
end



