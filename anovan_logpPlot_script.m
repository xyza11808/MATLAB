clear
clc
[fn,fp,fi] = uigetfile('*.txt','Please select the text files contains session plots path');
if ~fi
    return;
end
fpath = fullfile(fp,fn);
fid = fopen(fpath);
tline = fgetl(fid);

while ischar(tline)
    if isempty(strfind(tline,'\mode_f_change'))
        tline = fgetl(fid);
        continue;
    end
    if ~isempty(strfind(tline,'All BehavType Colorplot'))
        SessPath = strrep(tline,'All BehavType Colorplot','ROIcoef_plot_anova');
    else
        SessPath = [tline,'\ROIcoef_plot_anova'];
    end
    cd(SessPath);
    clearvars pValueMatrix
    load(fullfile(SessPath,'ROIcoefPmatrix.mat'));
    
    xticks = 0:frame_rate:size(pValueMatrix,2);
    xticklabels = xticks/frame_rate;
    SoundOffFrame = start_frame + 0.3*frame_rate;
    if ~isdir('./logP_lineplot/')
        mkdir('./logP_lineplot/');
    end
    cd('./logP_lineplot/');

    % cROI = 1;
    for cROI = 1 : size(pValueMatrix,1)
        cROIdata = squeeze(pValueMatrix(cROI,:,:));
        logpData = (-1)*log10(cROIdata);
        SmoothData = zeros(size(logpData));
        for n = 1 : size(logpData,2)
            SmoothData(:,n) = smooth(logpData(:,n));
        end
        %
        hhf = figure;
        hold on;
        hl1 = plot(SmoothData(:,1),'r','linewidth',1.6);
        hl2 = plot(SmoothData(:,2),'b','linewidth',1.6);
        hl3 = plot(SmoothData(:,3),'k','linewidth',1.6);
        yscales = get(gca,'ylim');
        xscales = get(gca,'xlim');
        line([start_frame,start_frame],yscales,'Color',[.7 .7 .7],'linewidth',1.4);
        line(xscales,[2 2],'Color',[.7 .7 .7],'linewidth',1.4,'linestyle','--');
        line([SoundOffFrame SoundOffFrame],yscales,'Color',[.7 .7 .7],'linewidth',1.4,'linestyle','--');
        text(xscales(2)*0.9,2,'p = 0.01','FontSize',16);
        set(gca,'xtick',xticks,'xticklabel',xticklabels,'ytick',[],'FontSize',18);
        set(gca,'xlim',xscales,'ylim',yscales);
        legend([hl1,hl2,hl3],{'Sound','Choice','Reward'},'FontSize',16);
        legend('boxoff');
        xlabel('Time (s)');
        ylabel('-Log(P)');
        title(sprintf('ROI%d anovan logP',cROI));
        saveas(hhf,sprintf('ROI%d logP line plot',cROI));
        saveas(hhf,sprintf('ROI%d logP line plot',cROI),'png');
        close(hhf);
    end
    %
    cd ..;
    tline = fgetl(fid);
end
%% check the log(p)_value and using constant significant values as significant related
clear
clc
[fn,fp,fi] = uigetfile('*.txt','Please select the text files contains session plots path');
if ~fi
    return;
end
fpath = fullfile(fp,fn);
fid = fopen(fpath);
tline = fgetl(fid);

while ischar(tline)
    if isempty(strfind(tline,'\mode_f_change'))
        tline = fgetl(fid);
        continue;
    end
    if ~isempty(strfind(tline,'All BehavType Colorplot'))
        SessPath = strrep(tline,'All BehavType Colorplot','ROIcoef_plot_anova');
    else
        SessPath = [tline,'\ROIcoef_plot_anova'];
    end
    cd(SessPath);
    load(fullfile(SessPath,'ROIcoefPmatrix.mat'));
    
    logpDataAll = (-1)*log10(pValueMatrix);
    SigLodFrameData = double(logpDataAll > 2);
    ROISelectTypeIndex = zeros(size(pValueMatrix,1),size(pValueMatrix,3));
     for cROI = 1 : size(pValueMatrix,1)
        cROIdata = squeeze(SigLodFrameData(cROI,:,:));
        SmoothIndexData = zeros(size(cROIdata)); % smoothed across multiple frame window
        ROIsigIndex = zeros(size(cROIdata,2),1);
        for n = 1 : size(cROIdata,2)
            SmoothIndexData(:,n) = smooth(cROIdata(:,n),21);
            if ~isempty(find(abs(SmoothIndexData(:,n) - 1) < 0.001, 1))
                ROIsigIndex(n) = 1;
            end
        end
        ROISelectTypeIndex(cROI,:) = ROIsigIndex;
     end
     save ROIselectiveTypeSave.mat ROISelectTypeIndex -v7.3
     %
     cSessDataPath = strrep(SessPath,'\ROIcoef_plot_anova','\');
     cSessDataFile = fullfile(cSessDataPath,'CSessionData.mat');
     SessRespData = load(cSessDataFile);
     TrStimAll = double(SessRespData.behavResults.Stim_toneFreq);
     TrChoice = double(SessRespData.behavResults.Action_choice);
     MissInds = SessRespData.trial_outcome == 2;
     
     NMTrStim = TrStimAll(~MissInds);
     NMTrChoice = TrChoice(~MissInds);
     NMoutcome = SessRespData.trial_outcome(~MissInds);
     NMOctaves = log2(NMTrStim/16000);
     NMData = SessRespData.data_aligned(~MissInds,:,:);
     AlignedF = SessRespData.start_frame;
     Frate = SessRespData.frame_rate;
     
     
     nROIs = size(ROISelectTypeIndex,1);
     nFrames = size(NMData,3);
     xticks = 0:Frate:nFrames;
     xticklabels = xticks/Frate;
     if ~isdir('Selective Type plot')
         mkdir('Selective Type plot');
     end
     cd('Selective Type plot');
     
     for cROI = 1 : nROIs
         cROIindex = ROISelectTypeIndex(cROI,:);
         cROIdata = squeeze(NMData(:,cROI,:));
         hhf = figure('position',[50 300 1800 700],'PaperpositionMode','auto');
         
         ax1 = subplot(1,3,1); % plot the mean trace according to frequency type
         hold on
         FreqTypes = unique(NMTrStim);
         nFreqTypes = length(FreqTypes);
         FreqTypeMeanData = zeros(nFrames,nFreqTypes);
         FreqTrN = zeros(1,nFreqTypes);
         FreqLegStr = cell(nFreqTypes,1);
         LineColor = jet(nFreqTypes);
         lineLeg = [];
         for nf = 1 : nFreqTypes
             cFreq = FreqTypes(nf);
             cFreqData = cROIdata(NMTrStim == cFreq,:);
             FreqTrN(nf) = size(cFreqData,1);
             FreqLegStr{nf} = sprintf('%.1fkHz,n=%d',cFreq/1000,FreqTrN(nf));
             hl = plot(mean(cFreqData),'color',LineColor(nf,:),'Linewidth',1.5);
             FreqTypeMeanData(:,nf) = mean(cFreqData);
             lineLeg = [lineLeg,hl];
         end
         legend(lineLeg,FreqLegStr,'FontSize',10);
         legend('boxoff');
         yscales = get(gca,'ylim');
         set(gca,'xtick',xticks,'xticklabel',xticklabels);
         line([AlignedF AlignedF],yscales,'color',[.7 .7 .7],'linewidth',1.4);
         set(gca,'xlim',[0 nFrames+1],'ylim',yscales);
         xlabel('Time (s)');
         ylabel('Mean \DeltaF/F_0(%)');
         title(sprintf('Stimulus selective = %d',cROIindex(1)));
         set(gca,'FontSize',16);
         
         ax2 = subplot(1,3,2); % plot the mean trace according to choice type
         hold on
         LChoiceInds = NMTrChoice == 0;
         LchoiceData = cROIdata(LChoiceInds,:);
         LchoiceMeanData = mean(LchoiceData);
         LchoiceSemData = std(LchoiceData)/sqrt(size(LchoiceData,1));
         Lxp = [1:nFrames,fliplr(1:nFrames)];
         Lyp = [LchoiceMeanData+LchoiceSemData,fliplr(LchoiceMeanData-LchoiceSemData)];
         
         RChoiceInds = NMTrChoice == 1;
         RChoiceData = cROIdata(RChoiceInds,:);
         RChoiceMean = mean(RChoiceData);
         RChoiceSemData = std(RChoiceData)/sqrt(size(RChoiceData,1));
         Rxp = Lxp;
         Ryp = [RChoiceMean+RChoiceSemData,fliplr(RChoiceMean-RChoiceSemData)];
         patch(Lxp,Lyp,1, 'EdgeColor','none','FaceColor',[.7 .7 .7],'FaceAlpha',0.5);
         patch(Rxp,Ryp,1, 'EdgeColor','none','FaceColor',[.7 .7 .7],'FaceAlpha',0.5);
         hl1 = plot(LchoiceMeanData,'b','linewidth',1.4);
         hl2 = plot(RChoiceMean,'r','linewidth',1.4);
         legStr = {sprintf('Left, n=%d',size(LchoiceData,1)),sprintf('Right, n=%d',size(RChoiceData,1))};
         legend([hl1,hl2],legStr,'FontSize',14);
         legend('boxoff');
         yscales = get(gca,'ylim');
         set(gca,'xtick',xticks,'xticklabel',xticklabels);
         line([AlignedF AlignedF],yscales,'color',[.7 .7 .7],'linewidth',1.4);
         set(gca,'xlim',[0 nFrames+1],'ylim',yscales);
         xlabel('Time (s)');
         ylabel('Mean \DeltaF/F_0(%)');
         title(sprintf('Choice selective = %d',cROIindex(2)));
         set(gca,'FontSize',16);
         
         ax3 = subplot(1,3,3);% plot the mean trace according to reward type
         hold on
         ReTrInds = NMoutcome == 1;
         ReTrData = cROIdata(ReTrInds,:);
         ReTrMean = mean(ReTrData);
         ReTrSem = std(ReTrData)/sqrt(size(ReTrData,1));
         Reyp = [ReTrMean+ReTrSem,fliplr(ReTrMean-ReTrSem)];
         
         NoReInds = NMoutcome == 0;
         NoReData = cROIdata(NoReInds,:);
         NoReMean = mean(NoReData);
         NoReSem = std(NoReData)/sqrt(size(NoReData,1));
         NoReyp = [NoReMean+NoReSem,fliplr(NoReMean-NoReSem)];
         patch(Lxp,Reyp,1, 'EdgeColor','none','FaceColor',[.7 .7 .7],'FaceAlpha',0.5);
         patch(Rxp,NoReyp,1, 'EdgeColor','none','FaceColor',[.7 .7 .7],'FaceAlpha',0.5);
         
         hl3 = plot(ReTrMean,'Color',[1 0 1],'Linewidth',1.5);
         hl4 = plot(NoReMean,'Color','k','Linewidth',1.5);
         LegStr = {sprintf('Reward, n=%d',size(ReTrData,1)),sprintf('NoRe, n=%d',size(NoReData,1))};
         legend([hl3,hl4],LegStr,'FontSize',14);
         legend('boxoff');
         yscales = get(gca,'ylim');
         set(gca,'xtick',xticks,'xticklabel',xticklabels);
         line([AlignedF AlignedF],yscales,'color',[.7 .7 .7],'linewidth',1.4);
         set(gca,'xlim',[0 nFrames+1],'ylim',yscales);
         xlabel('Time (s)');
         ylabel('Mean \DeltaF/F_0(%)');
         title(sprintf('Reward selective = %d',cROIindex(3)));
         set(gca,'FontSize',16);
         
         annotation('textbox',[0.49,0.7,0.3,0.3],'String',['ROI' num2str(cROI)],'FitBoxToText','on','EdgeColor',...
               'none','FontSize',20);
           
         saveas(hhf,sprintf('Selective type mean trace plot ROI%d',cROI));
         saveas(hhf,sprintf('Selective type mean trace plot ROI%d',cROI),'png');
         close(hhf);
     end
     
     tline = fgetl(fid);
end