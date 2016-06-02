function varargout=menu_PETH(varargin)
% menu_PETH: gateway to the spEventCorrelation function
%
% menu_PETH is a uimenu callback
%
% Example:
% varargout=menu_PETH(hObject, EventData)
% 
% menu_PETH is used also by the Event Auto- and Cross- Correlation menus
% 
% Toolboxes required: None
%
% Author: Malcolm Lidierth 11/06
% Copyright © King’s College London 2006
%
% Acknowledgements:
% Revisions:


% Called as menu_PETH(0)
if nargin==1 && varargin{1}==0
    varargout{1}=true;
    varargout{2}='Peri-event Time Histogram';
    varargout{3}=[];
    return
end

% Main function

[button fhandle]=gcbo;
AutoFlag=false;
switch get(button, 'Label')
    case 'Peri-event Time Histogram'
        str='Peri-event Time Histogram';
        retrig=false;
        helpfile='Peri event time histogram';
    case 'Event Cross Correlation'
        str='Event Cross Correlation';
        retrig=true;
        helpfile='Event crosscorrelation';
    case 'Event Auto-Correlation'
        str='Event Auto-Correlation';
        retrig=true;
        AutoFlag=true;
        helpfile='Event Autocorrelation';
end

h=jvDefaultPanel(fhandle, 'Title', str,...
    'ChannelType', {'Triggered' 'Triggered'},...
    'ChannelLabels', {'Triggers' 'Sources'});
if isempty(h)
    return
end
h=jvAddPETH(h);
if ~isempty(helpfile)
    jvSetHelp(h, helpfile);
end
if AutoFlag==true
    % Call to setEnabled may be in queue so flush it first
    drawnow();
    h{1}.ChannelB.setEnabled(0);
end

h{2}.Retrigger.setSelected(retrig);
uiwait();

s=getappdata(fhandle,'sigTOOLjvvalues');
if isempty(s)
    return
end

if AutoFlag==false
    if any(s{1}.ChannelA<=0) || any(s{1}.ChannelB<=0)
        warndlg('You must select a trigger channel and at least one source channel',...
            'sigTOOL: Peri-event Time Histogram');
        return
    end
else
    s{1}.ChannelB=[];
end


arglist={fhandle,...
    'Trigger', s{1}.ChannelA,...
    'Sources', s{1}.ChannelB,...
    'Start', s{1}.Start,...
    'Stop', s{1}.Stop,...
    'Duration', s{2}.Duration,...
    'BinWidth', s{2}.BinWidth,...
    'PreTime', s{2}.PreTime,...
    'SweepsPerAverage', s{2}.Sweepsperaverage,...
    'Retrigger', s{2}.Retrigger};
scExecute(@spEventCorrelation, arglist, s{1}.ApplyToAll)
return
end



