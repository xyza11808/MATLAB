function [chOffset, points, yScale, yOffset, xScale, xOffset]=CFSGetDSChan(fid, chan, DS)
% CFSGetDSChan - gateway to cfs32.dll CFSGetDSChan function
%
% Example:
% [chOffset, points, yScale, yOffset, xScale, xOffset]=...
%               CFSGetDSChan(fid, chan, DS)
%
% The CFS filing system is copyright Cambridge Electronic Design.
% See the Cambridge Electonic Design CFS manual for further details
% (www.ced.co.uk)
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 03/07
% Copyright © The Author & King's College London 2007
% -------------------------------------------------------------------------
[chOffset, points, yScale, yOffset, xScale, xOffset]=calllib('CFS32','GetDSChan',...
            fid, chan, DS, 0, 0, 0, 0, 0, 0);
return
end