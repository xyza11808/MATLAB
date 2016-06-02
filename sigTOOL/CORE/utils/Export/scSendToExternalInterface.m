function scSendToExternalInterface(fhandle, externalfunc) %#ok<INUSL>
% scSendToExternalInterface exports sigTOOL data to an external program
%
% Example:
% scSendToExternalInterface(fhandle, externalfunc)
%
% fhandle is the handle of the sigTOOL figure to export data from
% externalfunc is the handle to a function that does the work
%
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 1/06
% Copyright © The Author & King's College London 2006-2007
% -------------------------------------------------------------------------

% gco is the current object - figure, axes etc
h=get(gco, 'Children');
if strcmpi(get(h(1), 'Tag'), 'sigTOOL:CustomResultPanel')
    msgbox('To export custom objects you must select a single panel','sigTOOL: Not available');
else
    externalfunc(gco);
end




