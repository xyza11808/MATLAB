function filename=argcheck(filename, varname)
% argcheck does error checking for the MAT-file utilities
%
% Example:
% filename=argcheck(filename, varname)
% returns the filename with the .mat extension if no other
% is specified
% Where appropriate, also calls CheckIsLastEntry(filename,varname) to
% check varname is OK
%__________________________________________________________________________
%
% This program is distributed without any warranty,
% without even the implied warranty of fitness for a particular purpose.
%__________________________________________________________________________
%
% Author: Malcolm Lidierth 11/06
% Copyright © The Author & King's College London 2006
%__________________________________________________________________________
%
% Revisions: 30.01.07 delete call to which. This would return empty if 
% filename was not on the MATLAB path. Argcheck no longer attempts to
% return the full path of filename.
%

% Append default .mat extension if none supplied
[pathstr, name, ext] = fileparts(filename);
if isempty(ext)
    filename=[pathstr name '.mat'];
end

if nargin==2
    if CheckIsLastEntry(filename,varname)==false
        error('RestoreDiscClass: %s is not the last variable in %s',...
            varname,...
            filename);
    end
end
