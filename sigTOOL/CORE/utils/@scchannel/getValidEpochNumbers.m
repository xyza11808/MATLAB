function epochs=getValidEpochNumbers(channel, varargin)
% getValidEpochNumbers returns the physical numbers for valid epochs
% 
% epochs=getValidEpochNumbers(channel)
%       returns all valid epoch numbers
% epochs=getValidEpochNumbers(channel, n)
%       returns the nth valid epoch number
% epochs=getValidEpochNumbers(channel, n1, n2)
%       returns the n1th through n2th valid epoch numbers
% epochs=getValidEpochNumbers(channel, n1, step, n2)
%       returns every step valid epoch between the n1th and n2th
%           valid epoch numbers
%

if size(channel.adc, 2)==1
    epochs=1;
    return
end

for k=1:length(varargin)
    if strcmp(varargin{k},'end')
        if strcmp(channel.EventFilter.Mode,'on')
            idx=find(channel.EventFilter.Flags);
            varargin{k}=length(idx);
        else
            varargin{k}=size(channel.tim, 1);
        end
    end
end

switch nargin
    case 1
        if strcmp(channel.EventFilter.Mode,'on')
            idx=find(channel.EventFilter.Flags);
            epochs=1:length(idx);
        else
            epochs=1:size(channel.tim, 1);
        end
    case 2
        if iscell(varargin{1})
            epochs=cell2mat(varargin{1});
        else
            epochs=varargin{1};
        end
    case 3
        epochs=varargin{1}:varargin{2};
    case 4
        epochs=varargin{1}:varargin{2}:varargin{3};
    otherwise
        error('Too few arguments');
end


if strcmp(channel.EventFilter.Mode,'on')
    idx=find(channel.EventFilter.Flags);
    epochs=idx(epochs);
end

return
end