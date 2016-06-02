function times=extractPhysicalEpochTimes(channel, varargin)
% extractPhysicalEpochTimes returns the tim data in a channel object
% 
% [data epochs]=extractPhysicalEpochTimes(channel, epoch)
% [data epochs]=extractPhysicalEpochTimes(channel, epoch1, epoch2)
% [data epochs]=extractPhysicalEpochTimes(channel, epoch1, step, epoch2)
% 
%-------------------------------------------------------------------------
% Author: Malcolm Lidierth 09/06
% Copyright © The Author & King’s College London 2006-2007
%-------------------------------------------------------------------------
        
for k=1:length(varargin)
    if strcmp(varargin{k},'end')
        if strcmp(channel.EventFilter.Mode,'on')
            idx=find(channel.EventFilter.Flags);
            varargin{k}=length(idx);
        else
            varargin{k}=size(channel.adc, ndims(channel.adc));
        end
    end
end

switch nargin
    case 1
        epochs=1;
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
end

str={epochs ':'};

index=substruct('.', 'tim', '()', str);
times=subsref(channel, index);


return
end