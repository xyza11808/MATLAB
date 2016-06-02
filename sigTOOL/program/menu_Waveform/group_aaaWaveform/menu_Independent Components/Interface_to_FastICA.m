function Interface_to_FastICA(fhandle, clist, start, stop, Save_sigTOOL, Save_File, Save_MATLAB)
% Interface_to_FastICA provides a sigTOOL inteface to the FastICA software
% of Hugo Gävert, Jarmo Hurri, Jaakko Särelä, and Aapo Hyvärinen
%
% FastICA is copyright (c) Hugo Gävert, Jarmo Hurri, Jaakko Särelä, and Aapo Hyvärinen
%
% Example:
% Interface_to_FastICA(fhandle, clist, start, stop, Save_sigTOOL,...
%               Save_File, Save_MATLAB)
% where
%       fhandle     is the handle of sigTOOL data view
%       clist       is a list of continuous waveforn channels on which
%                   to perform the independent components analysis
%       start           start time for analysis (in seconds)
%       stop            stop time for analysis (in seconds)
%       Save_sigTOOL    logical flag, if true save independent components
%                       to the sigTOOL data view as as new channels.
%       Save_File       logical flag, if true save results to MAT-file
%       Save_MATLAB     logical flag, if true save results to base workspace
%
% Interface_to_FastICA passes data to FastICA in double precision format.
%
% The results are saved  by selecting the "Export to sigTOOL" button
% that is added to the FastICA GUI. Note that these will be stored in RAM
% until you save the file.
% 
% For details of the output to the base workspace or a file, see the
% FastICA documentation
%
% The FastICA GUI can not be used when batch processing files in sigTOOL.
% To include calls to FastICA in a sigTOOL history file, use the Icasso
% option. This calls FastICA and can be used for batch processing (setting
% the number of iterations to 1 will result in a single call to FastICA if
% that is required).
%
% For an introduction to independent components analysis and a description
% of the FastICA software visit the FastICA website at:
%           http://www.cis.hut.fi/projects/ica/fastica/
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 11/08
% Copyright © The Author & King's College London 2008-
% -------------------------------------------------------------------------

% globals declared in FastICA
global g_FastICA_mixedsig

if ~ishandle(fhandle)
    str='You must supply a sigTOOL data view handle on input. Channel cell array input not supported';
    errordlg(str, 'sigTOOL Interface To FastICA');
    error(str);
end

% Get the channel data...
channels=getappdata(fhandle, 'channels');

% Start and stop times
tu=channels{clist(1)}.tim.Units;
if nargin<3
    start=0;% Default
else
    start=start*(1/tu);
end

if nargin<4
    stop=Inf;% Default
else
    stop=stop*(1/tu);
end

% Get the handle to the FastICA GUI (do not rely on the global)
local_FastICA_MAIN=findall(0,'Tag', 'f_FastICA');



% Process first channels - pre-allocate x
thischan=getData(channels{clist(1)}, start, stop);
x=zeros(length(clist),size(thischan.adc,1));
x(1,:)=thischan.adc(1:end)';
% Remaining channels
for j=2:length(clist)
    thischan=getData(channels{clist(j)}, start, stop+tu);
    x(j,:)=thischan.adc(1:end)';
end

if isempty(local_FastICA_MAIN)
    % Start FastICA GUI...
    fasticag(x);
    local_FastICA_MAIN=findall(0,'Tag', 'f_FastICA');
    ModifyGUI(local_FastICA_MAIN, clist, start, stop, Save_sigTOOL, Save_File, Save_MATLAB)
else
    %... or use existing instance
    % Make sure it has been instantiated from sigTOOL
    if isempty(getappdata(local_FastICA_MAIN,'sigTOOLSourceView'))
        % If not modify it
        ModifyGUI(local_FastICA_MAIN, clist, start, stop, Save_sigTOOL, Save_File, Save_MATLAB)
    else
        % It it has, update clist in callback
        set(findobj(local_FastICA_MAIN, 'Tag', 'sigTOOL Export'),...
            'Callback', {@LocalSaveData, clist, start, stop, Save_sigTOOL, Save_File, Save_MATLAB});
    end
    g_FastICA_mixedsig=x;
    gui_cb('NewData');
end

% Log the sigTOOL view handle in the FastICA GUI
setappdata(local_FastICA_MAIN, 'sigTOOLSourceView', fhandle);

% Ensure GUI is visible
figure(local_FastICA_MAIN);
return
end

function ModifyGUI(local_FastICA_MAIN, clist, start, stop, Save_sigTOOL, Save_File, Save_MATLAB)
% Disable load from outside sigTOOL
button=findobj(local_FastICA_MAIN,'Tag','b_LoadData');
set(button,'Enable','off','Callback',[]);

button=findobj(local_FastICA_MAIN,'Tag','b_SaveData');
set(button,'String','<HTML><CENTER>Export to<P>workspace</P></CENTER></HTML>');

quitbutton=findobj(local_FastICA_MAIN,'Tag','b_Quit');

uicontrol('Parent',local_FastICA_MAIN, ...
    'BackgroundColor',[0.701961 0.701961 0.701961], ...
    'ForegroundColor','b',...
    'Callback',{@LocalSaveData, clist, start, stop, Save_sigTOOL, Save_File, Save_MATLAB}, ...
    'Interruptible', 'off', ...
    'Position',get(quitbutton,'Position'), ...
    'String','<HTML><CENTER>Export to<P>sigTOOL</P></CENTER></HTML>', ...
    'Tag','sigTOOL Export');
pos=get(quitbutton, 'Position');
pos(2)=pos(2)-3*pos(4);
set(quitbutton, 'Position',pos);

% Tidy up on deletion of FastICA GUI
set(local_FastICA_MAIN, 'DeleteFcn', @DeleteFastICAGUI);
return
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%---------------------------- CALLBACKS------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function DeleteFastICAGUI(hObject, EventData) %#ok<INUSD>
% Clear up globals
a=whos('global','*FastICA*');
for i=1:length(a)
    clear('global', a(i).name)
end
return
end


function LocalSaveData(hObject, EventData, clist, start, stop, Save_sigTOOL, Save_File, Save_MATLAB) %#ok<INUSL>

% Globals defined in FastICA
global g_FastICA_ica_sig;
global g_FastICA_ica_A;
global g_FastICA_ica_W;
global g_FastICA_white_sig;
global g_FastICA_white_wm;
global g_FastICA_white_dwm;
global g_FastICA_pca_E;
global g_FastICA_pca_D;

% Delete FastICA signal figure: may need the memory
fh=findobj('Tag','f_FastICA_ica');
if ~isempty(fh)
    delete(fh);
end

if Save_sigTOOL
    % sigTOOL info
    [button local_FastICA_MAIN]=gcbo;
    sigTOOLSourceView=getappdata(local_FastICA_MAIN, 'sigTOOLSourceView');
    channels=getappdata(sigTOOLSourceView,'channels');
    % Update the channels
    source=clist(1);
    n=size(g_FastICA_ica_sig,1);
    len=length(channels);
    channels=vertcat(channels(:), cell(len,1));
    for k=1:n
        target=len+k;
        channels{target}=getData(channels{source}, start, stop);
        channels{target}.adc=adcarray(g_FastICA_ica_sig(k,:)',1,0);
        channels{target}.hdr.title=sprintf('IC%d',k);
        channels{target}.hdr.adc.Npoints=size(g_FastICA_ica_sig,2);
        channels{target}.hdr.adc.YLim=[min(g_FastICA_ica_sig(k,:)),...
            max(g_FastICA_ica_sig(k,:))];
        channels{target}.hdr.adc.Units='';
    end
    setappdata(sigTOOLSourceView,'channels',channels);
    % Refresh the channel manager
    scChannelManager(sigTOOLSourceView, true);
    % Include the new channel in the display
    scDataViewDrawChannelList(sigTOOLSourceView,...
        unique([getappdata(sigTOOLSourceView, 'ChannelList') (len:len+n)]));
end

if Save_File
        % Save the variable sR to file
    [a b]=fileparts(get(sigTOOLSourceView,'Name'));
    if isempty(a)
        % Use the system temp folder as default - usual
        a=tempdir();
    end
    vname=fullfile(a, ['FastICA_' b '.mat']);
    IC=g_FastICA_ica_sig; %#ok<*NASGU>
    A=g_FastICA_ica_A;
    W=g_FastICA_ica_W;
    whitesig=g_FastICA_white_sig;
    whiteningMatrix=g_FastICA_white_wm;
    dewhiteningMatrix=g_FastICA_white_dwm;
    E=g_FastICA_pca_E;
    D=g_FastICA_pca_D;
    save(vname, 'IC', 'A', 'W', 'whitesig', 'whiteningMatrix',...
        'dewhiteningMatrix', 'E', 'D');
    fprintf('FastICA results save to %s\n', vname);
end

if Save_MATLAB
    [dum suffix]=fileparts(get(sigTOOLSourceView, 'Name'));
    if isvarname(suffix)
        suffix=['_' suffix];
    else
        suffix='';
    end
    assignin('base',['IC' suffix],g_FastICA_ica_sig);
    assignin('base',['A' suffix],g_FastICA_ica_A);
    assignin('base',['W' suffix],g_FastICA_ica_W);
    assignin('base',['whitesig' suffix],g_FastICA_white_sig);
    assignin('base',['whiteningMatrix' suffix],g_FastICA_white_wm);
    assignin('base',['dewhiteningMatrix' suffix],g_FastICA_white_dwm);
    assignin('base',['E' suffix],g_FastICA_pca_E);
    assignin('base',['D' suffix],g_FastICA_pca_D);
end
 
return
end


