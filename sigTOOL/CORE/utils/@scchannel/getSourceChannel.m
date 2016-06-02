function schan=getSourceChannel(varargin)
% getSourceChannel method for scchannels
% 
% Example:
% schan=getSourceChannel(obj);
% schan=getSourceChannel(obj1, obj2,[], obj3);
% 
% Typically, getSourceChannel will be used to analyze a cell array of
% scchannels:
% schan=getSourceChannel(channels{:})
% 
% The output is a row vector of source channel numbers.
% Zero is returned if a channel has no source or the cell array entry is
% empty
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 01/10
% Copyright © The Author & King's College London 2010-
% -------------------------------------------------------------------------

schan=zeros(size(varargin));
for k=1:length(varargin)
    if isempty(varargin{k})
        schan(k)=0;
    else
        schan(k)=varargin{k}.hdr.Group.SourceChannel;
    end
end