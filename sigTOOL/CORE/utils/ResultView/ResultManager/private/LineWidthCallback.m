function LineWidthCallback(hObject, EventData) %#ok<INUSD>
fhandle=ancestor(handle(hObject.hghandle),'figure');
width=str2num(hObject.getSelectedItem()); %#ok<ST2NM>
h=findobj(fhandle, 'Type', 'line', 'Tag', 'sigTOOL:ResultData');
set(h,'LineWidth', width);
h=findobj(fhandle, 'Type', 'patch');
set(h, 'LineWidth', width);
h=findobj(fhandle, 'Type', 'surface');
set(h, 'LineWidth', width);
return
end