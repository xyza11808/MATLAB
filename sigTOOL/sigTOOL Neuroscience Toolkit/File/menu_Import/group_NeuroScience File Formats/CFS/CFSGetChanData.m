function [count, buf]=CFSGetChanData(fid, chan, DS, chOffset, points, buffer)
% CFSGetChanData - gateway to cfs32.dll GetChanData function
%
% The CFS filing system is copyright Cambridge Electronic Design.
% See the Cambridge Electonic Design CFS manual for further details
% (www.ced.co.uk)
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 03/07
% Copyright © The Author & King's College London 2007
% -------------------------------------------------------------------------
%
% Revisions:
%   03.12.10    Accommodate data arrays > 65535 elements

[chanName, yUnits, xUnits, dataType, dataKind, spacing, other]=CFSGetFileChan(fid, chan);

if points==0
    points=1;
end

buf=CFSCreateBuffer(points, dataType);

bsz=65535;
nblocks=fix(points/bsz);
nover=rem(points, bsz);

count=1;
if nblocks>0
for k=1:nblocks
[npoints, buf(count:count+bsz-1)]=calllib('CFS32', 'GetChanData',...
    fid, chan, DS, count-1, bsz, buf(count:count+bsz-1), bsz*sizeof(class(buf)));
    count=count+npoints;
end
end

if nover>0
    [npoints, buf(count:count+nover-1)]=calllib('CFS32', 'GetChanData',...
    fid, chan, DS, count-1, nover, buf(count:count+nover-1), nover*sizeof(class(buf)));
    count=count+npoints;
end

count=count-1;
if count~=points
    warning('Number of data points requested and the number returned do not match');
end

return
end
