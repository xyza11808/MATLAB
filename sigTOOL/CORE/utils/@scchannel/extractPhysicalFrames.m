function [data tb epochs trig]=extractPhysicalFrames(channel, trig, duration, pretime)
% extractPhysicalFrames extracts framed adc data from valid epochs
%
% Example:
% [data tb epochs trig]=extractPhysicalFrames(channel, trig, duration, pretime)
% where
%     channel     is a sigTOOL channel object
%     trigger     is a vector of trigger time
%     duration    is the duration of the sweeep
%     pretime     is the pre-trigger time
%  All times are in units defined by getTimeUnits(channel) [usually seconds]
%
% Returns
%     data        a double matrix. Each coloumn is a frame of data
%     tb          the timebase for each frame of data (pretime to
%                   duration-pretime) in seconds
%     epochs      the physical numbers of the epochs from which data was
%                   taken for each frame
%     trig        an updated copy of the input, with invalid trigger times
%                   omitted
%
% Note that, in the case of multiplexed channels, extractValidFrames
% returns data for the currently selected subchannel as set in
% channel.CurrentSubchannel.
%
% See also scchannel/getTimeUnits
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 01/08
% Copyright © The Author & King's College London 2008
% -------------------------------------------------------------------------

% Get the indices
[idx epochs trig]=findPhysicalFrameIndices(channel, trig, duration, pretime);
if isempty(idx)
    % No valid frames
    data=[];
    tb=[];
    return
end

% Correct for the selected subchannel if required and set up data matrix
if channel.CurrentSubchannel>0
    inc=channel.hdr.adc.Multiplex;
    idx=idx+(channel.CurrentSubchannel-1);
    data=zeros(size(idx,1),  fix((idx(1,2)-idx(1,1))/inc)+1);
else
    % If channel.CurrentSubchannel is set to zero, data for all subchannels
    % will be returned in interleaved order. This behaviour may not be
    % maintained.
    inc=1;
    data=zeros(size(idx,1), fix((idx(1,2)-idx(1,1))/inc)+1);
end

% Initially fill data with the linear indices
if size(channel.adc, 2)>1
    idx(:,1)=sub2ind(size(channel.adc), idx(:,1), epochs);
    idx(:,2)=sub2ind(size(channel.adc), idx(:,2), epochs);
end
for k=1:size(idx,1)
    data(k,:)=idx(k,1):inc:idx(k,2);
end

% Get the data
data=channel.adc(data);

if isvector(data)
    % Make sure we have a column vector
    data=data';
end

% Calculate the timebase (s)
interval=getSampleInterval(channel)/channel.tim.Units;
tb=-pretime:interval:-pretime+((size(data, 2)-1)*interval);

return
end
