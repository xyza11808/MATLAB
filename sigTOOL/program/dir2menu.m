function handle=dir2menu(ParentDirectory, type, varargin)
% DIR2MENU populates a menu by selectively replicating a folder structure.
% If populating a figure menu (the default) a new figure will be created
% and its handle returned. If populating a uicontextmenu, the handle of the
% menu will be returned and may be used to set the uicontextmenu property
% of a graphic object explicitly using the set function.
%
% Examples:
% HANDLE=DIR2MENU(PARENTDIRECTORY)
% HANDLE=DIR2MENU(PARENTDIRECTORY, OPTIONS)
% HANDLE=DIR2MENU(PARENTDIRECTORY, TYPE, OPTIONS)
%
%
% PARENTDIRECTORY is the folder to be replicated
% TYPE, if supplied, is a string: either 'figure' or 'uicontextmenu'.
% Defaults to 'figure'.
% OPTIONS (if supplied) is a cell array of menu properties that will be
% passed by DIR2MENU to the MATLAB uimenu function when it is called.
%
% DIR2MENU returns the handle of the figure or uicontextmenu whos menu has
% been populated.
%
% As the menu is created dynamically at run time, DIR2MENU removes the need
% to edit a GUI when a new function is added to an application. They
% can be added instead by using the system directory/file manager and the
% folder/file naming convention described below.
%
%--------------------------------------------------------------------------
% CHANGE (Dec '06):
% menu callbacks now receive hObject and EventData as the first two
% arguments.
% If your menu_* files tested for nargin==0, they will now need to test
% for nargin==2. To reverse this change for backwards compatibility,
% edit PopulateSubMenus (see comments in the function)
%
% ADDED:
% Libraries of functions stored outside of the PARENTDIRECTORY
% can now be included using the 'external_' keyword as a prefix to an
% m-file name.
% This allows a single copy of a function library to be shared by several
% applications calling dir2menu- reducing code cloning and therefore
% helping with file management. This is described further below.
%
% Tags
% To help keep track of what's where, each uimenu item's Tag now contains
% the folder/function name for the relevant callback(s) with full path
% information.
%
% UserData
% Calls to the callback routine with a zero input can now return data in
% the third output argument. These data are placed in the UserData property
% for the menu item. This might be used e.g. to return an image which can
% subsequently be placed in a uipanel toolbar
%--------------------------------------------------------------------------
%
% DIR2MENU(PARENTDIRECTORY) does the following:
% (1). Adds all folders and subfolders of PARENTDIRECTORY to the MATLAB
% search path.
%
% (2). If type=='figure:
%   Creates a figure window populated initially with the default MATLAB
%   figure menu
%      If type=='uicontextmenu'
%   Create a uicontextmenu, adds it to the current figure (returned by gcf)
%   and populates it from the directory
%
% (3). Analyzes the directory tree of PARENTDIRECTORY. Folders, subfolders
% and executable files prefixed by "menu_" are added to the  menu
% tree in a position that corresponds to their position in the directory
% tree. The menu items' labels are the same as the folder names but with the
% "menu_" prefix removed. The menu is populated recursively, so you can
% nest to any depth of folder/subfolder => menu/menulist organization.
%
% In addition, if type=='figure':
% "File", "Edit" and "View" items are grouped to the left of
% the menu bar and "Insert", "Tools", "Desktop", "Window" and "Help" items
% are grouped on the right. User supplied "menu_" prefixed items are placed
% between these groups.
% If present, the File, Edit, View etc folder names should not be prefixed
% with "menu_".
%
% (4). Drop down menu items may also be grouped by placing them in a folder
% prefixed with "group_". These will appear with lines above and below
% them.
%
% (5). For executable files (i.e. m- or mex files), the menu item's
% CallBack property is set to invoke the function. The handle of the
% item and an additional MATLAB reserved variable will each be passed
% implicitly by MATLAB as the first two inputs to the function(equivalent
% to hObject and EventData in GUIDE-generated GUIs. EventData
% will be empty - as of R2006b).
% It is assumed that user data that will be passsed using the figure's
% 'UserData' property or application data area.
%
% During menu creation, the functions are called with a zero input
% e.g. [flag, string, itemdata]=menu_myFunc(0).
% If flag==true, the menu item wil be enabled. The returned string is used
% for the menu item's label. itemdata will be added to the menu item's
% UserData property.
%
% (6). When type=='figure', if the File, Edit, View, Insert, Tools,
% DeskTop, Window and Help menus are empty, dir2menu leaves them as
% populated by the standard MATLAB call to h=figure(). If not, the menus
% are replaced by those derived from the folder tree.
%
% Take the following example directory tree:
%
%   MyFolder.....
%               .
%               ....File
%               .       .
%               .       ......menu_Open.m
%               .       .
%               .       ......menu_Import
%               .       .                .
%               .       .                ....menu_ImportAVI.m
%               .       .                .
%               .       .                ....menu_ImportWAV.m
%               .       .
%               .       ......group_zzzPrint
%               .                       .
%               .                       ....menu_Print.m
%               .                       .
%               .                       ....menu_PrintPreview.m
%               .
%               ....menu_User
%                           .
%                           ...menu_UserFunction.m
%                           .
%                           ...external_ExternalFolder.m
%                           .
%                           .
%
% DIR2MENU('MYFOLDER') will populate the File menu with:
% 1. An item labeled with the string returned by [flag, string]=menu_Open(0)
%
% 2. An item labeled "Import", which will activate a lower level menu
% containing two items, labeled according to the output returned by calls
% to menu_ImportAVI(0) and menu_ImportWAV(0). Selecting the items will call
% menu_ImportAVI(hObject, EventData) and menuImportWAV(hObject, EventData)
% respectively.
%
% 3. A print group will appear in the File menu containing two items
% labeled as before with the output of menu_Print(0) and
% menu_PrintPreview(0).
%
% 4. Create a "User" item on the menu bar and populate its drop down list
% in this case with a two items: one  labeled with the output from a call to
% menu_UserFuntion(0) and the second from a call to
% external_ExternalFolder() - see below for further details of
% 'external_' prefixed m-files.
%
% 5. Leave the standard Edit, View etc menus active
%
% The sequence of the items in any menu list will be alphabetical by
% folder/file name. As executable file names and group names are not used
% as labels, you can force an order by prefixing the names with letters e.g.
% in the example above, the "group_zzzPrint" list will appear at the bottom
% of the File menu. Note that all names are cast to lower case before
% sorting.
%
% Any outputs from the called functions can be placed in the figure window's
% UserData property or application data area e.g. for the menu_ImportAVI
% function above, the function might look as follows:
%
%   function varargout=menu_ImportAVI(varargin)
%
%   if nargin==0 and varargin{1}==0
%       varargout{1}=true;
%       varargout{2}='Microsoft AVI file';
%       varargout{3}=imread('icon.png');
%       return;
%   end
%   ....
%   ....
%   if nargin>=2 % ***see Note
%       [filename pathname]=uigetfile('*.avi')
%       mov = aviread([pathname filesep filename]);
%       [h, figurehandle]=gcbo;
%       setappdata(figurehandle,'MyData',mov);
%   end
%   ....
%   ....
%   return
%   end
%
% ***Note: in early DIR2MENU versions, no arguments were passed when a
% menu_ file was called. Now two arguments are passed implicitly by MATLAB:
% hObject: the menu item's handle (as returned by gcbo)
% EventData: presently empty (and MATLAB reserved)
%
% -------------------------------------------------------------------------
% Using the 'external_' prefix:
%
% If an m_file is prefixed by 'external_', it will be called in much the
% same way as  a 'menu_' prefixed m-file (but in this case, without the
% zero input argument). Like an menu_ m-file, an external_*.m file should
% return a logical flag and the menu item label. It should, in addition,
% return a string which is the full path and name of a folder lying
% outside of PARENTDIRECTORY. This folder will be treated as
% though it were a menu_ folder inside PARENTDIRECTORY located at the
% same place in the directory tree as the 'external_' file.
% e.g.
% function varargout=external_MyExternalFunctions(varargin)
%  varargout{1}=true; % or false after a test
%  varargout{2}='MyLabel'; % appears on the menu
%  varargout{3}='c:\Program Files\MATLAB\2006b\work\CommonFunctionsToolbox';
%  return
%  end
%
% The CommonFunctionsToolbox can be shared by several main functions each
% of which calls DIR2MENU. The CommonFunctionsToolbox folder will be
% treated as though it were a menu_ folder. It may therefore contain menu_
% routines and folders/subfolders, group_ folders (and also further external_
% m-files as everything is done recursively. Note the external_ file should
% not return its own folder (or an ancestor of it), or you will enter an
% infinite recursion).
%
% DIR2MENU automatically adds CommonFunctionsToolbox and all its subfolders
% to the MATLAB path. The CommonFunctionsToolbox folder need not be on the
% same disc as MATLAB - or the same machine if networked.
%--------------------------------------------------------------------------
%
%
% See also:
% UIMENU, FIGURE, GCBO, SETAPPDATA, GETAPPDATA, GUIDE,
% together with
% "Function Handle Callback Syntax" in the Help Search box
%
%--------------------------------------------------------------------------
% Author: Malcolm Lidierth 09/06
% Copyright © The Author & King's College London 2006-2007
%--------------------------------------------------------------------------

% Toolboxes required: None
% Acknowledgements:
% Revisions:
% 19.10.06 Populates standard matlab menu items (such as File and Help)
%          with the standard menu tree if they are not replaced from the
%          folder tree.
% 31.10.06 Bug fix. Deletion of non-menu items could delete File/Edit/Menu
% 17.11.06 Fix fix. Replaced while with for. Revert to while
% 09.12.06 Included code to support the 'external_' prefix. The tags of
%          uimenu items now contain the full path of the folder/executable
%          they relate to.
% 10.12.06 Replaced evals with function handles. Function handle in cell
%          array so hObject and EventData added as first input arguments by
%          MATLAB.
% 16.10.06 Add the capacity to have the callback routine add data to the
%          menu item UserData area when called as function(0).
% 23.12.06 Add support for uicontextmenus
% 02.01.07 File extensions are stripped away from top menu item labels.
%          Useful for uicontextmenus
% 17.02.07 CheckNestLevel included for more versatile performance with
%          external_ files.
%          Fix bug: reference to Children not children + fix in
%          GetChildren
% 14.03.08 CheckNestLevel: give priority to lowest menu in list
% 21.04.08 CheckNestLevel: now acts on uicontextmenus also


DirectoryAtEntry=pwd;
GroupMarker=false;

% Get arguments maintaining backwards compatability
switch nargin
    case 1
        type='figure';
        Options={};
    case 2
        if iscell(type)
            type='figure';
            Options=type{:};
        else
            Options={};
        end
    case 3
        Options=varargin{:};
end

cd(ParentDirectory);
addpath(genpath(pwd));

% TOP LEVEL MENU
switch type
    case 'uicontextmenu'
        handle=uicontextmenu();
        % For uicontextmenus, may have *.m file at the top level - add
        % these first
        d=dir([ParentDirectory filesep '*.m']);
        for kk=1:length(d)
            d(kk).source=[ParentDirectory filesep d(kk).name];
        end
        UiMenuDirectories=[];
        UiMenuDirectories=GetMenuDirectories(ParentDirectory, UiMenuDirectories);
        if ~isempty(d) && ~isempty(UiMenuDirectories)
            UiMenuDirectories=[d; UiMenuDirectories];
        elseif ~isempty(d)
            UiMenuDirectories=d;
        end
        if isempty(UiMenuDirectories)
            delete(handle);
            handle=[];
            return
        end
        [str idx]=menusort(UiMenuDirectories);
        TopMenuDirectories(1).name='';
        TopMenuDirectories(1).date='';
        TopMenuDirectories(1).bytes=[];
        TopMenuDirectories(1).source=ParentDirectory;
        TopMenuDirectories(1).children=UiMenuDirectories(idx);
    case 'figure'
        handle=figure('NumberTitle','off',...
            'Units','normalized',...
            'Position',[0.05 0.05 0.85 0.85]);
        set(handle,'name',...
            sprintf('Generated by DIR2MENU. %c King''s College London 2006',169));
        % Set up the top menu items File, Edit & View
        % Seed TopMenuDirectories with a call to dir
        TopMenuDirectories=dir('..');
        TopMenuDirectories=TopMenuDirectories(1);

        % Add a source field - this will contain the full directory path relevant
        % to each item and be used as an object Tag in the menus
        TopMenuDirectories(1).name='File';
        TopMenuDirectories(end).date='';
        TopMenuDirectories(end).bytes=[];
        TopMenuDirectories(end).source=[ParentDirectory filesep...
            TopMenuDirectories(end).name];

        TopMenuDirectories(end+1,1).name='Edit';
        TopMenuDirectories(end).date='';
        TopMenuDirectories(end).bytes=[];
        TopMenuDirectories(end).source=[ParentDirectory filesep...
            TopMenuDirectories(end).name];

        TopMenuDirectories(end+1).name='View';
        TopMenuDirectories(end).date='';
        TopMenuDirectories(end).bytes=[];
        TopMenuDirectories(end).source=[ParentDirectory filesep...
            TopMenuDirectories(end).name];

        TopMenuDirectories=GetMenuDirectories(ParentDirectory, TopMenuDirectories);

        % Finish off with Tools, Desktop, Window and Help menu items

        TopMenuDirectories(end+1).name='Insert';
        TopMenuDirectories(end).date='';
        TopMenuDirectories(end).bytes=[];
        TopMenuDirectories(end).source=[ParentDirectory filesep...
            TopMenuDirectories(end).name];

        TopMenuDirectories(end+1).name='Tools';
        TopMenuDirectories(end).date='';
        TopMenuDirectories(end).bytes=[];
        TopMenuDirectories(end).source=[ParentDirectory filesep...
            TopMenuDirectories(end).name];

        TopMenuDirectories(end+1).name='Desktop';
        TopMenuDirectories(end).date='';
        TopMenuDirectories(end).bytes=[];
        TopMenuDirectories(end).source=[ParentDirectory filesep...
            TopMenuDirectories(end).name];

        TopMenuDirectories(end+1).name='Window';
        TopMenuDirectories(end).date='';
        TopMenuDirectories(end).bytes=[];
        TopMenuDirectories(end).source=[ParentDirectory filesep...
            TopMenuDirectories(end).name];

        TopMenuDirectories(end+1).name='Help';
        TopMenuDirectories(end).date='';
        TopMenuDirectories(end).bytes=[];
        TopMenuDirectories(end).source=[ParentDirectory filesep...
            TopMenuDirectories(end).name];
end

%For each top menu item....(only 1 for uicontextmenus)
TopMenuHandles=zeros(length(TopMenuDirectories),1);
for index=1:length(TopMenuDirectories)
    %Get any child menu items
    TopMenuDirectories(index).children=...
        GetChildren(TopMenuDirectories(index).source);
    %Sort them alphabetically
    [str idx]=menusort(TopMenuDirectories(index).children);
    TopMenuDirectories(index).children=TopMenuDirectories(index).children(idx);
    %Create the menu item
    label=strrep(TopMenuDirectories(index).name,'menu_','');
    label=strrep(label,'.m','');% added 02/01/07
    label=strrep(label,['.' mexext()],'');
    %Add any lower level items - searching recursively through the
    %directory tree if need be.
    if strcmp(type,'figure')
        TopMenuHandles(index)=makemenu(handle,'label',label,...
            'Tag',TopMenuDirectories(index).name,...
            Options{:});
        PopulateSubMenus(TopMenuHandles(index),TopMenuDirectories(index).children);
    elseif strcmp(type,'uicontextmenu')
        PopulateSubMenus(handle,TopMenuDirectories(index).children);
    end
end


if strcmp(type,'figure')
    CleanUpFigure(handle, TopMenuHandles);
    TopMenuHandles=TopMenuHandles(ishandle(TopMenuHandles));
    % Combine items with common labels etc
    for idx=1:length(TopMenuHandles)
    CheckNestLevel(TopMenuHandles(idx));
    end
else
    CheckNestLevel(handle);
end

cd(DirectoryAtEntry);


%*************************************************************************
    function handle=PopulateSubMenus(mainhandle, list)
        %*************************************************************************

        Executables{1}='.m';
        Executables{2}=['.' mexext()];

        handle=[];
        if isempty(list)
            return
        end

        %Single item in a menu list
        if length(list)==1
            if list.isdir==true
                % Item is a directory so recursively populate its menu list
                if ~isempty(strfind(list.name,'group_'))
                    GroupMarker=true;
                    handle=PopulateSubMenus(mainhandle, list.children);
                    GroupMarker=true;
                else
                    label=strrep(list.name,'menu_','');
                    handle=makemenu(mainhandle,'label',label,...
                        'Tag',list.source,...
                        Options{:});
                    handle=PopulateSubMenus(handle, list.children);
                end
            else
                % Item is a file
                [pname fname ext]=fileparts(list.name);
                % Add to menu only if it is an executable file
                if strcmpi(ext, Executables{1})==1 ||...
                        strcmpi(ext, Executables{2})==1
                    funchandle=str2func([pname fname]);
                    [flag label data]=funchandle(0);
                    % In the line below, remove the brackets around
                    % funchandle to make this backwards compatible with the
                    % previous dir2menu version callback format
                    handle=makemenu(mainhandle,'label',label,...
                        'Tag',list.source,...
                        'Callback',{funchandle},...
                        'Enable',Log2Str(flag),...
                        Options{:});
                    % Put any info returned by funchandle(0) call in the
                    % UserData property
                    set(handle,'UserData',data);
                else
                    handle=mainhandle;
                    return
                end
            end
        else
            %Multiple items in list - deal with each in turn
            for i=1:length(list)
                if list(i).isdir==true
                    %Directory
                    if ~isempty(strfind(list(i).name,'group_'))
                        GroupMarker=true;
                        handle=PopulateSubMenus(mainhandle, list(i).children);
                        GroupMarker=true;
                    else
                        label=strrep(list(i).name,'menu_','');
                        tophandle=makemenu(mainhandle,'label',label,...
                            'Tag',list(i).source,...
                            Options{:});
                        for j=1:length(list(i).children);
                            handle=PopulateSubMenus(tophandle, list(i).children(j));
                        end
                    end
                else
                    %File - the next call to PopulateSubMenus will set up
                    %the menu item that terminates this branch
                    handle=PopulateSubMenus(mainhandle, list(i));
                end
            end
            return
        end
    end

%*************************************************************************
%*************************************************************************

%*************************************************************************
    function out=makemenu(varargin)
        %*************************************************************************
        % Calls uimenu placing a line above the first item of a "group_" entry and
        % above the next entry on the parent list i.e. below the last item of the
        % group. GROUPMARKER is declared in the main routine and has scope here.
        % PopulateSubMenus toggles its value to control makemenu.
        if GroupMarker==true
            out=uimenu(varargin{:},'Separator','on');
            GroupMarker=false;
        else
            out=uimenu(varargin{:},'Separator','off');
        end
        return
    end
%*************************************************************************
%*************************************************************************



end
%*************************************************************************
%End of scope for main function
%*************************************************************************


%*************************************************************************
function val=GetChildren(directory)
%*************************************************************************
% Called once for each top menu item. GetChildren populates the drop down
% lists for the top menu items. GetChildren creates the initial
% val.children entries that will grow recursively through a call to
% PopulateSubMenus

% Deal with external_*.m files by calling GetChildren recursively
valtemp=dir([directory filesep 'external_*.m']);
for k=1:length(valtemp)
    valtemp(k).children=[];
    [path name]=fileparts(valtemp(k).name);
    funchandle=str2func(name);
    [flag name folder]=funchandle();
    if flag==true
        % Add (k) subscript 17/2/07
        valtemp(k).children=GetChildren(folder);
        addpath(genpath(folder));
    end
    valtemp(k).name=name;
    valtemp(k).isdir=true;
    valtemp(k).source=folder;
end

% menu_ or group_ items
d=dir([directory filesep 'menu_*']);
d=[d; dir([directory filesep 'group_*'])];
if ~isempty(d)
    for k=1:length(d)
        d(k).children=[];
        d(k).source=[directory filesep d(k).name];
    end
    if isempty(valtemp)
        valtemp=d;
    else
        valtemp=[valtemp; d];
    end
end

% d=dir([directory filesep 'group_*']);
% if ~isempty(d)
%     for k=1:length(d)
%         d(k).children=[];
%         d(k).source=[directory filesep d(k).name];
%     end
%     if isempty(valtemp)
%         valtemp=d;
%     else
%         valtemp=[valtemp; d];
%     end
% end

% Return if nothing of interest found
if isempty(valtemp)
    val=[];
    return
end

% Sort the output
[str idx]=menusort(valtemp);
val=valtemp(idx);

for i=1:length(val)
    if val(i).isdir==true && isempty(val(i).children)
        temp=[directory filesep val(i).name];
        val(i).children=GetChildren(temp);
    end
end
if isempty(val)
    val=[];
end
return
end
%*************************************************************************



%*************************************************************************
function [str idx]=menusort(valtemp)
%*************************************************************************
% Sorts the menu lists alphabetically by file/folder name.
% Note that names are cast to lower case before sorting
name=cell(1,length(valtemp));
for i=1:length(valtemp)
    name{i}=strrep(valtemp(i).name,'menu_','');
    name{i}=strrep(name{i},'group_','');
end
name=lower(name);
[str idx]=sort(name);
return
end
%*************************************************************************


%*************************************************************************
function str=Log2Str(flag)
%*************************************************************************
% Translate true/false to on/off string
if flag==true
    str='on';
else
    str='off';
end
return
end
%*************************************************************************

%*************************************************************************
function TopMenuDirectories=GetMenuDirectories(ParentDirectory, TopMenuDirectories)
%**************************************************************************
% Add any user-defined external tool folders
d=dir('external_*.m');
for kk=1:length(d)
    [path name]=fileparts(d(kk).name);
    funchandle=str2func(name);
    [flag name folder]=funchandle();
    if flag==true
        d2=dir(folder);
        %[parent name]=fileparts(folder);
        d2(1).name=name;
        d2(1).source=folder;
        TopMenuDirectories=[TopMenuDirectories; d2(1)]; %#ok<AGROW>
        addpath(genpath(folder));
    end
end
startindex=length(TopMenuDirectories)+1;

% Add any user defined top-level directories
% Get their names - always prefixed by "menu_"
d=dir('menu_*');
if ~isempty(d)
    for kk=1:length(d)
        d(kk).source=[ParentDirectory filesep d(kk).name];
    end
    TopMenuDirectories=[TopMenuDirectories; d];
    % Delete any that are not directories
    % CHANGE: Bug fix 31/10/06
    % CHANGE: Fix fix. Revert to while loop 17/11/06
    % CHANGE: incorporate 'external_' 9/12/06
    index=startindex;
    while index<length(TopMenuDirectories)
        if TopMenuDirectories(index).isdir==false
            TopMenuDirectories(index)=[];
        else
            index=index+1;
        end
    end

end
end
%*************************************************************************
%*************************************************************************


%*************************************************************************
function CleanUpFigure(handle, TopMenuHandles)
%*************************************************************************
% If new menus are empty, leave the standard menu items with their standard
% callbacks. Otherwise replace.

h3=allchild(handle);
h=findobj(handle,'Label','File');
if isempty(get(h,'Children'))
    delete(h);
else
    hd=findobj(h3,'Tag','figMenuFile');
    set(h,'Position',get(hd,'Position'));
    delete(hd);
end

h3=allchild(handle);
h=findobj(handle,'Label','Edit');
if isempty(get(h,'Children'))
    delete(h);
else
    hd=findobj(h3,'Tag','figMenuEdit');
    set(h,'Position',get(hd,'Position'));
    delete(hd);
end

h3=allchild(handle);
h=findobj(handle,'Label','View');
if isempty(get(h,'Children'))
    delete(h);
else
    hd=findobj(h3,'Tag','figMenuView');
    set(h,'Position',get(hd,'Position'));
    delete(hd);
end

%Place custom menus between View and Insert
for k=4:length(TopMenuHandles)
    set(TopMenuHandles(k),'Position',k);
end


h3=allchild(handle);
h=findobj(handle,'Label','Insert');
if isempty(get(h,'Children'))
    delete(h);
else
    hd=findobj(h3,'Tag','figMenuInsert');
    set(h,'Position',get(hd,'Position'));
    delete(hd);
end

h3=allchild(handle);
h=findobj(handle,'Label','Tools');
if isempty(get(h,'Children'))
    delete(h);
else
    hd=findobj(h3,'Tag','figMenuTools');
    set(h,'Position',get(hd,'Position'));
    delete(hd);
end

h3=allchild(handle);
h=findobj(handle,'Label','Desktop');
if isempty(get(h,'Children'))
    delete(h);
else
    hd=findobj(h3,'Tag','figMenudesktop');
    set(h,'Position',get(hd,'Position'));
    delete(hd);
end

h3=allchild(handle);
h=findobj(handle,'Label','Window');
if isempty(get(h,'Children'))
    delete(h);
else
    hd=findobj(h3,'Tag','figMenuWindow');
    set(h,'Position',get(hd,'Position'));
    delete(hd);
end

h3=allchild(handle);
h=findobj(handle,'Label','Help');
if isempty(get(h,'Children'))
    delete(h);
else
    hd=findobj(h3,'Label','&Help');
    set(h,'Position',get(hd,'Position'));
    delete(hd);
end
end
%*************************************************************************

%*************************************************************************
function CheckNestLevel(handle)
%*************************************************************************
% Collapse lists together if they share the same label as other menuitems
% at the same level in the tree, or if a child shares its label with its
% parent. This allows external_ and menu_ items to be included in the same 
% subfolder

mhandles=get(handle,'Children');
index=1;
if strcmp(get(handle, 'Type'), 'uimenu')==1
    % uimenus only - not context menus
    while index<=length(mhandles)
        % Does a child menu have the same label as its parent
        if strcmp(get(mhandles(index), 'Label'),get(handle, 'Label'))
            h=get(mhandles(index),'Children');
            copyobj(h, handle);
            delete(mhandles(index));
            %mhandles(index)=[];
            % Start the checking again
            CheckNestLevel(handle);
            return
        else
            index=index+1;
        end
    end
end

% Check for duplication of labels at a specific level
% Combine them if duplicated
mhandles=sort(get(handle,'Children'));
lidx=1;
while lidx<=length(mhandles)
    hidx=lidx+1;
    while hidx<=length(mhandles)
        if strcmp(get(mhandles(hidx), 'Label'), get(mhandles(lidx), 'Label'))
            % 14.03.08 Reverse priority: copy hidx/delete lidx
            h=get(mhandles(lidx),'Children');
            copyobj(h,mhandles(hidx));
            delete(mhandles(lidx));
            mhandles(lidx)=[];
%             h=get(mhandles(hidx),'Children');
%             copyobj(h,mhandles(lidx));
%             delete(mhandles(hidx));
%             mhandles(hidx)=[];
        end
        hidx=hidx+1;
    end
    lidx=lidx+1;
end

% Work through the deeper elements through recursive calls
mhandles=get(handle,'Children');
for index=1:length(mhandles)
    CheckNestLevel(mhandles(index));
end

return
end
%*************************************************************************