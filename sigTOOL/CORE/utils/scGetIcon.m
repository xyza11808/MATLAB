function img=scGetIcon(name)
% scGetIcon reads image data for making icons from menu items
%
% Example:
% img=scGetIcon(name)
% returns the image in file name 'name' from the ...sigTOOL\CORE\icons
% folder
%
%-------------------------------------------------------------------------
% Author: Malcolm Lidierth 09/07
% Copyright © The Author & King’s College London 2007-
%-------------------------------------------------------------------------

name=[scGetBaseFolder() 'CORE' filesep 'icons' filesep name];
img=imread(name);