function varargout=menu_aabNew(varargin)
% menu_aabNew creates a new sigTOOL data file
% 
% Example:
% menu_aabNew(hObject, EventData)
%     standard menu callback
%     
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 11/06
% Copyright © The Author & King's College London 2006-
% -------------------------------------------------------------------------

if nargin==1 && (isnumeric(varargin{1}) && varargin{1}==0)
    varargout{1}=true;
    varargout{2}='New';
    varargout{3}='';
    return
end

[button fhandle]=gcbo;
% Filing=getappdata(fhandle,'Filing');
% if isempty(dir(Filing.OpenSaveDir))
%     Filing.OpenSaveDir='';
% end
scCreateNewKCLFile();
return
end