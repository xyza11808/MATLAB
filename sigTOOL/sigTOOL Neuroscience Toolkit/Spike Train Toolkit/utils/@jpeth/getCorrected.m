function matrix=getCorrected(obj)
% getCorrected methods for the jpeth class
%
% Example:
% matrix=getCorrected(obj)
%   returns the corrected coincidence matrix i.e. the raw matrix scaled
%   by subtracting the cross product of peth1 and peth2
%
%
% See also jpeth
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 02/09
% Copyright © The Author & King's College London 2009-
% -------------------------------------------------------------------------


matrix=getRaw(obj);
matrix=matrix-obj.peth2'*obj.peth1/obj.nsweeps;
return
end
