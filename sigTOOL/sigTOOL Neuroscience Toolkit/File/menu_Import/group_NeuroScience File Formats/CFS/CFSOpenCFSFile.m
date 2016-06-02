function fid=CFSOpenCFSFile(filename)
% CFSOpenCFSFile opens a cfs file and returns the handle
% 
% Example:
% fid=CFSOpenCFSFile(filename)
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

% 19.11.09 Get rid of dummy string
[fid, filename]=calllib('CFS32','OpenCFSFile',filename,0,0); %#ok<NASGU>
return
end