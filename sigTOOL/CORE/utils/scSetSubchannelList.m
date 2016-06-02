function channels=scSetSubchannelList(varargin)
% scSetSubchannelList sets the current subchannels
% 
% Example
% channels=scSetSubchannelList(fhandle, list)
% channels=scSetSubchannelList(channels, list)
% sets the current subchannel setting for each channel to the value in
% the corresponding element of list which should be a cell array
% 
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 01/08
% Copyright © The Author & King's College London 2008-
% -------------------------------------------------------------------------

[fhandle channels]=scParam(varargin{1});
list=varargin{2};
for i=1:length(channels)
    if ~isempty(channels{i})
        channels{i}.CurrentSubchannel=list{i};
    end
end
