function filename=RestoreDiscClass(filename, varname)
% RestoreDiscClass changes the class of the data in a MAT file (v6)
%
% Example:
% filename=RestoreDiscClass(FILENAME, VARNAME)
%
% FILENAME: The target file. Must be a v6 MAT-file
% VARNAME: string with the variable name
%
% VARNAME must be a standard matrix (numeric (including complex), logical
% or char) but may not be sparse. RestoreDiscClass works with both real and
% complex variables
% 
% The MATLAB builin SAVE command casts data to the smallest class possible
% without causing loss of data. LOAD then casts back to the original class.
% RestoreDiscClass casts the data on disc to the original class. The target
% variable must be the final variable in the MAT-file i.e. it must be at
% the end of the file
%
% RestoreDiscClass should be called before using any of the AppendXXXXX
% functions to ensure that adequate bytes have been set aside to store
% the appended data without loss.
%
% FILENAME is returned by RestoreDiscClass prefixed with full path details.
% This can be used to avoid confusion if multiple files with the same name
% occur and no path is specified expicitly (although this would normally
% only cause problems if there are MAT files in the \private folder of the 
% MAT-utilities)
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
% Revisions:    04.11.07   Reposition code for no change: now faster

% Append default .mat extension if none supplied and check for problems
filename=argcheck(filename, varname);

mi=StandardMiCodes();

w=where(filename,varname);

% Return if no change needed: Moved 04.11.07
if strcmp(w.DiscClass{1}, w.class)==1 
    return
end

% Otherwise....
d=load(filename,varname,'-mat');
names=fieldnames(d);
var=d.(names{1});
clear('d');


if ~isreal(var) &&...
        strcmp(w.DiscClass{1}, class(var))==1 &&...
        strcmp(w.DiscClass{2}, class(var))==1
    return
end

% Return if class not supported
if (~isnumeric(var) && ~islogical(var) && ~ischar(var)) ||...
    issparse(var)
    return
end

% Do the work
fh=MATOpen(filename,'r+');
fseek(fh,w.TagOffset+24,'bof');
%Dimensions array
DA_DataType=mi{fread(fh,1,'uint32=>uint32')};
DA_NumberOfBytes=fread(fh,1,'uint32');
fseek(fh,DA_NumberOfBytes,'cof');
ByteAlign(fh);

%Name Array
N_DataType=fread(fh,1,'uint32');
if (N_DataType>2^16)
    fseek(fh,4,'cof')
else
    N_DataType=mi{N_DataType};
    N_NumberOfBytes=fread(fh,1,'uint32');
    n=N_NumberOfBytes/sizeof(N_DataType);
    fseek(fh, n, 'cof');
end
ByteAlign(fh);

% Find and write the MATLAB numeric code for this class from mi
fwrite(fh,find(strcmp(mi,class(var))),'uint32');
% Recalculate and save the new size in bytes (excludes padding)
fwrite(fh,numel(var)*sizeof(class(var)),'uint32');
% Save the data, preserving the class.
fwrite(fh, real(var), class(var));
% Pad to 64 bit boundary
PadToEightByteBoundary(fh)
% If the data is complex, save the imaginary components
if w.complex==true
    fwrite(fh,find(strcmp(mi,class(var))),'uint32');
    fwrite(fh,numel(var)*sizeof(class(var)),'uint32');
    fwrite(fh, imag(var), class(var));
end
% Pad to 64 bit boundary
PadToEightByteBoundary(fh)
% Recalculate and save the variable's size (bytes, inclusive of padding)
eof=ftell(fh);
fseek(fh,w.TagOffset+4,'bof');
fwrite(fh,eof-w.TagOffset-8,'uint32');
fclose(fh);
return
end