function h=AddHelp(parent)
% Help button
img=javax.swing.ImageIcon(fullfile(scGetBaseFolder(),...
    'CORE', 'icons', 'QuestionMark.gif'));
button=javax.swing.JButton(img);
h=jcontrol(parent, button,...
    'Position', [0.95 0.1 0.1 0.1],...
    'Units', 'normalized',...
    'Tag', 'CV:HELPButton');
set(h, 'units', 'pixels');
h.Position(3)=20;
h.Position(4)=20;
set(h, 'units', 'normalized');
% h.Help.Visible='off';


return
end
