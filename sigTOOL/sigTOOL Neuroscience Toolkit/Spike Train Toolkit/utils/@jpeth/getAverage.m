function matrix=getAverage(obj)
% getAverage methods for the jpeth class
%
% Example:
% matrix=getAverage(obj)
%   returns the averaged coincidence matrix i.e. the raw matrix divided by
%   the number of triggers
%
% See also jpeth
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 02/09
% Copyright © The Author & King's College London 2009-
% -------------------------------------------------------------------------
matrix=getRaw(obj)/obj.nsweeps;
return
end
