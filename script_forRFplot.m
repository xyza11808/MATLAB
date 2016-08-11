
SingDBData = squeeze(AllRFMean(:,2,:,:));

%%
[fn,fn_path]=uigetfile('*.*');
sound_array=textread([fn_path,'\',fn]);
FreqType = unique(sound_array(:,1));
FerqTick = FreqType/1000;

%%
ROINum = 4;
FrameRate = 55;
cROIData = squeeze(SingDBData(25,:,:));
xtick = 0 : FrameRate : size(cROIData,2);
xticklabel = xtick/FrameRate;
ytick = 1 : size(cROIData,1);


h_RFMean = figure;
imagesc(cROIData,[0 100]);
colorbar;
set(gca,'xtick',xtick,'xticklabel',xticklabel,'ytick',ytick,'yticklabel',cellstr(num2str(FerqTick(:),'%.2f')));
line([FrameRate FrameRate],[0 size(cROIData,1)+2],'LineWidth',1.5,'color',[.8 .8 .8]);
xlabel('Time (s)');
ylabel('Frequency (KHz)');
set(gca,'FontSize',20);
title(sprintf('ROI %d',ROINum));

%%
TargetFreq = 8000;
TargetMeanTrace = cROIData(FreqType == TargetFreq,:);
h_targetMean = figure;
plot(1:length(TargetMeanTrace),TargetMeanTrace,'color','b','LineWidth',1.5);
line([FrameRate FrameRate],[-20 150],'color',[.8 .8 .8],'LineWidth',1.5);
set(gca,'xtick',xtick,'xticklabel',xticklabel);
ylim([-20 150]);
xlabel('Time (s)');
ylabel('\DeltaF/F_0');
set(gca,'FontSize',20);
title(sprintf('ROI %d %dHz Mean Trace',ROINum,TargetFreq));
saveas(gcf,sprintf('ROI%d_%dHz_meanTrace',ROINum,TargetFreq),'png');
saveas(gcf,sprintf('ROI%d_%dHz_meanTrace',ROINum,TargetFreq),'fig');

%%
TargetFreq = 8000;
TFreqInds = FreqType == TargetFreq;
ALLROISingleFreq = squeeze(AllRFMean(:,2,TFreqInds,:));
NormalizedData = ALLROISingleFreq ./ repmat(max(ALLROISingleFreq,[],2),1,size(ALLROISingleFreq,2));

FrameRate = 55;
% cROIData = squeeze(SingDBData(25,:,:));
xtick = 0 : FrameRate : size(NormalizedData,2);
xticklabel = xtick/FrameRate;
ytick = 1 : size(NormalizedData,1);

f_popu = figure;
imagesc(NormalizedData,[0 1]);
set(gca,'xtick',xtick,'xticklabel',xticklabel);
xlabel('Time (s)');
ylabel('# ROIs');