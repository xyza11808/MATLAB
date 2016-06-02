function out=scAddDistributionTool(h)
% scAddDistributionTool creates/adds a distribution fitting uicontextmenu
%
% Example:
% out=scAddDistributionTool(h)
%
% out is the handle to the uicontextmenu which will be added to the
% existing menu h if supplied
%
% The work is done by the scDistributionTool callback
%
% Toolboxes required: Statistics
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 08/08
% Copyright © The Author & King's College London 2008-
% -------------------------------------------------------------------------

if nargin==0 || (nargin>0 && isempty(h))
    out=uicontextmenu();
    thismode=0;
elseif isfield(h, 'Options')
    out=h.Options;
    thismode=1;
else
    out=h;
    thismode=2;
end

switch thismode
    case {0,1}
        new=uimenu(out, 'Label', 'Fit Distribution');
    case {2}
        new=uimenu(out, 'Label', 'Fit Distribution', 'UserData', 'Selected Data');
end

distNames = {'beta', 'exponential', 'extreme value', ...
    'gamma', 'generalized extreme value', 'generalized pareto', ...
    'lognormal', 'normal', ...
    'poisson', 'rayleigh', 'discrete uniform', 'uniform', 'weibull'};

try
    % Check for presence of mle function
    mle(-10:10); 
    % OK: add menus
    for i=1:length(distNames)
        uimenu(new, 'Label', distNames{i},...
            'Callback', {@scDistributionTool, distNames(i)});
    end
catch %#ok<CTCH>
    % mle not present: disbale menu
    set(new,'Enable','off');
    reset(lasterror()); %#ok<LERR>
end



return
end