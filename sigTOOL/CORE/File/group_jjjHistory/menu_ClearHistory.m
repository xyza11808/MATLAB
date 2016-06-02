function varargout=menu_ClearHistory(varargin)
% menu_ClearHistory clears the history entry for a sigTOOL data view
% 
% Example:
% menu_ClearHistory(hObject, EventData)
%     standard menu callback
%     
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 11/06
% Copyright © The Author & King's College London 2006-
% -------------------------------------------------------------------------

if nargin==1 && (isnumeric(varargin{1}) && varargin{1}==0)
    varargout{1}=false;
    varargout{2}='Clear history';
    varargout{3}=sprintf(...
        'Author: Malcolm Lidierth\n© 2006 King’s College London');
    return
end

[button handle]=gcbo;
History=StandardHeader();
setappdata(handle,'History',History);
return
end