function idx=findFirstChannel(varargin)
% findFirstChannel method returns the index of the first valid channel on input
% 
% Example:
% idx=findFirstChannel(channels{:});
% 
% findFirstChannel(channels{:}) returns 1 if the first element contains an
%    scchannel object
% findFirstChannel(channels{54:102}) returns 1 if the element 54 contains an
%    scchannel object
% findFirstChannel([], '', 10, channels{:}) returns 4 if the channels{1}
%   contains an scchannel object
% Returns zero if no scchannel objects are present on input.
%
% 
% The findFirstChannel method is shadowed by a function which deals
% with cases where no scchannel object is contained in the input
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 11/09
% Copyright © The Author & King's College London 2009-
% -------------------------------------------------------------------------

for idx=1:length(varargin)
    if isa(varargin{idx}, 'scchannel');
        break
    end
end

return
end
