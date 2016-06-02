function varargout=menu_ExportToEPS(varargin)
% menu_ExportToEPS sigTOOL menu callback: exports a EPS format
% graphic
% 
% Example:
% menu_ExportToEPS(hObject, EventData)
%       standard callback
%
%
% This is a callback designed specifically for sigTOOL data views
%
%--------------------------------------------------------------------------
% Author: Malcolm Lidierth 07/06
% Copyright © The Author & King's College London 2006-
%--------------------------------------------------------------------------

% Setup
if nargin==1 && varargin{1}==0
    varargout{1}=true;
    varargout{2}='EPS';
    varargout{3}=[];
    return
end

[button, handle]=gcbo;
scExportFigure(handle, 'eps');
return
end
