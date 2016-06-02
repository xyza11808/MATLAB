function idx=findFirstChannel(varargin)
% findFirstChannel returns 0
% 
% idx=findFirstChannel(in)
% 
% will return zero if none of the elements in IN are scchannel objects
% This function shadows the findFirstChannel method for scchannel objects

if iscell(varargin) && nargin==1
    % Try to invoke scchannel method
    findFirstChannel(varargin{:});
else
    idx=0;
end

return
end