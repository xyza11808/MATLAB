function varargout=menu_ImportNEV(varargin)
% menu_ImportNEV gateway to the NeuroShare data loader for NEV files
%
% This requires nsNEVLibrary.dll from CyberKinetics Inc
%
% Toolboxes required: None
%
% Author: Malcolm Lidierth 07/06
% Copyright © The Author & King's College London 2006
%
% Acknowledgements:
% Revisions:


% Called as menu_ImportNEV(0)
if nargin==1 && varargin{1}==0
    switch computer()
        case {'PCWIN' 'GLNX86'}
            varargout{1}=true;
        otherwise
            varargout{1}=false;
    end
    varargout{2}='Cyberkinetics Inc (NEV)';
    varargout{3}=[];
    return
end

% Normal call from menu
if nargin>=2
    % Load the appropriate DLL
    switch computer()
        case 'PCWIN'
            [pathname, name, ext]=fileparts(which('nsNEVLibrary.dll'));
        case 'GLNX86'
            [pathname, name, ext]=fileparts(which('nsNEVLibrary.so'));
    end
    if (ns_SetLibrary([pathname filesep name ext]) ~= 0)
        sprintf('''%s'' was not found on the MATLAB path',...
            fullfile(pathname, name, ext));
        return
    end
    % Import data
    scImport(@ImportNS, '*.nev');
    return
end
end


