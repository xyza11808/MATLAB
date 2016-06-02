function varargout=external_View(varargin)
% external_View sets up the view menu
% 
% Example
% varargout=external_View(varargin)
%     is called be dir2menu. Not user callable
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 11/07
% Copyright © The Author & King's College London 2007-
% -------------------------------------------------------------------------

folder=fullfile(scGetBaseFolder, 'CORE', filesep, 'View');

if ~exist(folder,'dir')
    varargout{1}=false;
    varargout{2}='View';
    varargout{3}='';
else
    varargout{1}=true;
    varargout{2}='View';
    varargout{3}=folder;
end