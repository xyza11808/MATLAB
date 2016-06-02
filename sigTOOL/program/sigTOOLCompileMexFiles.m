function sigTOOLCompileMexFiles()
% sigTOOLCompileMexFiles compiles sigTOOL source files written in C or C++
% 
% This will only be needed if the sigTOOL distribution does not include
% mex-files for the current platform.
%
% This file should be run from sigTOOL so that the target files are on the
% MATLAB path.
%
% Example:
% sigTOOL('compile');
%       from the command line to invoke this function
% 
% You must have set up the mex compiler beforehand from MATLAB.
% 
% If mex-files are absent from the distribution, the supplied C/C++ code
% will not have been tested on the target platform. Note that no testing
% has been done to-date on 64 bit platforms.
%
% Platform-specific m-files, such as those that call Windows
% application extensions for file import, will not be compiled here. The
% individual file format libraries provide details if you need to
% re-compile these.
%
% 32-bit Windows-platform users with older versions of MATLAB(< version 7.1)
% require mex-files with the dll extension instead of mexw32: 
% Either recompile the files or just rename the existing ones from
% *.mexw32 to *.dll. Note that most of the existing files need the
% Microsoft Visual Studio 2005 run-time libraries to be installed. See
% http://www.mathworks.com/support/solutions/data/1-2223MW.html
% for further details.If you recompile with MATLAB lcc compiler these
% libraries will not be needed
% 
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 04/08
% Copyright © The Author & King's College London 2008-
% -------------------------------------------------------------------------


% This file should be run from sigTOOL so that the target files are on the
% MATLAB path.
    
currentfolder=pwd;

% List of C/C++ files to compile
files={'eventcorr.cpp',...
    'rasterprep.cpp'};

% Compile loop
toterr=0;
for i=1:length(files)
    thisfile=which(files{i});
    [pathname name ext]=fileparts(thisfile);
    % Use cd here to stop problems with compilers/linkers not finding files
    % with spaces in path.
    cd(pathname);
    err=logical(mex([name ext]));
    if err==0
        % OK
        fprintf('%s: successfully compiled\n',[name ext]);
    else
        % Failed
        fprintf('%s: failed to compile\n',name);
        toterr=toterr+1;
    end
end

% Error message
if toterr==length(files)
    fprintf('\nAll files failed to compile. Have you set up the compiler using "mex -setup"? \n');
    fprintf('Type "help mex" at the MATLAB command line for details.\n')
    fprintf('Is the compiler (and version) you are using supported? Visit http://www.mathworks.com/\n');
    if isunix
        fprintf('Is gcc installed? If so check for version/Linux specific info at http://www.mathworks.com/support/\n');
    elseif ismac
        fprintf('Is XCode installed on this Mac?\n');
    end
end

cd(currentfolder);
return
end
