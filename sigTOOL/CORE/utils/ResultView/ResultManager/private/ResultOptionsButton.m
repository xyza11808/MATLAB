function tp=ResultOptionsButton(tp)

tp.ResultOptionsButton=jcontrol(tp.Panel, 'javax.swing.JButton',...
    'Tag', 'ResultOptionsButton');
set(tp.ResultOptionsButton,'Position', [0.05 0.07 .1 .025]);
set(tp.ResultOptionsButton,'Units', 'pixels');
pos=get(tp.ResultOptionsButton, 'Position');
pos(3)=27;
pos(4)=27;
set(tp.ResultOptionsButton,'Position', pos);
set(tp.ResultOptionsButton,'Units', 'normalized');
tp.ResultOptionsButton.setIcon(javax.swing.ImageIcon(which('ResultOptionsButton.gif')));
tp.ResultOptionsButton.setToolTipText('Add to SketchPad');
tp.ResultOptionsButton.setEnabled(false);


return
end

