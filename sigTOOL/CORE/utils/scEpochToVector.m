function vec=scEpochToVector(channel, indices)
% scEpochToVector returns adc data as a vector of doubles
% 
% Example:
% vec=scEpochToVector(channel, indices)
%     returns the data indicated by indices
%     
%     channel is a sigTOOL data cell array element (or structure). Note
%     single channel.
%     
%     indices, if supplied, is a matrix of linear indices into channel.adc.
%     Each row of indices gives the first and last indices of a section of
%     data to return. The sections are vertically concatenated in the output 
%     vector
%
% It is anticipated that indices will generally indicate data sections of
% equal length and scEpochToVector will issue a warning if not.
%
%-------------------------------------------------------------------------
% Author: Malcolm Lidierth 09/07
% Copyright © The Author & King’s College London 2007-
%-------------------------------------------------------------------------
%
% Acknowledgements:
% Revisions:

error('Is this obsolete?');

if numel(channel)>1
    error('scChannelToVector: single channel required on input');
end

if iscell(channel)
    channel=channel{1};
end

if any(diff(indices(:,2)-indices(:,1)~=1))
    warning('scEpochToVector: data sections are not of equal length'); %#ok<WNTAG>
end

% Pre-allocate vec.
vec=zeros(sum(indices(:,2)-indices(:,1))+size(indices,1),1);
% Add data to vec
idx1=1;
for i=1:size(indices,1)
    vec(idx1:idx1+indices(i,2)-indices(i,1))=channel.adc(indices(i,1):indices(i,2))';
    idx1=idx1+indices(i,2)-indices(i,1)+1;
end

return
end