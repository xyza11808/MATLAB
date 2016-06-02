function varargout=menu_ImportMCD(varargin)
% menu_ImportMCD gateway to the Multi Channel Systems data loader for MCD files
%
% This requires nsMCDLibrary shared library from Multi Channel Systems
%
% Toolboxes required: None
%
% Author: Malcolm Lidierth 09/09
% Copyright � The Author & King's College London 2009-
%
% Acknowledgements:
% Revisions:


% Called as menu_ImportMCD(0)
if nargin==1 && varargin{1}==0
    varargout{1}=true;
    varargout{2}='Multi Channel Systems (MCD)';
    varargout{3}=[];
    return
end

% Normal call from menu
if nargin>=2
    % Load the appropriate shared library
    switch computer()
        case 'PCWIN'
            [pathname, name, ext]=fileparts(which('nsMCDLibrary.dll'));
         case 'PCWIN64'
            [pathname, name, ext]=fileparts(which('nsMCDLibrary64.dll'));
        case 'GLNX86'
            [pathname, name, ext]=fileparts(which('nsMCDLibraryLinux32.so'));
        case 'GLNXA64'
            % TODO: Will need appropriate mexprog
            [pathname, name, ext]=fileparts(which('nsMCDLibraryLinux64.so'));
        case {'MACI', 'MACI64'}
            [pathname, name, ext]=fileparts(which('nsMCDLibrary.dylib'));
    end
    if (ns_SetLibrary([pathname filesep name ext]) ~= 0)
        sprintf('''%s'' was not found on the MATLAB path',...
            fullfile(pathname, name, ext));
        return
    end
    % Import data
    scImport(@ImportNS, '*.mcd');
    return
end
end


