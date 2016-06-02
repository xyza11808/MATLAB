function varargout=menu_FastICA(varargin)
% menu_FastICA: gateway to the Interface_to_FastICA function
%
% Example:
% menu_FastICA(hObject)
%   This is a menu callback
%
% menu_FastICA calls Interface_to_FastICA which provides a sigTOOL inteface
% to the FastICA software of Hugo Gävert, Jarmo Hurri, Jaakko Särelä,
% and Aapo Hyvärinen
% 
% FastICA is copyright (c) Hugo Gävert, Jarmo Hurri, Jaakko Särelä, and Aapo Hyvärinen
%
% Interface_to_FastICA passes data to FastICA in double precision format.
%
% The results can be saved  by selecting the "Export to sigTOOL" button 
% that is added to the FastICA GUI. Note that these will be stored in RAM.
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
%

% Called as menu_FastICA(0)
if nargin==1 && varargin{1}==0
    varargout{1}=true;
    varargout{2}='FastICA';
    varargout{3}=[];
    return
end


[button fhandle]=gcbo;

h=jvDefaultPanel(fhandle, 'Title', 'sigTOOL Interface to FastICA',...
    'Position', [0.325 0.325 0.35 0.35],...
    'ChannelType', {'Continuous Waveform' 'Continuous Waveform'},...
    'ChannelLabels', {'First Waveform' 'Remaining Waveforms'},...
    'AckText', 'FastICA by Hugo Gavert, Jarmo Hurri, Jaakko Sarela, and Aapo Hyvarinen');
jvLinkChannelSelectors(h, 'synchro');
set(h{1}.ApplyToAll,'Enabled',0);
jvSetHelp(h, 'Independent Components Analysis');
h=jvAddFastICA(h);
h{2}.Saveresultstofile.setSelected(false);

if isempty(h)
    return
end

uiwait();

s=getappdata(fhandle,'sigTOOLjvvalues');

if isempty(s)
    return
end

clist=unique([s{1}.ChannelA(s{1}.ChannelA>0), s{1}.ChannelB(s{1}.ChannelB>0)]);

if isempty(clist) || numel(clist)<2
    warndlg('You must select multiple channels',...
        'sigTOOL: Interface to FastICA');
    return
end

% Note: no history recorded here. Use menu_Icasso for that
Interface_to_FastICA(fhandle,...
    clist,...
    s{1}.Start,...
    s{1}.Stop,...
    s{2}.SaveresultstosigTOOL,...
    s{2}.Saveresultstofile,...
    s{2}.SaveresultstoMATLAB);

return
end


 
