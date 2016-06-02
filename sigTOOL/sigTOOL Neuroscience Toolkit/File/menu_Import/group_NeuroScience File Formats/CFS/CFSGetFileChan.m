function [chanName, yUnits, xUnits, dataType, dataKind, spacing, other]=...
    CFSGetFileChan(fid, chan)
% CFSGetFileChan - gateway to cfs32.dll GetFileChan function
%
% Example:
% [chanName, yUnits, xUnits, dataType, dataKind, spacing, other]=...
%    CFSGetFileChan(fid, chan)
%
% The CFS filing system is copyright Cambridge Electronic Design.
% See the Cambridge Electonic Design CFS manual for further details
% (www.ced.co.uk)
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 03/07
% Copyright © The Author & King's College London 2007
% -------------------------------------------------------------------------
chanName=char(ones(1,22));%'0123456789012345678901';
yUnits='012345678';
xUnits='012345678';
[chanName, yUnits, xUnits, dataType, dataKind, spacing, other]=calllib('CFS32', 'GetFileChan',...
    fid, chan, chanName, yUnits, xUnits, 0, 0, 0, 0);

return
end