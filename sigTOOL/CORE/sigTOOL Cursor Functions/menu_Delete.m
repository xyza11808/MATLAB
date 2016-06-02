function varargout=menu_Delete(varargin)
% menu_Delete deletes all cursors in sigTOOL
% 
% Example:
% menu_Delete(hObject, EventData)
%         standard menu callback
%__________________________________________________________________________
%
% Author: Malcolm Lidierth 11/06
% Copyright © The Author & King's College London 2006
%__________________________________________________________________________
        
        
% Setup
if nargin==1 && varargin{1}==0
    varargout{1}=true;
    varargout{2}='Delete All';
    varargout{3}=[];
    return
end

% Called form GUI
[button fhandle]=gcbo;
cursor=getappdata(fhandle, 'VerticalCursors');
for i=1:length(cursor)
    DeleteCursor(fhandle, i);
end
return
end

