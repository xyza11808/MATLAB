function w=gausswindow(N)
% gausswindow returns a gaussian window
%
% Example:
% w=gausswindow(N);
%   where N is the width of the window
% 
% The standard deviation of the window is fixed at 0.5
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 03/08
% Copyright © The Author & King's College London 2008-
% -------------------------------------------------------------------------

N = N-1;
n = (0:N)'-N/2;
w = exp(-(1/2)*(2*n/(N/2)).^2);
return
end