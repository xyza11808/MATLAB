function varargout=external_Export(varargin)
% external_Export sets up the export menu
% 
% Example
% varargout=external_Export(varargin)
%     is called be dir2menu. Not user callable
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 11/07
% Copyright © The Author & King's College London 2007-
% -------------------------------------------------------------------------
folder=fullfile(scGetBaseFolder, 'CORE', filesep, 'File', filesep, 'menu_Export');

if ~exist(folder,'dir')
    varargout{1}=false;
    varargout{2}='Export';
    varargout{3}='';
else
    varargout{1}=true;
    varargout{2}='Export';
    varargout{3}=folder;
end