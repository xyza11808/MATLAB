function varargout=menu_StartRecording(varargin)
% menu_StartRecording activates sigTOOL history logging
% 
% Example:
% menu_StartRecording(hObject, EventData)
% standard menu callback
% 
% menu_StartRecording sets the RecordFlag in the parent figure's 
% application data area. 
% 
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 11.07
% Copyright © The Author & King's College London 2007-
% -------------------------------------------------------------------------

if nargin==1 && (isnumeric(varargin{1}) && varargin{1}==0)
    varargout{1}=true;
    varargout{2}='Start recording';
    varargout{3}=[];
    return
end

[button fhandle]=gcbo;
setappdata(fhandle,'RecordFlag','on')

History=StandardHeader();
setappdata(fhandle, 'History', History);


set(button,'Enable','off');
h=findobj(fhandle,'Label','Pause recording');
set(h,'Enable','on');
h=findobj(fhandle,'Label','Clear history');
set(h,'Enable','on');
return
end