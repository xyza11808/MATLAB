function varargout=menu_Autocorrelation(varargin)
% menu_Autocorrelation: gateway to the wvCorrelation function
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
    varargout{2}='Autocorrelation';
    varargout{3}=[];
    return
end


% User Menu
[button fhandle]=gcbo;
h=jvDefaultPanel(fhandle, 'Title', 'Autocorrelation',...
    'ChannelType', 'Continuous Waveform',...
    'ChannelLabels', {'Source' ''});
h=jvAddCorrelation(h);
jvSetHelp(h, mfilename(), 'Waveform Correlation');
%h{1}.ChannelB.setEnabled(false);
uiwait();


s=getappdata(fhandle,'sigTOOLjvvalues');
if isempty(s) || sum(s{1}.ChannelA)==0
    return
end
s{1}.ChannelA=s{1}.ChannelA(s{1}.ChannelA>0);

arglist={fhandle, 'Refs', s{1}.ChannelA,...
        'Sources', [],...
        'Start', s{1}.Start,...
        'Stop', s{1}.Stop,...
        'MaximumLag', s{2}.MaximumLag,...
        'RemoveDC', s{2}.RemoveDC,...
        'MaxBlockSize', 2^s{2}.MaxBlockSize,...
        'ScaleMode', s{2}.Scaling};
scExecute(@wvCorrelation, arglist, s{1}.ApplyToAll)
return
end


 
