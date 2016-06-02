function varargout=external_Edit(varargin)
% external_Edit sets up the edit menu
% 
% Example
% varargout=external_Edit(varargin)
%     is called be dir2menu. Not user callable
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 11/07
% Copyright © The Author & King's College London 2007-
% -------------------------------------------------------------------------

folder=fullfile(scGetBaseFolder, 'CORE', filesep, 'Edit');

if ~exist(folder,'dir')
    varargout{1}=false;
    varargout{2}='Edit';
    varargout{3}='';
else
    varargout{1}=true;
    varargout{2}='Edit';
    varargout{3}=folder;
end