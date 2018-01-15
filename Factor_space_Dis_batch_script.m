% DataSavePath = uigetdir('Please select your current data save path');
% cd(DataSavePath);
clear
clc
[fn,fp,fi] = uigetfile('*.txt','Please select the factor analysis data path');
if ~fi
    return;
end
[Passfn,Passfp,~] = uigetfile('*.txt','Please select passive factor analysis data path');

%%
clearvars -except fn fp Passfp Passfn
fpath = fullfile(fp,fn);
fid = fopen(fpath);
tline = fgetl(fid);
Passid = fopen(fullfile(Passfp,Passfn));
Passline = fgetl(Passid);
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
FreqIndexAll = {};
NorFreqIndexAll = {};
IndexTaskPassFitValues = {};
TaskFrate = [];
TaskAlignF = [];
SessPowerPeak = [];
m = 1;
%
while ischar(tline)
    if isempty(strfind(tline,'NO_Correction\mode_f_change'))
        tline = fgetl(fid);
        Passline = fgetl(Passid);
        continue;
    end
    %
    TaskPath = fullfile(tline,'DimRed_Resplot_smooth','FactorAnaData.mat');
    cd(fullfile(tline,'DimRed_Resplot_smooth'));
    
    isBoundaryToneexits = 0;
%     [fn,fp,~] = uigetfile('FactorAnaData.mat','Please select your task factor analysis saved data');
%     TaskPath = fullfile(fp,fn);
    TaskData = load(TaskPath);
    TaskTimeDataStrs = strrep(TaskPath,'FactorAnaData.mat','MeanPlotData.mat');
    BehavBoundfile = load(fullfile(tline,'RandP_data_plots','boundary_result.mat'));
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
    % Task stimulus session plots
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
    NMTrInds = Actions ~= 2;
    NMTrTones = Stimtones(NMTrInds);
    NMTrChoice = Actions(NMTrInds);
    NMSIndexData = LRindex(NMTrInds,:);
    NMTrOutcomes = TaskData.trial_outcome(NMTrInds);
    StimOnTime = TaskStartF.start_frame/TaskxTimes.frame_rate;
    
    TaskFrate = [TaskFrate,TaskxTimes.frame_rate];
    TaskAlignF = [TaskAlignF,TaskStartF.start_frame];
    if mod(ToneNum,2)
        BoundaryTone = Tones(ceil(ToneNum/2));
        Tones(ceil(ToneNum/2)) = [];
        ToneNum = ToneNum - 1;
        isBoundaryToneexits = 1;
    end
    %
    if isBoundaryToneexits
        %
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
        %
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
        cToneInds = NMTrTones(:) == cTone & NMTrOutcomes(:) == 1;
        cToneIndex = NMSIndexData(cToneInds,:);
        subplot(2,ToneNum/2,n);
        hold on;
        plot(xsTime,cToneIndex','color',[.7 .7 .7]);
        plot(xsTime,mean(cToneIndex),'k','LineWidth',3);
        set(gca,'xtick',xTickTime);
        yscales = get(gca,'ylim');
        line([StimOnTime StimOnTime],yscales,'Color',[.7 .7 .7],'LineWidth',1.8,'LineStyle','--');
        ylim(yscales);
        ylabel('Selection index');
        xlabel('Times(s)');
        title(sprintf('Tone = %d kHz',cTone));
    end
    annotation('textbox',[0.02,0.25,0.3,0.3],'String',sprintf('All corrects trials'),'FitBoxToText','on','EdgeColor',...
                'none','FontSize',14,'Color','r');
            %
    saveas(h_corr,sprintf('Session all correct trials selection index plot'));
    saveas(h_corr,sprintf('Session all correct trials selection index plot'),'png');
    close(h_corr);
    % all error trials selection index plot
    h_erro = figure('position',[100 80 850 540],'Paperpositionmode','auto');
    for n = 1 : ToneNum
        cTone = Tones(n);
        cToneInds = NMTrTones(:) == cTone & NMTrOutcomes(:) == 0;
        cToneIndex = NMSIndexData(cToneInds,:);
        if isempty(cToneIndex)
            continue;
        else
            subplot(2,ToneNum/2,n);
            hold on;
            plot(xsTime,cToneIndex','color',[.7 .7 .7]);
            plot(xsTime,mean(cToneIndex),'k','LineWidth',3);
            set(gca,'xtick',xTickTime);
            yscales = get(gca,'ylim');
            line([StimOnTime StimOnTime],yscales,'Color',[.7 .7 .7],'LineWidth',1.8,'LineStyle','--');
            ylim(yscales);
            ylabel('Selection index');
            xlabel('Times(s)');
            title(sprintf('Tone = %d kHz',cTone));
            set(gca,'FontSize',14);
        end
    end
    annotation('textbox',[0.02,0.25,0.3,0.3],'String',sprintf('All error trials'),'FitBoxToText','on','EdgeColor',...
                'none','FontSize',14,'Color','r');
            %
    saveas(h_erro,sprintf('Session all error trials selection index plot'));
    saveas(h_erro,sprintf('Session all error trials selection index plot'),'png');
    close(h_erro);
    
    % plot all Stimulus types selection index together, with
    % shade indicates SEM
    Opt.t_eventOn = StimOnTime;
    Opt.eventDur = 0.3;
    eventOff = Opt.t_eventOn + Opt.eventDur;
    AllMap = blue2red_2(ToneNum/2+1,0.8);
    CMap = AllMap([1:ToneNum/2,end-ToneNum/2+1:end],:);
    Opt.isPatchPlot = 0;
    lineMemoStrs = cellstr(num2str(Tones(:)/1000,'%.1fKHz'));
    
    
    lineobj = [];
    hhf = figure('position',[100 100 460 350]);
    hold on
    for nf = 1 : ToneNum
        cFreqs = Tones(nf);
        cFreqData = NMSIndexData(NMTrTones==cFreqs,:);  % correct trials,  & NMOutcomes == 1
        H = plot_meanCaTrace(mean(cFreqData),std(cFreqData)/sqrt(size(cFreqData,1)),xsTime,hhf,Opt);
        set(H.meanPlot,'color',CMap(nf,:));
        set(H.ep,'facecolor',CMap(nf,:),'facealpha',0.4);
        lineobj = [lineobj,H.meanPlot];
    end
    yscales = get(gca,'ylim');
    patch([Opt.t_eventOn Opt.t_eventOn eventOff eventOff],[yscales(1) yscales(2) yscales(2) yscales(1)],1,...
        'Edgecolor','none','facecolor',[.8 .8 .8] ,'facealpha',0.6);
    legend(lineobj,lineMemoStrs,'FontSize',8)
    legend('boxoff')
    title('FreqWise Selection index');
    xlabel('Time (s)');
    ylabel('Selction index');
    set(gca,'FontSize',16);
    %
    saveas(hhf,sprintf('Sess Normalized Sindex sumPlot'));
    saveas(hhf,sprintf('Sess Normalized Sindex sumPlot'),'png');
    close(hhf);
    
    % calculate the peak selection index for each frequency type
    Tones = double(unique(Stimtones));
    ToneNum = length(Tones);
    FrameScale = [TaskStartF.start_frame+1,TaskStartF.start_frame+TaskxTimes.frame_rate]; % within 1s time window
    FreqMaxIndex = zeros(ToneNum,1);
    for cf = 1 : ToneNum
        cfFreq = Tones(cf);
        cFreqData = NMSIndexData(NMTrTones==cfFreq,:);  % correct trials,  & NMOutcomes == 1
        % calculate the peak value within given time win
        MeanTrace = mean(cFreqData);
        AbsTrace = abs(MeanTrace);
        [~,MaxInds] = max(AbsTrace(FrameScale(1):FrameScale(2)));
        FreqMaxIndex(cf) = MeanTrace(TaskStartF.start_frame+MaxInds);
    end
    ToneOctave = log2(Tones/16000);
    ToneBehavCorr = BehavBoundfile.boundary_result.StimCorr;
    ToneBehavCorr(1:floor(ToneNum/2)) = 1 - ToneBehavCorr(1:floor(ToneNum/2));
    BehavB = max(ToneBehavCorr);
    BehavA = min(ToneBehavCorr);
    NorFreqIndex = (FreqMaxIndex - min(FreqMaxIndex))/(max(FreqMaxIndex) - min(FreqMaxIndex));
    Nor2BehavFreqIndex = (BehavB - BehavA)*(FreqMaxIndex - min(FreqMaxIndex))/(max(FreqMaxIndex) - min(FreqMaxIndex)) + BehavA;
    Freqstr = cellstr(num2str(Tones(:)/1000,'%.1f'));
    
    UL = [0.5, 0.5, max(ToneOctave), 100];
    SP = [ToneBehavCorr(1),1 - ToneBehavCorr(end)-ToneBehavCorr(1), mean(ToneOctave), 1];
    SP_FA = [NorFreqIndex(1),1 - NorFreqIndex(end)-NorFreqIndex(1), mean(ToneOctave), 1];
    Nor2BehavSP_FA = [Nor2BehavFreqIndex(1),1 - Nor2BehavFreqIndex(1) - Nor2BehavFreqIndex(end),mean(ToneOctave), 1];
    LM = [0, 0, min(ToneOctave), 0];
    ParaBoundLim = ([UL;SP;LM]);
    ParaBoundLimFA = ([UL;SP_FA;LM]);
    Nor2BehavParaBoundLim = [UL;Nor2BehavSP_FA;LM];
    fit_ReNew = FitPsycheCurveWH_nx(ToneOctave, ToneBehavCorr, ParaBoundLim);
    fit_ReNew_FA = FitPsycheCurveWH_nx(ToneOctave, NorFreqIndex, ParaBoundLimFA);
    fit_ReNew_Nor2behavFA = FitPsycheCurveWH_nx(ToneOctave, Nor2BehavFreqIndex, Nor2BehavParaBoundLim);
    FAFitTaskOctaveValues = feval(fit_ReNew_FA.ffit,ToneOctave);
    Nor2BehavTaskOctValues = feval(fit_ReNew_Nor2behavFA.ffit,ToneOctave);
    OctStep = mean(diff(fit_ReNew.curve(:,1)));
    BehavDerivateCurve = diff(fit_ReNew.curve(:,2));
    BehavDerivateCurve = [BehavDerivateCurve(1);BehavDerivateCurve]/OctStep;
    TaskFA_DerivateCurve = diff(fit_ReNew_FA.curve(:,2));
    TaskFA_DerivateCurve = [TaskFA_DerivateCurve(1);TaskFA_DerivateCurve]/OctStep;
    
    hf = figure('position',[560 500 500 370]);
    yyaxis left
    hold on
    plot(ToneOctave,ToneBehavCorr,'ro','MarkerSize',12,'linewidth',1.8);
    hl1 = plot(fit_ReNew.curve(:,1),fit_ReNew.curve(:,2),'Color','r','linewidth',2,'Linestyle','-');
    plot(ToneOctave,NorFreqIndex,'ko','MarkerSize',12,'linewidth',1.8);
    hl2 = plot(fit_ReNew_FA.curve(:,1),fit_ReNew_FA.curve(:,2),'Color','k','linewidth',2,'Linestyle','-');
    set(gca,'yColor','k');
    ylabel('Psycho. Curve');
    
    yyaxis right
    hold on
    hl3 = plot(fit_ReNew.curve(:,1),BehavDerivateCurve,'Color',[.9 .6 .6],'linewidth',1.8,'Linestyle','-');
    hl4 = plot(fit_ReNew_FA.curve(:,1),TaskFA_DerivateCurve,'Color',[0.7 0.7 0.7],'linewidth',1.8,'Linestyle','-');
    set(gca,'yColor',[.7 .7 .7]);
    ylabel('Dis. power');
%     if IsBoundToneExist
%         plot(BoundTone,BoundNorFA,'bo','MarkerSize',10,'linewidth',1.5);
%     end
    % legend(plot(0,0,'r-o','visible','off'),'Behav');
    legend([hl1,hl2,hl3,hl4],...   %plot(0,0,'r-o','visible','off'),plot(0,0,'k-o','visible','off')
        {'Behav','FAPeak','BehavDisPower','TaskIndexPower'},'Location','NorthWest','FontSize',12);
    legend('boxoff')
    set(gca,'xtick',ToneOctave,'xticklabel',Freqstr,'xlim',[-1.1 1.1]);
    xlabel('Freq (kHz)');
    set(gca,'FontSize',20);
    %
    saveas(hf,'Factor and behavior compare plot');
    saveas(hf,'Factor and behavior compare plot','png');
    close(hf);
    
    FreqIndexAll{m} = FreqMaxIndex;
    NorFreqIndexAll{m} = NorFreqIndex;

    % load passive factor analysis data
    DatafPath = fullfile(Passline,'DimRed_Resplot','MeanPlotData.mat');
    PassFactorData = load(DatafPath);
    PassFreqDatas = load(fullfile(Passline,'rfSelectDataSet.mat'),'SelectSArray');
    PassFreqTypes = unique(PassFreqDatas.SelectSArray);
    PassOctave = log2(double(PassFreqTypes)/16000);
    PassTrTones = double(PassFreqDatas.SelectSArray);
    PassToneNum = length(PassFreqTypes);
    PassFrameScale = [PassFactorData.start_frame+1,PassFactorData.start_frame+PassFactorData.frame_rate];
    PassFreqMaxindex = zeros(PassToneNum,1);
    for cf = 1 : PassToneNum
        cfFreq = PassFreqTypes(cf);
        cFreqData = PassFactorData.cLRIndexSum(PassTrTones==cfFreq,:);  % correct trials,  & NMOutcomes == 1
        % calculate the peak value within given time win
        MeanTrace = mean(cFreqData);
        AbsTrace = abs(MeanTrace);
        [~,MaxInds] = max(AbsTrace(PassFrameScale(1):PassFrameScale(2)));
        PassFreqMaxindex(cf) = MeanTrace(PassFactorData.start_frame+MaxInds);
    end
    UsedPassInds = abs(PassOctave) <= 1;
    UsedPassOctaves = PassOctave(UsedPassInds);
    UsedPassFreqMaxIndex = PassFreqMaxindex(UsedPassInds);
    UsedPassFreqs = PassFreqTypes(UsedPassInds);
    PassNorFreqIndex = (UsedPassFreqMaxIndex - min(FreqMaxIndex))/(max(FreqMaxIndex) - min(FreqMaxIndex));
    Nor2BehavPassIndex = (BehavB - BehavA)*(UsedPassFreqMaxIndex - min(FreqMaxIndex))/(max(FreqMaxIndex) - min(FreqMaxIndex)) + BehavA;
    PassFreqstr = cellstr(num2str(UsedPassFreqs(:)/1000,'%.1f'));
    PassSP_FA = [PassNorFreqIndex(1),1 - PassNorFreqIndex(end)-PassNorFreqIndex(1), mean(ToneOctave), 1];
    Nor2BehavPassSP_FA = [Nor2BehavPassIndex(1),1 - Nor2BehavPassIndex(1) - Nor2BehavPassIndex(end),mean(ToneOctave), 1];
    ParaBoundLimFAPass = ([UL;PassSP_FA;LM]);
    ParaBoundLim_Nor2behFAPass = ([UL;Nor2BehavPassSP_FA;LM]);
    
    fit_ReNew_PassFA = FitPsycheCurveWH_nx(UsedPassOctaves, PassNorFreqIndex, ParaBoundLimFAPass);
    fit_ReNew_PassNor2behFA = FitPsycheCurveWH_nx(UsedPassOctaves, Nor2BehavPassIndex, ParaBoundLim_Nor2behFAPass);
    PassFAFitTaskOctV = feval(fit_ReNew_PassFA.ffit,ToneOctave);
    PassNor2behFAFitTaskOctV = feval(fit_ReNew_PassNor2behFA.ffit,ToneOctave);
    PassFA_DerivateCurve = diff(fit_ReNew_PassFA.curve(:,2));
    PassFA_DerivateCurve = [PassFA_DerivateCurve(1);PassFA_DerivateCurve]/OctStep;
    
    hf = figure('position',[560 500 500 370]);
    yyaxis left
    hold on
    plot(ToneOctave,ToneBehavCorr,'ro','MarkerSize',12,'linewidth',1.8);
    hl1 = plot(fit_ReNew.curve(:,1),fit_ReNew.curve(:,2),'Color','r','linewidth',2,'Linestyle','-');
    plot(UsedPassOctaves,PassNorFreqIndex,'ko','MarkerSize',12,'linewidth',1.8);
    hl2 = plot(fit_ReNew_PassFA.curve(:,1),fit_ReNew_PassFA.curve(:,2),'Color','k','linewidth',2,'Linestyle','-');
    set(gca,'ycolor','k','ylim',[0 1])
    ylabel('Psycho. curve');
    
    yyaxis right
    hl3 = plot(fit_ReNew.curve(:,1),BehavDerivateCurve,'Color',[.9 .6 .6],'linewidth',1.8,'Linestyle','-');
    hl4 = plot(fit_ReNew_PassFA.curve(:,1),PassFA_DerivateCurve,'Color',[.7 .7 .7],'linewidth',1.8,'Linestyle','-');
    set(gca,'ycolor',[.6 .6 .6],'ylim',[-0.1 max(max(PassFA_DerivateCurve),max(BehavDerivateCurve))+0.2]);
    ylabel('Dis. power');
    
%     if IsBoundToneExist
%         plot(BoundTone,BoundNorFA,'bo','MarkerSize',10,'linewidth',1.5);
%     end
    % legend(plot(0,0,'r-o','visible','off'),'Behav');
    legend([hl1,hl2,hl3,hl4],...  % plot(0,0,'r-o','visible','off'),plot(0,0,'k-o','visible','off')
        {'Behav','FAPeak','Behavpower','PassIndexPower'},'Location','NorthWest','FontSize',12);
    legend('boxoff')
    set(gca,'xtick',ToneOctave,'xticklabel',Freqstr,'xlim',[-1.1 1.1]);
    xlabel('Freq (kHz)');
    set(gca,'FontSize',20);
    %
    saveas(hf,'Passive Factor and behavior compare plot');
    saveas(hf,'Passive Factor and behavior compare plot','png');
    close(hf);
    
    IndexTaskPassFitValues{m,1} = ToneOctave(:);
    IndexTaskPassFitValues{m,2} = FAFitTaskOctaveValues(:);
    IndexTaskPassFitValues{m,3} = PassFAFitTaskOctV(:);
    IndexTaskPassFitValues{m,4} = ToneBehavCorr(:);
    IndexTaskPassFitValues{m,5} = Nor2BehavTaskOctValues(:);
    IndexTaskPassFitValues{m,6} = PassNor2behFAFitTaskOctV(:);
    
    SessPowerPeak(m,:) = [max(BehavDerivateCurve),max(TaskFA_DerivateCurve),max(PassFA_DerivateCurve)];
    
    m = m + 1;
    tline = fgetl(fid);
    Passline = fgetl(Passid);
end
%%
cd('E:\DataToGo\data_for_xu\Factor_new_smooth\New_correct_factorAna\SessionSummary');
save FactorAnaDataSave.mat TaskFactorData TaskTime PLotsTLRDis PlotsPLRDis -v7.3
% save FactorAnaDataSave.mat TaskFactorData TaskTime PassFactorData PassTime PLotsTLRDis PlotsPLRDis -v7.3
save LRIndexsumSave.mat TaskTones TaskOutcomes ActionChoice LRIndexSum TaskFrate TaskAlignF FreqIndexAll ...
    NorFreqIndex IndexTaskPassFitValues SessPowerPeak -v7.3
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
            PPTname = 'Session_FAPeak_BehavPlot_all_new';
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
            SessSelectIndexf = fullfile(cTunDataPath,'Sess Normalized Sindex sumPlot.png');
            PassFABehavFile = fullfile(cTunDataPath,'Passive Factor and behavior compare plot.png');
            
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
            exportToPPTX('addtext',sprintf('Session%d',nSession),'Position',[7.5 0 2 0.5],'FontSize',24);
            exportToPPTX('addnote',tline);
            exportToPPTX('addpicture',imread(AllCorrectPlotfile),'Position',[0 0 7.08 4.5]);
            exportToPPTX('addpicture',imread(AllErrorPlotfile),'Position',[0 4.5 7.08 4.5]);
            exportToPPTX('addpicture',imread(SessSelectIndexf),'Position',[7.1 0.5 5 4]);
            exportToPPTX('addpicture',imread(FABehavFile),'Position',[6.7 4.5 4.64 3.5]);
            exportToPPTX('addpicture',imread(PassFABehavFile),'Position',[11.4 4.5 4.5 3.5]);
%                 exportToPPTX('addpicture',TaskRespMapIM,'Position',[6 0.2 5 4.19]);
%                 exportToPPTX('addtext','Task','Position',[11 2 1 2],'FontSize',22);
%                 exportToPPTX('addpicture',PassRespMapIM,'Position',[6 4.5 5 4.19]);
%                 exportToPPTX('addtext','Passive','Position',[11 5.5 3 2],'FontSize',22);
%                 exportToPPTX('addpicture',BoundDiffIM,'Position',[12 4.5 4 3.35]);
% %                     exportToPPTX('addpicture',PassMeanFig,'Position',[12.8 0.8 3 3]);
            exportToPPTX('addtext',sprintf('Batch:%s \r\nAnm: %s\r\nDate: %s\r\nField: %s',...
                Anminfo.BatchNum,Anminfo.AnimalNum,Anminfo.SessionDate,Anminfo.TestNum),...
                'Position',[13 1.5 3 3],'FontSize',22);
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

%%
clear
clc
[fn,fp,fi] = uigetfile('*.txt','Please select the factor analysis data path');
if ~fi
    return;
end
[Passfn,Passfp,~] = uigetfile('*.txt','Please select passive factor analysis data path');

%%
clearvars -except fn fp Passfp Passfn
fpath = fullfile(fp,fn);
fid = fopen(fpath);
tline = fgetl(fid);
Passid = fopen(fullfile(Passfp,Passfn));
Passline = fgetl(Passid);

while ischar(tline)
    if isempty(strfind(tline,'NO_Correction\mode_f_change'))
        tline = fgetl(fid);
        Passline = fgetl(Passid);
        continue;
    end
    %
    cd(tline);
    load(fullfile(tline,'CSessionData.mat'));
    UsedROIInds = [];
    Data_pcTrace_script
    
    clearvars -except tline Passline fn fp Passfp Passfn fid Passid
    cd(Passline);
    load('rfSelectDataSet.mat')
    Passive_factroAna_scripts
    
    clearvars -except tline Passline fn fp Passfp Passfn fid Passid
    
    tline = fgetl(fid);
    Passline = fgetl(Passid);
end

%% plot the multi-session curve together
SessNum = size(IndexTaskPassFitValues,1);
SessOctaves = zeros(SessNum,6);
SessTaskIndexData = zeros(SessNum,6);
SessPassIndexData = zeros(SessNum,6);
SessBehavData = zeros(SessNum,6);
for cSess = 1 : SessNum
    cSessOctaves = IndexTaskPassFitValues{cSess,1};
    cSessTaskIndex = IndexTaskPassFitValues{cSess,2};
    cSessPassIndex = IndexTaskPassFitValues{cSess,3};
    cSessBehav = IndexTaskPassFitValues{cSess,4};
    if length(cSessOctaves) > 6
        cUsedOctInds = abs(cSessOctaves) > 0.18;  % not  include the closet two tones for simplicity
    else
        cUsedOctInds = 1:length(cSessOctaves);
    end
    SessOctaves(cSess,:) = cSessOctaves(cUsedOctInds);
    SessTaskIndexData(cSess,:) = cSessTaskIndex(cUsedOctInds);
    SessPassIndexData(cSess,:) = cSessPassIndex(cUsedOctInds);
    SessBehavData(cSess,:) = cSessBehav(cUsedOctInds);
end
MeanOctaves = mean(SessOctaves);
% SEMOctaves = std(SessOctaves)/sqrt(SessNum);
MeanBehavs = mean(SessBehavData);
SEMBehavs = std(SessBehavData)/sqrt(SessNum);
MeanTaskIndex = mean(SessTaskIndexData);
SEMTaskIndex = std(SessTaskIndexData)/sqrt(SessNum);
MeanPassIndex = mean(SessPassIndexData);
SEMPassIndex = std(SessPassIndexData)/sqrt(SessNum);
OctFreqStrs = cellstr(num2str((2.^MeanOctaves(:))*16,'%.1f'));

% fit logistic curves using everysingle data points but not mean values
OctavesAll = cell2mat(IndexTaskPassFitValues(:,1));
TaskIndexAll = cell2mat(IndexTaskPassFitValues(:,2));
PassIndexAll = cell2mat(IndexTaskPassFitValues(:,3));
BehavDataAll = cell2mat(IndexTaskPassFitValues(:,4));

UL = [0.5, 0.5, max(OctavesAll), 100];
Behav_SP = [min(BehavDataAll),1 - min(BehavDataAll) - max(BehavDataAll), mean(OctavesAll), 1];
SP_TaskIndex = [min(TaskIndexAll),1 - min(TaskIndexAll) - max(TaskIndexAll), mean(OctavesAll), 1];
SP_PassIndex = [min(PassIndexAll),1 - min(PassIndexAll) - max(PassIndexAll), mean(OctavesAll), 1];
LM = [0, 0, min(OctavesAll), 0];

BehavParaBoundLim = ([UL;Behav_SP;LM]);
ParaBoundLim_TaskI = ([UL;SP_TaskIndex;LM]);
ParaBoundLim_PassI = ([UL;SP_PassIndex;LM]);
fit_Behav = FitPsycheCurveWH_nx(OctavesAll, BehavDataAll, BehavParaBoundLim);
fit_TaskI = FitPsycheCurveWH_nx(OctavesAll, TaskIndexAll, ParaBoundLim_TaskI);
fit_PassI = FitPsycheCurveWH_nx(OctavesAll, PassIndexAll, ParaBoundLim_PassI);

BehavFit_ci = predint(fit_Behav.ffit,fit_Behav.curve(:,1),0.95,'functional','on');
TaskIFit_ci = predint(fit_TaskI.ffit,fit_TaskI.curve(:,1),0.95,'functional','on');
PassIFir_ci = predint(fit_PassI.ffit,fit_PassI.curve(:,1),0.95,'functional','on');
%%
hf = figure('position',[100 100 480 400]);
hold on
hl1 = plot(fit_Behav.curve(:,1),fit_Behav.curve(:,2),'r','linewidth',2);
hl2 = plot(fit_TaskI.curve(:,1),fit_TaskI.curve(:,2),'b','linewidth',2);
hl3 = plot(fit_PassI.curve(:,1),fit_PassI.curve(:,2),'k','linewidth',2);
% plot(fit_Behav.curve(:,1),BehavFit_ci,'r','linewidth',0.8,'linestyle','--');
% plot(fit_TaskI.curve(:,1),TaskIFit_ci,'b','linewidth',0.8,'linestyle','--');
% plot(fit_PassI.curve(:,1),PassIFir_ci,'k','linewidth',0.8,'linestyle','--');
errorbar(MeanOctaves,MeanBehavs,SEMBehavs,'ro','MarkerSize',12,'linewidth',1);  %,'Marker','none'
errorbar(MeanOctaves,MeanTaskIndex,SEMTaskIndex,'bo','MarkerSize',12,'linewidth',1);
errorbar(MeanOctaves,MeanPassIndex,SEMPassIndex,'ko','MarkerSize',12,'linewidth',1);
set(gca,'xtick',MeanOctaves,'xticklabel',OctFreqStrs);
xlabel('Frequency (kHz)');
ylabel({'Right Prob.';'Nor. Selection Index'});
set(gca,'FontSize',16);
legend([hl1,hl2,hl3],{'BehavData','Task SelectionIndex','Pass SelectionIndex'},'FontSize',8,'Location','Northwest');
legend('Boxoff')
saveas(hf,'Behavior and selection index logistic plot without CI');
saveas(hf,'Behavior and selection index logistic plot without CI','png');
%%
BehavCI = mean(SessBehavData(:,4:6),2) - mean(SessBehavData(:,1:3),2);
TaskIndexCI = mean(SessTaskIndexData(:,4:6),2) - mean(SessTaskIndexData(:,1:3),2);
PassIndexCI = mean(SessPassIndexData(:,4:6),2) - mean(SessPassIndexData(:,1:3),2);
[~,TaskIndex_p] = ttest(BehavCI,TaskIndexCI);
[~,PassIndex_p] = ttest(BehavCI,PassIndexCI);
hhf = figure('position',[100 100 420 350]);
hold on
Cir1 = plot(BehavCI,TaskIndexCI,'bo','MarkerSize',9,'Linewidth',2);
Cir2 = plot(BehavCI,PassIndexCI,'ko','MarkerSize',9,'Linewidth',2);
line([0 1],[0 1],'Color',[.7 .7 .7],'linewidth',1.6,'linestyle','--');
line([0 0.5],[0.5 0.5],'Color',[.7 .7 .7],'linewidth',1.6,'linestyle','--');
line([0.5 0.5],[0 0.5],'Color',[.7 .7 .7],'linewidth',1.6,'linestyle','--');
set(gca,'xlim',[0 1],'ylim',[0 1],'xtick',[0 0.5 1],'ytick',[0 0.5 1]);
xlabel('Behav CI');
ylabel({'TaskIndexCI';'PassIndexCI'});
set(gca,'FontSize',16)
LegH = legend([Cir1,Cir2],{sprintf('TaskInCI,p=%.2e',TaskIndex_p),sprintf('PassInCI,p=%.2e',PassIndex_p)},...
    'FontSize',8,'Location','Southwest','TextColor','r');
legend('boxoff');
set(LegH,'position',get(LegH,'position')+[-0.1 0 0 0]);
title('Category Index');
saveas(hhf,'Category Index compare plot');
saveas(hhf,'Category Index compare plot','png');

%% normalize the index data according to the behabior result
SessNum = size(IndexTaskPassFitValues,1);
SessOctaves = zeros(SessNum,6);
SessTaskIndexData = zeros(SessNum,6);
SessPassIndexData = zeros(SessNum,6);
SessBehavData = zeros(SessNum,6);
for cSess = 1 : SessNum
    cSessOctaves = IndexTaskPassFitValues{cSess,1};
    cSessTaskIndex = IndexTaskPassFitValues{cSess,5};
    cSessPassIndex = IndexTaskPassFitValues{cSess,6};
    cSessBehav = IndexTaskPassFitValues{cSess,4};
    if length(cSessOctaves) > 6
        cUsedOctInds = abs(cSessOctaves) > 0.18;  % not  include the closet two tones for simplicity
    else
        cUsedOctInds = 1:length(cSessOctaves);
    end
    SessOctaves(cSess,:) = cSessOctaves(cUsedOctInds);
    SessTaskIndexData(cSess,:) = cSessTaskIndex(cUsedOctInds);
    SessPassIndexData(cSess,:) = cSessPassIndex(cUsedOctInds);
    SessBehavData(cSess,:) = cSessBehav(cUsedOctInds);
end
MeanOctaves = mean(SessOctaves);
% SEMOctaves = std(SessOctaves)/sqrt(SessNum);
MeanBehavs = mean(SessBehavData);
SEMBehavs = std(SessBehavData)/sqrt(SessNum);
MeanTaskIndex = mean(SessTaskIndexData);
SEMTaskIndex = std(SessTaskIndexData)/sqrt(SessNum);
MeanPassIndex = mean(SessPassIndexData);
SEMPassIndex = std(SessPassIndexData)/sqrt(SessNum);
OctFreqStrs = cellstr(num2str((2.^MeanOctaves(:))*16,'%.1f'));

% fit logistic curves using everysingle data points but not mean values
OctavesAll = cell2mat(IndexTaskPassFitValues(:,1));
TaskIndexAll = cell2mat(IndexTaskPassFitValues(:,5));
PassIndexAll = cell2mat(IndexTaskPassFitValues(:,6));
BehavDataAll = cell2mat(IndexTaskPassFitValues(:,4));

UL = [0.5, 0.5, max(OctavesAll), 100];
Behav_SP = [min(BehavDataAll),1 - min(BehavDataAll) - max(BehavDataAll), mean(OctavesAll), 1];
SP_TaskIndex = [min(TaskIndexAll),1 - min(TaskIndexAll) - max(TaskIndexAll), mean(OctavesAll), 1];
SP_PassIndex = [min(PassIndexAll),1 - min(PassIndexAll) - max(PassIndexAll), mean(OctavesAll), 1];
LM = [0, 0, min(OctavesAll), 0];

BehavParaBoundLim = ([UL;Behav_SP;LM]);
ParaBoundLim_TaskI = ([UL;SP_TaskIndex;LM]);
ParaBoundLim_PassI = ([UL;SP_PassIndex;LM]);
fit_Behav = FitPsycheCurveWH_nx(OctavesAll, BehavDataAll, BehavParaBoundLim);
fit_TaskI = FitPsycheCurveWH_nx(OctavesAll, TaskIndexAll, ParaBoundLim_TaskI);
fit_PassI = FitPsycheCurveWH_nx(OctavesAll, PassIndexAll, ParaBoundLim_PassI);

BehavFit_ci = predint(fit_Behav.ffit,fit_Behav.curve(:,1),0.95,'functional','on');
TaskIFit_ci = predint(fit_TaskI.ffit,fit_TaskI.curve(:,1),0.95,'functional','on');
PassIFir_ci = predint(fit_PassI.ffit,fit_PassI.curve(:,1),0.95,'functional','on');
%
hf = figure('position',[100 100 480 400]);
hold on
hl1 = plot(fit_Behav.curve(:,1),fit_Behav.curve(:,2),'r','linewidth',2);
hl2 = plot(fit_TaskI.curve(:,1),fit_TaskI.curve(:,2),'b','linewidth',2);
% hl3 = plot(fit_PassI.curve(:,1),fit_PassI.curve(:,2),'k','linewidth',2);
% plot(fit_Behav.curve(:,1),BehavFit_ci,'r','linewidth',0.8,'linestyle','--');
% plot(fit_TaskI.curve(:,1),TaskIFit_ci,'b','linewidth',0.8,'linestyle','--');
% plot(fit_PassI.curve(:,1),PassIFir_ci,'k','linewidth',0.8,'linestyle','--');
errorbar(MeanOctaves,MeanBehavs,SEMBehavs,'ro','MarkerSize',12,'linewidth',1);  %,'Marker','none'
errorbar(MeanOctaves,MeanTaskIndex,SEMTaskIndex,'bo','MarkerSize',12,'linewidth',1);
% errorbar(MeanOctaves,MeanPassIndex,SEMPassIndex,'ko','MarkerSize',12,'linewidth',1);
set(gca,'xtick',MeanOctaves,'xticklabel',OctFreqStrs);
xlabel('Frequency (kHz)');
ylabel({'Right Prob.';'Nor. Selection Index'});
set(gca,'FontSize',16);
legend([hl1,hl2,hl3],{'BehavData','Task SelectionIndex','Pass SelectionIndex'},'FontSize',8,'Location','Northwest');
legend('Boxoff')
saveas(hf,'Behavior and Nor2BehSI logistic plot without 95CI without Pass');
saveas(hf,'Behavior and Nor2BehSI logistic plot without 95CI without Pass','png');
%%
BehavCI = mean(SessBehavData(:,4:6),2) - mean(SessBehavData(:,1:3),2);
TaskIndexCI = mean(SessTaskIndexData(:,4:6),2) - mean(SessTaskIndexData(:,1:3),2);
PassIndexCI = mean(SessPassIndexData(:,4:6),2) - mean(SessPassIndexData(:,1:3),2);
[~,TaskIndex_p] = ttest(BehavCI,TaskIndexCI);
[~,PassIndex_p] = ttest(BehavCI,PassIndexCI);
hhf = figure('position',[100 100 420 350]);
hold on
Cir1 = plot(BehavCI,TaskIndexCI,'bo','MarkerSize',9,'Linewidth',2);
Cir2 = plot(BehavCI,PassIndexCI,'ko','MarkerSize',9,'Linewidth',2);
line([0 1],[0 1],'Color',[.7 .7 .7],'linewidth',1.6,'linestyle','--');
line([0 0.5],[0.5 0.5],'Color',[.7 .7 .7],'linewidth',1.6,'linestyle','--');
line([0.5 0.5],[0 0.5],'Color',[.7 .7 .7],'linewidth',1.6,'linestyle','--');
set(gca,'xlim',[0 1],'ylim',[0 1],'xtick',[0 0.5 1],'ytick',[0 0.5 1]);
xlabel('Behav CI');
ylabel({'TaskIndexCI';'PassIndexCI'});
set(gca,'FontSize',16)
% LegH = legend([Cir1,Cir2],{sprintf('TaskInCI,p=%.2e',TaskIndex_p),sprintf('PassInCI,p=%.2e',PassIndex_p)},...
%     'FontSize',8,'Location','Southwest','TextColor','r');
% legend('boxoff');
% set(LegH,'position',get(LegH,'position')+[-0.1 0 0 0]);
title('Category Index');
saveas(hhf,'Category Index Nor2beh compare plot without legh');
saveas(hhf,'Category Index Nor2beh compare plot without legh','png');

%%
hf = figure('position',[100 100 460 300]);
plot([1,2,3],SessPowerPeak','Color',[.7 .7 .7],'linewidth',1.4);
hf = GrdistPlot(SessPowerPeak,{'BehavSlope','TaskSIslope','PassSIslope'},hf);
set(hf,'position',[100 100 460 300]);
[~,BehavTaskp] = ttest(SessPowerPeak(:,1),SessPowerPeak(:,2));
[~,BehavPassp] = ttest(SessPowerPeak(:,1),SessPowerPeak(:,3));
[~,TaskPassp] = ttest(SessPowerPeak(:,2),SessPowerPeak(:,3));
hf = GroupSigIndication([1,2],max(SessPowerPeak(:,1:2)) , BehavTaskp, hf);
hf = GroupSigIndication([1,3],max(SessPowerPeak(:,[1,3])) , BehavPassp, hf);
hf = GroupSigIndication([2,3],max(SessPowerPeak(:,2:3)) , TaskPassp, hf,1.3);
% cd('E:\DataToGo\data_for_xu\Factor_new_smooth\New_correct_factorAna\SessionSummary');
saveas(hf,'Neuro and behav Slope comparison new');
saveas(hf,'Neuro and behav Slope comparison new','png');
saveas(hf,'Neuro and behav Slope comparison new','pdf');
