function varargout=menu_ViewDetails(varargin)
% menu_ViewDetails opens the result in the MATLAB variable editor
% 
% menu_ViewDetails(hObject, EventData)
%     standard menu callback
%     
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 01/08
% Copyright © The Author & King's College London 2008-
% -------------------------------------------------------------------------

if nargin==1 && varargin{1}==0
    varargout{1}=true;
    varargout{2}='View Details';
    varargout{3}=[];
    return
end

[button rhandle]=gcbo;

subs=getappdata(gca, 'AxesSubscript');
data=getappdata(rhandle, 'sigTOOLResultData');
assignin('base', 'ans', data.data{subs(1),subs(2)}.details)
openvar('ans');
return
end

