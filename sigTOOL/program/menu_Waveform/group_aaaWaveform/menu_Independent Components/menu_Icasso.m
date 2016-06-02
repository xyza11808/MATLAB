function varargout=menu_Icasso(varargin)
% menu_FastICA: gateway to the Interface_to_Icasso function
%
% Example:
% menu_Icasso(hObject)
%   This is a menu callback
%
% menu_Icasso calls Interface_to_Icasso which provides a sigTOOL inteface
% to the Icasso software of Johan Himberg
%
% Icassi is copyright (c) Johan Himberg
% and uses FastICA
% FastICA  is copyright (c) Hugo Gävert, Jarmo Hurri, Jaakko Särelä, and
% Aapo Hyvärinen

% Interface_to_Icasso passes data to FastICA in double precision format.
%
%
% For an introduction to independent components analysis and a description
% of the FastICA software visit the FastICA website at:
%           http://www.cis.hut.fi/projects/ica/fastica/
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 11/08
% Copyright © The Author & King's College London 2008-
% -------------------------------------------------------------------------
%

% Called as menu_Icasso(0)
if nargin==1 && varargin{1}==0
    varargout{1}=true;
    varargout{2}='Icasso';
    varargout{3}=[];
    return
end


[button fhandle]=gcbo;
    
% GUI
h=jvDefaultPanel(fhandle, 'Title', 'Interface to FastICA',...
    'Position', [0.325 0.325 0.35 0.35],...
    'ChannelType', {'Continuous Waveform' 'Continuous Waveform'},...
    'ChannelLabels', {'First Waveform' 'Remaining Waveforms'},...
    'AckText', 'Icasso by Johan Himberg');
jvLinkChannelSelectors(h, 'synchro');
jvSetHelp(h, 'Independent Components Analysis');
h=jvAddIcasso(h);
h{2}.Saveresultstofile.setSelected(false);

if isempty(h)
    return
end

uiwait();

s=getappdata(fhandle,'sigTOOLjvvalues');

if isempty(s)
    return
end

% Combine A and B lists
clist=unique([s{1}.ChannelA(s{1}.ChannelA>0), s{1}.ChannelB(s{1}.ChannelB>0)]);

if strcmpi(s{2}.Numberofcomponents,'default')
    s{2}.Numberofcomponents=length(clist);
end


% Must have more than 1 signal
if isempty(clist) || numel(clist)<2
    warndlg('You must select multiple channels',...
        'sigTOOL: Interface to Icasso');
    return
end

% Interface to FastICA
eval(sprintf('varg={%s}',s{2}.FastICAoptionalarguments));
arglist={fhandle,...
     clist,...
     s{1}.Start,...
     s{1}.Stop,...
     s{2}.Mode,...
     s{2}.Iterations,...
     s{2}.Numberofcomponents,...
     s{2}.SaveresultstosigTOOL,...
     s{2}.Saveresultstofile,...
     s{2}.SaveresultstoMATLAB,...
     varg{:}}; %#ok<USENS>
     
scExecute(@Interface_to_Icasso, arglist, s{1}.ApplyToAll);

return
end


 
