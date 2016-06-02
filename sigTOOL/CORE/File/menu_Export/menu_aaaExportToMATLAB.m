function varargout=menu_aaaExportToMATLAB(varargin)
% menu_ExportToMATLAB exports data to the MATLAB base workspace
%
% Example:
% menu_ExportToMATLAB(hObject, EventData)
%   standadr menu callback
%
% Toolboxes required: None
%
% Author: Malcolm Lidierth 07/06
% Copyright © The Author & King's College London 2006
%
% Acknowledgements:
% Revisions:


% Called as menu_ExportToMATLAB(0)
if nargin==1 && varargin{1}==0
    varargout{1}=true;
    varargout{2}='To MATLAB';
    varargout{3}=[];
    return
end

[button, fhandle]=gcbo;
if strcmp(get(fhandle, 'Tag'), 'sigTOOL:DataView')
    % sigTOOL data view
    assignin('base', 'channels', getappdata(fhandle,'channels'));
elseif strcmp(get(fhandle, 'Tag'), 'sigTOOL:ResultView')
    % sigTOOL result view
    assignin('base', 'data', getappdata(fhandle,'data'));
end