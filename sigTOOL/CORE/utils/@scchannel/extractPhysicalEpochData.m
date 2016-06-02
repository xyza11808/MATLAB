function [data npoints]=extractPhysicalEpochData(channel, varargin)
% extractPhysicalEpochData returns the adc data in an episodically sampled scchannel object
% 
% [data npoints epochs]=extractPhysicalEpochData(channel, epoch)
% [data npoints epochs]=extractPhysicalEpochData(channel, epoch1, epoch2)
% [data npoints epochs]=extractPhysicalEpochData(channel, epoch1, step, epoch2)
% 
% 
% Inputs:
%         channel is a scchannel object containing episodic data
%         epoch is the required epoch (e.g. 1, 2) or range of epochs (e.g. 1:10)
%                 Note that the 'end' statement can not be used with this form
%         epoch1 and epoch2 allow the the use of the end statement but it
%                 must be included as a string e.g.
%                     getEpochData(channel, 2, 'end') returns epochs 2:end
%                     where 'end' refers to the last valid epoch.
%         step if specified sets the increment e.g.
%                     getPhysicalEpochData(channel, 2, 2, 'end')
%                     returns epochs 2:2:end where 'end' refers to the last
%                     valid epoch as above.
%                     
% Ouputs:
%         data contains the scaled adc data in double precision with each epoch 
%         represented in columns
%         npoints and epochs are optional outputs. Each is a row vector.
%           npoints gives the number of valid data points in each column
%           epochs gives the physical epoch number of the returned data.
        
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

nd=ndims(channel.adc);
str=repmat({':'}, nd-1);
str{end+1}=epochs;

index=substruct('.', 'adc', '()', str);
data=subsref(channel, index);

if nargout>1
    index=substruct('.', 'hdr', '.', 'adc', '.', 'Npoints', '()', str);
    npoints=subsref(channel, index);
end

return
end