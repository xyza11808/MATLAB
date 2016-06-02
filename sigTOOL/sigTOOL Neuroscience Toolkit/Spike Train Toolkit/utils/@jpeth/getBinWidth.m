function  b=getBinWidth(obj)
% getBinWidth method for jpeth objects
% 
% Example:
% t=getBinWidth(ml)
% returns the binwidth in seconds used to construct the jpeth object
% 
% NB If the tscale property is empty, getBinWidth returns an empty result.

% Note: If numel(b)>1, we have IEEE rounding issues
%
%
% See also jpeth
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 02/09
% Copyright © The Author & King's College London 2009-
% -------------------------------------------------------------------------

b=unique(diff(obj.tbase))*obj.tscale;
return
end
