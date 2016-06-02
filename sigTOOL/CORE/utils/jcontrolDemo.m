function jcontrolDemo()
% jcontrolDemo()
%
% Example:
% jcontrolDemo()
%
% 30.08.07 Revised for backwards compatability with MATLAB 7.01 onwards
disp(' ');
disp('Tested on R2007a: If you are using an older copy of MATLAB and this demo fails,');
disp('see README.TXT or http://www.mathworks.com/matlabcentral/fileexchange/loadFile.do?objectId=15580&objectType=FILE');
disp('for suggestions on modifying earlier javacomponent.m files');
disp(' ');
disp(' ');

% Make sure there is an open figure
gcf;
% Get the current L&F
LF=javax.swing.UIManager.getLookAndFeel();
% Available L&Fs
LFI=javax.swing.UIManager.getInstalledLookAndFeels;
for i=1:min(4,length(LFI))
    LF=[LF; LFI(i).getClassName]; %#ok<AGROW>
end
% Position matrix
pos=[0.05 0.05 0.28 0.28;...
    0.4 0.05 0.28 0.28;...
    0.05 0.38 0.28 0.28;...
    0.4 0.38 0.28 0.28;...
    0.05 1-0.3 0.28 0.28];

% Do not need this here but could prevent typecastign error if h was
% already declared when we set h(1) below
h=jcontrol();

% Draw up to 5 JPanels and populate them with  a few components
for i=1:6:length(LF)*6;
    % Set L&F
    javax.swing.UIManager.setLookAndFeel(LF(floor(i/6)+1));
    % Create a panel
    h(i)=jcontrol(gcf,'javax.swing.JPanel',...
        'Units','normalized',...
        'Position',pos(floor(i/6)+1,:));
    % A ComboBox
    h(i+1)=jcontrol(h(i),'javax.swing.JComboBox',...
        'Position',[0.1 0.8 0.8 0.1]);
    h(i+1).addItem('Item1');
    h(i+1).addItem('Item2');
    % A CheckBox
    h(i+2)=jcontrol(h(i),'javax.swing.JCheckBox',...
        'Position',[0.1 0.6 0.7 0.1],...
        'Text','My check box');
    % A slider
    h(i+3)=jcontrol(h(i),'javax.swing.JSlider',...
        'Position',[0.1 0.3 0.8 0.2],...
            'MajorTickSpacing',20,...
    'PaintTicks',1,...
        'ToolTipText','My Slider');
    % A text label
    h(i+4)=jcontrol(h(i),'javax.swing.JLabel',...
        'Position',[0.0 0.9 0.99 0.1]);
    h(i+4).setText(0);%h(i+4).setText(char(LF(floor(i/6)+1)));
    % Finally the cancel button. Do this last so it superimposes on the
    % other controls
        h(i+5)=jcontrol(h(i),'javax.swing.JButton',...
        'Position',[0.5 0.1 0.4 0.1],...
        'Text','Cancel',...
        'ToolTipText','Click to close panel',...
        'ActionPerformedCallback',{@Cancel, h(i)});
    % Message to the MATLAB command line
    disp(LF(floor(i/6)+1));
    %Now we could tidy up - set units to character then set width of text
    %fields etc - and add a ResizeFcn to h(1).hgcontainer
end
% Set the L&F back to the original
javax.swing.UIManager.setLookAndFeel(LF(1))
% Bring up the figure
figure(gcf);
return
end

function Cancel(hObject, EventData, parent) %#ok<INUSL>
delete(parent);
return
end