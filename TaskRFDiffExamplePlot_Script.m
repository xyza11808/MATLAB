% input data structure
% CSessionData.mat smooth_data data_aligned trial_outcome behavResults start_frame frame_rate NormalTrialInds
clear
clc

 [fn,fp,fi] = uigetfile('CSessionData.mat','Please select your ROI response summary plot');
 if ~fi
     return;
 else
     cd(fp);
     xcxc = load(fn);
     csData = xcxc.smooth_data;
     csAlignF = xcxc.start_frame ;
     csFrate = xcxc.frame_rate;
     csStimAll = double(xcxc.behavResults.Stim_toneFreq);
     csTrOutCome = xcxc.trial_outcome;
 end
 Freqtypes = unique(csStimAll);
 CorrTrInds = csTrOutCome == 1; %only correct trials will be included for plot
 cUsingdata = csData(CorrTrInds,:,:);
 cUsingStim = csStimAll(CorrTrInds);
 
 [rffn,rffp,~] = uigetfile('rfSelectDataSet.mat','Please select your rf data set');
 xrxr = load(fullfile(rffp,rffn));
 PassiveDataAll = xrxr.SelectData;
 PassiveFreq = double(xrxr.SelectSArray);
 PassiveStartF = xrxr.frame_rate;
 PassiveFrate = xrxr.frame_rate;
 
 %%
  % single trace example selection for plot
 nROI = 13;  % selct ROI to be plotted and compared
 nNumOfTr = 4;
 cROIdata = squeeze(cUsingdata(:,nROI,:));
 cROIpassData = squeeze(PassiveDataAll(:,nROI,:));
 
 cROITaskData = cell(length(Freqtypes),1);
 cROIPassiveData = cell(length(Freqtypes),1);
 for nmnm = 1 : length(Freqtypes)
     cStim = Freqtypes(nmnm);
     PassiveStimInds = abs(log2(PassiveFreq/cStim)) < 0.2;
     if ~sum(PassiveStimInds)
         fprintf('No Passive stimulus data for Task frequency %d, skip trial selection.\n',cStim);
         continue;
     else
         % TaskIndsSelction
         h_cfreq = figure('position',[400 200 900 800]);
         hold on;
         cTaskInds = cUsingStim == cStim;
         cROIcFreqData = cROIdata(cTaskInds,:);
         imagesc(cROIcFreqData,[0 min([max(cROIdata(:)),300])]);
         title({sprintf('cFreq = %d',cStim);'Please select five trials for example plot'});
         colorbar;
         %Select five trials for further plot
         cFreqTrInds = zeros(nNumOfTr,1);
         for np = 1 : nNumOfTr
             figure(h_cfreq)
             [fInds,TrInds] = ginput(1);
             cTr = round(TrInds);
             cFr = round(fInds);
             plot(cFr,cTr,'rp','MarkerSize',15,'LineWidth',2.4);
             cFreqTrInds(np) = cTr;
         end
         cROITaskData{nmnm} = cROIcFreqData(cFreqTrInds,:);
         close(h_cfreq);
         
         h_passive = figure('position',[400 200 900 800]);
         hold on;
         PassiveData = cROIpassData(PassiveStimInds,:);
         imagesc(PassiveData,[0 min([max(cROIdata(:)),300])]);
         colorbar;
         title({sprintf('cFreq = %d',cStim),'Passive data selection'});
         cPassiveInds = zeros(nNumOfTr,1);
         for nq = 1 : nNumOfTr
             figure(h_passive);
             [fInds,TrInds] = ginput(1);
             cTr = round(TrInds);
             cFr = round(fInds);
             plot(cFr,cTr,'rp','MarkerSize',15,'LineWidth',2.4);
             cPassiveInds(nq) = cTr;
         end
         cROIPassiveData{nmnm} = PassiveData(cPassiveInds,:);
         close(h_passive);
     end
 end
 
 %%
 % single trace example plot
 % plot the example trace for comparation
 TaskDataSet = cell2mat(cROITaskData);
 RFDataSet = cell2mat(cROIPassiveData);
 GapNanMatrix = nan(size(TaskDataSet,1),csFrate);
 TotaldataMatrix = [TaskDataSet,GapNanMatrix,RFDataSet];
 h = figure('position',[200 200 1200 900]);
 hold on;
 yBase = 0;
 yUpThres = zeros(length(Freqtypes),1); % the upper limits for each frequency type
 k = 1;
 for ntt = 1 : size(TotaldataMatrix,1)
     plot((TotaldataMatrix(ntt,:)+yBase),'k','LineWidth',2);
     yBase = yBase + max(TotaldataMatrix(ntt,:)) + 50;
     if ~mod(ntt,nNumOfTr)
         yUpThres(k) = yBase;
         k = k + 1;
     end
 end
 yLoThres = [0;yUpThres(1:end-1)];
 yCenter = (yUpThres + yLoThres)/2 - 50;
 xCenter = (-2.5)*ones(length(yCenter),1)*csFrate;
 centerStr = cellstr(num2str(Freqtypes(:)/1000,'%.2fkHz'));
 ylims = get(gca,'ylim');
 line([csAlignF csAlignF],[(ylims(1) - 50),(ylims(2) + 50)],'color',[.8 .8 .8],'LineWidth',1.8);
 PassiveStartF = size(TaskDataSet,2) + csFrate + PassiveFrate;
 line([PassiveStartF PassiveStartF],[(ylims(1) - 50),(ylims(2) + 50)],'color',[.8 .8 .8],'LineWidth',1.8);
 set(gca,'xtick',[0,csAlignF,csAlignF+csFrate,(size(TaskDataSet,2) + csFrate),PassiveStartF,(PassiveStartF+PassiveFrate)]...
     ,'xticklabel',{num2str((csAlignF/csFrate)*(-1),'%d'),0,1,-1,0,1});
 text(xCenter,yCenter,centerStr,'FontSize',16,'color','b');
 ylim([-50,yBase+150]);
 set(gca,'ytick',[],'ycolor','w')
 xlabel('Time(s)');
 TrialLength = size(TotaldataMatrix,2) + PassiveFrate;
line([TrialLength TrialLength],[100,200],'LineWidth',2,'color','k');
text((TrialLength),150,'100% \DeltaF/F_0');
line([TrialLength TrialLength+csFrate*1],[100,100],'LineWidth',2,'color','k');
text(TrialLength,50,'1 s');
subTitlexPos = [csAlignF+(csFrate*2.5),PassiveStartF+(PassiveFrate*2)];
text(subTitlexPos,[yBase+80 yBase+80],{'Task','Passive'},'Color','r','FontSize',18);

title('Example ROI plot---Task vs passive');
set(gca,'fontSize',20);
% add text for each frequency gruop
saveas(h,sprintf('ROI%d example plot of task and passive diff',nROI));
saveas(h,sprintf('ROI%d example plot of task and passive diff',nROI),'png');
% close(h);
save(sprintf('ROI%d example plot.mat',nROI),'cROITaskData','cROIPassiveData','v7.3');

%%
if ~isdir('./Example_ROI_Compplots/')
    mkdir('./Example_ROI_Compplots/');
end
cd('./Example_ROI_Compplots/');
% plot of the mean trace for plot
 nROI = 98;  % selct ROI to be plotted and compared
%  nNumOfTr = 4;
 cROIdata = squeeze(cUsingdata(:,nROI,:));
 cROIpassData = squeeze(PassiveDataAll(:,nROI,:));
 
 cROITaskDataMean = cell(length(Freqtypes),1);
 cROITaskDataSem = cell(length(Freqtypes),1);
 cROIPassDataMean = cell(length(Freqtypes),1);
 cROIPassDataSem = cell(length(Freqtypes),1);
 for nmnm = 1 : length(Freqtypes)
     cStim = Freqtypes(nmnm);
      PassiveStimInds = abs(log2(PassiveFreq/cStim)) < 0.2;
      cTaskInds = cUsingStim == cStim;
      
      cTaskData = cROIdata(cTaskInds,:);
      cTaskDataMean = mean(cTaskData);
      cTaskDataSem = std(cTaskData)/sqrt(size(cTaskData,1));
      cROITaskDataMean{nmnm} = cTaskDataMean;
      cROITaskDataSem{nmnm} = cTaskDataSem;
      
      cPassiveData = cROIpassData(PassiveStimInds,:);
      cPassiveDataMean = mean(cPassiveData);
      cPassiveDataSem = std(cPassiveData)/sqrt(size(cPassiveData,1));
      cROIPassDataMean{nmnm} = cPassiveDataMean;
      cROIPassDataSem{nmnm} = cPassiveDataSem;
 end
 %
 % plot the mean and sem shadow line plot
 TaskDataSetMean = cell2mat(cROITaskDataMean);
 TaskDataSetSem = cell2mat(cROITaskDataSem);
 RFDataSetMean = cell2mat(cROIPassDataMean);
 RFDataSetSem = cell2mat(cROIPassDataSem);
 GapNanMatrix = nan(size(TaskDataSetMean,1),csFrate);
 TotaldataMatrix = [TaskDataSetMean,GapNanMatrix,RFDataSetMean];
 TotalSemDataMatrix = [TaskDataSetSem,GapNanMatrix,RFDataSetSem];
 EqualGapSpace= max(max(TotaldataMatrix,[],2))+50;
 nTraces = size(TotaldataMatrix,1);
 
 PassiveStartF = size(TaskDataSetMean,2) + csFrate + PassiveFrate;
 PassStratInds = size(TaskDataSetMean,2) + csFrate;
 xTaskLength = 1 : size(TaskDataSetMean,2);
 xPassLength = (1 : size(RFDataSetMean,2)) + PassStratInds;
 xTaskPatch = [xTaskLength,fliplr(xTaskLength)];
 xPassPatch = [xPassLength,fliplr(xPassLength)];
 
 %
 h = figure('position',[200 200 1200 900]);
 hold on;
 yBase = 0;
 yUpThres = zeros(length(Freqtypes),1); % the upper limits for each frequency type
 k = 1;
 for nnnn = 1 : nTraces
     
     yTaskPatch = [(TotaldataMatrix(nnnn,1:size(TaskDataSetMean,2)) + TotalSemDataMatrix(nnnn,1:size(TaskDataSetMean,2))),...
         fliplr(TotaldataMatrix(nnnn,1:size(TaskDataSetMean,2)) - TotalSemDataMatrix(nnnn,1:size(TaskDataSetMean,2)))]+yBase;
     yPassPatch = [(TotaldataMatrix(nnnn,(PassStratInds+1):end) + TotalSemDataMatrix(nnnn,(PassStratInds+1):end)),...
         fliplr(TotaldataMatrix(nnnn,(PassStratInds+1):end) - TotalSemDataMatrix(nnnn,(PassStratInds+1):end))]+yBase;
     patch(xTaskPatch,yTaskPatch,1,'facecolor',[.8 .8 .8],...
              'edgecolor','none',...
              'facealpha',0.7);
     patch(xPassPatch,yPassPatch,1,'facecolor',[.8 .8 .8],...
              'edgecolor','none',...
              'facealpha',0.7);
     
     plot((TotaldataMatrix(nnnn,:)+yBase),'k','LineWidth',2);
     yUpThres(k) = yBase + 30;
     k = k + 1;
     yBase = yBase + EqualGapSpace;
 end
  yCenter = yUpThres;
 xCenter = (-2)*ones(length(yCenter),1)*csFrate;
 centerStr = cellstr(num2str(Freqtypes(:)/1000,'%.2fkHz'));
 ylims = get(gca,'ylim');
 line([csAlignF csAlignF],[(ylims(1) - 50),(ylims(2) + 50)],'color',[.8 .8 .8],'LineWidth',1.8);

 line([PassiveStartF PassiveStartF],[(ylims(1) - 50),(ylims(2) + 50)],'color',[.8 .8 .8],'LineWidth',1.8);
 set(gca,'xtick',[0,csAlignF,csAlignF+csFrate,(size(TaskDataSetMean,2) + csFrate),PassiveStartF,(PassiveStartF+PassiveFrate)]...
     ,'xticklabel',{num2str((csAlignF/csFrate)*(-1),'%d'),0,1,-1,0,1});
 text(xCenter,yCenter,centerStr,'FontSize',16,'color','b');
 ylim([-50,yBase+150]);
 set(gca,'ytick',[],'ycolor','w')
 xlabel('Time(s)');
 TrialLength = size(TotaldataMatrix,2) + PassiveFrate;
line([TrialLength TrialLength],[100,200],'LineWidth',2,'color','k');
text((TrialLength),150,'100% \DeltaF/F_0');
line([TrialLength TrialLength+csFrate*1],[100,100],'LineWidth',2,'color','k');
text(TrialLength,50,'1 s');
subTitlexPos = [csAlignF+(csFrate*2.5),PassiveStartF+(PassiveFrate*2)];
text(subTitlexPos,[yBase+40 yBase+40],{'Task','Passive'},'Color','r','FontSize',18);
title(sprintf('Example ROI%d plot---Task vs passive',nROI));
set(gca,'fontSize',20);
%%
% add text for each frequency gruop
saveas(h,sprintf('ROI%d example mean plot of task and passive diff',nROI));
saveas(h,sprintf('ROI%d example mean plot of task and passive diff',nROI),'png');
close(h);
DataStrc = struct('TaskDataMean',TaskDataSetMean,'TaskdataSEM',TaskDataSetSem,'PassDataMean',RFDataSetMean,'PassDataSEM',RFDataSetSem,...
    'TaskFrate',csFrate,'PassFrate',PassiveFrate,'TaskAlignF',csAlignF);
save(sprintf('ROI%d example mean plot.mat',nROI),'DataStrc','-v7.3');
cd ..;