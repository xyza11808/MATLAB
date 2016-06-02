function list=scGetSubchannelList(varargin)
% scGetSubchannelList returns the current subchannel for multiplexed channels
% 
% Examples:
% list=scGetSubchannelList(fhandle)
% list=scGetSubchannelList(channels)
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 03/08
% Copyright © The Author & King's College London 2008-
% -------------------------------------------------------------------------

[fhandle channels]=scParam(varargin{1});

for i=1:length(channels)
    if ~isempty(channels{i})
        list{i}=channels{i}.CurrentSubchannel;
    end
end
