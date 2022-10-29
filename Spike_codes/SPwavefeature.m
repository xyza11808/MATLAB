function wavefeature = SPwavefeature(waveform,timewin,toughpeakinds)
% this function is used to extract waveform features 
% used features:
%       tough-to-peak time:             tough2peakT
%       postPeak-to-reflection time:    postHyperT  % but what's the
%               definition of reflection time ???
%       pre-tough-positive-peak:        pre2post_peakratio, usually an
%           indication of neuritic spike
BaselineAvgInds = min(abs(timewin(1)),10);
waveform = waveform - mean(waveform(1:BaselineAvgInds)); % adjust baseline to 0 position
% 
% [~, toughInds] = min(waveform(10:end)); %abs(timewin(1))+1;
% toughInds = toughInds + 9;
% [postPeakValue, postPeakInds] = max(waveform(toughInds:end));
% postPeakIndex = postPeakInds + toughInds-1;
toughInds = toughpeakinds(1);
postPeakIndex = toughpeakinds(2);

wavefeature.toughPeakInds = [toughInds, postPeakIndex];
wavefeature.WaveAmplitude = postPeakValue - waveform(toughInds);
wavefeature.NormWaves = waveform / wavefeature.WaveAmplitude; % normalize the waveform using wave amplitude

wavefeature.tough2peakT = postPeakInds-1; % sample number, not in time

% calculate reflection time
% using second deviation peak after positive peak
WaveSecondPeak = [0,0,diff(wavefeature.NormWaves,2)];

[~,ReflecInds] = max(WaveSecondPeak(postPeakIndex:end));

if isempty(ReflecInds)
    wavefeature.postHyperT = length(waveform) - postPeakIndex;
else
    wavefeature.postHyperT = ReflecInds - 1;
end

% check whether there is a positive peak exist before tough
[pks,locs] = findpeaks(wavefeature.NormWaves(1:toughInds),'MinPeakProminence',0.05);

if ~isempty(pks)
    UsedPeaklocs =  locs(end);
    PeakAmp = wavefeature.NormWaves(UsedPeaklocs);
    pre2post_posPeakRatio = PeakAmp / wavefeature.NormWaves(postPeakIndex);
    wavefeature.IsPrePosPeak = 1;
    wavefeature.pre2post_peakratio = pre2post_posPeakRatio;
else
    wavefeature.IsPrePosPeak = 0;
    wavefeature.pre2post_peakratio = 0;
end

