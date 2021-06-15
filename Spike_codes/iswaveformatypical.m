function varargout = iswaveformatypical(waveform,timewin,IsNormedwave)
% three criterias were used for atypical waveform check,
% Ref:  Trainito et al., 2019, Current Biology 29, 1¨C10

% adjust baseline to 0
BaselineAvgInds = min(abs(timewin(1)),10);
waveform = waveform - mean(waveform(1:BaselineAvgInds)); % adjust baseline to 0 position

if IsNormedwave
    % the input wavefrom is already normalized by amplitude
    
    toughInds = abs(timewin(1))+1;
    [~, postPeakInds] = max(waveform(toughInds:end));
    postPeakIndex = postPeakInds + toughInds-1;
    NormedWave = waveform;
else
   % normalize the waveform using amplitude
%     [~,toughInds] = min(waveform);
    toughInds = abs(timewin(1))+1;
    [postPeakValue, postPeakInds] = max(waveform(toughInds:end));
    postPeakIndex = postPeakInds + toughInds-1;

    WaveAmplitude = postPeakValue - waveform(toughInds);
    NormedWave = waveform / WaveAmplitude; % normalize the waveform using wave amplitude
    
end
WaveLen = numel(NormedWave);

upsamplexx = 0:0.2:WaveLen;
upsampleWave = spline(1:WaveLen,NormedWave,upsamplexx);
if any(isinf(NormedWave)) || any(isnan(upsampleWave))
    Isatypical = 1;
    atypicalVec = [-1,-1,-1,-1];
    if nargout == 1
        varargout{1} = Isatypical;
    elseif nargout == 2
        varargout{1} = Isatypical;
        varargout{2} = atypicalVec;
    end

    return;
end
[~,upsample_toughInds] = min(abs(upsamplexx - toughInds));
[~,upsample_postpeakInds] = min(abs(upsamplexx - postPeakIndex));

Isatypical = 0;
atypicalVec = [0,0,0,0];
% criteria 1
if abs(upsampleWave(upsample_toughInds)) < abs(upsampleWave(upsample_postpeakInds))
    Isatypical = 1;
    atypicalVec(1) = 1;
end

% criteria 2
[pks,~] = findpeaks(upsampleWave,upsamplexx,'MinPeakProminence',0.01);
if length(pks) >= 6
    Isatypical = 1;
    atypicalVec(2) = 1;
end

% criteria 3
Tough2peakInds = upsample_toughInds:upsample_postpeakInds;
pks = findpeaks(upsampleWave(Tough2peakInds),upsamplexx(Tough2peakInds),'MinPeakProminence',0.01);
if ~isempty(pks)
    Isatypical = 1;
    atypicalVec(3) = 1;
end

% criteria 4
% in case there are plateau period between tough and postpeak
tough2peakTrace_diff = [0,diff(upsampleWave(Tough2peakInds))];
tough2peakTrace_xx = upsamplexx(Tough2peakInds);
pks = findpeaks(tough2peakTrace_diff/0.2,tough2peakTrace_xx,'MinPeakProminence',0.03);
if length(pks) > 1
    Isatypical = 1;
    atypicalVec(4) = 1;
end

if nargout == 1
    varargout{1} = Isatypical;
elseif nargout == 2
    varargout{1} = Isatypical;
    varargout{2} = atypicalVec;
end








