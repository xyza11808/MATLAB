function varargout=menu_PauseRecording(varargin)
% menu_PauseRecording pauses history recoding for a sigTOOL data view
% 
% Example:
% menu_PauseRecording(hObject, EventData)
%     standard menu callback
%     
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 11/06
% Copyright © The Author & King's College London 2006-
% -------------------------------------------------------------------------

if nargin==1 && (isnumeric(varargin{1}) && varargin{1}==0)
    varargout{1}=false;
    varargout{2}='Pause recording';
    varargout{3}=sprintf(...
        'Author: Malcolm Lidierth\n© 2006 King’s College London');
    return
end

[button handle]=gcbo;
setappdata(handle,'RecordFlag','off');
set(button,'Enable','off');
h=findobj(handle,'Label','Start recording');
set(h,'Enable','on');
return
end