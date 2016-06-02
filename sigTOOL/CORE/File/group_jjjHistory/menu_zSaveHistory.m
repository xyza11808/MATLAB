function varargout=menu_zSaveHistory(varargin)
% menu_zSaveHistory saves a sigTOOL history log to a MATLAB m-file
% 
% Example:
% menu_zSaveHistory(hObject, EventData)
% standard menu callback
% 
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 11.07
% Copyright © The Author & King's College London 2007-
% -------------------------------------------------------------------------

if nargin==1 && (isnumeric(varargin{1}) && varargin{1}==0)
    varargout{1}=true;
    varargout{2}='Save history';
    varargout{3}=[];
    return
end

[button handle]=gcbo;
History=getappdata(handle,'History');

if isempty(History)
    return
end

% Write the main history file
History.main=[History.main sprintf('delete(thisview);\nreturn\nend\n\n')];
[name pathname]=uiputfile('scHistory.m');
filename=[pathname name];
fh=fopen(filename,'w+');
fwrite(fh,History.main);

% Now write any extra subfunctions
str=sprintf('return\nend\n');
spacer=sprintf('%%--------------------------------------------------------------------------\n');
for i=1:length(History.functions)
    fwrite(fh, spacer);
    fwrite(fh, History.functions{i});
    fwrite(fh, str);
    fwrite(fh, spacer);
    fwrite(fh, sprintf('\n'));
end

% Close and open file in editor
fclose(fh);
edit(filename);

return
end