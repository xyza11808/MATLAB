function varargout=menu_ImportSTA(varargin)
% menu_ImportSTA provides the sigTOOL menu gateway to the ImportSTA function
%
% Examples:
% [flag, menulabel, credits]=menu_ImportSTA(0)
% returns the standard sigTOOL menuitem output as used by dir2menu
% 
% targetfile=menuIImportABF()
% prompts the user to select a CED  file,
% loads it into a standard sigTOOL kcl file and imports it into the sigTOOL
% environment. The kcl file's name is returned in targetfile.
%
% See also dir2menu
%
% Toolboxes required: None
%
% Requires the presence of the Weill Spike Train Analysis Toolkit
% See http://neuroanalysis.org/toolkit/
%
%
% Author: Malcolm Lidierth 08/09
% Copyright © The Author & King's College London 2009-
%
% Acknowledgements:
% Revisions:


% Called as menu_ImportSTA(0)
if nargin==1 && varargin{1}==0
    switch computer
        case 'PCWIN'
            if ~isempty(which('staread'))
                varargout{1}=true;
            else
                varargout{1}=false;
            end
        otherwise
            varargout{1}=false;
    end
    varargout{2}='Weill Medical College Format (STAM/STAD)';
    varargout{3}='';
    return
end



if nargin>=2
    scImport(@ImportSTA, '*.stam');
end
end

