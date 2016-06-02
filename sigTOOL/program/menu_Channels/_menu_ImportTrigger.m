function varargout=menu_ImportTrigger(varargin)
% menu_ImportTrigger imports triggers
% 
% menu_ImportTrigger(hObject, EventData)
%     standard menu callback
%
% See scImportTrigger for details
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 11/06
% Copyright © The Author & King's College London 2006-
% -------------------------------------------------------------------------

if nargin==1 && varargin{1}==0
    varargout{1}=true;
    varargout{2}='Import Trigger';
    varargout{3}=[];
    return
end

[button fhandle]=gcbo;

h=jvDefaultPanel(fhandle, 'ChannelType', {'Triggered' 'Episodic'},...
    'ChannelLabels', {'Source' 'Target'});
h{1}.Start.setEnabled(false);
h{1}.Stop.setEnabled(false);
h{1}.ApplyToAll.setEnabled(false);

jvLinkChannelSelectors(h, 'Equal Epochs');
uiwait();

s=getappdata(fhandle, 'sigTOOLjvvalues');
if isempty(s) || s.ChannelA==0 || s.ChannelB==0
    return
end

channels=getappdata(fhandle, 'channels');
if size(channels{s.ChannelB}.tim, 2)==3
    answer=questdlg('Do you really want to overwrite the current trigger values',...
        'Import Trigger', 'Yes', 'No', 'No');
    if strcmpi(answer, 'no')
        return
    end
end
clear('channels');
arglist={fhandle, s.ChannelA, s.ChannelB};
scExecute(@scImportTrigger, arglist);
return
end

