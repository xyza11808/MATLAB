function varargout=menu_ImportNSN(varargin)
% menu_ImportNSN gateway to the Neuroshare native importer
%
% This requires nsNSNLibrary shared library
%
% Toolboxes required: None
%
% Author: Malcolm Lidierth 09/09
% Copyright © The Author & King's College London 2009-
%
% Acknowledgements:
% Revisions:


% Called as menu_ImportMCD(0)
if nargin==1 && varargin{1}==0
   switch computer
        case 'PCWIN'
            varargout{1}=true;
        otherwise
            varargout{1}=false;
    end
    varargout{2}='Neuroshare Native (NSN)';
    varargout{3}=[];
    return
end

% Normal call from menu
if nargin>=2
    % Load the appropriate shared library
    [pathname, name, ext]=fileparts(which('nsNSNLibrary.dll'));
    if (ns_SetLibrary([pathname filesep name ext]) ~= 0)
        sprintf('''%s'' was not found on the MATLAB path',...
            fullfile(pathname, name, ext));
        return
    end
    % Import data
    scImport(@ImportNS, '*.nsn');
    return
end
end


