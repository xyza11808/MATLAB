function scSec()
% scSec function

% 
% Example:
% scSec()
% 
% sigTOOL requires this function. Do not remove it.
% 
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 11/06
% Copyright © The Author & King's College London 2006-
% -------------------------------------------------------------------------

persistent t;

if ~exist('t','var') || (exist('t','var') && (isempty(t) || ~isvalid(t)))
    t = timer('TimerFcn',@scInsertLogo,...
        'Period', 60.0,...
        'ExecutionMode','fixedRate',...
        'Tag','sigTOOL',...
        'ObjectVisibility','off');
    start(t);
elseif isvalid(t) && strcmp(get(t, 'Running'),'off')
    start(t);    
end