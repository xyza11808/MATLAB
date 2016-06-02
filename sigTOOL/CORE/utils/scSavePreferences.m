function scSavePreferences(fhandle)
% scSavePreferences saves a sigTOOL preferences MAT file
% 
% Example:
% scSavePreferences(fhandle)
% saves the preferences from the data view with handle fhandle as the
% default preferences
%
%-------------------------------------------------------------------------
% Author: Malcolm Lidierth 09/06
% Copyright © The Author & King’s College London 2006-2007
%-------------------------------------------------------------------------

% Save to file
s=getappdata(fhandle);
Filing=s.Filing;
save(s.PreferencesFile, 'Filing', '-append', '-v6');
DataView=s.DataView;
save(s.PreferencesFile, 'DataView', '-append', '-v6');

% Update all currently open views
h=findall(0, 'Tag', 'sigTOOL:DataView');
for i=1:length(h);
    setappdata(h(i), 'Filing', Filing);
    setappdata(h(i), 'DataView', DataView);
end

return
end