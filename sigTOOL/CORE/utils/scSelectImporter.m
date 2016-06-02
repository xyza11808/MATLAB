function fcn=scSelectImporter(filename)
% scSelectImporter returns a function handle to the appropriate sigTOOL import function
%
% Example:
% fcn=scSelectImporter(filename);
% fcn=scSelectImporter(extension);
%
% where filename or extension are strings e.g
%       fcn=scSelectImporter('myfile.abf');
%       fcn=scSelectImporter('.mcd');
%
% scSelectImporter also sets up the relevant ImportXXX function by
% loading any required libraries (e.g. the relevant NeuroShare DLL)
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 11/09
% Copyright © The Author & King's College London 2009-
% -------------------------------------------------------------------------



[pathname filename extension]=fileparts(filename);

switch extension
    case '.abf'
        fcn=@ImportABF;
    case '.cfs'
        fcn=@ImportCFS;
    case '.dat'
        fcn=@SelectDAT;
    case '.map'
        [pathname, name, ext]=fileparts(which('nsAOLibrary.dll'));
        if (ns_SetLibrary([pathname filesep name ext]) ~= 0)
            error('''%s'' was not found on the MATLAB path',...
                name);
        end
        fcn=@ImportNS;
    case '.mcd'
        [pathname, name, ext]=fileparts(which('nsMCDLibrary.dll'));
        if (ns_SetLibrary([pathname filesep name ext]) ~= 0)
            error('''%s'' was not found on the MATLAB path',...
                name);
        end
        fcn=@ImportNS;
    case '.nev'
        [pathname, name, ext]=fileparts(which('nsNEVLibrary.dll'));
        if (ns_SetLibrary([pathname filesep name ext]) ~= 0)
            error('''%s'' was not found on the MATLAB path',...
                name);
        end
        fcn=@ImportNS;
    case '.nex'
        [pathname, name, ext]=fileparts(which('NeuroExplorerNeuroShareLibrary.dll'));
        if (ns_SetLibrary([pathname filesep name ext]) ~= 0)
            error('''%s'' was not found on the MATLAB path',...
                name);
        end
        fcn=@ImportNS;
    case '.nsn'
        [pathname, name, ext]=fileparts(which('nsNSNLibrary.dll'));
        if (ns_SetLibrary([pathname filesep name ext]) ~= 0)
            error('''%s'' was not found on the MATLAB path',...
                name);
        end
        fcn=@ImportNS;
    case '.plx'
        [pathname, name, ext]=fileparts(which('nsPlxLibrary.dll'));
        if (ns_SetLibrary([pathname filesep name ext]) ~= 0)
            error('''%s'' was not found on the MATLAB path',...
                name);
        end
        fcn=@ImportNS;
    case {'.smr' '.son'}
        fcn=@ImportSMR;
    case {'.ssd'}
        fcn=@ImportSSD;
    case {'.wav'}
        fcn=@ImportWAV;
        
end

return
end