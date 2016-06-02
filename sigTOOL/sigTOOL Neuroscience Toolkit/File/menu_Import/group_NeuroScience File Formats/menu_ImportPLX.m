function varargout=menu_ImportPLX(varargin)
% menu_ImportPLX gateway to the NeuroShare data loader for PLX files
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
%       13.02.2011 Add 64 bit support


% Called as menu_ImportPLX(0)
if nargin==1 && varargin{1}==0
    switch computer
        case {'PCWIN', 'PCWIN64'}
            varargout{1}=true;
        otherwise
            varargout{1}=false;
    end
    varargout{2}='Plexon Instruments (PLX)';
    varargout{3}=[];
    return
end

% Normal call from menu
if nargin>=2
    % Load the appropriate DLL
    switch computer()
        case 'PCWIN'
            [pathname, name, ext]=fileparts(which('nsPlxLibrary.dll'));
        case 'PCWIN64'
            [pathname, name, ext]=fileparts(which('nsPlxLibrary64.dll'));
    end
    if (ns_SetLibrary([pathname filesep name ext]) ~= 0)
        sprintf('''%s'' was not found on the MATLAB path',...
            fullfile(pathname, name, ext));
        return
    end
    % Import data
    scImport(@ImportNS, '*.plx');
    return
end
end


