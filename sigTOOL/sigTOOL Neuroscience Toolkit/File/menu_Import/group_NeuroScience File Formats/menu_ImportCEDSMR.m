function varargout=menu_ImportCEDSMR(varargin)
% menu_ImportCEDSMR provides the sigTOOL menu gateway to the ImportSMR function
%
% Examples:
% [flag, menulabel, credits]=menu_ImportSMR(0)
% returns the standard sigTOOL menuitem output as used by dir2menu
% 
% targetfile=menuIImportSMR()
% prompts the user to select a CED Spike2 for Windows SMR file,
% loads it into a standard sigTOOL kcl file and imports it into the sigTOOL
% environment. The kcl file's name is returned in targetfile.
%
% See also dir2menu
%
% Toolboxes required: None
%
% Author: Malcolm Lidierth 10/06
% Copyright © The Author & King's College London 2006-
%
% Acknowledgements:
% Revisions:


% Called as menu_ImportSMR(0)
if nargin==1 && varargin{1}==0
    varargout{1}=true;
    varargout{2}='CED Spike2 for Windows/Mac (SMR/SON)';
    varargout{3}=sprintf(...
        'Author: Malcolm Lidierth\n© 2006 King’s College London');
    return
end


% Import data
if nargin>=2
    scImport(@ImportSMR, '*.smr;*.son');
end
end

