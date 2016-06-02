function update(obj)
% update method for jpeth objects
% 
% Example:
% update(obj)
% 
% updates the plot of a jpeth object using the current settings in 
% the same figure or uipanel as the latest call to plot.
% If plot has not been called yet, update will emulate the initial call
%
% See also jpeth
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 02/09
% Copyright © The Author & King's College London 2009-
% -------------------------------------------------------------------------

if ~isempty(obj.handle)
    % Use latest figure/uipanel
    plot(obj.handle, obj);
else
    % Plot not called yet so emulate initial call
    plot(obj);
    if ~isempty(inputname(1))
        assignin('caller', inputname(1), obj);
    end
end
return
end