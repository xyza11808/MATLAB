function sR=Interface_to_Icasso(fhandle, clist, start, stop, Mode, Iter, NComp, Save_sigTOOL, Save_File, Save_MATLAB, varargin)
% Interface_to_Icasso provides a sigTOOL inteface to the Icasso software
% of Johan Himberg
%
% Icassi is copyright (c) Johan Himberg
% and uses FastICA
% FastICA  is copyright (c) Hugo Gävert, Jarmo Hurri, Jaakko Särelä, and Aapo Hyvärinen
%
% Example:
% sR=Interface_to_Icasso(fhandle, clist, start, stop, Approach, Iter, NComp,...
%           Save_sigTOOL, Save_File, Save_MATLAB)
% sR=Interface_to_Icasso(fhandle, clist, start, stop, Approach, Iter, NComp,...
%           Save_sigTOOL, Save_File, Save_MATLAB, Param1, Value1,.....)
% where
%       fhandle         is the handle of sigTOOL data view
%       clist           is a list of continuous waveforn channels on which
%                       to perform the independent components analysis
%       start           start time for analysis (in seconds)
%       stop            stop time for analysis (in seconds)
%       Mode            'randinit', 'bootstrap' or both - sets mode for
%                       Icasso
%       Iter            number of iterations (of FastICA)
%       NComp           number of components to return
%       Save_sigTOOL    logical flag, if true save independent components
%                       to sigTOOL as new channels: the order of the
%                       components will be set according to the values of
%                       Iq returned by IcassoResult
%       Save_File       logical flag, if true save Icasso result structure
%                       to MAT-file
%       Save_MATLAB     logical flag, if true save Icasso result structure
%                       to base workspace
%
% Optional Param/Value pairs represent optional arguments to IcassoEst
% which will be passed to FastICA.
% 
% If requested, the function will return the Icasso result structure in sR
%
% Interface_to_Icasso passes data to FastICA in double precision format.
%
%
% For an introduction to independent components analysis and a description
% of Iccaso and the FastICA software visit the FastICA website at:
%           http://www.cis.hut.fi/projects/ica/fastica/
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 11/08
% Copyright © The Author & King's College London 2008-
% -------------------------------------------------------------------------


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

% Process first channels - pre-allocate x
thischan=getData(channels{clist(1)}, start, stop);
x=zeros(length(clist),size(thischan.adc,1));
x(1,:)=thischan.adc(1:end)';
% Remaining channels
for j=2:length(clist)
    thischan=getData(channels{clist(j)}, start, stop);
    x(j,:)=thischan.adc(1:end)';
end

commandwindow();
drawnow();
disp('-----------------sigTOOL is running Icasso----------------------');
disp('--------------Icasso software by Johan Himberg------------------');
disp('----------see http://www.cis.hut.fi/projects/ica/fastica/-------');

% Run Icasso
sR=icassoEst(Mode, x, Iter, varargin{:});
disp('---------------------Generate the stats-------------------------');

% Generate stats
sR=icassoExp(sR);

disp('--------------Icasso software by Johan Himberg------------------');
disp('FastICA by Hugo Gävert, Jarmo Hurri, Jaakko Särelä and Aapo Hyvärinen');
disp('----------see http://www.cis.hut.fi/projects/ica/fastica/-------');

if Save_sigTOOL
    fprintf('\nCopying to sigTOOL\n');
    
    % Reduce NComp if number of ICs too few
    n=size(sR.cluster.partition,1);
    if n<NComp
        NComp=n;
        fprintf('Reducing number of returned ICs to %d\n', NComp);
    end
   
    % Get results
    [Iq, A, W, S]=icassoResult(sR,NComp);

    % Pass independent components back to sigTOOL - sorted by Iq
    source=clist(1);
    len=length(channels);
    channels=vertcat(channels, cell(NComp,1));

    % Pass them back sorted by Iq - clusters containing single items are
    % given an Iq of NaN so put force these to be last
    Iq2=Iq;
    Iq2(isnan(Iq))=-Inf;
    [order idx]=sort(Iq2,'descend');
    for k=1:NComp
        target=len+k;
        channels{target}=getData(channels{source}, start, stop);
        channels{target}.adc=adcarray(S(idx(k),:)',1,0);
        channels{target}.hdr.title=sprintf('IC%d**',k);
        channels{target}.hdr.adc.Npoints=size(S,2);
        fprintf('IC%d: Copying cluster %d to channel %d Iq=%g\n', k, idx(k), target, Iq(idx(k)));
        channels{target}.hdr.adc.YLim=[min(S(idx(k),:)), max(S(idx(k),:))];
        channels{target}.hdr.adc.Units='';
    end
    
    setappdata(fhandle,'channels',channels);
    % Refresh the channel manager
    scChannelManager(fhandle, true);
    % Include the new channel in the display
    scDataViewDrawChannelList(fhandle,...
        unique([getappdata(fhandle, 'ChannelList') (len:len+NComp)]));
end

if Save_File
    % Save the variable sR to file
    [a b]=fileparts(get(fhandle,'Name'));
    if isempty(a)
        % Use the system temp folder as default - usual
        a=tempdir();
    end
    vname=fullfile(a, ['Icasso_' b '.mat']);
    save(vname, 'sR');
    fprintf('----Icasso results saved to "%s"----\n', vname);
end

if Save_MATLAB
    try
        % Save result to base workspace - remember this will not work in debug
        % mode
        [a b]=fileparts(get(fhandle,'Name'));
        vname=['Icasso_' b];
        assignin('base',vname, sR);
    catch %#ok<CTCH>
        % May have invalid characters in name above, so...
        vname='Icasso';
        assignin('base',vname, sR);
    end
    fprintf('----Icasso results saved to "%s" in base workspace----\n', vname);
end

disp('----------------------------------------------------------------');



return
end



