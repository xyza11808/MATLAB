function postprinttidy(obj, AxesPanel, annot, pos, displaymode)
% postprinttidy methods for sigTOOLResultView objects
%
% serves as helper for print/export functions
%
% Example:
% postprinttidy(obj, AxesPanel, annot, pos, displaymode)
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 02/09
% Copyright © The Author & King's College London 2009-
% -------------------------------------------------------------------------
fhandle=get(obj, 'Parent');
delete(annot);
set(findobj(fhandle, 'Type', 'uicontrol'), 'Visible', 'on');
warning('on','MATLAB:Print:CustomResizeFcnInPrint')
set(AxesPanel, 'Position', pos);
scResultManager(fhandle, true);
hlist=getappdata(fhandle, 'ResultManager');
fcn=hlist.DisplayMode.ActionPerformedCallback;
hlist.DisplayMode.ActionPerformedCallback=[];
hlist.DisplayMode.setSelectedItem(displaymode);
hlist.DisplayMode.ActionPerformedCallback=fcn;
result=getappdata(fhandle, 'sigTOOLResultData');
h=findobj(fhandle, 'Tag', 'sigTOOL:ShowOnExport');
set(h, 'Visible', 'off')
MaxTime=Inf;
for i=2:size(result.data,1)
    for j=2:size(result.data,2)
        if ~isobject(result.data{i,j}) && ~isempty(result.data{i,j})...
                && ~isempty(result.data{i,j}.tdata)
            MaxTime=min([MaxTime max(result.data{i,j}.tdata)]);
        end
    end
end
warning('on','MATLAB:Print:CustomResizeFcnInPrint');
scCreateFigControls(fhandle, MaxTime);
return
end