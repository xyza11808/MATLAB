function matrix=getErrors(obj)
% getErrors method for jpeth class
% 
% Example:
% matrix=getErrors(obj)
%   returns the binomial errors.
% 
% Statistical measures usually rely on having 0 or 1 coincidences in any
% bin in a single sweep but, with finite bin widths, more than one
% coincidence may occur. getErrors returns the number of occasions
% when more than one coincidence occurred in a single bin in a single sweep.
%
%
% See also jpeth
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 02/09
% Copyright © The Author & King's College London 2009-
% -------------------------------------------------------------------------


matrix=full(sum(obj.data.matrix2'>1)'*sum(obj.data.matrix1'>1));
return
end
