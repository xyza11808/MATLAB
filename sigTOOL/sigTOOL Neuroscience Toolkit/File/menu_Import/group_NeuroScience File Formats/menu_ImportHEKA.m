function varargout=menu_ImportHEKA(varargin)
% menu_ImportHEKA provides the sigTOOL menu gateway to the ImportHEKA function
%
% Examples:
% [flag, menulabel, credits]=menu_ImportHEKA(0)
% returns the standard sigTOOL menuitem output as used by dir2menu
% 
% targetfile=menuIImportHEKA()
% prompts the user to select a HEKA DAT file,
% loads it into a standard sigTOOL kcl file and imports it into the sigTOOL
% environment. The kcl file's name is returned in targetfile.
%
% See also dir2menu
%
% Toolboxes required: None
%
% Author: Malcolm Lidierth 12/09
% Copyright © The Author & King's College London 2009-
%
% Acknowledgements:
% Revisions:


% Called as menu_ImportHEKA(0)
if nargin==1 && varargin{1}==0
    varargout{1}=true;
    varargout{2}='HEKA PatchMaster/ChartMaster (DAT)';
    varargout{3}='';
    return
end



if nargin>=2
    scImport(@ImportHEKA, '*.dat');
end
end

