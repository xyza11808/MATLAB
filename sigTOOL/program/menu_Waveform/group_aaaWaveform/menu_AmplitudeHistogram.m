function varargout=menu_AmplitudeHistogram(varargin)
% menu_Average: gateway to the wvAmplitudeHistogram function
%
% Toolboxes required: None
%
% Author: Malcolm Lidierth 02/08
% Copyright © King’s College London 2008
%
% Acknowledgements:
% Revisions:


% Called as menu_PowerSpectra(0)
if nargin==1 && varargin{1}==0
    varargout{1}=true;
    varargout{2}='Amplitude Histogram';
    varargout{3}=[];
    return
end


[button fhandle]=gcbo;

    
h=jvDefaultPanel(fhandle, 'Title', 'Waveform Amplitude Histogram',...
    'ChannelType', {'Waveform' 'None'},...
    'ChannelLabels', {'Waveforms' ''});
if isempty(h)
    return
end
% Re-use the Channel B list for the bin width selection
h{1}.ChannelBLabel.setText('Number of bins');
h{1}.ChannelB.removeAllItems;
h{1}.ChannelB.addItem('10');
h{1}.ChannelB.addItem('20');
h{1}.ChannelB.addItem('50');
h{1}.ChannelB.addItem('100');
h{1}.ChannelB.addItem('200');
h{1}.ChannelB.addItem('500');
h{1}.ChannelB.setSelectedItem('100');
h{1}.ChannelB.setEnabled(true);
h{1}.ChannelB.Position(1)=h{1}.ChannelB.Position(1)+0.1;
h{1}.ChannelB.Position(3)=h{1}.ChannelB.Position(3)-0.2;
h{1}.ChannelBLabel.Position(1)=h{1}.ChannelBLabel.Position(1)+0.1;
h{1}.ChannelBLabel.Position(3)=h{1}.ChannelBLabel.Position(3)-0.2;
%h=jvAddAverage(h);
jvSetHelp(h, 'Waveform Amplitude.html');
uiwait();

s={getappdata(fhandle,'sigTOOLjvvalues')};



arglist={fhandle,...
    'Sources', s{1}.ChannelA,...
    'Start', s{1}.Start,...
    'Stop', s{1}.Stop,...
    'nbins', s{1}.ChannelB};
scExecute(@wvAmplitudeHistogram, arglist, s{1}.ApplyToAll)
return
end


 
