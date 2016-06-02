function varargout=external_SendToFigure(varargin)
% external_SendToFigure sets up the export menu for a figure
% 
% Example
% varargout=external_SendToFigure(varargin)
%     is called be dir2menu. Not user callable
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 11/07
% Copyright © The Author & King's College London 2007-
% -------------------------------------------------------------------------
folder=fileparts(which('menu_SendToExcel'));
if ~exist(folder,'dir')
    varargout{1}=false;
    varargout{2}='Send To';
    varargout{3}='';
else
    varargout{1}=true;
    varargout{2}='Send To';
    varargout{3}=folder;
end