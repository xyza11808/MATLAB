function varargout=menu_CurrentSourceDensity(varargin)
%
% Acknowledgements:
% Revisions:


% Called as menu_PowerSpectra(0)
if nargin==1 && varargin{1}==0
    varargout{1}=true;
    varargout{2}='Current Source Density';
    varargout{3}=[];
    return
end

% Main function

[button fhandle]=gcbo;
h=jvDefaultPanel(fhandle, 'Title', '1D Current Source Density',...
    'ChannelType', {'All' 'Waveform'},...
    'ChannelLabels', {'Trigger' 'Waveforms'});
if isempty(h)
    return
end
h=jvAddCurrentSourceDensity(h);
h{2}.Retrigger.setSelected(false);
jvSetHelp(h, 'Current Source Density.html');
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
    'Overlap', 0,...
    'Retrigger', false,...
    'DCFlag', s{2}.SubtractDC,...
    'Method', s{2}.Method,...
    'ErrType', 'none',...
    'Spacing', s{2}.Spacing};
scExecute(@wvCurrentSourceDensity, arglist, s{1}.ApplyToAll)
return
end


 
