function ret=CFSCloseCFSFile(fid)
% CFSCloseCFSFile closes a cfs file
% 
% Example:
% ret=CFSCloseCFSFile(fid)
% where fid is the file handle
%
% The CFS filing system is copyright Cambridge Electonic Design.
% See the Cambridge Electonic Design CFS manual for further details
% (www.ced.co.uk)
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 03/07
% Copyright © The Author & King's College London 2007
% -------------------------------------------------------------------------

ret=calllib('CFS32','CloseCFSFile',fid);
return
end
