function varname=GetLastEntry(filename)
% GetLastEntry checks that a variable is the last entry in a MAT-file
% 
% Example:
% VARNAME=GetLastEntry(FILENAME)
% FILENAME is the name of the MAT-file
% 
%__________________________________________________________________________
%
% This program is distributed without any warranty,
% without even the implied warranty of fitness for a particular purpose.
%__________________________________________________________________________
%
% Author: Malcolm Lidierth 11/06
% Copyright © The Author & King's College London 2006
%__________________________________________________________________________

% Append default .mat extension if none supplied
filename=argcheck(filename);
s=where(filename);
maxTag=0;
for i=1:length(s)
    if s(i).TagOffset>maxTag
        maxTag=s(i).TagOffset;
        j=i;
    end
end

varname=s(j).name;

return
end