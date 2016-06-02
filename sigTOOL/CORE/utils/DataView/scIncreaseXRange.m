function scIncreaseXRange(hObject, EventData)
% scIncreaseXRange callback: increases the x-axis range in a sigTOOL data view
% 
% Example
% scIncreaseXRange(hObject, EventData)
%     standard callback
%     
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 11/06
% Copyright © The Author & King's College London 2006-
% -------------------------------------------------------------------------    

fhandle=ancestor(hObject.hghandle, 'figure');
panel=findobj(fhandle, 'Tag', 'sigTOOL:AxesPanel');

handle=findobj(fhandle,'Type','axes');
if isempty(handle)
    return
end
XLim=get(handle(end),'XLim');
diff=XLim(2)-XLim(1);
XLim(2)=XLim(2)+diff;
AxesList=getappdata(fhandle,'AxesList');
AxesList=AxesList(AxesList~=0);
set(AxesList,'XLim',XLim);

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

h=findobj(fhandle,'Tag','sigTOOL:AddedPlotAxes');
set(h, 'Xlim', XLim);

setappdata(fhandle,'DataXLim',[0 0]);
scUpdateAxisControls(fhandle, 'increase');
return
ebd
