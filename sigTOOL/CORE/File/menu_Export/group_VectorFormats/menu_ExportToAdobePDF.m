function varargout=menu_ExportToAdobePDF(varargin)
% menu_ExportToAdobePDF sigTOOL menu callback: exports a PDF format
% graphic
% 
% Example:
% menu_ExportToAdobePDF(hObject, EventData)
%       standard callback
%
%
% This is a callback designed specifically for sigTOOL data views
%
%--------------------------------------------------------------------------
% Author: Malcolm Lidierth 07/06
% Copyright © The Author & King's College London 2006-
%--------------------------------------------------------------------------


if nargin==1 && varargin{1}==0
    varargout{1}=true;
    varargout{2}='Adobe PDF';
    varargout{3}=[];
    return
end

[button, handle]=gcbo;
scExportFigure(handle, 'pdf');
end