function ChannelList=scGenerateChannelList(fhandle, ChannelListIn)
% scGenerateChannelList generates the list of channels to display
% 
% Examples:
% list=scGenerateChannelList(fhandle);
% list=scGenerateChannelList(fhandle, list);
% 
% scGenerateChannelList returns the list of channels to display in a
% sigTOOL data view. By default, the first 32 channels are displayed.
% If list is supplied on input, these will be returned in the correct
% order with no repetitions
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 01/10
% Copyright © The Author & King's College London 2010-
% -------------------------------------------------------------------------

[fhandle channels]=scParam(fhandle);


k=findFirstChannel(channels{:});
ChannelList=[];

ngroup=1;
for idx=k:length(channels)
    if ~isempty(channels{idx}) && channels{idx}.hdr.Group.Number>ngroup
        ngroup=ngroup+1;
    end
end

count=1;

if ngroup>1
    for grp=1:ngroup
        for n=k:length(channels)
            if ~isempty(channels{n}) && channels{n}.hdr.Group.Number==grp...
                    && channels{n}.hdr.Group.SourceChannel==0
                ChannelList(count)=n; %#ok<AGROW>
                count=count+1;
                [ChannelList count]=getDerivedChannels(channels, ChannelList, count, n);
            end
        end
    end
end

if isempty(ChannelList)
count=1;
for n=k:numel(channels)
    if ~isempty(channels{n});
        ChannelList(count)=n; %#ok<AGROW>
        count=count+1;
    end
end
end

if nargin<2
ChannelList=ChannelList(1:min([numel(ChannelList),32]));
end


if nargin==2
    ChannelList=ChannelList(ismember(ChannelList, ChannelListIn));
end

if ~isempty(fhandle)
    setappdata(fhandle, 'ChannelList', ChannelList);
end

return
end

%--------------------------------------------------------------------------
function [ChannelList count]=getDerivedChannels(channels, ChannelList,count, n)
%--------------------------------------------------------------------------
for k=1:numel(channels)
    if ~isempty(channels{k}) && channels{k}.hdr.Group.SourceChannel==n
        ChannelList(count)=k; %#ok<AGROW>
        count=count+1;
        [ChannelList count]=getDerivedChannels(channels, ChannelList, count, k);
    end
end
return
end
%--------------------------------------------------------------------------
