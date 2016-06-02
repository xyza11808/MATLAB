function varargout=external_Cursors(varargin)
% external_Cursors sets up the cursor menu
% 
% Example
% varargout=external_Cursors(varargin)
%     is called be dir2menu. Not user callable
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 11/07
% Copyright © The Author & King's College London 2007-
% -------------------------------------------------------------------------

folder=fullfile(scGetBaseFolder, 'CORE', filesep, 'sigTOOL Cursor Functions');

if ~exist(folder,'dir')
    varargout{1}=false;
    varargout{2}='Cursors';
    varargout{3}='';
else
    varargout{1}=true;
    varargout{2}='Cursors';
    varargout{3}=folder;
end