
StimFrequency = double(behavResults.Stim_toneFreq);
TrChoices = double(behavResults.Action_choice);
ProbInds = double(behavResults.Trial_isProbeTrial);
IsProbRewardGiven = double(behavResults.IsProbRandReGiven);

Freqtypes = unique(StimFrequency);
disp(Freqtypes);
nFreqs = length(Freqtypes);
if mod(nFreqs,2)
    BoundFreq = Freqtypes(ceil(nFreqs/2));
end
BoundInds = StimFrequency == BoundFreq;
BoundChoice = TrChoices(BoundInds);
BoundRandReward = IsProbRewardGiven(BoundInds);
BoundData = smooth_data(BoundInds,:,:);
FrameScales = [start_frame+1,start_frame+round(1.5*frame_rate)];
BoundRespdata = max(BoundData(:,:,FrameScales(1):FrameScales(2)),[],3);
BoundMissTr = BoundChoice == 2;
BoundChoice = BoundChoice';
%%
if ~isdir('./Bound_ROIResp_Colorplot/')
    mkdir('./Bound_ROIResp_Colorplot/');
end
cd('./Bound_ROIResp_Colorplot/');

ROIAUC = zeros(size(BoundRespdata,2),2); % RealAUC; isAUCreverse
for nROI = 1 : size(BoundRespdata,2)
    cROIdata = squeeze(BoundData(:,nROI,:));
    
    hROI = figure;
    subplot(211)
    imagesc(cROIdata(BoundChoice == 0,:),[0 300]);
    ylabel('# Trials');
    title('Left');
    
    subplot(212)
    imagesc(cROIdata(BoundChoice == 1,:),[0 300]);
    ylabel('# Trials');
    title('Right');
    
    suptitle(sprintf('ROI%d',nROI));
    
    saveas(hROI,sprintf('ROI%d Boundary color plot save',nROI));
    saveas(hROI,sprintf('ROI%d Boundary color plot save',nROI),'png');
    close(hROI);
    
    ROIrespData = BoundRespdata(:,nROI);
     [ROCSummary,LabelMeanS]=rocOnlineFoff([ROIrespData(~BoundMissTr,:),BoundChoice(~BoundMissTr)]);
     ROIAUC(nROI,:) = [ROCSummary,double(LabelMeanS)];
end
%%
% save ROIAUCsave.mat ROIAUC -v7.3
ROIABS = ROIAUC(:,1);
ROIABS(ROIAUC(:,2) == 1) = 1 - ROIABS(ROIAUC(:,2) == 1);
hAUC = figure;
hist(ROIABS)
title(sprintf('Mean AUC = %.3f',mean(ROIABS)));
set(gca,'FontSize',18);
saveas(hAUC,'Session Boundary ROI AUC distribution');
saveas(hAUC,'Session Boundary ROI AUC distribution','png');
close(hAUC);

%%
% BoundMissTr = BoundChoice == 2;
% BoundChoice = BoundChoice';
BoundChoiceClf = fitcsvm(BoundRespdata(~BoundMissTr,:),BoundChoice(~BoundMissTr));
mdlLoss = kfoldLoss(crossval(BoundChoiceClf));
fprintf('The model correct rate is %.3f.\n',1-mdlLoss);
save ROIAUCClfsave.mat ROIAUC BoundChoiceClf -v7.3
cd ..;

%%
 [Imdata,~] = load_scim_data('d449.16_soma_randomprobe_920_90%_3x_026.tif');
dImdata = double(Imdata);
examData = squeeze(dImdata(:,:,10));
figure;imagesc(examData)
figure;imagesc(squeeze(mean(dImdata(:,:,1:100),3)))
MeanIm = squeeze(mean(dImdata(:,:,1:100),3));

%%
RawImfft = fftshift(fft2(examData));
MeanImfft = fftshift(fft2(MeanIm));
RawAmpIm = log(abs(RawImfft));
MeanAmppIm = log(abs(MeanImfft));
figure;imagesc(RawAmpIm);
colormap gray
figure;imagesc(MeanAmppIm);
colormap gray

%%
AmpDiff = RawAmpIm - MeanAmppIm;
% figure;imagesc(AmpDiff);
% colormap gray
BrightFreqs = AmpDiff < 0;
RawImfftBU = RawImfft;
RawImfft(BrightFreqs) = 0;
filterIm = ifft(fftshift(RawImfft));
AmpFiltIm = abs(filterIm);
figure;imagesc(AmpFiltIm,[-100 300])
colormap gray