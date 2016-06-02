function compileNeuroShare
% This will generate the Neuroshare mexprog library (application extension)
% for the Neuroshare/MATLAB interface. The file extension will be 
% platform/MATLAB version specific
%
% There should be no need to run this on Windows (not too sure about Linux)
%
%
% Requires main.c, mexversion.c and ns.c and associated .h file to complete.
% For authorship of this API see these files or visit www.neuroshare.org.
%
% Malcolm Lidierth 03/08

fprintf('\nGenerating mexprog.%s for the Neuroshare/MATLAB API\n', mexext());

if ispc
    mex -output mexprog main.c mexversion.c ns.c
elseif ismac
    % OK on G4 PPC (MATLAB R?????) and Intel (MATLAB R2007a 32bit)
    mex -output mexprog main.c ns.c
elseif isunix
    % OK on 32 bit Fedora Linux
    mex -output mexprog -Dlinux -ldl -v main.c mexversion.c ns.c
end

return
end
