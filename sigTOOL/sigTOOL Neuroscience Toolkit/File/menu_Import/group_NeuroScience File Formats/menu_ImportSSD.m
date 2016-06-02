function varargout=menu_ImportSSD(varargin)
% menu_ImportSSD provides the sigTOOL menu gateway to the ImportSSD function
%
% Examples:
% [flag, menulabel, credits]=menu_ImportSSD(0)
% returns the standard sigTOOL menuitem output as used by dir2menu
% 
% targetfile=menuIImportABF()
% prompts the user to select a CED Signal for Windows CFS file,
% loads it into a standard sigTOOL kcl file and imports it into the sigTOOL
% environment. The kcl file's name is returned in targetfile.
%
% See also dir2menu
%
% Toolboxes required: None
%
% Author: Malcolm Lidierth 10/06
% Copyright © The Author & King's College London 2006
%
% Acknowledgements:
% Revisions:


% Called as menu_ImportABF(0)
if nargin==1 && varargin{1}==0
    varargout{1}=true;
    varargout{2}='CONSAM (SSD;DAT)';
    varargout{3}='';
    return
end



if nargin>=2
    scImport(@ImportSSD, '*.ssd;*.dat');
end
end

