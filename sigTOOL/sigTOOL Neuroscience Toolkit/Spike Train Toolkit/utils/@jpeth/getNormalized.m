function matrix=getNormalized(obj)
% getNormalized methods for the jpeth class
%
% Example:
% matrix=getNormalized(obj)
%   returns the normalized coincidence matrix i.e. the raw matrix 
%   scaled by product of the standard deviations of the peths.
%   Normalized values are therefore correlation coefficients with a
%   range of -1 to 1.
%
%
% See also jpeth
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 02/09
% Copyright © The Author & King's College London 2009-
% -------------------------------------------------------------------------


matrix=getCorrected(obj);
N=obj.nsweeps;
sd = sqrt((obj.sqpeth2 - obj.peth2.*obj.peth2/N)'*...
    (obj.sqpeth1 - obj.peth1.*obj.peth1/N)); 
matrix = matrix./sd;
return
end