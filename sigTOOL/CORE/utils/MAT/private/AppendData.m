function AppendData(filename, w, newdata, AddColumnFlag)
% AppendData adds data to an existing variable in a v6 MAT-file
%
% Example:
% AppendData(FILENAME, W, NEWDATA, ADDCOLUMNFLAG)
% FILENAME is a string 
% W is the output of a prior cell to WHERE(FILENAME, VARNAME) - VARNAME is
%   the target variable in the file
% NEWDATA are the data to append to the variable
% ADDCOLUMNFLAG forces data to be added to a new column in the case where
%   VARNAME is a row vector (not required otherwise)
%
% AppendData does the work when called from AppendVector, AppendColumns and
% AppendMatrix
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

mi=StandardMiCodes();

if strcmp(fileparts(which(filename)),fileparts(which('/private/AppendData')))
    error('AppendData: Found %s in private folder', which(filename));
end
fh=MATOpen(filename,'r+');
fseek(fh,w.TagOffset+24,'bof');

% Get current dimension array
DA_DataType=mi{fread(fh,1,'uint32=>uint32')};
DA_NumberOfBytes=fread(fh,1,DA_DataType);
DimArray=fread(fh,DA_NumberOfBytes/sizeof(DA_DataType),...
    [DA_DataType '=>' DA_DataType]);
ByteAlign(fh);

% Which dimension should grow?
if length(DimArray)==2
    % 2D target
    if DimArray(1)==1
        % Column Vector
        TargetDim=2;
    else
        if DimArray(2)==1
            % Row Vector
            if nargin>=4 && AddColumnFlag==true
                % Adding a new column
                TargetDim=2;
            else
                % Appending rows
                TargetDim=1;
            end
        else
            % 2D Matrix
            TargetDim=length(DimArray);
        end
    end
else
    % >2D so add to highest dimension
    TargetDim=length(DimArray);
end

% Skip over name Array
N_DataType=fread(fh,1,'uint32');
if (N_DataType>2^16)
    fseek(fh,4,'cof');
else
    N_NumberOfBytes=fread(fh,1,'uint32');
    fseek(fh,N_NumberOfBytes,'cof');
end
ByteAlign(fh);

temp=fread(fh,1,'uint32');
if (temp>2^16)
    fclose(fh);
    error('AppendData: target variable is stored as a small data element\nin %s',filename);
else
    BytesOfData=fread(fh,1,'uint32');
    pos=ftell(fh);
end

% UPDATE THE TARGET VARIABLE
fseek(fh,w.TagOffset+32,'bof');
% Update the dimension array
s=size(newdata);
if length(DimArray)==ndims(newdata)
    % Growing a matrix
    DimArray(TargetDim)=DimArray(TargetDim)+s(TargetDim);
else
    % Adding an additional matrix to the highest dimension of an exising
    % matrix e.g. after call to AddDimension
    switch length(DimArray)-length(s)
        case 0
            DimArray(end)=DimArray(end)+s(end);
        case 1
            DimArray(end)=DimArray(end)+(s(end)/DimArray(end-1));
        otherwise
            fclose(fh);
            error('AppendData: "%s" has unexpected dimensions\nin %s',inputname(3),filename);
    end
end
%Before corrupting file let's make sure we have the right number of elements
if prod(double(DimArray))~=prod(w.size)+numel(newdata)
    error('AppendData: mismatched matrix dimensions\nin %s',filename);
end


fwrite(fh, DimArray, DA_DataType);

% Change the number of bytes
fseek(fh,pos-4,'bof');
fwrite(fh, BytesOfData+...
    (numel(newdata)*sizeof(class(newdata))),DA_DataType);

% Add the new data
fseek(fh,pos+BytesOfData,'bof');
fwrite(fh,newdata(:),class(newdata));

% Pad to 64 bit boundary
PadToEightByteBoundary(fh)

% Recalculate and save the variable's size (bytes, inclusive of padding)
eof=ftell(fh);
fseek(fh,w.TagOffset+4,'bof');
fwrite(fh,eof-w.TagOffset-8,'uint32');

fclose(fh);
return
end