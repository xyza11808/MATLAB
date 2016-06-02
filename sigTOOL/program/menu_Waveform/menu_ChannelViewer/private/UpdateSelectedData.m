function UpdateSelectedData()
fhandle=gcf;
pos1=GetCursorLocation(1);
pos2=GetCursorLocation(2);
h=findobj(fhandle, 'Tag', 'CV:RawData');
x=get(h, 'XData');
y=get(h, 'YData');
idx1=find(x>=pos1, 1);
idx2=find(x<=pos2,1, 'last');
h2=findobj(fhandle,'Tag', 'CV:SelectedData');
set(h2, 'XData', x(idx1:idx2), 'YData', y(idx1:idx2));
h3=findobj(fhandle,'Tag', 'CV:BaseLineData');
delete(h3);
axes(ancestor(h2, 'axes'));
axis('tight');


return
end
