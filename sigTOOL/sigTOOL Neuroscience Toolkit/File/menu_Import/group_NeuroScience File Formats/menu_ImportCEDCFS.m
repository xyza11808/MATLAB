function varargout=menu_ImportCEDCFS(varargin)
% menu_ImportCEDCFS provides the sigTOOL menu gateway to the ImportCFS function
%
% Examples:
% [flag, menulabel, credits]=menu_ImportCFS(0)
% returns the standard sigTOOL menuitem output as used by dir2menu
% 
% targetfile=menuIImportCEDCFS()
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


% Called as menu_ImportCEDCFS(0)
if nargin==1 && varargin{1}==0
    switch computer
        case 'PCWIN'
            varargout{1}=true;
        otherwise
            varargout{1}=false;
    end
    varargout{2}='CED Signal for Windows (CFS)';
    varargout{3}='';
    return
end



if nargin>=2
    scImport(@ImportCFS, '*.cfs');
end
end

