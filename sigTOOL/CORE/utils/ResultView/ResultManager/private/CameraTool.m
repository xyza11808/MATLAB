function tp=CameraTool(tp)
Foreground=java.awt.Color(64/255,64/255,122/255);
Background=java.awt.Color(1,1,0.9);

tp.CameraTool=jcontrol(tp.Panel, 'javax.swing.JButton',...
    'Position',[0.1 0.15 0.8 0.025],...
    'Text','Camera Tool',...
    'Foreground', Foreground,...
    'Background', Background);
tp.CameraTool.MouseClickedCallback=@LocalRotate3D;

return
end

function LocalRotate3D(hObject, EventData) %#ok<INUSD>
fhandle=ancestor(handle(hObject.hghandle),'figure');
cameratoolbar(fhandle, 'NoReset');
tb=findall(fhandle, 'tag', 'CameraToolBar');
hObject.setForeground(java.awt.Color(1,0,0))
hObject.setText('Close Camera Tool');
hObject.MouseClickedCallback=@CloseCameraTool;
while ishandle(tb)
    pause(.1)
end
hObject.setText('Camera Tool');
hObject.setForeground(java.awt.Color(64/255,64/255,122/255))
hObject.MouseClickedCallback=@LocalRotate3D;
return
end


function CloseCameraTool(hObject, EventData) %#ok<INUSD>
try
    cameratoolbar('Close');
catch
    % Deal with bug in R2006a
    fhandle=ancestor(handle(hObject.hghandle),'figure');
    tb=findall(fhandle, 'tag', 'CameraToolBar');
    delete(tb);
end
return
end

