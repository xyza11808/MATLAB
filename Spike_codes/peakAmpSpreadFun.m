function SpreadLength = peakAmpSpreadFun(AllChnAmpData, toughPeakInds, MaxChnIndex)
% function to calculate the amplitude spread, which is the channel have 12%
% of the maximum channel amplitude

% UnitAllchnWaveData = AllchnData.UnitDatas; % SPNums,channel(384),spikewindowlength    

% Amplitude4AllSP = squeeze(AllChnAmpData(:,:,toughPeakInds(2)) - AllChnAmpData(:,:,toughPeakInds(1)));
% ChnAmp_spikeAvg = mean(Amplitude4AllSP);
try
    ChnAmp_spikeAvg = AllChnAmpData(:,toughPeakInds(2)) - AllChnAmpData(:,toughPeakInds(1));
catch ME
   fprintf('Something is wrong.\n'); 
end
MaximumAmp = ChnAmp_spikeAvg(MaxChnIndex);
AmpThres = MaximumAmp * 0.12;

LowerChnThresInds = find(ChnAmp_spikeAvg(1:MaxChnIndex) < AmpThres,1,'last');
if isempty(LowerChnThresInds)
    LowerChnThresInds = 0;
end
RealStartInds = LowerChnThresInds + 1;

HigherChnThresInds = find(ChnAmp_spikeAvg(MaxChnIndex:end) < AmpThres , 1, 'first');
if isempty(HigherChnThresInds)
    HigherChnThresInds = numel(ChnAmp_spikeAvg)+1;
else
    HigherChnThresInds = HigherChnThresInds + MaxChnIndex;
end
RealEndInds = HigherChnThresInds - 1;

if RealEndInds < RealStartInds
    fprintf('Something is wrong 2.\n'); 
end
SpreadLength = (RealEndInds - RealStartInds) * 20; % in um, for NP 1.0 probe





