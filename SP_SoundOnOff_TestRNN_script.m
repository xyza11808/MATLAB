
ROI = 93;
ROIData = squeeze(nnspike(:,ROI,:));
SoundOnsetFrame = 29;
SoundDur = round(sound_array(:,3)/1000*29);

TrialNum = size(ROIData,1);
TrialFrame = size(ROIData,2);
TrBaseline = cumsum([0;ones(TrialNum-1,1)*TrialFrame]);
TrFrameOn = TrBaseline + SoundOnsetFrame;
TrFrameOff = TrBaseline + SoundOnsetFrame + SoundDur;
RawROITrace = reshape(ROIData',[],1);

figure;
plot(RawROITrace);
hold on
yscales = get(gca,'ylim');

OnsetFrame_x = repmat(TrFrameOn',2,1);
OnsetFrame_yy = repmat(yscales(:),1,TrialNum);
OnsetFrame_xAll = [OnsetFrame_x;nan(1,TrialNum)];
OnsetFrame_yyAll = [OnsetFrame_yy;nan(1,TrialNum)];

OffSetFrame_x = repmat(TrFrameOff',2,1);
OffSetFrame_yy = OnsetFrame_yy;
OffSetFrame_xAll = [OffSetFrame_x;nan(1,TrialNum)];
OffSetFrame_yyAll = [OffSetFrame_yy;nan(1,TrialNum)];

plot(reshape(OnsetFrame_xAll,[],1),reshape(OnsetFrame_yyAll,[],1),'b','linewidth',1);
plot(reshape(OffSetFrame_xAll,[],1),reshape(OffSetFrame_yyAll,[],1),'m','linewidth',1);

StdThres = std(RawROITrace(RawROITrace~=0));
line([1,numel(RawROITrace)],[StdThres StdThres],'Color',[0.1 0.8 0.1],'linewidth',1.4);

%%
% sucstract off-threshold spike values
ThresFactor = 1; % times of std for each ROI
ThresSubData = zeros(size(nnspike));
[NumTrials,NumROIs,NumFrames] = size(nnspike);

for cR = 1 : NumROIs
    cRData = squeeze(nnspike(:,cR,:));
    cRDataStd = std(cRData(cRData > 1e-6));
    cR_ThresSubData = cRData;
    cR_ThresSubData(cR_ThresSubData <= cRDataStd*ThresFactor) = 0;
    
    cR_ThresSubData = cR_ThresSubData/max(cR_ThresSubData(:)); % normalize to [0 1]
    ThresSubData(:,cR,:) = cR_ThresSubData;
end

ThresSubDataCell = cell(1,NumTrials);
SounOnOffLabelsCell = cell(1,NumTrials);
% sound_array
% 
FreqTypes = unique(sound_array(:,1));
FreqTypeNum = length(FreqTypes);
SoundOnOffFrames = zeros(FreqTypeNum,NumFrames);
for cTr = 1 : NumTrials
    cTrFreqsInds = sound_array(cTr,1) == FreqTypes;
    cTrOnOff_frame = frame_rate + [1,round(sound_array(cTr,3)*frame_rate/1000)];
    cTrLabel = SoundOnOffFrames;
    cTrLabel(cTrFreqsInds,cTrOnOff_frame(1):cTrOnOff_frame(2)) = 1;
    
    SounOnOffLabelsCell{cTr} = cTrLabel;
    
    ThresSubDataCell{cTr} = squeeze(ThresSubData(cTr,:,:));
    
end

%%
ThresSubDataCellNew = cell(1,NumFrames);
SounOnOffLabelsCellNew = cell(1,NumFrames);
SounOnOffLabelsAll = cat(3,SounOnOffLabelsCell{:});
% sound_array
% 
% SoundOnOffFrames = zeros(FreqTypeNum,NumFrames);
for cFr = 1 : NumFrames
    
    SounOnOffLabelsCellNew{cFr} = squeeze(SounOnOffLabelsAll(:,cFr,:));
    
    ThresSubDataCellNew{cFr} = (squeeze(ThresSubData(:,:,cFr)))';
    
end



%%



