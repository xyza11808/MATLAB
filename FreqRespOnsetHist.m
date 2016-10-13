function SigROIinds = FreqRespOnsetHist(DataAll,TrialFreq,TrialOutcome,AlignOnset,FrameRate,varargin)
% this function will be used for calculate the onset response hist plot and
% calculate a relative range to represente sound-responsive neuron
% population

TrialFreq = double(TrialFreq);
CorrTrInds = TrialOutcome == 1;
CorrTrData = DataAll(CorrTrInds,:,:);
CorrTrTypes = TrialFreq(CorrTrInds);
AllTrialTypes = unique(CorrTrTypes);
FreqNum = length(AllTrialTypes);
[CorrTrialsNum,ROINum,FrameNum] = size(CorrTrData);

MeanTraceDataSet = zeros(FreqNum,ROINum,FrameNum);
for nnn = 1 : FreqNum
    cfreqinds = CorrTrTypes == AllTrialTypes(nnn);
    MeanTraceDataSet(nnn,:,:) = squeeze(mean(CorrTrData(cfreqinds,:,:)));
end
SoundOffF = round(AlignOnset + 0.3*FrameRate);
SoundOffResponse = squeeze(MeanTraceDataSet(:,:,SoundOffF));

%%
h_hist = figure;
hdata = histogram(SoundOffResponse(:),30);
xx = get(gca,'xlim');
xlim([-200 xx(2)]);
xlabel('Cell Response');
ylabel('Cell Count');

%%
[Counts, Centers] = hist(SoundOffResponse(:),30);
[~,inds] = max(Counts);
TargetValue = Centers(inds+1);
SigRespInds = SoundOffResponse > TargetValue;
SigROIinds = sum(SigRespInds) > 0;
fprintf('Significant ROI number is %d out of %d ROIs.\n',sum(SigROIinds),length(SigROIinds));