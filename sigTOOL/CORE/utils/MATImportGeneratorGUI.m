function MATImportGeneratorGUI(fhandle)

[name pathname]=uigetfile('*.mat', 'Select Template File');
if ischar(name)
    name=fullfile(pathname, name);
end
s=whos('-file', name);

% Panel
p=uipanel('Title','MAT File Import Function Wizard',...
    'ForegroundColor', [0 0 1],...
    'Position', [0.1 0.1 0.8 0.8]);

% Variable Information
jcontrol(p, 'javax.swing.JComboBox',...
    'Position', [0.125 0.9 0.35 0.035]);
jcontrol(p,'javax.swing.JComboBox',...
    'Position', [0.525 0.9 0.35 0.035]);

% Channel Type
jcontrol(p, 'javax.swing.JComboBox',...
    'Position', [0.125 0.8 0.35 0.035]);
                
jcontrol(p, 'javax.swing.JComboBox',...
    'Position', [0.525 0.8 0.35 0.035]);               


ax=axes('Parent', p, 'Position', [0.05 0.1 .9 0.15]);
return
end
