function varargout=menu_CreateRateChannel(varargin)
% menu_CreateRateChannel: gateway to the spRateHistogram function
%
% Example:
% menu_CreateRateChannel(hObejct, EventData)
%           menu callback function
%
% Toolboxes required: None
%
%--------------------------------------------------------------------------
% Author: Malcolm Lidierth 03/08
% Copyright © The author and King’s College London 2008-
%--------------------------------------------------------------------------
%
% Acknowledgements:
% Revisions:


% Called as menu_PowerSpectra(0)
if nargin==1 && varargin{1}==0
    varargout{1}=true;
    varargout{2}='Create Rate Channel';
    varargout{3}=[];
    return
end

% Main function

[button fhandle]=gcbo;

h=jvDefaultPanel(fhandle, 'Title', 'Create Rate Channel',...
    'ChannelType', {'Triggered' 'Empty'},...
    'ChannelLabels', {'Sources' 'Targets'});
if isempty(h)
    return
end
h=jvAddRateChannel(h);
jvSetHelp(h, 'Create Rate Channel');
uiwait();

s=getappdata(fhandle,'sigTOOLjvvalues');
if isempty(s)
    return
end
if any(s{1}.ChannelA<=0) || any(s{1}.ChannelB<=0) || length(s{1}.ChannelA)~=length(s{1}.ChannelB)
    warndlg('You must select a target channel for each source channel',...
        'sigTOOL: Create Rate Histogram');
    return
end

switch lower(s{end}.Window)
    case 'rectangular'
        w=ones(1, s{end}.Width);
    case 'gaussian'
        w=gausswindow(s{end}.Width);
    otherwise
        w=1;
end
w=w/sum(w);

arglist={fhandle,...
    'Sources', s{1}.ChannelA,...
    'Targets', s{1}.ChannelB,...
    'Start', s{1}.Start,...
    'Stop', s{1}.Stop,...
    'BinWidth', s{2}.BinWidth,...
    'Scaling', s{2}.Scaling,...
    'WindowCoeff', w};
    
scExecute(@spCreateRateChannel, arglist, s{1}.ApplyToAll)
return
end


 
