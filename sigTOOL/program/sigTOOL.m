function fhandle=sigTOOL(filename)
% sigTOOL: Main entry routine
%
% Examples:
% sigTOOL()
%       invokes sigTOOL creating an empty data view.
%
% sigTOOL(filename)
%       invokes sigTOOL and loads the sigTOOL data file filename.
%       If called from an existing empty figure (via a menu callback),
%       filename is loaded into that figure. If the figure is already populated,
%       sigTOOL invokes another instance of itself.
%
% h=sigTOOL(...) returns the handle of the populated figure
%
% Also:
% sigTOOL('nojvm')      sets up the path and returns. This can be used to
%                       make sigTOOL core functions accessible from the
%                       command line without invoking a data view. Only
%                       child folders of: 
%                               ...sigTOOL/program 
%                               and
%                               ...sigTOOL/CORE/utils 
%                           will be added to the path.
% sigTOOL('version')    returns the sigTOOL version number
% sigTOOL('cleanup')    deletes MAT files in the system temporary directory.
%                       Do not use this when sigTOOL is running. Note that
%                       temporary MAT files deleted by this process may be
%                       required by Fast Saved kclf files. 
% sigTOOL('compile')    Compiles sigTOOL C/C++ source files. Only needed if
%                       mex-files for the present platform are not included
%                       in the distribution
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 11/06
% Copyright © The Author & King's College London 2006-
% -------------------------------------------------------------------------
% Multiple sigTOOL version can be run from different parent folders,
% each providing different analysis functions via the sub-folders.
% However, different versions should be run in separate instances of MATLAB
% to avoid interaction.
%
% Revisions:
% 
% doi:10.1016/j.jneumeth.2008.11.004
% http://dx.doi.org/10.1016/j.jneumeth.2008.11.004
% http://www.sciencedirect.com/science?_ob=ArticleURL&_udi=B6T04-4TX78YP-4&_user=121727&_coverDate=11%2F13%2F2008&_rdoc=2&_fmt=high&_orig=browse&_srch=doc-info(%23toc%234852%239999%23999999999%2399999%23FLA%23display%23Articles)&_cdi=4852&_sort=d&_docanchor=&_ct=97&_acct=C000010000&_version=1&_urlVersion=0&_userid=121727&md5=e43fa8165befc0cc663ecf7bdb2affed
%
% 01.08.09 Web addresses updated to http://sigtool.sourceforge.net
%           Out-of-date reminder now triggered at 1 year.

%--------------------------------------------------------------------------
% Options
%--------------------------------------------------------------------------

persistent LF;
if isempty(LF)
    LF=javax.swing.UIManager.getLookAndFeel();
end

persistent RunNumber;
if isempty(RunNumber)
    RunNumber=1;
else
    RunNumber=RunNumber+1;
end


ShowMessage=false;

% Get the full path for this version of sigTOOL
parentdirectory=fileparts(which('sigTOOL'));
idx=strfind(parentdirectory,'program');
% Add the general utilities directory to the path
UtilsDirectory=parentdirectory(1:idx-1);
UtilsDirectory=[UtilsDirectory 'CORE' filesep 'utils'];
addpath(genpath(UtilsDirectory));
PrefFile=[parentdirectory filesep 'scPreferences.mat'];

% Check for option argument on input
if ~usejava('awt') || (nargin==1 && strcmpi(filename,'nojvm'))
    % No JVM in use - set up path (as above), deactivate progress bars
    % and return.
    scProgressBar('off');
    return
end

if RunNumber==1
    [v dated]=scVersion('nodisplay');
    if datenum(date)>datenum(dated)+720
        ShowOutOfDate();
    else
        % Code here to show message for first instance
    end
end

scProgressBar('on');
% Process options
if nargin==1
    % Only the options listed in the help text are likely to remain in
    % future versions. Other options are included for development only -
    % invoking them may cause subsequent problems in MATLAB such as
    % java exceptions
    switch filename
        case 'version'
            fhandle=scVersion('nodisplay');
            return
        case 'restore'
            if ~isempty(LF)
                % N.B. Undocumented. DO NOT USE: This will cause subsequent   
                % Java exceptions when invoking the property inspector.
                javax.swing.UIManager.setLookAndFeel(LF);
                return
            end
        case 'cleanup'
            d=dir([tempdir() '*.mat']);
            count=0;
            for i=1:length(d)
                try
                    delete([tempdir() d(i).name])
                catch %#ok<CTCH>
                    count=count+1;
                    fprintf('%s could not be deleted', d(i).name);
                end
            end
            fprintf('\n\nFound %d files: At least %d could not be deleted\n', length(d), count);
            return
        case 'metal'
            % N.B. Undocumented. DO NOT USE: This will cause subsequent
            % Java exceptions when invoking the property inspector.
            javax.swing.UIManager.setLookAndFeel(javax.swing.plaf.metal.MetalLookAndFeel);
            return
        case 'compile'
            % Need dir2menu to generate path (including external_ folders)
            fprintf('Setting up. Please wait...\n\n');
            fhandle=dir2menu(parentdirectory);
            close(fhandle);
            fhandle=[];
            sigTOOLCompileMexFiles();
            return
        case 'firstrun'
            % Do not use - dev only
            fhandle=dir2menu(parentdirectory);
            % Set up the closing callback to tidy memory
            set(fhandle,'DeleteFcn','scDeleteFigure()')
            % Switch off the axes visibility
            set(gca,'Visible','off');
            load(PrefFile, 'Setup');
            Setup.FirstRun=true;
            LocalWelcome(Setup, PrefFile);
            sigTOOL(fhandle);
            FirstRunMessage(fhandle);
            return
       case 'pref'
           % Do not use - dev only
           Setup.FirstRun=true;
           Setup.HostIP='';
           Setup.Date=datenum(date);
           DataView.DefaultLineColor=[0.2510 0.2510 0.4784];
           DataView.MarkerTextBackgroundColor=[1 1 0];
           DataView.MarkerTextEdgeColor=[0.6000 0 0];
           DataView.MarkerTextFontSize=6;
           DataView.MarkerTextMargin=1;
           DataView.NumberOfMarkersToShow=1;
           DataView.ShowMarkersGreaterThanOrEqualTo=1;
           DataView.UseColorCycling=0;
           DataView.PreRenderDataView=1; %#ok<STRNU>
           Filing.OpenSaveDir=[parentdirectory(1:idx-1) 'demos' filesep];
           Filing.ImportReplace.Source='';
           Filing.ImportReplace.Target='';
           Filing.ImportDir='';
           Filing.ExportVector='evince';
           Filing.ExportBitmap='eog'; %#ok<STRNU>
           save(PrefFile, 'Setup', 'DataView', 'Filing', '-v6');
           return
    end
end

%--------------------------------------------------------------------------
% Main rountine for GUI
%--------------------------------------------------------------------------



switch nargin
    case 0
        % No file specified: command line call
        % Let dir2menu set up a figure and populate the menu
        fhandle=dir2menu(parentdirectory);
        % Set up the closing callback to tidy memory
        set(fhandle,'DeleteFcn','scDeleteFigure()')
        % Switch off the axes visibility
        set(gca,'Visible','off');
        try
            load(PrefFile, 'Setup');
        catch
            % May have corrupted file or more recent MAT version
            sigTOOL('pref');
            load(PrefFile, 'Setup');
        end
        if Setup.FirstRun==true %#ok<NODEF>
            LocalWelcome(Setup, PrefFile);
            ShowMessage=true;
        else
            if ~strcmp(Setup.HostIP, char(java.net.InetAddress.getLocalHost()))
                % Redistrubuted?
                TF=~isempty(strfind(Setup.HostIP, 'kings')) & ~isempty(strfind(Setup.HostIP, '.88')) | ~isempty(strfind(Setup.HostIP, '127.0.0.1'));
                if ~TF
                    % Not by King's
                    NotSoLocalWelcome(Setup, PrefFile);
                else
                    % OK - set this PC as host
                    Setup.HostIP=char(java.net.InetAddress.getLocalHost());
                    save(PrefFile, 'Setup', '-append', '-v6');
                end
            end
        end
        
    case 1
        % File named on input
        % Invoke new instance of sigTOOL
        if ischar(filename)
            fhandle=sigTOOL();
            % Load the data and create a data view
            [channels DataView]=scOpen(filename);
            setappdata(fhandle,'channels',channels);
            [path name]=fileparts(filename);
            set(fhandle, 'Name', name);
            scCreateDataView(fhandle);
            scProcessDataView(fhandle, DataView);
        else
            % Do not use - dev only
            fhandle=filename;
        end
end
% Read the scPreferences.mat file and place preferences in the figure
% application data area
set(fhandle,'Tag','sigTOOL:DataView');
setappdata(fhandle,'PreferencesFile',PrefFile);
load(PrefFile,'DataView');
setappdata(fhandle, 'DataView', DataView);
load(PrefFile,'Filing');
setappdata(fhandle,'Filing',Filing);
% Make all menu text dark blue
h=findall(fhandle,'Type','uimenu');
set(h,'ForegroundColor',[64 64 122]/255);

% These functions support multiplexed channels - highlight them on menu
h=findobj(fhandle, 'Type', 'uimenu');
set(findobj(h, 'Label', 'Decimate'), 'ForegroundColor', [0 0.4 1]);
set(findobj(h, 'Label', 'Digital Filter'), 'ForegroundColor', [0 0.4 1]);
set(findobj(h, 'Label', 'Copy channel'), 'ForegroundColor', [0 0.4 1]);

if ShowMessage
    FirstRunMessage(fhandle);
end

hp=findall(fhandle,'Label','&Help');
if isempty(findobj(hp, 'Label', 'sigTOOL'))
sh=uimenu(hp, 'Label', 'sigTOOL', 'Separator', 'on');
    uimenu(sh, 'Label', 'Register as user', 'Callback', @Register);
    uimenu(sh, 'Label', 'Send comment/feature request', 'Callback', @Feature);
    uimenu(sh, 'Label', 'Send bug report', 'Callback', @Bug);
    uimenu(sh, 'Label', 'sigTOOL Web Page', 'Separator', 'on', 'Callback', @Website);
    uimenu(sh, 'Label', 'sigTOOL Downloads', 'Callback', @Downloadsite);
    uimenu(sh, 'Label', 'sigTOOL on the ISI Web of Knowledge', 'Callback', @ISIWoK);
    uimenu(sh, 'Label', 'sigTOOL on Google Scholar', 'Callback', @GoogleScholar);
    uimenu(sh, 'Label', 'View user guide','Separator', 'on', 'Callback', @User);
    uimenu(sh, 'Label', 'View programmers'' guide', 'Callback', @Programmer);
    
end

return
end


function LocalWelcome(Setup, PrefFile)
Setup.FirstRun=false;
Setup.HostIP=char(java.net.InetAddress.getLocalHost());
Setup.Date=datenum(date);
save(PrefFile, 'Setup', '-append', '-v6');
fprintf('Welcome to sigTOOL %s', Setup.HostIP);
return
end

function NotSoLocalWelcome(Setup, PrefFile)
str=sprintf('This copy of sigTOOL appears to have been redistibuted from another computer:\nIP address: %s Installed %s\n',...
    Setup.HostIP,...
    datestr(Setup.Date));
str=sprintf('%sThe code may be out-of-date, may have been altered and may contain bugs/viruses.\n\n',str);
str=sprintf('%sYou can download an original copy from the sigTOOL website', str);
button=questdlg(str, 'sigTOOL Startup', 'Set this PC as host',...
    'Visit website', 'Continue', 'Continue');
switch button
    case 'Set this PC as host'
        LocalWelcome(Setup, PrefFile);
    case 'Visit website'
        % TODO: Update exact url when available
        web('http://sigtool.sourceforge.net','-browser');
end
return
end

function ShowOutOfDate()
str=sprintf('This version of sigTOOL is rather old\n\n');
str=sprintf('%sYou can check for an update at the sigTOOL website', str);
button=questdlg(str, 'sigTOOL Startup',...
    'Visit website', 'Continue', 'Continue');
switch button
    case 'Visit website'
        web('http://sigtool.sourceforge.net','-browser');
end
return
end


function Register(hObject, EventData)
scRegister(gcf);
return
end

function Feature(hObject, EventData)
scFeature(gcf);
return
end

function Bug(hObject, EventData)
scBugReport(gcf);
return
end

function Website(hObject, EventData)
web('http://sigtool.sourceforge.net/', '-browser');
return
end

function Downloadsite(hObject, EventData)
web('http://sourceforge.net/projects/sigtool/files', '-browser');
return
end

function ISIWoK(hObject, EventData)
web('http://apps.isiknowledge.com/CitedFullRecord.do?product=WOS&db_id=WOS&SID=S2opfECHeA12fPo9iKE&search_mode=CitedFullRecord&isickref=178014037', '-browser');
return
end

function GoogleScholar(hObject, EventData)
web('http://scholar.google.com/scholar?cites=6357913935809768444&hl=en&as_sdt=2000', '-browser');
return
end

function User(hObject, EventData)
open(fullfile(scGetBaseFolder(), 'documentation', 'sigTOOL GUI User Guide.pdf'));
return
end

function Programmer(hObject, EventData)
open(fullfile(scGetBaseFolder(), 'documentation', 'sigTOOL Programming Guide.pdf'));
return
end
