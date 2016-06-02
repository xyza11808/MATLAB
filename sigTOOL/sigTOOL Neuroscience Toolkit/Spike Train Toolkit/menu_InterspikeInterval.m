function varargout=menu_InterspikeInterval(varargin)
% menu_ISIH: gateway to the wvPowerSpectralDensity function
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
    varargout{2}='Interspike Interval Distribution';
    varargout{3}=[];
    return
end

% Main function

[button fhandle]=gcbo;
h=jvDefaultPanel(fhandle, 'Title', 'Interspike Interval Distribution',...
    'ChannelType', {'All' 'none'});

% Re-use the Channel B list for the bin width selection
h{1}.ChannelBLabel.setText('Bin Width (ms)');
h{1}.ChannelB.removeAllItems;
h{1}.ChannelB.addItem('1');
h{1}.ChannelB.addItem('2');
h{1}.ChannelB.addItem('5');
h{1}.ChannelB.addItem('10');
h{1}.ChannelB.setEnabled(true);
h{1}.ChannelB.Position(1)=h{1}.ChannelB.Position(1)+0.1;
h{1}.ChannelB.Position(3)=h{1}.ChannelB.Position(3)-0.2;
h{1}.ChannelBLabel.Position(1)=h{1}.ChannelBLabel.Position(1)+0.1;
h{1}.ChannelBLabel.Position(3)=h{1}.ChannelBLabel.Position(3)-0.2;

jvSetHelp(h, 'Interspike interval histogram');
if isempty(h)
    return
end
% jvSetHelp(h, 'Waveform Average.html');
uiwait();

s=getappdata(fhandle,'sigTOOLjvvalues');
if isempty(s)
    return
end

s={s};
arglist={fhandle,...
    'Sources', s{1}.ChannelA,...
    'Start', s{1}.Start,...
    'Stop', s{1}.Stop,...
    'BinWidth', s{1}.ChannelB/1000};
scExecute(@spInterspikeInterval, arglist, s{1}.ApplyToAll)
return
end


 
