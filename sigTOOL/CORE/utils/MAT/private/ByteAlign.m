function ByteAlign(fh)
% ByteAlign aligns the file position to an 8 byte boundary
%
% Example:
% BYTEALIGN(FH)
% where FH is the file handle
% 
% The file position will be unchanged if already at an 8 byte boundary.
% Otherwise it will be moved to the next boundary.
%
% Author: Malcolm Lidierth 09/06
% Copyright © King’s College London 2006

pos=ftell(fh);
o=rem(pos,8);
if o==0
    return;
else
    fseek(fh,8-o,'cof');
    return;
end
end