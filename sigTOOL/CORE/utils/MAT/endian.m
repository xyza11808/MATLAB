function str=endian(filename)
% endian returns the endian format for the specified MAT file
%
% Example:
% endianformat=endian(filename)
%       filename is string
%       endianformat will be returned as 'ieee.le' or 'ieee-be' 
%           (or [] if undetermined)
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
[pathstr, name, ext] = fileparts(filename);
if isempty(ext)
    filename=[pathstr name '.mat'];
end

% Let MATOpen do the work
[platform,maxsize,system_endian] = computer;
[fh, swapbyteorder]=MATOpen(filename, 'r');

% Default return value
str=[];

if fh<0
    return
else
    fclose(fh);
    switch system_endian
        case 'L'
            if swapbyteorder==false
                str='ieee-le';
            else
                str='ieee-be';
            end
        case 'B'
            if swapbyteorder==false
                str='ieee-be';
            else
                str='ieee-le';
            end
    end
end