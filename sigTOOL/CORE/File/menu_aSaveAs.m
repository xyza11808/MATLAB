function varargout=menu_aSaveAs(varargin)
% mmenu_aSaveAs saves a new sigTOOL data file
% 
% Example:
% menu_aSaveAs(hObject, EventData)
%     standard menu callback
%     
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 11/06
% Copyright © The Author & King's College London 2006-
% -------------------------------------------------------------------------

if nargin==1 && (isnumeric(varargin{1}) && varargin{1}==0)
    varargout{1}=true;
    varargout{2}='Save As';
    varargout{3}='';
    return
end


[button fhandle]=gcbo;
scSaveAs(fhandle);
return
end