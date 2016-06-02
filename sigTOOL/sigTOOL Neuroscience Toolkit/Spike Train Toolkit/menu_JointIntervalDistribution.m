function varargout=menu_JointIntervalDistribution(varargin)
% menu_JointIntervalDistribution: gateway function
%
% Toolboxes required: None
%
% Author: Malcolm Lidierth 11/07
% Copyright © King’s College London 2007
%
% Acknowledgements:
% Revisions:


% Called from dir2menu
if nargin==1 && varargin{1}==0
    varargout{1}=true;
    varargout{2}='Joint Interval Distribution';
    varargout{3}=[];
    return
end

% Main function

[button fhandle]=gcbo;
h=jvDefaultPanel(fhandle, 'Title', 'Joint Interval Distribution',...
    'ChannelType', {'All' 'All'});

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
h{1}.ChannelBLabel.Position(3)=h{1}.ChannelBLabel.Position(3)-0.2; %#ok<NASGU>
jvSetHelp(h, 'Joint Interval Distribution');
uiwait();

s=getappdata(fhandle,'sigTOOLjvvalues');
if isempty(s) || (length(s.ChannelA)==1 && s.ChannelA==0)
    return
end

s={s};
arglist={fhandle,...
    'Sources', s{1}.ChannelA,...
    'Start', s{1}.Start,...
    'Stop', s{1}.Stop,...
    'BinWidth', s{1}.ChannelB};
scExecute(@spJointIntervalDistribution, arglist, s{1}.ApplyToAll)
return
end


 
