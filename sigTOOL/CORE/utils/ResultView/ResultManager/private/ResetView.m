function tp=ResetView(tp)
Foreground=java.awt.Color(64/255,64/255,122/255);
Background=java.awt.Color(1,1,0.9);

tp.CameraTool=jcontrol(tp.Panel, 'javax.swing.JButton',...
    'Position',[0.1 0.125 0.8 0.025],...
    'Text','Reset View',...
    'Foreground', Foreground,...
    'Background', Background);
tp.CameraTool.MouseClickedCallback=@LocalReset;

return
end

function LocalReset(hObject, EventData) %#ok<INUSD>
fhandle=ancestor(handle(hObject.hghandle),'figure');
result=getappdata(fhandle, 'sigTOOLResultData');
rm=getappdata(fhandle, 'ResultManager');
rm.DisplayMode.setSelectedItem(result.displaymode);
try
    cameratoolbar('Close');
catch
    % Close may fail on some versions
    tb=findall(fhandle, 'tag', 'CameraToolBar');
    delete(tb);
end
h=findobj(fhandle,'Tag','Colorbar');
tp=getappdata(fhandle,'ResultManager');
fcn=tp.Options3D.colorbar.ActionPerformedCallback;
tp.Options3D.colorbar.ActionPerformedCallback=[];
if isempty(h)
    tp.Options3D.colorbar.setSelected(0);
else
     tp.Options3D.colorbar.setSelected(1);
end
tp.Options3D.colorbar.ActionPerformedCallback=fcn;
return
end

