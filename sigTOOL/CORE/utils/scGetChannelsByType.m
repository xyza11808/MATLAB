function list=scGetChannelsByType(varargin)
% scGetChannelsByType returns a list of channels with a specified type
%
% Examples:
% list=scGetChannelsByType(fhandle, type)
% list=scGetChannelsByType(channels, type)
%
% Inputs:
% fhandle/channels
%       is a sigTOOL data view figure handle or channel list
% type
%       is the string to match in the hdr.channeltype field e.g. 'Waveform'
%       'Framed Waveform'
%       type may also be  one of: 'all', 'empty', 'episodic', 'triggered',
%                                 'list' or 'none'.
%
% Output:
% list is the list of matching channels (empty for type=='none')
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 06/07
% Copyright © The Author & King's College London 2007
% -------------------------------------------------------------------------
list=[];
if nargin<2
    return
end

[fhandle channels]=scParam(varargin{1});
if isempty(channels)
    return
end

targettype=varargin{2};

if ~iscell(targettype)
    targettype={targettype};
end

list=zeros(1,length(channels));
switch lower(targettype{1})
    case 'all'
        % Return numbers of all used channels
        for i=1:length(channels)
            if ~isempty(channels{i})
                list(i)=i;
            end
        end
    case 'empty'
        % Return all empty channels
        for i=1:length(channels)
            if isempty(channels{i})
                list(i)=i;
            end
        end
        % Always add an empty channel at the end
        list(end+1)=length(channels)+1;
    case 'episodic'
        for i=1:length(channels)
            if ~isempty(channels{i})
                if size(channels{i}.tim, 2)>1
                    list(i)=i;
                end
            end
        end
    case 'triggered'
         for i=1:length(channels)
            if ~isempty(channels{i})
                if size(channels{i}.tim,1)>1 &&...
                        size(channels{i}.tim, 2)==1 || size(channels{i}.tim, 2)==3 ||...
                        ~isempty(strfind(channels{i}.hdr.channeltype, 'Framed'))
                    list(i)=i;
                end
            end
         end
    case 'multiplexed'
         for i=1:length(channels)
            if ~isempty(channels{i}) && ~isempty(channels{i}.hdr.adc)
                if channels{i}.hdr.adc.Multiplex>1
                    list(i)=i;
                end
            end
         end
    case 'none'
        list=[];
    otherwise
        for i=1:length(channels)
            % Returns channels matching targettype(s)
            if ~isempty(channels{i})
                for k=1:length(targettype)
                    pattern=targettype{k};
                    if ~isempty(strfind(channels{i}.hdr.channeltype, pattern))
                        list(i)=i;
                    end
                end
            end
        end
end
list=list(list>0);
return
end

