function FirstSampleTime=scGetFirstSampleTime(channels)
% scGetFirstSampleTime returns the time of the first continuous waveform sample
%
% Example:
% FirstSampleTime=scGetFirstSampleTime(channels)
% where
% channels is a sigTOOL channel cell array (or cell array element)
%
% Returns FirstSampleTime: the time of the first sample on a continuous
% waveform channel in channels [i.e. the minimum of the
% values for channels{}.tim(1,1)].
%
% If FirstSampleTime can not be determined (because there are no continuous
% waveforms in the input, it will be set to its default of zero.
%
% With continuous waveforms, there is no guarantee that sampling started at
% time zero e.g. a section of channels may have been exported from another
% application representing the period 10-20s. FirstSample should then be
% used to correct for the 'missing' channels elements when converting from
% times to indices into the relevant channels vector. scGetTimePeriod does this
% automatically
% Note that FirstSample is only of use on continuous waveforms (or when
% handling a single column of channels derived from a episodic or framed
% waveform).
%
% See also scGetTimePeriod
%
%-------------------------------------------------------------------------
% Author: Malcolm Lidierth 09/06
% Copyright © The Author & King’s College London 2006-2007
%-------------------------------------------------------------------------
%
% Acknowledgements:
% Revisions:

if length(channels)==1 && isstruct(channels)
    channels={channels};
end
    
FirstSampleTime=Inf;
for i=1:length(channels)
    if ~isempty(channels{i}) &&...
            ~isempty(strfind(channels{i}.hdr.channeltype,...
                'Continuous Waveform')) &&...
            ~isempty(channels{i}.tim)
        FirstSampleTime=min(channels{i}.tim(1,1),FirstSampleTime);
    end
end
if FirstSampleTime==Inf
    FirstSampleTime=0;
end