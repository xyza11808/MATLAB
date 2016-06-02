function varargout=menu_PhaseCorrelation(varargin)
% menu_PhaseCorrelation: gateway to the spPhaseCorrelation function
%
% menu_PhaseCorrelation is a uimenu callback
%
% Example:
% varargout=menu_PhaseCorrelation(hObject, EventData)
% 
% 
% Toolboxes required: None
%
% Author: Malcolm Lidierth 08/08
% Copyright © King’s College London 2008
%
% Acknowledgements:
% Revisions:


% Called as menu_PETH(0)
if nargin==1 && varargin{1}==0
    varargout{1}=true;
    varargout{2}='Phase Correlation';
    varargout{3}=[];
    return
end

% Main function

[button fhandle]=gcbo;

h=jvDefaultPanel(fhandle, 'Title', 'Phase Histogram',...
    'ChannelType', {'Triggered' 'Triggered'},...
    'ChannelLabels', {'Triggers' 'Sources'});
if isempty(h)
    return
end
h=jvAddPhaseHistogram(h);
jvSetHelp(h, 'Phase Correlation');


uiwait();

s=getappdata(fhandle,'sigTOOLjvvalues');
if isempty(s)
    return
end

    if any(s{1}.ChannelA<=0) || any(s{1}.ChannelB<=0)
        warndlg('You must select a trigger channel and at least one source channel',...
            'sigTOOL: Peri-event Time Histogram');
        return
    end



arglist={fhandle,...
    'Trigger', s{1}.ChannelA,...
    'Sources', s{1}.ChannelB,...
    'Start', s{1}.Start,...
    'Stop', s{1}.Stop,...
    'Duration', s{2}.Duration,...
    'BinWidth', s{2}.BinWidth,...
    'PreTime', s{2}.PreTime,...
    'SweepsPerAverage', s{2}.Sweepsperaverage};
scExecute(@spPhaseCorrelation, arglist, s{1}.ApplyToAll)
return
end



