function matrix=getRaw(obj)
% getRaw methods for the jpeth class
%
% Example:
% matrix=getRaw(obj)
%   returns the raw coincidence matrix
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 02/09
% Copyright © The Author & King's College London 2009-
% -------------------------------------------------------------------------


matrix=full(obj.raw);
return
end