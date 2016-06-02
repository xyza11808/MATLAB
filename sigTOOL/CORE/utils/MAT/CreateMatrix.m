function CreateMatrix(filename, var, varsz)
% CreateMatrix is presently unused
%
% CreateMatrix creates a new variable in a MAT-file (v6)
% 
% Example:
% CreateMatrix(filename, var)
% CreateMatrix(filename, var, varsz)
% 
% FILENAME is the name of the target MAT-file, which will be created if it
% does not already exist.
%
% VAR is the variable to create. It may be any standard MATLAB class and 
% may be complex. It may not be a cell, structure or object. The contents
% of VAR will be written to the target MAT-file. VAR must be the 
% first elements of the final variable - correctly ordered in memory.
% The variable in the file will then be padded to the required
% number of elements to match VARSZ. (Note: with complex data, the padding
% is not guaranteed to be zero-padding - some pad elements may be set to
% eps(class(var)). 
% Note that a variable with the same name as VAR may not already be present
% if FILENAME already exists.
%
% VARSZ is the target size of VAR
%
% Use:
% Suppose we wish to write 180 frames of a video to a MAT file. Each frame
% is a 100x100x3 RGB image (total of 43200000 bytes for the video).
% Then using AVIREAD to load each frame in turn:
% f=aviread('myvideo.avi',1); % Read frame 1
% CreateMatrix('mymatfile.mat',f,[1000 1000 3 180]);
% for n=2:180
% f=aviread('myvideo.avi',n);
% SavePartMatrix('mymatfile.mat',f);
% end
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

% Get the name of the input variable
varname=inputname(2);

% Initially, use dummy values to force the builtin SAVE command to preserve
% the class of var when writing to disc.
% N.B. Could use just 1 or 2 elements here but subsequent use of fwrite with
% skip (in ChangeDimensions) means any pre-exisitng data on the disc would
% be preserved
buf=var;
if isreal(var)
    if isinteger(var)
        buf(:)=intmin(class(var));
        buf(1:end/2)=intmax(class(var));
    else
        buf(:)=eps(class(var));
    end
else
    if isinteger(var)
        buf(:)=complex(intmin(class(var)),intmin(class(var)));
        buf(1:end/2)=complex(intmax(class(var)),intmax(class(var)));
    else
        buf(:)=eps(class(var))+(eps(class(var))*i);
    end
end

% Keep a copy of the original - it will be overwritten by EVAL
keep=var;

% Open the file and let SAVE do the most of the work. This should improve
% future compatability e.g. if new Array Flags are used in the header
[fh]=MATOpen(filename,'r');
if fh<0
    % MAT-file does not exist - so create it
    eval(sprintf('%s=buf;',varname));
    save(filename, varname,'-v6');
    [fh]=MATOpen(filename,'r+');
else
    %MAT-file already exists
    dum=whos('-file',filename,varname);
    if ~isempty(dum)
        error('CreateMatrix: %s already exists in %s', varname, filename);
    end
    eval(sprintf('%s=buf;',varname));
    save(filename, varname,'-v6','-append');
    endianformat=endian(filename);
    fh=fopen(filename,'r+',endianformat);
end

% Finally, alter the dimensions array entries and rewrite data
% appropriately using low-level I/O
w=where(filename, varname);
if nargin==3
    ChangeDimensions(fh, w, keep, varsz);
end
fclose(fh);
end



