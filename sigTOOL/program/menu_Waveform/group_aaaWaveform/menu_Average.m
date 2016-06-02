function varargout=menu_Average(varargin)
% menu_Average: gateway to the wvAverage function
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
    varargout{2}='Average';
    varargout{3}=[];
    return
end

% Main callback
% Note this is shared with the Spike Train Toolkit spike-triggered
% averaging function

[button fhandle]=gcbo;

lab=get(button, 'Label');
if strcmpi(lab, 'Spike-Triggered Average')
    PanelTitle=lab;
else
    PanelTitle='Waveform Average';
end
    
h=jvDefaultPanel(fhandle, 'Title', PanelTitle,...
    'ChannelType', {'All' 'Waveform'},...
    'ChannelLabels', {'Trigger' 'Waveforms'},...
    'AckText', 'Acknowledgement text placed here');
if isempty(h)
    return
end
h=jvAddAverage(h);


if strcmpi(lab, 'Spike-Triggered Average')
    h{2}.Retrigger.setSelected(true);
    h{2}.Overlap.setEnabled(false);
else
    h{2}.Retrigger.setSelected(false);
end
jvSetHelp(h, 'Waveform Average.html');
uiwait();

s=getappdata(fhandle,'sigTOOLjvvalues');
if isempty(s)
    return
end
if any(s{1}.ChannelA<=0) || any(s{1}.ChannelB<=0)
    warndlg('You must select a trigger channel and at least one source channel',...
        'sigTOOL: Waveform Average');
    return
end


switch s{2}.Method
    case 'mean'
        % Standard deviation
        errormethod='std';
    case 'median'
        % Percentile
        try
            prctile(0, 99)
            errormethod='prctile';
        catch
            % No toolbox
            errormethod='none';
        end
end


arglist={fhandle,...
    'Trigger', s{1}.ChannelA,...
    'Sources', s{1}.ChannelB,...
    'Start', s{1}.Start,...
    'Stop', s{1}.Stop,...
    'Duration', s{2}.Duration,...
    'PreTime', s{2}.PreTime,...
    'SweepsPerAverage', s{2}.Sweepsperaverage,...
    'Overlap', s{2}.Overlap,...
    'Retrigger', s{2}.Retrigger,...
    'DCFlag', s{2}.SubtractDC,...
    'Method', s{2}.Method,...
    'ErrType', errormethod,...
    'Pairwise', s{2}.Pairwise};
scExecute(@wvAverage, arglist, s{1}.ApplyToAll)
return
end


 
