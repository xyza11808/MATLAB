function varargout=menu_PhaseRaster(varargin)
% menu_PhaseRaster: gateway to the spPhaseRatser function
%
% Toolboxes required: None
%
% Author: Malcolm Lidierth 11/06
% Copyright © King’s College London 2006
%
% Acknowledgements:
% Revisions:


% Called as menu_PhaseRaster(0)
if nargin==1 && varargin{1}==0
    varargout{1}=true;
    varargout{2}='Phase Raster';
    varargout{3}=[];
    return
end

% Main function

[button fhandle]=gcbo;

h=jvDefaultPanel(fhandle, 'Title', 'Phase Raster',...
    'ChannelType', {'Triggered' 'Triggered'},...
    'ChannelLabels', {'Triggers' 'Sources'});
if isempty(h)
    return
end
h=jvAddPhaseRaster(h);
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
    'PreTime', s{2}.PreTime};
scExecute(@spPhaseRaster, arglist, s{1}.ApplyToAll)
return
end


 
