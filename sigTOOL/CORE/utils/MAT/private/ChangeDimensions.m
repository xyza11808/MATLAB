function ChangeDimensions(fh, w, var, varsz)
% ChangeDimensions is called to increase the size of an existing variable
%
% Example:
% ChangeDimensions(FH, W, VAR, VARSZ)
% FH: the file handle
% W: the structure returned by a call to WHERE for var
% VAR: the variable
% VARSZ: the required dimensions array
%
% The product of the elements of VARSZ must be greater than numel(VAR)
% VAR must be the last variable in the MAT-file
%
% Normally called from CreateMatrix
%
% See also CreateMatrix
%
% Toolboxes required: None
%
% Acknowledgements:
% Revisions:
%__________________________________________________________________________
%
% This program is distributed without any warranty,
% without even the implied warranty of fitness for a particular purpose.
%__________________________________________________________________________
%
% Author: Malcolm Lidierth 11/06
% Copyright © The Author & King's College London 2006
%__________________________________________________________________________


mi=StandardMiCodes();
fseek(fh,w.TagOffset+24,'bof');

% Get current dimensions array
DA_DataType=mi{fread(fh,1,'uint32=>uint32')};
DA_NumberOfBytes=fread(fh,1,DA_DataType);
DimArray=fread(fh,DA_NumberOfBytes/sizeof(DA_DataType),...
    [DA_DataType '=>' DA_DataType]);
ByteAlign(fh);

% Get name Array
N_DataType=fread(fh,1,'uint32');
if (N_DataType>2^16)
    buf=fread(fh,4,'uint8');
    sdo=true;
else
    N_NumberOfBytes=fread(fh,1,'uint32');
    n=N_NumberOfBytes/sizeof(N_DataType);
    Name=fread(fh, n, N_DataType);
    sdo=false;
end
ByteAlign(fh);

% Change the dimensions array entries
fseek(fh,w.TagOffset+28,'bof');
% DA_DataType=mi{fread(fh,1,'uint32=>uint32')};
% fread(fh,1,DA_DataType);%DA_NumberOfBytes
% fseek(fh,-sizeof(DA_DataType),'cof')
% New values
fwrite(fh, length(varsz)*sizeof(DA_DataType),DA_DataType);
fwrite(fh, varsz, DA_DataType);
PadToEightByteBoundary(fh)

% Rewrite the name data
fwrite(fh, N_DataType,'uint32');
if sdo==true
    fwrite(fh, buf, 'uint8');
else
    fwrite(fh, N_NumberOfBytes, 'uint32');
    fwrite(fh, Name, N_DataType);
end
PadToEightByteBoundary(fh)

% Number of bytes of padding needed to achieve the size specified in varsz
npad=prod(double(varsz))*sizeof(class(var))-...
    (numel(var)*sizeof(class(var)));

% Real data, or real part of complex data:
% The class on disc
fwrite(fh,find(strcmp(mi,class(var))),'uint32');
% The number of bytes
fwrite(fh,prod(double(varsz))*sizeof(class(var)),'uint32');
% Write the data
fwrite(fh, real(var), class(var));
% Add padding
fwrite(fh,0,'uint8',npad-1);
% Finally zero pad to 64 bit boundary
PadToEightByteBoundary(fh)

% Complex data so repeat for imaginary component
if ~isreal(var)
    fwrite(fh,find(strcmp(mi,class(var))),'uint32');
    fwrite(fh,prod(double(varsz))*sizeof(class(var)),'uint32');
    fwrite(fh, imag(var), class(var));
    fwrite(fh,0,'uint8',npad-1);
    PadToEightByteBoundary(fh)
end

% Recalculate and save the variable's size (bytes, inclusive of padding)
eof=ftell(fh);
fseek(fh,w.TagOffset+4,'bof');
fwrite(fh,eof-w.TagOffset-8,'uint32');
return
end