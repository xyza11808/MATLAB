function varargout=menu_aaaNewVerticalCursor(varargin)
% menu_aaaNewVerticalCursor inserts a new cursor
% 
% Example:
% menu_aaaNewVerticalCursor(hObject, EventData)
%     standard menu callback
%     
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 11/06
% Copyright © The Author & King's College London 2006-
% -------------------------------------------------------------------------

if nargin==1 && varargin{1}==0
    varargout{1}=true;
    varargout{2}='New Cursor';
    try
        tmp.Icon=scGetIcon('VerticalCursor.png');
        tmp.Tip='New vertical cursor';
        varargout{3}=tmp;
    catch
        varargout{3}='';
    end
    return
end

[button handle]=gcbo;
CreateCursor(handle);
return
end