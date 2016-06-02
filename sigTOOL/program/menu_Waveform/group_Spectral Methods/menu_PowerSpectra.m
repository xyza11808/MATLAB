function varargout=menu_PowerSpectra(varargin)
% menu_PowerSpectra: gateway to the wvPowerSpectralDensity function
%
% Toolboxes required: None
%
% Author: Malcolm Lidierth 11/06
% Copyright © King’s College London 2006
%
% Acknowledgements:
% Revisions:


% Called as menu_PowerSpectra(0)
if nargin==1 && varargin{1}==0
    varargout{1}=true;
    varargout{2}='Power Spectra';
    varargout{3}=[];
    return
end

% Main function

[button fhandle]=gcbo;
h=jvDefaultPanel(fhandle, 'Title', 'Power Spectra',...
    'ChannelType', 'Waveform');
h=jvAddFFT(h);
jvSetHelp(h, 'Power Spectra (Continuous waveforms).html');
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
        'SpectrogramFlag', false,...
        'Decimation', s{2}.Decimation}; 
scExecute(@wvPowerSpectra, arglist, s{1}.ApplyToAll)
return
end


 
