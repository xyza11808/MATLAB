function LineColorCallback(hObject, EventData) %#ok<INUSD>
fhandle=ancestor(handle(hObject.hghandle),'figure');
s=jvPanel('Title', 'Line Color',...
    'Position',[0.25 0.25 0.5 0.5]);
s=jvElement(s, 'Component', 'javax.swing.JColorChooser',...
    'Label', 'ColorChooser',...
    'Position',[0 0.2 1 0.8]);
s=jvElement(s, 'Component', 'javax.swing.JButton',...
    'Label', 'None',...
    'Position', [0.2 0.5 0.2 0.1]);
h=jvDisplay(fhandle,s);
h{1}.ApplyToAll.setEnabled(0);
h{1}.None.MouseClickedCallback=@NoColor;
uiwait();
s=getappdata(fhandle, 'sigTOOLjvvalues');
if isempty(s)
    return
end
col=s.ColorChooser;
newcolor=[col.getRed col.getGreen col.getBlue]/255;
if ~all(newcolor==1)
    h=findobj(fhandle, 'Type', 'line', 'Tag', 'sigTOOL:ResultData');
    set(h,'Color',newcolor);
    h=findobj(fhandle, 'Type', 'patch');
    set(h, 'MarkerEdgeColor', newcolor);
    set(h, 'EdgeColor', newcolor);
    h=findobj(fhandle, 'Type', 'surface');
    set(h, 'EdgeColor', newcolor);
end
return
end

function NoColor(hObject, EventData)
fhandle=ancestor(handle(hObject.hghandle),'figure');
h=findobj(fhandle, 'Type', 'surface');
set(h, 'EdgeColor', 'none');
return
end