function varargout=menu_ChannelViewer(varargin)
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
    varargout{2}='Channel Viewer';
    varargout{3}=[];
    return
end

[button fhandle]=gcbo;
cvSetup(fhandle);


 
