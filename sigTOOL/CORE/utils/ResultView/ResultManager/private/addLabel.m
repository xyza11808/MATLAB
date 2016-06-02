function addLabel(item, label)
% addLabel - private function
%
% Adds labels Result Manager controls
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 1/08
% Copyright © The Author & King's College London 2008-
% -------------------------------------------------------------------------
Foreground=java.awt.Color(64/255,64/255,122/255);
Background=java.awt.Color(1,1,0.9);
pos=get(item, 'Position');
pos(2)=pos(2)+pos(4);
lb=jcontrol(get(item, 'Parent'), 'javax.swing.JLabel',...
    'Position', pos,...
    'Text', label,...
    'Background', Background,...
    'Foreground', Foreground);
return
end