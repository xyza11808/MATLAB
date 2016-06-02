function varargout=Frequencygram(varargin)
% menu_Frequencygram: gateway to the spPeriEventFrequencygram function
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
    varargout{2}='Peri-event Frequencygram';
    varargout{3}=[];
    return
end

% Main function

[button fhandle]=gcbo;

h=jvDefaultPanel(fhandle, 'Title', 'Peri-event Frequencygram',...
    'ChannelType', {'Triggered' 'Triggered'},...
    'ChannelLabels', {'Triggers' 'Sources'});
if isempty(h)
    return
end
h=jvAddFrequencygram(h);
h{2}.Retrigger.setSelected(true);
jvSetHelp(h, 'peri event frequencygram');

uiwait();

s=getappdata(fhandle,'sigTOOLjvvalues');
if isempty(s)
    return
end
if any(s{1}.ChannelA<=0) || any(s{1}.ChannelB<=0)
    warndlg('You must select a trigger channel and at least one source channel');
    return
end



arglist={fhandle,...
    'Trigger', s{1}.ChannelA,...
    'Sources', s{1}.ChannelB,...
    'Start', s{1}.Start,...
    'Stop', s{1}.Stop,...
    'Duration', s{2}.Duration,...
    'PreTime', s{2}.PreTime,...
    'Retrigger', s{2}.Retrigger};
scExecute(@spPeriEventFrequency, arglist, s{1}.ApplyToAll)
return
end


 
