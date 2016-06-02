function PadToEightByteBoundary(fh)
% PadToEightByteBoundary does what its name suggests
%
% Example:
% PadToEightByteBoundary(filehandle)
%__________________________________________________________________________
%
% This program is distributed without any warranty,
% without even the implied warranty of fitness for a particular purpose.
%__________________________________________________________________________
%
% Author: Malcolm Lidierth 11/06
% Copyright © The Author & King's College London 2006
%__________________________________________________________________________

pos=ftell(fh);
pad=8-rem(pos,8);
if pad~=8
    for i=1:pad
        fwrite(fh,0,'uint8');
    end
end
return
end