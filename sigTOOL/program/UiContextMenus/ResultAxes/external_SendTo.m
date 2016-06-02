function varargout=external_SendTo(varargin)
% external_SendTo sets up the export menu
% 
% Example
% varargout=external_SendTo(varargin)
%     is called be dir2menu. Not user callable
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 11/07
% Copyright © The Author & King's College London 2007-
% -------------------------------------------------------------------------
folder=fileparts(which('menu_SendToExcel'));
if ~exist(folder,'dir') || ~ispc
    varargout{1}=false;
    varargout{2}='Send To';
    varargout{3}='';
else
    varargout{1}=true;
    varargout{2}='Send To';
    varargout{3}=folder;
end