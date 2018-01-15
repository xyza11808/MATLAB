% DataSavePath = uigetdir('Please select your current data save path');
% cd(DataSavePath);


clear
clc
[fn,fp,fi] = uigetfile('*.txt','Please select the factor analysis data path');
if ~fi
    return;
end
%%
clearvars -except fn fp
fpath = fullfile(fp,fn);
fid = fopen(fpath);
tline = fgetl(fid);

%
% addchar = 'y';
TaskFactorData = {};
PassFactorData = {};
TaskTime = {};
PassTime = {};
PLotsTLRDis = {};
PlotsPLRDis = {};
TaskTones = {};
TaskOutcomes = {};
ActionChoice = {};
LRIndexSum = {};
TaskFrate = [];
TaskAlignF = [];
m = 1;
while ischar(tline)
    if isempty(strfind(tline,'NO_Correction\mode_f_change'))
        tline = fgetl(fid);
        continue;
    end
    %%
    TaskPath = fullfile(tline,'DimRed_Resplot_smooth','FactorAnaData.mat');
    cd(fullfile(tline,'DimRed_Resplot_smooth'));
    
    isBoundaryToneexits = 0;
%     [fn,fp,~] = uigetfile('FactorAnaData.mat','Please select your task factor analysis saved data');
%     TaskPath = fullfile(fp,fn);
    TaskData = load(TaskPath);
    TaskTimeDataStrs = strrep(TaskPath,'FactorAnaData.mat','MeanPlotData.mat');
%     TaskExtraData = load(TaskTimeDataStrs);
    TaskStartF = load(TaskTimeDataStrs,'start_frame');
    TimeStrings = {'xTimes','frame_rate','cLRIndexSum','cLRIndexSumNor'};
    TaskxTimes = load(TaskTimeDataStrs,TimeStrings{:});
    TaskxTimes.AlignedF = TaskStartF.start_frame;
    DataAll = TaskData.FSDataNorm;
    TLeftCorrData = DataAll(TaskData.LeftCorrInds,:,:);
    TRightCorrData = DataAll(TaskData.RightCorrInds,:,:);
    TLeftCorrMean = squeeze(mean(TLeftCorrData));
    TRightCorrMean = squeeze(mean(TRightCorrData));
    TaskFactorData{m} = TaskData;
    TaskTime{m} = TaskxTimes;
    %% Task stimulus session plots
    Stimtones = double(TaskData.behavResults.Stim_toneFreq);
    Actions = double(TaskData.behavResults.Action_choice);
    LRindex = TaskxTimes.cLRIndexSum;
    LRindexNor = TaskxTimes.cLRIndexSumNor;
    xticksF = 0:TaskxTimes.frame_rate:size(LRindex,2);
    xsTime = (1:size(LRindex,2))/TaskxTimes.frame_rate;
    xTickTime = xticksF/TaskxTimes.frame_rate;
    xticklabels = xticksF/(TaskxTimes.frame_rate);
    Tones = double(unique(Stimtones));
    ToneNum = length(Tones);
    TaskTones{m} = Stimtones(:);
    TaskOutcomes{m} = TaskData.trial_outcome(:);
    ActionChoice{m} = Actions;
    LRIndexSum{m} = LRindex;
    TaskFrate = [TaskFrate,TaskxTimes.frame_rate];
    TaskAlignF = [TaskAlignF,TaskStartF.start_frame];
    if mod(ToneNum,2)
        BoundaryTone = Tones(ceil(ToneNum/2));
        Tones(ceil(ToneNum/2)) = [];
        ToneNum = ToneNum - 1;
        isBoundaryToneexits = 1;
    end
    
    if isBoundaryToneexits
        h_bound = figure('position',[200 200 800 540],'Paperpositionmode','auto');
        subplot(1,2,1)
        cToneInds = Stimtones(:) == BoundaryTone & Actions(:) == 0;
        cToneIndex = LRindex(cToneInds,:);
        hold on;
        plot(cToneIndex','color',[.7 .7 .7]);
        plot(mean(cToneIndex),'k','LineWidth',3);
        set(gca,'xtick',xticksF,'xticklabel',xticklabels);
        yscales = get(gca,'ylim');
        line([TaskStartF.start_frame TaskStartF.start_frame],yscales,'Color',[.7 .7 .7],'LineWidth',1.8,'LineStyle','--');
        ylim(yscales);
        ylabel('Selection index');
        xlabel('Times(s)');
        title(sprintf('Tone = %d kHz, Left trials',BoundaryTone));
        
        subplot(1,2,2)
        cToneInds = Stimtones(:) == BoundaryTone & Actions(:) == 1;
        cToneIndex = LRindex(cToneInds,:);
        hold on;
        plot(cToneIndex','color',[.7 .7 .7]);
        plot(mean(cToneIndex),'k','LineWidth',3);
        set(gca,'xtick',xticksF,'xticklabel',xticklabels);
        yscales = get(gca,'ylim');
        line([TaskStartF.start_frame TaskStartF.start_frame],yscales,'Color',[.7 .7 .7],'LineWidth',1.8,'LineStyle','--');
        ylim(yscales);
        ylabel('Selection index');
        xlabel('Times(s)');
        title(sprintf('Tone = %d kHz, right trials',BoundaryTone));
        annotation('textbox',[0.3,0.68,0.3,0.3],'String',sprintf('session plots Boundary tine plots'),'FitBoxToText','on','EdgeColor',...
                'none','FontSize',14,'Color','r');
        saveas(h_bound,sprintf('Session boundary index plots'));
        saveas(h_bound,sprintf('Session boundary index plots'),'png');
        close(h_bound);
    end
    % all correct trials selection index plots
    h_corr = figure('position',[100 80 850 540],'Paperpositionmode','auto');
    for n = 1 : ToneNum
        cTone = Tones(n);
        cToneInds = Stimtones(:) == cTone & TaskData.trial_outcome(:) == 1;
        cToneIndex = LRindex(cToneInds,:);
        subplot(2,ToneNum/2,n);
        hold on;
        plot(cToneIndex','color',[.7 .7 .7]);
        plot(mean(cToneIndex),'k','LineWidth',3);
        set(gca,'xtick',xticksF,'xticklabel',xticklabels);
        yscales = get(gca,'ylim');
        line([TaskStartF.start_frame TaskStartF.start_frame],yscales,'Color',[.7 .7 .7],'LineWidth',1.8,'LineStyle','--');
        ylim(yscales);
        ylabel('Selection index');
        xlabel('Times(s)');
        title(sprintf('Tone = %d kHz',cTone));
    end
    annotation('textbox',[0.02,0.25,0.3,0.3],'String',sprintf('All corrects trials'),'FitBoxToText','on','EdgeColor',...
                'none','FontSize',14,'Color','r');
    saveas(h_corr,sprintf('Session all correct trials selection index plot'));
    saveas(h_corr,sprintf('Session all correct trials selection index plot'),'png');
    close(h_corr);
    % all error trials selection index plot
    h_erro = figure('position',[100 80 850 540],'Paperpositionmode','auto');
    for n = 1 : ToneNum
        cTone = Tones(n);
        cToneInds = Stimtones(:) == cTone & TaskData.trial_outcome(:) == 0;
        cToneIndex = LRindex(cToneInds,:);
        subplot(2,ToneNum/2,n);
        hold on;
        plot(cToneIndex','color',[.7 .7 .7]);
        plot(mean(cToneIndex),'k','LineWidth',3);
        set(gca,'xtick',xticksF,'xticklabel',xticklabels);
        yscales = get(gca,'ylim');
        line([TaskStartF.start_frame TaskStartF.start_frame],yscales,'Color',[.7 .7 .7],'LineWidth',1.8,'LineStyle','--');
        ylim(yscales);
        ylabel('Selection index');
        xlabel('Times(s)');
        title(sprintf('Tone = %d kHz',cTone));
        set(gca,'FontSize',14);
    end
    annotation('textbox',[0.02,0.25,0.3,0.3],'String',sprintf('All error trials'),'FitBoxToText','on','EdgeColor',...
                'none','FontSize',14,'Color','r');
            %
    saveas(h_erro,sprintf('Session all error trials selection index plot'));
    saveas(h_erro,sprintf('Session all error trials selection index plot'),'png');
    close(h_erro);
    
    % plot all Stimulus types selection index together, with
    % shade indicates SEM
    Opt.t_eventOn = TaskStartF.start_frame/TaskxTimes.frame_rate;
    Opt.eventDur = 0.3;
    eventOff = Opt.t_eventOn + Opt.eventDur;
    CMap = [(linspace(0,1,ToneNum))',zeros(ToneNum,1)+0.1,(linspace(1,0,ToneNum))'];
    Opt.isPatchPlot = 0;
    lineMemoStrs = cellstr(num2str(Tones(:)/1000,'%.1fKHz'));
     
    lineobj = [];
    hhf = figure('position',[100 100 850 640]);
    hold on
    for nf = 1 : ToneNum
        cFreqs = Tones(nf);
        cFreqData = LRindex(NMTones==cFreqs,:);  % correct trials,  & NMOutcomes == 1
        
    end
    
%     % all correct trials Normalized selection index plots
%     h_corrNor = figure('position',[100 80 1750 1000],'Paperpositionmode','auto');
%     for n = 1 : ToneNum
%         cTone = Tones(n);
%         cToneInds = Stimtones(:) == cTone & TaskData.trial_outcome(:) == 1;
%         cToneIndex = LRindexNor(cToneInds,:);
%         subplot(2,ToneNum/2,n);
%         hold on;
%         plot(cToneIndex','color',[.7 .7 .7]);
%         plot(mean(cToneIndex),'k','LineWidth',3);
%         set(gca,'xtick',xticksF,'xticklabel',xticklabels);
%         yscales = get(gca,'ylim');
%         line([TaskStartF.start_frame TaskStartF.start_frame],yscales,'Color',[.7 .7 .7],'LineWidth',1.8,'LineStyle','--');
%         ylim(yscales);
%         ylabel('Nor. Selection index');
%         xlabel('Times(s)');
%         title(sprintf('Tone = %d kHz',cTone));
%     end
%     annotation('textbox',[0.42,0.68,0.3,0.3],'String',sprintf('session%d plots All corrects trials',m),'FitBoxToText','on','EdgeColor',...
%                 'none','FontSize',18);
%     saveas(h_corrNor,sprintf('Session%d all correct trials Norselection index plot',m));
%     saveas(h_corrNor,sprintf('Session%d all correct trials Norselection index plot',m),'png');
%     close(h_corrNor);
%     % all error trials normalized selection index plot
%     h_erroNor = figure('position',[100 80 1750 1000],'Paperpositionmode','auto');
%     for n = 1 : ToneNum
%         cTone = Tones(n);
%         cToneInds = Stimtones(:) == cTone & TaskData.trial_outcome(:) == 0;
%         cToneIndex = LRindexNor(cToneInds,:);
%         subplot(2,ToneNum/2,n);
%         hold on;
%         plot(cToneIndex','color',[.7 .7 .7]);
%         plot(mean(cToneIndex),'k','LineWidth',3);
%         set(gca,'xtick',xticksF,'xticklabel',xticklabels);
%         yscales = get(gca,'ylim');
%         line([TaskStartF.start_frame TaskStartF.start_frame],yscales,'Color',[.7 .7 .7],'LineWidth',1.8,'LineStyle','--');
%         ylim(yscales);
%         ylabel('Nor. Selection index');
%         xlabel('Times(s)');
%         title(sprintf('Tone = %d kHz',cTone));
%     end
%     annotation('textbox',[0.42,0.68,0.3,0.3],'String',sprintf('session%d plots All error trials',m),'FitBoxToText','on','EdgeColor',...
%                 'none','FontSize',18);
%     saveas(h_erroNor,sprintf('Session%d all error trials Norselection index plot',m));
%     saveas(h_erroNor,sprintf('Session%d all error trials Norselection index plot',m),'png');
%     close(h_erroNor);
    
%     %
%     [fn,fp,~] = uigetfile('FactorAnaData.mat','Please select your passive factro analysis saved data');
%     PassPath = fullfile(fp,fn);
% %     PassPath = 'M:\batch\batch32\20160815\anm03\test02rf\im_data_reg_cpu\result_save\plot_save\NO_Correction\DimRed_Resplot\FactorAnaData.mat';
%     PassData = load(PassPath);
%     PassTimeStrs = strrep(PassPath,'FactorAnaData.mat','MeanPlotData.mat');
%     PassStartF = load(PassTimeStrs,'start_frame');
%     PassxTimes = load(PassTimeStrs,TimeStrings{:});
%     PassxTimes.AlignedF = PassStartF.start_frame;
%     DataAll = PassData.FSDataNorm;
%     PLeftCorrData = DataAll(PassData.LeftCorrInds,:,:);
%     PRightCorrData = DataAll(PassData.RightCorrInds,:,:);
%     PLeftCorrMean = squeeze(mean(PLeftCorrData));
%     PRightCorrMean = squeeze(mean(PRightCorrData));
%     PassFactorData{m} = PassData;
%     PassTime{m} = PassxTimes;
%     %
%     AlignFbeforeS = min([TaskStartF.start_frame,PassStartF.start_frame]);
%     TaskmoveInds = TaskStartF.start_frame - AlignFbeforeS;
%     PassmoveInds = PassStartF.start_frame - AlignFbeforeS;
%     TaskAlignxtimes = TaskxTimes.xTimes((TaskmoveInds+1):end);
%     PassAlignxtimes = PassxTimes.xTimes((TaskmoveInds+1):end);
%     AlineTime = AlignFbeforeS/TaskxTimes.frame_rate;
%     TLRDis = sqrt(sum((TLeftCorrMean - TRightCorrMean).^2));
%     PLRDis = sqrt(sum((PLeftCorrMean - PRightCorrMean).^2));
%     PlotTLRDis = TLRDis((TaskmoveInds+1):end);
%     PlotPLRDis = PLRDis((TaskmoveInds+1):end);
%     PLotsTLRDis{m} = PlotTLRDis;
%     PlotsPLRDis{m} = PlotPLRDis;
%     
%     %
%     h = figure;
%     hold on;
%     l1 = plot(TaskAlignxtimes,PlotTLRDis,'k','LineWidth',1.6);
%     l2 = plot(PassAlignxtimes,PlotPLRDis,'r','LineWidth',1.6);
%     yscales = get(gca,'ylim');
%     line([AlineTime,AlineTime],yscales,'Color',[.7 .7 .7],'LineWidth',1.8,'LineStyle','--');
%     set(gca,'ylim',yscales);
%     xlabel('Time(s)');
%     ylabel('Mean trace difference')
%     set(gca,'FontSize',18);
%     legend([l1,l2],{'Task Mean Distance','Pass Mean Distance'},'FontSize',12);
%     saveas(h,sprintf('Session%d factor space distance compare plot',m));
%     saveas(h,sprintf('Session%d factor space distance compare plot',m),'png');
%     close(h);
%     %
%     addchar = input('Would you like to add another session data?\n','s');
    m = m + 1;
    tline = fgetl(fid);
end
%%
save FactorAnaDataSave.mat TaskFactorData TaskTime PLotsTLRDis PlotsPLRDis -v7.3
% save FactorAnaDataSave.mat TaskFactorData TaskTime PassFactorData PassTime PLotsTLRDis PlotsPLRDis -v7.3
save LRIndexsumSave.mat TaskTones TaskOutcomes ActionChoice LRIndexSum TaskFrate TaskAlignF -v7.3
%% summarize session figs into one ppt file
clearvars -except fn fp
m = 1;
nSession = 1;

fpath = fullfile(fp,fn);
ff = fopen(fpath);
tline = fgetl(ff);

while ischar(tline)
    if isempty(strfind(tline,'NO_Correction\mode_f_change')) %#ok<*STREMP>
        tline = fgetl(ff);

        continue;
    else
        %
        if m == 1
            %
%                 PPTname = input('Please input the name for current PPT file:\n','s');
            PPTname = 'Session_FAPeak_BehavPlot';
            if isempty(strfind(PPTname,'.ppt'))
                PPTname = [PPTname,'.pptx'];
            end
%                 pptSavePath = uigetdir(pwd,'Please select the path used for ppt file savege');
            pptSavePath = 'E:\DataToGo\data_for_xu\Factor_new_smooth\New_correct_factorAna\SessionSummary';
            %
        end
            Anminfo = SessInfoExtraction(tline);
            cTunDataPath = [tline,filesep,'DimRed_Resplot_smooth'];
            AllCorrectPlotfile = fullfile(cTunDataPath,'Session all correct trials selection index plot.png');
            AllErrorPlotfile = fullfile(cTunDataPath,'Session all error trials selection index plot.png');
            FABehavFile = fullfile(cTunDataPath,'Factor and behavior compare plot.png');
            
            pptFullfile = fullfile(pptSavePath,PPTname);
            if ~exist(pptFullfile,'file')
                NewFileExport = 1;
            else
                NewFileExport = 0;
            end
            if NewFileExport
                exportToPPTX('new','Dimensions',[16,9],'Author','XinYu','Comments','Export of tunning curve plot data');
            else
                exportToPPTX('open',pptFullfile);
            end

            exportToPPTX('addslide');
            exportToPPTX('addtext',sprintf('Session%d',nSession),'Position',[7.5 0 2 1],'FontSize',24);
            exportToPPTX('addnote',tline);
            exportToPPTX('addpicture',imread(AllCorrectPlotfile),'Position',[0 0 7.08 4.5]);
            exportToPPTX('addpicture',imread(AllErrorPlotfile),'Position',[0 4.5 7.08 4.5]);
            exportToPPTX('addpicture',imread(FABehavFile),'Position',[7.5 1 4.38 3.5]);
%                 exportToPPTX('addpicture',TaskRespMapIM,'Position',[6 0.2 5 4.19]);
%                 exportToPPTX('addtext','Task','Position',[11 2 1 2],'FontSize',22);
%                 exportToPPTX('addpicture',PassRespMapIM,'Position',[6 4.5 5 4.19]);
%                 exportToPPTX('addtext','Passive','Position',[11 5.5 3 2],'FontSize',22);
%                 exportToPPTX('addpicture',BoundDiffIM,'Position',[12 4.5 4 3.35]);
% %                     exportToPPTX('addpicture',PassMeanFig,'Position',[12.8 0.8 3 3]);
            exportToPPTX('addtext',sprintf('Batch:%s \r\nAnm: %s\r\nDate: %s\r\nField: %s',...
                Anminfo.BatchNum,Anminfo.AnimalNum,Anminfo.SessionDate,Anminfo.TestNum),...
                'Position',[12 1.5 3 3],'FontSize',22);
    end
     m = m + 1;
     nSession = nSession + 1;
     saveName = exportToPPTX('saveandclose',pptFullfile);
     tline = fgetl(ff);
end
fprintf('Current figures saved in file:\n%s\n',saveName);
cd(pptSavePath);

%%
m = m - 1;
frame_rate = TaskxTimes.frame_rate;
TaskDataLen = cellfun(@length,PLotsTLRDis);
SelectLen = min(TaskDataLen);
TaskDataSum = zeros(m,SelectLen);
for nxnx = 1 : m
    TaskDataSum(nxnx,:) = PLotsTLRDis{nxnx}(1:SelectLen);
end
% TaskPlots = cell2mat(PLotsTLRDis');
PassPlots = cell2mat(PlotsPLRDis');
h_sumPlot = figure('position',[200 200 1000 800]);
hold on;
[hf,hp1,hl1] = MeanSemPlot(TaskDataSum,[],h_sumPlot,'k','LineWidth',1.6);
[hfsave,hp2,hl2] = MeanSemPlot(PassPlots,[],hf,'r','LineWidth',1.6);
yscales = get(gca,'ylim');
line([AlignFbeforeS AlignFbeforeS],yscales,'Color',[.7 .7 .7],'LineWidth',1.8,'LineStyle','--');
set(gca,'FontSize',16,'xtick',0:55:SelectLen,'xTicklabel',0:(SelectLen/55));
set(hp1,'facecolor','k','facealpha',0.4);
set(hp2,'facecolor','r','facealpha',0.4);
xlabel('Time(s)');
ylabel('Mean Trace Distance');
title('Factor space distance');
legend([hl1,hl2],{'Task','Passive'},'FontSize',16);
saveas(hfsave,'Summarized compared plot of factor space distance');
saveas(hfsave,'Summarized compared plot of factor space distance','png');
close(hfsave);
save sumPlotDataSave.mat TaskDataSum PassPlots AlignFbeforeS frame_rate -v7.3