function EmailBrowse(hObject, EventData, vp)
[name folder]=uigetfile('*.*');
if ischar(name)
    vp.setText(sprintf('%s''%s'';\n', char(vp.getText()), fullfile(folder, name)));
end
return
end