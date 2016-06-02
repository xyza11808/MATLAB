function varargout=menu_Coherence(varargin)
% menu_Coherence: gateway to the wvCoherence function
%
% Toolboxes required: None
%
% Author: Malcolm Lidierth 11/06
% Copyright © King’s College London 2006-7
%
% Acknowledgements:
% Revisions:


% Called as menu_Coherence(0)
if nargin==1 && varargin{1}==0
    varargout{1}=true;
    varargout{2}='Coherence';
    varargout{3}=[];
    return
end

% Main function

[button fhandle]=gcbo;
h=jvDefaultPanel(fhandle, 'Title', 'Coherence',...
    'ChannelLabels', {'Reference' 'Source'},...
    'ChannelType', {'Continuous Waveform' 'Continuous Waveform'});
%jvLinkChannelSelectors(h, 'continuous');
h=jvAddCoherence(h);
jvSetHelp(h, mfilename());
uiwait();

s=getappdata(fhandle,'sigTOOLjvvalues');
if isempty(s) || (sum(s{1}.ChannelA==0) && sum(s{1}.ChannelB==0))
    return
end
s{1}.ChannelA=s{1}.ChannelA(s{1}.ChannelA>0);
s{1}.ChannelB=s{1}.ChannelB(s{1}.ChannelB>0);
list={s{1}.ChannelA, s{1}.ChannelB};


arglist={fhandle, 'ChannelList', list,...
        'Start', s{1}.Start,...
        'Stop', s{1}.Stop,...
        'WindowLength', s{2}.WindowLength,...
        'Overlap', s{2}.Overlap,...
        'WindowType', s{2}.Window,...
        'Detrend', s{2}.Detrend,...
        'Mode', s{2}.Mode}; 
scExecute(@wvCoherence, arglist, s{1}.ApplyToAll)
return
end


 
