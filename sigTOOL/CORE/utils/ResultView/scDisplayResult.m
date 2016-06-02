function obj=scDisplayResult(data)
% scDisplayResult creates a sigTOOL result view
%
% scDisplayResult populates the drop down menus and sets up the application
% data area based on the supplied data
%
% Example:
% obj=scDisplayResult(data)
%

error('This function has been replaced by the sigTOOLResultData/plot method');

if isstruct(data)
    data=sigTOOLResultData(data);
end


sourcepath=scGetBaseFolder();
rhandle=dir2menu(fullfile(sourcepath, 'CORE', 'utils', 'ResultView', 'menu'));
set(rhandle,'Color',[1 1 1]);
setappdata(rhandle,'sigTOOLResultData',data);
h=dir2menu(fullfile(sourcepath, 'program',  'UiContextMenus', 'ResultFigure'),'uicontextmenu');
if ~isempty(h)
    set(rhandle,'uicontextmenu',h);
end

obj=scCreateResultView(rhandle);

h=dir2menu(fullfile(sourcepath, 'program', 'UiContextMenus', 'ResultAxes'),'uicontextmenu');
AxesList=getappdata(rhandle,'AxesList');
AxesList=AxesList(AxesList~=0);
set(AxesList,'UiContextMenu',h);

if ~isempty(data.datasource)
    list=getappdata(data.datasource, 'sigTOOLResultViewList');
    list=[list rhandle];
    setappdata(data.datasource, 'sigTOOLResultViewList', list);
end

return
end