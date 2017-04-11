
%%
nF = size(data_aligned,3);
xt = (1:nF)/frame_rate;
nROI = 44;
nTr = 176;

% close;
figure('position',[430 330 1030 750]);
hold on;
yyaxis left
SmoothLine = smooth(squeeze(data_aligned(nTr,nROI,:)),17,'rloess');
plot(xt,squeeze(data_aligned(nTr,nROI,:)),'color',[.8 .8 .8],'LineWidth',0.5);
plot(xt,SmoothLine,'k','LineWidth',1.8);
ylabel('\DeltaF/F_0 (%)');

yyaxis right
stem(xt,squeeze(nnspike(nTr,nROI,:)),'Color','r');
legend('Fluo Trace','Estimated spike');
xlabel('Time (s)');
ylabel('Firing Rate(Hz)');
xlim([0 xt(end)]);
title(sprintf('ROI%d, Trial%d',nROI,nTr))
set(gca,'FontSize',20)

%%

% correct trials data extraction
CorrDataInds = trial_outcome == 1;
CorrFData = data_aligned(CorrDataInds,:,:);
CorrSData = nnspike(CorrDataInds,:,:);
CorrFreq = double(behavResults.Stim_toneFreq(CorrDataInds));

nROI = 44;
nTrCells = cell(10,1);
for ntrc = 1 : 10
    nTrs = (1+(ntrc - 1)*5):(ntrc*5);
    
    if ntrc*20 > size(CorrFData,1)
        nTrs(nTrs > size(CorrFData,1)) = [];
    end
    nTrCells{ntrc} = nTrs;
end

%
%%
Frame5sNumber = 5;
for nTrUse = 1 : 10
    cTrs = nTrCells{nTrUse};
    if isempty(cTrs)
        return;
    end
    SelectFData = squeeze(CorrFData(cTrs,nROI,:));
    SelectSData = squeeze(CorrSData(cTrs,nROI,:));
    VecFdata = reshape(SelectFData',[],1);
    SmoothLine = smooth(VecFdata,17,'rloess');
    VecSdata = reshape(SelectSData',[],1);
    SpikeUpRatio = max(SmoothLine)/max(VecSdata)/1.5;
    UpscaleSdata = VecSdata*SpikeUpRatio;
    xt = (1:length(VecFdata))/frame_rate;
    hsingleTrace = figure;
    hold on
    plot(xt,SmoothLine);
    plot(xt,UpscaleSdata,'m');
    xscales = get(gca,'xlim');
    line([xscales(2),xscales(2)]+5,[0 100],'color','k','lineWidth',1.8);
    line([xscales(2),xscales(2)+Frame5sNumber]+5,[0 0],'Color','k','lineWidth',1.8);
    line([xscales(2),xscales(2)]+5,[0 (-5*SpikeUpRatio)],'Color','k','lineWidth',1.8);
    text(xscales(2)+6,50,{'%100'; '\DeltaF/F_0'},'HorizontalAlignment','left');
    text(xscales(2)+6,(-2.5*SpikeUpRatio),{'5 estimated';'spike'},'HorizontalAlignment','left');
    text(xscales(2)+8.5,10,sprintf('%ds',Frame5sNumber),'HorizontalAlignment','left');
    axis off
    box off
    saveas(hsingleTrace,sprintf('Trace example%d plots',nTrUse));
    saveas(hsingleTrace,sprintf('Trace example%d plots',nTrUse),'pdf');
    saveas(hsingleTrace,sprintf('Trace example%d plots',nTrUse),'png');
    close(hsingleTrace);
end

%%
Frame5sNumber = 5;
UsrTrInds = nTrCells([6,7]);
ybase = 0;
hsingleTrace = figure;
hold on
for nTrUse = 1 : length(UsrTrInds)
    cTrs = nTrCells{nTrUse};
    if isempty(cTrs)
        return;
    end
    SelectFData = squeeze(CorrFData(cTrs,nROI,:));
    SelectSData = squeeze(CorrSData(cTrs,nROI,:));
    VecFdata = reshape(SelectFData',[],1);
    SmoothLine = smooth(VecFdata,17,'rloess');
    VecSdata = reshape(SelectSData',[],1);
    SpikeUpRatio = max(SmoothLine)/max(VecSdata)/1.5;
    UpscaleSdata = VecSdata*SpikeUpRatio;
    xt = (1:length(VecFdata))/frame_rate;
    
    plot(xt,SmoothLine + ybase,'b');
    plot(xt,UpscaleSdata + ybase,'m');
    ybase = ybase + max(SmoothLine) + 20;
    
end
%
xscales = get(gca,'xlim');
line([xscales(2),xscales(2)]+5,[0 100],'color','k','lineWidth',1.8);
line([xscales(2),xscales(2)+Frame5sNumber]+5,[0 0],'Color','k','lineWidth',1.8);
line([xscales(2),xscales(2)]+5,[0 (-5*SpikeUpRatio)],'Color','k','lineWidth',1.8);
text(xscales(2)+6,50,{'%100'; '\DeltaF/F_0'},'HorizontalAlignment','left');
text(xscales(2)+6,(-2.5*SpikeUpRatio),{'5 estimated';'spike'},'HorizontalAlignment','left');
text(xscales(2)+8.5,10,sprintf('%ds',Frame5sNumber),'HorizontalAlignment','left');
axis off
box off
%%
saveas(hsingleTrace,sprintf('Trace example sum plots'));
saveas(hsingleTrace,sprintf('Trace example sum plots'),'pdf');
saveas(hsingleTrace,sprintf('Trace example sum plots'),'png');
close(hsingleTrace);
%%  plot the colorplot for each frequency and corresponded spike raster, also corresponded mean trace
freqtypes = unique(CorrFreq);
nFrame = size(CorrFData,3);
nfreq = length(freqtypes);
xst = (1:nFrame)/frame_rate;

for nf = 1 : nfreq
    cFreq = freqtypes(nf);
    cfreqInds = CorrFreq == cFreq;
    cfreqFdata = squeeze(CorrFData(cfreqInds,nROI,:));
    cfreqSdata = squeeze(CorrSData(cfreqInds,nROI,:));
    yt = 1:size(cfreqFdata,1);
    hfff = figure('position',[270 100 1300 900]);
    
    subplot(2,2,1)
    imagesc(xst,yt,cfreqFdata,[0 300]);
    colorbar;
    line([start_frame start_frame],[0.5,size(cfreqFdata,1)+0.5],'Color',[.7 .7 .7],'LineWidth',1.6);
    xlabel('Time (s)');
    ylabel('#Trials');
    title(sprintf('cFreq = %d',cFreq));
    
    subplot(2,2,2)
    imagesc(xst,yt,cfreqSdata,[0 20]);
    colorbar;
    line([start_frame start_frame],[0.5,size(cfreqFdata,1)+0.5],'Color',[.7 .7 .7],'LineWidth',1.6);
    xlabel('Time (s)');
    ylabel('#Trials');
    title(sprintf('cFreq = %d',cFreq));
    
    subplot(2,2,3)
    plot(xst,mean(cfreqFdata),'k','LineWidth',1.4);
    yscales = get(gca,'ylim');
    line([start_frame start_frame]/frame_rate,yscales,'Color',[.7 .7 .7],'LineWidth',1.6,'LineStyle','--');
    xlabel('Time (s)');
    ylabel('Mean \DeltaF/F_0');
    title('Mean Fluo trace');
    
    subplot(2,2,4)
    plot(xst,mean(cfreqSdata),'k','LineWidth',1.4);
    yscales = get(gca,'ylim');
    line([start_frame start_frame]/frame_rate,yscales,'Color',[.7 .7 .7],'LineWidth',1.6,'LineStyle','--');
    xlabel('Time (s)');
    ylabel('Mean spike rate');
    title('Mean firing rate');
    
    saveas(hfff,sprintf('Freq%d_plotsave',cFreq));
    saveas(hfff,sprintf('Freq%d_plotsave',cFreq),'pdf');
    saveas(hfff,sprintf('Freq%d_plotsave',cFreq),'png');
    close(hfff);
end

%%
figure('position',[430 330 1030 750]);
hold on;
yyaxis left
plot(xt,VecFdata,'k','LineWidth',1.4);
yscales = get(gca,'ylim');
set(gca,'ylim',[0 yscales(2)]);
ylabel('\DeltaF/F_0 (%)');

yyaxis right
plot(xt,VecSdata,'Color','m');
legend('Fluo Trace','Estimated spike');
xlabel('Time (s)');
ylabel('Firing Rate(Hz)');
xlim([0 xt(end)]);
title(sprintf('ROI%d, Trial%dTo%d',nROI,nTrs(1),nTrs(end)))
set(gca,'FontSize',20)

%%

% % initial smooth trace plot
% [nTrs, nROIs, nFrames] = size(data_aligned);
% InitialSmData = zeros(nTrs, nROIs, nFrames);
% for nTr = 1 : nTrs
%     for nROI = 1 : nROIs
%         cTrace = squeeze(data_aligned(nTr,nROI,:));
%         InitialV = mean(cTrace(1:10));
%         cTrace(1:10) = InitialV;
%         InitialSmData(nTr,nROI,:) = cTrace;
%     end
% end
% 
% figure('position',[430 330 1030 750]);
% hold on;
% yyaxis left
% SmoothLine = smooth(squeeze(data_aligned(nTr,nROI,:)),17,'rloess');
% plot(xt,squeeze(data_aligned(nTr,nROI,:)),'color',[.8 .8 .8],'LineWidth',0.5);
% plot(xt,SmoothLine,'k','LineWidth',1.8);
% ylabel('\DeltaF/F_0 (%)');
% 
% yyaxis right
% stem(xt,squeeze(nnIniSMspike(nTr,nROI,:)),'Color','r');
% legend('Fluo Trace','Estimated spike');
% xlabel('Time (s)');
% ylabel('Firing Rate(Hz)');
% xlim([0 xt(end)]);
% title(sprintf('ROI%d, Trial%d',nROI,nTr))
% set(gca,'FontSize',20)
% 

%%
% if ~isdir('./Spike_estimate_plot/')
%     mkdir('./Spike_estimate_plot/');
% end
% cd('./Spike_estimate_plot/');
% 
% nF = size(data_aligned,3);
% xticks = 0:frame_rate:nF;
% Ticklabels = xticks/frame_rate;
% 
% for nROI = 1 : 102
% % nROI = 10;
% % Tr = 2;
% % FFTrace = squeeze(data_aligned(Tr,nROI,:));
% % SpikeTrain = squeeze(nnspike(Tr,nROI,:));
% % figure('position',[430 100 1150 1000]);
% % subplot(2,1,1);
% % plot(FFTrace);
% % 
% % subplot(2,1,2);
% % stem(SpikeTrain);
% 
% close all;
% cROIFFColor = squeeze(data_aligned(:,nROI,:));
% cROISPColor = squeeze(nnspike(:,nROI,:));
% figure('position',[250 350 1500 700]);
% 
% subplot(1,2,1)
% imagesc(cROIFFColor,[0 min(300,max(cROIFFColor(:)))]);
% set(gca,'xtick',xticks,'xticklabel',Ticklabels);
% xlabel('Time (s)');
% ylabel('# Trials');
% set(gca,'FontSize',20)
% colorbar;
% 
% 
% subplot(1,2,2)
% imagesc(cROISPColor,[5 20]);
% set(gca,'xtick',xticks,'xticklabel',Ticklabels);
% set(gca,'xtick',xticks,'xticklabel',Ticklabels);
% xlabel('Time (s)');
% ylabel('# Trials');
% set(gca,'FontSize',20)
% colorbar;
% 
% suptitle(sprintf('ROI%d Fluo trace and estimated spike',nROI));
% saveas(gcf,sprintf('ROI%d spike plot',nROI));
% saveas(gcf,sprintf('ROI%d spike plot',nROI),'png');
% 
% 
% end
% cd ..;
% 
