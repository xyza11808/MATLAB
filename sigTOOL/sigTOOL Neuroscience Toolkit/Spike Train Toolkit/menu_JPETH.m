function varargout=menu_JPETH(varargin)
% menu_JPETH: gateway to the spJPSTH function
%
% menu_JPETH is a uimenu callback
%
% Example:
% varargout=menu_JPETH(hObject, EventData)
% 
% menu_JPETH is used also by the Event Auto- and Cross- Correlation menus
% 
% Toolboxes required: None
%
% Author: Malcolm Lidierth 12/08
% Copyright © King’s College London 2008-
%
% Acknowledgements:
% Revisions:


% Called as menu_JPETH(0)
if nargin==1 && varargin{1}==0
    varargout{1}=true;
    varargout{2}='Joint Peri-Event Time Histogram';
    varargout{3}=[];
    return
end

% Main function

[button fhandle]=gcbo;

h=jvDefaultPanel(fhandle, 'Title', 'Joint peri-event time histogram',...
    'ChannelType', {'Triggered' 'Triggered'},...
    'ChannelLabels', {'Triggers' 'Sources'});
h=jvAddJPETH(h);
jvSetHelp(h, 'Joint peri event time histogram');
if isempty(h)
    return
end

uiwait();

s=getappdata(fhandle,'sigTOOLjvvalues');
if isempty(s)
    return
end

if isnumeric(s{2}.FilterWidth)
    filter=ones(s{2}.FilterWidth);
    filter=filter/sum(filter(:));
else
    % "None" selected
    filter=[];
end

arglist={fhandle,...
    'Trigger', s{1}.ChannelA,...
    'Sources', s{1}.ChannelB,...
    'Start', s{1}.Start,...
    'Stop', s{1}.Stop,...
    'Duration', s{2}.Duration,...
    'BinWidth', s{2}.BinWidth,...
    'PreTime', s{2}.PreTime,...
    'Filter', filter,...
    'Symmetric', s{2}.Symmetric,...
    'Mode', s{2}.Mode};

scExecute(@spJPETH, arglist, s{1}.ApplyToAll)
return
end



