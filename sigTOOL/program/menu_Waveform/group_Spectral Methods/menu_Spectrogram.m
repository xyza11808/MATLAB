function varargout=menu_Spectrogram(varargin)
%
% Toolboxes required: None
%
% Author: Malcolm Lidierth 11/06
% Copyright © King’s College London 2006
%
% Acknowledgements:
% Revisions:


% Called as menu_Spectrogram(0)
if nargin==1 && varargin{1}==0
    varargout{1}=true;
    varargout{2}='Spectrogram';
    varargout{3}=[];
    return
end

% Main function

[button fhandle]=gcbo;
h=jvDefaultPanel(fhandle, 'Title', 'Spectrogram',...
    'ChannelType', 'Waveform');
h=jvAddFFT(h);
jvSetHelp(h, mfilename(), 'Power Spectra (Continuous waveforms).html');
uiwait();

s=getappdata(fhandle,'sigTOOLjvvalues');
if isempty(s) || (sum(s{1}.ChannelA==0) && sum(s{1}.ChannelB==0))
    return
end
list=unique([s{1}.ChannelA, s{1}.ChannelB]);
list=list(list>0);

arglist={fhandle, 'ChannelList', list,...
        'Start', s{1}.Start,...
        'Stop', s{1}.Stop,...
        'WindowLength', s{2}.WindowLength,...
        'Overlap', s{2}.Overlap,...
        'OverlapMode', s{2}.OverlapMode,...
        'WindowType', s{2}.Window,...
        'Detrend', s{2}.Detrend,...
        'SpectrumMode', s{2}.SpectrumMode,...
        'SpectrogramFlag', 'image',...
        'Decimation', s{2}.Decimation};
scExecute(@wvPowerSpectra, arglist, s{1}.ApplyToAll);
return
end


 
