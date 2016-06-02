function varargout=menu_PlaySound(varargin)
% menu_PlaySound: menu gateway to the audio playback function scPlaySound
%
% Toolboxes required: None
%
% Author: Malcolm Lidierth 11/06
% Copyright © King’s College London 2006
%
% Acknowledgements:
% Revisions:


% Called as menu_PlaySound(0)
if nargin==1 && varargin{1}==0
    varargout{1}=true;
    varargout{2}='Play Sound';
    varargout{3}=[];
    return
end

[button fhandle]=gcbo;

% Select the channels to play

h=jvDefaultPanel(fhandle, 'Title', 'Play Sound', 'ChannelType', 'Continuous Waveform',...
    'AckText', 'sigTOOL: CORE function');
jvLinkChannelSelectors(h, 'Fs');
uiwait();
s=getappdata(fhandle,'sigTOOLjvvalues');
if isempty(s) || s.ChannelA==0 || (isempty(s.ChannelA) && isempty(s.ChannelB))
    return
end

% Do not use scExecute here, unlikely to be wanted
scPlaySound(fhandle, s.ChannelA, s.ChannelB, s.Start, s.Stop);


 
