function h=jvAddRateChannel(h)
% jvAddRateChannel addpanel function
% 
% Example:
% h=jvAddRateChannel(h)
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 11/07
% Copyright © The Author & King's College London 2007-
% -------------------------------------------------------------------------


Height=0.09;
Top=0.75;

h=jvAddPanel(h, 'Title', 'Details',...
    'dimension', 0.6);



h=jvElement(h{end},'Component', 'javax.swing.JComboBox',...
    'Position',[0.1 Top 0.8 Height],...
    'DisplayList', {'0.001' '0.002' '0.005' '0.01' '0.02'},...
    'Label', 'Bin Width(s)',...
    'ToolTipText', 'Histogram Bin Width (s)');

h=jvElement(h{end}, 'Component', 'javax.swing.JComboBox',...
    'Position',[0.1 Top-(2*Height) 0.8 Height],...
    'DisplayList', {'Count' 'Rate'},...
    'Label', 'Scaling',...
    'ToolTipText', 'Scaling of result');

% Create an empty cell for the new handles...
h{end+1}={};
% ... and add the new panel to it
p=get(h{2}.Panel,'uipanel');
p=uipanel('Parent', p,...
     'Units', 'normalized',...
    'Position', [0.1 0.01 0.8 0.55]);
h{end}.Panel=jcontrol(p,'javax.swing.JPanel',...
    'Units', 'normalized',...
    'Position', [0 0 1 1],...
    'Border',javax.swing.BorderFactory.createTitledBorder('Smoothing'));

% Update figure application data area with the new handles structure
setappdata(get(h{1}.Panel,'Parent'),'sigTOOLjvhandles',h);

h=jvElement(h{end},'Component', 'javax.swing.JComboBox',...
    'Position',[0.1 0.55 0.8 .15],...
    'DisplayList', {'Gaussian' 'Rectangular' 'None'},...
    'Label', 'Window',...
    'ToolTipText', 'Smoothing window type');

h=jvElement(h{end},'Component', 'javax.swing.JComboBox',...
    'Position',[0.1 0.25 0.8 .15],...
    'DisplayList', {'3' '5' '7' '9' '11'},...
    'Label', 'Width',...
    'ToolTipText', 'Smoothing window type');
h{end}.Width.setSelectedIndex(1);

h=jvElement(h{end},'Component', 'javax.swing.JButton',...
    'Position',[0.3 0.05 0.5 .15],...
    'DisplayList', '',...
    'Label', 'View',...
    'ToolTipText', 'View window');
set(h{end}.View, 'MouseClickedCallback', {@ViewWindow, h{end}.Window, h{end}.Width});


return
end


function ViewWindow(hObject, EventData, hwin, hwid) %#ok<INUSL>
width=str2double(hwid.getSelectedItem());
switch lower(char(hwin.getSelectedItem()))
    case 'rectangular'
        w=ones(width,1);
    case 'gaussian'
        w=gausswindow(width);
end
w=w/sum(w);
try
    wvtool(w);
catch %#ok<CTCH>
    h=figure();
    set(h, 'Name', 'Window Details');
    ax=subplot(1,2,1);
    plot(1:length(w), w);
    set(ax, 'XLim', [1 length(w)]);
    set(ax, 'YLim', [0 1]);
    title('Time Domain');
    ylabel('Amplitude');
    xlabel('Samples');
    grid('on');
    ax=subplot(1,2,2);
    fb=(0:2*pi/512:2*pi)/(2*pi);
    mg=10*log10(abs(fft(w,1024)).^2)';
    plot(fb(1:512), mg(1:512));
    set(ax, 'XLim', [0 1]);
    title('Frequency Domain');
    ylabel('Magnitude (dB)');
    xlabel('Normalized Frequency (x\pi rad/sample)');
    grid('on');
end
return
end
        
