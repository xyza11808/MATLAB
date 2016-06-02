function varargout=menu_ImportMAP(varargin)
% MENU_IMPORTSMR gateway to the NeuroShare data loader for PLX files
%
% This requires nsPlxLibrary.dll from Plexon Instruments and works on
% Windows platforms only
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
    switch computer
        case 'PCWIN'
            varargout{1}=true;
        otherwise
            varargout{1}=false;
    end
    varargout{2}='Alpha Omega (MAP)';
    varargout{3}=sprintf(...
        'Author: Malcolm Lidierth\n© 2006 King’s College London');
    return
end



if nargin>=2
    % Load the appropriate DLL
    [pathname, name, ext]=fileparts(which('nsAOLibrary.dll'));
    if (ns_SetLibrary([pathname filesep name ext]) ~= 0)
        sprintf('''%s'' was not found on the MATLAB path',...
            [pathname filesep name ext]);
        return
    end
    
    scImport(@ImportNS, '*.map');
end
end

