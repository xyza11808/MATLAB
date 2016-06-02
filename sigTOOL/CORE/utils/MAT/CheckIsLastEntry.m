function ret=CheckIsLastEntry(filename, varname)
% CheckIsLastEntry checks that a variable is the last entry in a MAT-file
% 
% Example:
% flag=CheckIsLastEntry(FILENAME, VARNAME)
% FILENAME is the name of the MAT-file
% VARNAME is the variable name
% 
% Returns FLAG==true if check proves OK, false otherwise
%__________________________________________________________________________
%
% This program is distributed without any warranty,
% without even the implied warranty of fitness for a particular purpose.
%__________________________________________________________________________
%
% Author: Malcolm Lidierth 11/06
% Copyright © King's College London 2006
%__________________________________________________________________________


% Append default .mat extension if none supplied
[pathstr, name, ext] = fileparts(filename);
if isempty(ext)
    filename=[pathstr name '.mat'];
end

d=dir(filename);

if isempty(d)
    ret=false;
    disp('CheckIsLastEntry: File not found');
    return
end

w=where(filename, varname);

if isempty(w) || d.bytes~=w.TagOffset+w.DiscBytes+8
    ret=false;% Check failed
else
    ret=true;% OK
end

return
end