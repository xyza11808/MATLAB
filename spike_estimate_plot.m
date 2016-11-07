
if ~isdir('./Spike_estimate_plot/')
    mkdir('./Spike_estimate_plot/');
end
cd('./Spike_estimate_plot/');

nF = size(data_aligned,3);
xticks = 0:frame_rate:nF;
Ticklabels = xticks/frame_rate;

for nROI = 1 : 102
% nROI = 10;
% Tr = 2;
% FFTrace = squeeze(data_aligned(Tr,nROI,:));
% SpikeTrain = squeeze(nnspike(Tr,nROI,:));
% figure('position',[430 100 1150 1000]);
% subplot(2,1,1);
% plot(FFTrace);
% 
% subplot(2,1,2);
% stem(SpikeTrain);

close all;
cROIFFColor = squeeze(data_aligned(:,nROI,:));
cROISPColor = squeeze(nnspike(:,nROI,:));
figure('position',[250 350 1500 700]);

subplot(1,2,1)
imagesc(cROIFFColor,[0 min(300,max(cROIFFColor(:)))]);
set(gca,'xtick',xticks,'xticklabel',Ticklabels);
xlabel('Time (s)');
ylabel('# Trials');
set(gca,'FontSize',20)
colorbar;


subplot(1,2,2)
imagesc(cROISPColor,[5 20]);
set(gca,'xtick',xticks,'xticklabel',Ticklabels);
set(gca,'xtick',xticks,'xticklabel',Ticklabels);
xlabel('Time (s)');
ylabel('# Trials');
set(gca,'FontSize',20)
colorbar;

suptitle(sprintf('ROI%d Fluo trace and estimated spike',nROI));
saveas(gcf,sprintf('ROI%d spike plot',nROI));
saveas(gcf,sprintf('ROI%d spike plot',nROI),'png');


end
cd ..;


%%
nF = size(data_aligned,3);
xt = (1:nF)/frame_rate;
nROI = 44;
nTr = 176;

close;
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