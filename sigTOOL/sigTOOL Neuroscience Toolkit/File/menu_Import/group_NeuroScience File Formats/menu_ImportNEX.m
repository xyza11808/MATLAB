function varargout=menu_ImportNEX(varargin)
% menu_ImportMEX gateway to the NeuroShare data loader for NEX files
%
% This requires NeuroExplorerNeuroShareLibrary.dll from Nex
% Technologies works on Windows platforms only
%
% Toolboxes required: None
%
% Author: Malcolm Lidierth 07/06
% Copyright © The Author & King's College London 2006
%
% Acknowledgements:
% Revisions:


% Called as menu_ImportSMR(0)
if nargin==1 && varargin{1}==0
    switch computer()
        case {'PCWIN'}
        varargout{1}=true;
        otherwise
        varargout{1}=false;
    end
    varargout{2}='Nex Technologies NeuroExplorer(NEX)';
    varargout{3}=[];
    return
end

% Normal call from menu
if nargin>=2
    % Load the appropriate DLL
    [pathname, name, ext]=fileparts(which('NeuroExplorerNeuroShareLibrary.dll'));
    if (ns_SetLibrary([pathname filesep name ext]) ~= 0)
        sprintf('''%s'' was not found on the MATLAB path',...
            fullfile(pathname, name, ext));
        return
    end
    % Import data
    scImport(@ImportNS, '*.nex');
    return
end
end


