function scReduceXRange(hObject, EventData)
% scReduceXRange callback: reduces the x-axis range in a sigTOOL data view
% 
% Example
% scReduceXRange(hObject, EventData)
%     standard callback
%     
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 11/06
% Copyright © The Author & King's College London 2006-
% -------------------------------------------------------------------------
% 
fhandle=ancestor(hObject.hghandle, 'figure');
panel=findobj(fhandle, 'Tag', 'sigTOOL:AxesPanel');

% Get value for one axis
handle=findobj(fhandle,'Type','axes');
if isempty(handle)
    return
end
% Find new limits
XLim=get(handle(end),'XLim');
diff=XLim(2)-XLim(1);
XLim(2)=XLim(2)-(diff*0.5);

% And set them
AxesList=getappdata(fhandle,'AxesList');
AxesList=AxesList(AxesList~=0);
set(AxesList,'XLim',XLim);

% Change both x & y axes for images
h=findobj(AxesList, 'Type', 'image');
if ~isempty(h) && strcmp(get(h(1), 'UserData'), 'sigTOOL:SYMMETRIC')
    h=ancestor(h, 'axes');
    if iscell(h)
        h=cell2mat(h);
    end
    set(h, 'YLim', XLim);
end

% if strcmp(get(fhandle,'Tag'),'sigTOOL:DataView')==1
%     scCleanUpAxes(AxesList);
% end

setappdata(fhandle,'DataXLim',[0 0]);

h=findobj(fhandle,'Tag','sigTOOL:AddedPlotAxes');
set(h, 'Xlim', XLim);

scUpdateAxisControls(fhandle, 'reduce');

end
