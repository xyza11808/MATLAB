function list=scFindMatchingFs(channels, interval)
% scFindMatchingFs Helper function for sigTOOL uicontrols
%
% scFindMatchingFs finds waveform data with matching sample rates
%
% Example:
% ChanList=scFindMatchingWaveforms(channels, interval)
% ChanList=scFindMatchingWaveforms(fhandle, interval)
% where:
%   channels is a sigTOOL data cell array
%   fhandle is the handle of a sigTOOL data view to take the channels from
%   interval is the sample interval to match
%
% ChanList is a vector of waveform channel numbers with matching sample
% rates
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

[fhandle channels]=scParam(channels);

list=zeros(1,length(channels));
for i=1:length(channels)
    if ~isempty(channels{i}) &&...
            ~isempty(channels{i}.hdr.adc) &&...
            prod(channels{i}.hdr.adc.SampleInterval)==interval
        list(i)=i;
    end
end
list=list(list>0);
