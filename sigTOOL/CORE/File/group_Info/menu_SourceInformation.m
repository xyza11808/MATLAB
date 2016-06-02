function varargout=menu_SourceInformation(varargin)
%
% Toolboxes required: None
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 01/10
% Copyright © The Author & King's College London 2010-
% -------------------------------------------------------------------------
% Acknowledgements:
% Revisions:


% Called as menu_Information(0)
if nargin==1 && varargin{1}==0
    varargout{1}=true;
    varargout{2}='Source Information';
    varargout{3}=[];
    return
end

[button fhandle]=gcbo;

channels=getappdata(fhandle, 'channels');

if numel(unique(getSourceName(channels{:}, true)))==1 &&...
        numel(unique(getFileName(channels{:}, true)))==1
    [pname fname ext]=fileparts(channels{1}.hdr.source.name);
    s=load(fullfile(pname, [fname '.kcl']), 'FileSource', '-mat');
    if ~isempty(s)
        assignin('base', 'ans', s.FileSource.header);
        openvar('ans');
    end
else
    msgbox('Information not available or data from multiple sources', 'Source Info');
end

return
end
