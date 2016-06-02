function [fhandle, ax, result, subs, data]=callbackgetparam(hObject)
% callbackgetparam helper function used in uicontextmenu callbacks
% 
% Example:
% [fhandle, ax, result, subs, data]=callbackgetparam(hObject)
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 03/08
% Copyright © The Author & King's College London 2008-
% -------------------------------------------------------------------------

ax=get(hObject, 'UserData');
fhandle=ancestor(hObject, 'figure');
result=getappdata(fhandle, 'sigTOOLResultData');
subs=getappdata(ax, 'AxesSubscript');
data=result.data{subs(1), subs(2)};
return
end
