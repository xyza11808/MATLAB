function [nchan, nVars, nDSVars, nDS]=CFSGetFileInfo(fid)
% CFSGetFileInfo - gateway to cfs32.dll GetFileIfo function
%
% The CFS filing system is copyright Cambridge Electronic Design.
% See the Cambridge Electonic Design CFS manual for further details
% (www.ced.co.uk)
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 03/07
% Copyright © The Author & King's College London 2007
% -------------------------------------------------------------------------
[nchan, nVars, nDSVars, nDS]=calllib('CFS32','GetFileInfo',...
    fid, 0, 0, 0, 0);

return
end
