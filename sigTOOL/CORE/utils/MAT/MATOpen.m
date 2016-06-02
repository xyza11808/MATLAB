function [fh, swapbyteorder]=MATOpen(filename, permission)
% MATOpen opens a MAT file in appropriate endian mode and returns a handle
%
% Example:
% [FH, SWAP]=MATOPEN(FILENAME, PERMISSION)
% FH is the returned file handle
% PERMISSION is the permission string for FOPEN
% SWAP is set true if the byte order is different to the default of the host
% platform
%
% The "appropriate" endian order is either:
% The system default endian if FILENAME does not exist
% The existing endian order for the file if FILENAME does exist
%
% See also endian
%
% Author: Malcolm Lidierth 09/06
% Copyright © King’s College London 2006
%
% Revisions:
% 16.03.08 Remove endian as varname now function endian is defined

[platform,maxsize,system_endian] = computer;
fh=fopen(filename,permission,system_endian);

if fh<0
    swapbyteorder=[];
    disp(sprintf('MATOPEN: Failed to open %s',filename));
    return
end

fseek(fh,0,'bof');
level=fread(fh,4,'uint8');
if level(1)==0 || level(1)==0 || level(2)==0 || level(3)==0
    disp('MATOPEN: unsupported Level 4 MAT-file format');
    fclose(fh);
    fh=-1;
    swapbyteorder=[];
    return;
end

fseek(fh,114+10,'bof');
level=fread(fh,1,'uint16=>uint16');
if level==512
    disp('MATOPEN: unsupported Level 7 MAT-file format');
    swapbyteorder=[];
    fclose(fh);
    fh=-1;
    return;
end

thisfileendian=fread(fh,1,'uint16=>uint16');
switch thisfileendian
    case 18765
        fclose(fh);
        switch system_endian
            case 'L'
                fh=fopen(filename,permission,'B');
            case 'B'
                fh=fopen(filename,permission,'L');
        end
        swapbyteorder=true;
    case 19785
        swapbyteorder=false;
    otherwise
        fclose(fh);
        fh=-1;
        disp('MATOPEN: could not determine file byte order.');
end