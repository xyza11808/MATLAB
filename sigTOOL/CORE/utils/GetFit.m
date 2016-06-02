function GetFit(hObject, EventData, target) %#ok<INUSL>
% GetFit copies the fit from an EytFit window to the sigTOOL result view
%
% Example:
% GetFit(hObject, EventData, target)
% callback from EzyFit 'Export to sigTOOL' uimenu item
%
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 08/08
% Copyright © The Author & King's College London 2008-
% -------------------------------------------------------------------------

fhandle=ancestor(hObject, 'figure');
h1=findobj(fhandle, 'Type', 'line');
h2=findobj(fhandle, 'Tag', 'sigTOOL:ExportedData');
h=h1(~ismember(h1,h2));
x=get(h,'XData');
y=get(h,'YData');
newax=scAddPlot(target);
h=line(x, y, 'Parent', newax, 'Color', [0 0 0], 'LineWidth', 2);
set(h, 'Tag', 'AddedPlot',...
    'UserData', [x(:), y(:)],...
    'ButtonDownFcn', @scWindowButtonDownFcn);
annot=findobj(findall(fhandle), 'UserData', 'equationbox');
figure(ancestor(target,'figure'));
str=get(annot(1),'String');
h=annotation('textbox',[0.6 0.7 0.2 0.2], ...
    'String',str,...
    'Tag', 'sigTOOL:Annotation');
set(h, 'Units', 'character');
pos=get(h,'Position');
pos(3)=max(size(str{1},2),size(str{end},2))+5;
pos(4)=size(str,1)+5;
set(h,'Position',pos);
set(h,'Units','normalized');
return
end