%% given data path in a txt file for imaging
clear
clc

[fn,fp,fi] = uigetfile('*.txt','Please select the used data path saved file');
if ~fi
    return;
end
fPath = fullfile(fp,fn);
fids = fopen(fPath);
tline = fgetl(fids);
NormSessPathTask = {};
m = 1;

while ischar(tline)
    if isempty(strfind(tline,'NO_Correction\mode_f_change'))
        tline = fgetl(fids);
        continue;
    end
    
    NormSessPathTask{m} = tline;

    tline = fgetl(fids);
    m = m + 1;
end
%%
clearvars -except NormSessPathTask NormSessPathPass
nSessPath = length(NormSessPathTask); % NormSessPathTask  NormSessPathPass
TunDataCellAll = cell(nSessPath,11);
CategDataCellAll = cell(nSessPath,7);
CategROIFracs = zeros(nSessPath,2);
%%
for cSess = 1 : nSessPath

%
    cSessPath = NormSessPathTask{cSess};
    try
        %
    cTuningDataPath = fullfile(cSessPath,'Tunning_fun_plot_New1s','TunningSTDDataSave.mat');
    cTunFitDataPath = fullfile(cSessPath,'Tunning_fun_plot_New1s','Curve fitting plotsNew','NewLog_fit_test_new','NewCurveFitsave.mat');
    cd(fullfile(cSessPath,'Tunning_fun_plot_New1s','Curve fitting plotsNew','NewLog_fit_test_new'));
    cTunDataUsed = load(cTuningDataPath);
    cTunFitDataUsed = load(cTunFitDataPath,'IsTunedROI','BehavBoundResult','IsCategROI');
    %
    SessBehavBound = cTunFitDataUsed.BehavBoundResult;
    TaskROIBFAll = cTunDataUsed.TaskFreqOctave;
    PassROIBFAll = cTunDataUsed.PassFreqOctave;
    NumROIs = numel(cTunFitDataUsed.IsTunedROI);
    cSessTaskFreqs = (2.^cTunDataUsed.TaskFreqOctave)*cTunDataUsed.BoundFreq;
    cSessPassFreqs = (2.^cTunDataUsed.PassFreqOctave)*cTunDataUsed.BoundFreq;
    
    if length(cSessTaskFreqs) ~= length(cSessPassFreqs)
%         continue;
    end
    NumberROIs = length(cTunFitDataUsed.IsTunedROI);
    TunROIInds = find(cTunFitDataUsed.IsTunedROI);
    TunROINum = length(TunROIInds);
    TunROITaskDatas = cTunDataUsed.CorrTunningFun(:,TunROIInds);
    TunROIPassDatas = cTunDataUsed.PassTunningfun(:,TunROIInds);

    [~,TunDataTaskPeakInds] = max(TunROITaskDatas);
    [~,TunDataPassPeakInds] = max(TunROIPassDatas);
    
    [~,AllTaskPeakInds] = max(cTunDataUsed.CorrTunningFun);
    [~,AllPassPeakInds] = max(cTunDataUsed.PassTunningfun);

    TaskTunROIOctaves = zeros(TunROINum,1);
    PassTunROIOctaves = zeros(TunROINum,1);
    for cR = 1 : TunROINum
        TaskTunROIOctaves(cR) = cTunDataUsed.TaskFreqOctave(TunDataTaskPeakInds(cR));
        PassTunROIOctaves(cR) = cTunDataUsed.PassFreqOctave(TunDataPassPeakInds(cR));
    end
    
    TaskTunOctAll = zeros(NumberROIs,1);
    PassTunOctAll = zeros(NumberROIs,1);
    for ccR = 1 : NumberROIs
        TaskTunOctAll(ccR) = cTunDataUsed.TaskFreqOctave(AllTaskPeakInds(ccR));
        PassTunOctAll(ccR) = cTunDataUsed.PassFreqOctave(AllPassPeakInds(ccR));
    end
    
    TaskOctTypes = cTunDataUsed.TaskFreqOctave;
    [TaskOctaveNum,~]= histc(TaskTunROIOctaves,TaskOctTypes);
    PassOctTypes = cTunDataUsed.PassFreqOctave;
    [PassOctaveNum,~] = histc(PassTunROIOctaves,PassOctTypes);

    TaskFreqs = (2.^cTunDataUsed.TaskFreqOctave(:))*cTunDataUsed.BoundFreq;
    PassFreqs = (2.^cTunDataUsed.PassFreqOctave(:))*cTunDataUsed.BoundFreq;
    TaskFreqStrs = cellstr(num2str(TaskFreqs/1000,'%.1f'));
    PassFreqStrs = cellstr(num2str(PassFreqs/1000,'%.1f'));
    % plots for tuning octave distribution
    hDistribution = figure('position',[100 100 380 320]);
    hold on
    bar(TaskOctTypes-0.05,TaskOctaveNum,0.4,'FaceColor',[1 .2 .2],'EdgeColor','none')
    bar(PassOctTypes+0.05,PassOctaveNum,0.4,'FaceColor',[.6 .6 .6],'EdgeColor','none')
    set(gca,'xtick',TaskOctTypes,'xtickLabel',TaskFreqs);
    xlabel('Freqs (kHz)');
    ylabel('Counts');
    saveas(hDistribution,'Tuning ROI BF distribution plots');
    saveas(hDistribution,'Tuning ROI BF distribution plots','png');
    close(hDistribution)

    % plots for tuning position plots
    TaskZSTunData = zscore(TunROITaskDatas);
    PassZSTunData = zscore(TunROIPassDatas);
    [~,MaxInds] = max(TaskZSTunData);
    [~,MaxSortInds] = sort(MaxInds);
    ROISeqSort = TaskZSTunData(:,MaxSortInds);
    huf = figure('position',[100 100 800 300]);
    subplot(121)
    imagesc(ROISeqSort,[-1.5 1.5]);
    set(gca,'ytick',1:numel(TaskFreqs),'yticklabel',TaskFreqStrs);
    set(gca,'xtick',1:numel(TunROIInds),'xticklabel',TunROIInds(MaxSortInds));
    xtickangle(-90)
    ylabel('Freq (kHz)');
    xlabel('# ROIs');
    title('Task Tuning');
    set(gca,'FontSize',10);

    subplot(122)
    imagesc(PassZSTunData(:,MaxSortInds),[-1.5 1.5]);
    set(gca,'ytick',1:numel(PassFreqs),'yticklabel',PassFreqStrs);
    ylabel('Freq (kHz)');
    xlabel('# ROIs');
    title('Passove Tuning');
    set(gca,'FontSize',10);
%
    saveas(huf,'Tuning ROIs summary plots');
    saveas(huf,'Tuning ROIs summary plots','png');
    close(huf);
    
    
    % task and passive zscore using same mean and std values
    TaskDataMean = repmat(mean(TunROITaskDatas),size(TunROITaskDatas,1),1);
    TaskDataStd = repmat(std(TunROITaskDatas),size(TunROITaskDatas,1),1);

    NewTaskZSTunData = (TunROITaskDatas - TaskDataMean) ./TaskDataStd;
    NewPassZSTunData = (TunROIPassDatas - TaskDataMean) ./TaskDataStd;

    [~,MaxInds] = max(NewTaskZSTunData);
    [~,MaxSortInds] = sort(MaxInds);
    ROISeqSort = NewTaskZSTunData(:,MaxSortInds);
    hNewuf = figure('position',[100 100 800 300]);
    subplot(121)
    imagesc(ROISeqSort,[-1.5 1.5]);
    set(gca,'ytick',1:numel(TaskFreqs),'yticklabel',TaskFreqStrs);
    set(gca,'xtick',1:numel(TunROIInds),'xticklabel',TunROIInds(MaxSortInds));
    xtickangle(-90)
    ylabel('Freq (kHz)');
    xlabel('# ROIs');
    title('Task Tuning');
    set(gca,'FontSize',10);

    subplot(122)
    imagesc(NewPassZSTunData(:,MaxSortInds),[-1.5 1.5]);
    set(gca,'ytick',1:numel(PassFreqs),'yticklabel',PassFreqStrs);
    ylabel('Freq (kHz)');
    xlabel('# ROIs');
    title('Passove Tuning');
    set(gca,'FontSize',10);
    
    saveas(hNewuf,'Tuning ROIs CommonZs summary plots');
    saveas(hNewuf,'Tuning ROIs CommonZs summary plots','png');
    close(hNewuf);
    
    % add plots for all ROIs response summary plots
    TaskDataALLMean = repmat(mean(cTunDataUsed.CorrTunningFun),size(cTunDataUsed.CorrTunningFun,1),1);
    TaskDataALLStd = repmat(std(cTunDataUsed.CorrTunningFun),size(cTunDataUsed.CorrTunningFun,1),1);

    TaskZSALLTunData = (cTunDataUsed.CorrTunningFun - TaskDataALLMean) ./TaskDataALLStd;
    PassZSALLTunData = (cTunDataUsed.PassTunningfun - TaskDataALLMean) ./TaskDataALLStd;

    [~,MaxInds] = max(TaskZSALLTunData);
    [~,MaxSortInds] = sort(MaxInds);
    ROISeqSort = TaskZSALLTunData(:,MaxSortInds);
    hALLuf = figure('position',[100 100 800 300]);
    subplot(121)
    imagesc(ROISeqSort,[-2 2]);
    set(gca,'ytick',1:numel(TaskFreqs),'yticklabel',TaskFreqStrs);
    % set(gca,'xtick',1:numel(TunROIInds),'xticklabel',TunROIInds);
    % xtickangle(-90)
    ylabel('Freq (kHz)');
    xlabel('# ROIs');
    title('Task Tuning');
    set(gca,'FontSize',10);

    subplot(122)
    imagesc(PassZSALLTunData(:,MaxSortInds),[-2 2]);
    set(gca,'ytick',1:numel(PassFreqs),'yticklabel',PassFreqStrs);
    ylabel('Freq (kHz)');
    xlabel('# ROIs');
    title('Passove Tuning');
    set(gca,'FontSize',10);
    
    saveas(hALLuf,'All ROIs CommonZs summary plots');
    saveas(hALLuf,'All ROIs CommonZs summary plots','png');
    close(hALLuf);
    
    % plots for categorical ROIs
    CategROIs = find(cTunFitDataUsed.IsCategROI);
    CategROINum = length(CategROIs);
    CtgROITaskDatas = cTunDataUsed.CorrTunningFun(:,CategROIs);
    CtgROIPassDatas = cTunDataUsed.PassTunningfun(:,CategROIs);

    Nor_CtgROITaskDatas = (CtgROITaskDatas - repmat(min(CtgROITaskDatas),numel(TaskFreqs),1))./...
        (repmat(max(CtgROITaskDatas),numel(TaskFreqs),1) - repmat(min(CtgROITaskDatas),numel(TaskFreqs),1));
    Nor_CtgROIPassDatas = (CtgROIPassDatas - repmat(min(CtgROIPassDatas),numel(PassFreqs),1))./...
        (repmat(max(CtgROIPassDatas),numel(PassFreqs),1) - repmat(min(CtgROIPassDatas),numel(PassFreqs),1));
    GrInds = (cTunDataUsed.TaskFreqOctave < 0);

    PreferSide = mean(CtgROITaskDatas(GrInds,:)) < mean(CtgROITaskDatas(~GrInds,:));
    PreferSideData = Nor_CtgROITaskDatas;
    PreferSideData(:,~PreferSide) = flipud(PreferSideData(:,~PreferSide));

    PreferPassData = Nor_CtgROIPassDatas;
    PreferPassData(:,~PreferSide) = flipud(PreferPassData(:,~PreferSide));

    huCtgf = figure('position',[100 100 800 300]);
    subplot(121)
    imagesc(PreferSideData',[0 1]);
    set(gca,'xtick',1:numel(TaskFreqs),'xticklabel',TaskFreqStrs);
    set(gca,'ytick',1:numel(CategROIs),'yticklabel',CategROIs);
    xlabel('Freq (kHz)');
    ylabel('# ROIs');
    title('Task Categ');
    set(gca,'FontSize',14);

    subplot(122)
    imagesc(PreferPassData',[0 1]);
    set(gca,'xtick',1:numel(PassFreqs),'xticklabel',PassFreqStrs);
    xlabel('Freq (kHz)');
    ylabel('# ROIs');
    title('Passove Categ');
    set(gca,'FontSize',14);
%
    saveas(huCtgf,'Categ ROIs summary plots');
    saveas(huCtgf,'Categ ROIs summary plots','png');
    close(huCtgf);
    
    % calculate the categorical ROI fraction compared with slope value
    try
        cSessBehavPath = fullfile(cSessPath,'RandP_data_plots','boundary_result.mat');
        cSessBehavData = load(cSessBehavPath);
        BehavSlope = max(cSessBehavData.boundary_result.SlopeCurve);
        CategFrac = numel(PreferSide)/NumROIs;
        CategROIFracs(cSess,:) = [BehavSlope,CategFrac];
    catch
        %
    end
    
    TunDataCellAll{cSess,1} = cTunFitDataUsed.IsTunedROI;
    TunDataCellAll{cSess,2} = TaskROIBFAll;
    TunDataCellAll{cSess,3} = TaskTunROIOctaves;
    TunDataCellAll{cSess,4} = PassROIBFAll;
    TunDataCellAll{cSess,5} = PassTunROIOctaves;
    TunDataCellAll{cSess,6} = TunROITaskDatas;
    TunDataCellAll{cSess,7} = TunROIPassDatas;
    TunDataCellAll{cSess,8} = SessBehavBound;
    TunDataCellAll{cSess,9} = TaskTunOctAll;
    TunDataCellAll{cSess,10} = PassTunOctAll;
    
    CategDataCellAll{cSess,1} = cTunFitDataUsed.IsCategROI;
    CategDataCellAll{cSess,2} = CtgROITaskDatas;
    CategDataCellAll{cSess,3} = CtgROIPassDatas;
    CategDataCellAll{cSess,4} = PreferSideData;
    CategDataCellAll{cSess,5} = PreferPassData;
    CategDataCellAll{cSess,6} = TaskFreqs;
    CategDataCellAll{cSess,7} = PreferSide;
    
    save TypeSavedData.mat  TaskOctTypes PassOctTypes TaskTunROIOctaves PassTunROIOctaves ...
        TunROITaskDatas TunROIPassDatas CtgROITaskDatas CtgROIPassDatas PreferSideData ...
        PreferPassData TaskFreqs PassFreqs TunROIInds CategROIs TaskROIBFAll PassROIBFAll ...
        TaskZSALLTunData PassZSALLTunData SessBehavBound PreferSide -v7.3
    catch 
        fprintf('Error at session %d.\n',cSess);
    end
end

%%
TaskDisModeAlls = cellfun(@(x,y) abs(mode(x) - y),TunDataCellAll(:,9),TunDataCellAll(:,8));
PassDisModeAlls = cellfun(@(x,y) abs(mode(x) - y),TunDataCellAll(:,10),TunDataCellAll(:,8));

TaskDisMeanAlls = cellfun(@(x,y) mean(abs(x - y)),TunDataCellAll(:,9),TunDataCellAll(:,8));
PassDisMeanAlls = cellfun(@(x,y) mean(abs(x - y)),TunDataCellAll(:,10),TunDataCellAll(:,8));


%%
UsedSessPath = 'S:\BatchData\batch53\UsedSessionIndex.mat';
SessUsedIndex = load(UsedSessPath);
SessUsedLogiIndex = logical(SessUsedIndex.SessUsedIndex(:));
%% 
TaskTunOctSumm = TunDataCellAll(:,3);
PassTunOctSumm = TunDataCellAll(:,5);
SessBehavCell = TunDataCellAll(:,8);
SessROINumCell = TunDataCellAll(:,1);
EmptyInds = cellfun(@(x) isempty(x),SessBehavCell);

TaskTun2BehavDis = cellfun(@(x,y) abs(x - y),TaskTunOctSumm(~EmptyInds & SessUsedLogiIndex),SessBehavCell(~EmptyInds & SessUsedLogiIndex),'UniformOutput',false);
PassTun2BehavDis = cellfun(@(x,y) abs(x - y),PassTunOctSumm(~EmptyInds & SessUsedLogiIndex),SessBehavCell(~EmptyInds & SessUsedLogiIndex),'UniformOutput',false);

TaskOctsDisAll = cell2mat(TaskTun2BehavDis);
PassOctsDisAll = cell2mat(PassTun2BehavDis);

TaskBFAlls = cell2mat(TaskTunOctSumm(~EmptyInds & SessUsedLogiIndex));
PassBFAlls = cell2mat(PassTunOctSumm(~EmptyInds & SessUsedLogiIndex));


ROISums = cellfun(@numel,SessROINumCell(~EmptyInds & SessUsedLogiIndex));

%% summarized all plots in a ppt file
clearvars -except NormSessPathTask
m = 1;
nSession = length(NormSessPathTask);

for cSess = 1 : nSession
    tline = NormSessPathTask{cSess};
    IsErrorExist = 0;
    %
    if m == 1
        %
        %                 PPTname = input('Please input the name for current PPT file:\n','s');
        PPTname = 'Celltype_response_colorplot_1sCorr';
        if isempty(strfind(PPTname,'.ppt'))
            PPTname = [PPTname,'.pptx'];
        end
        %                 pptSavePath = uigetdir(pwd,'Please select the path used for ppt file savege');
        if ismac
            pptSavePath = '/Volumes/XIN-Yu-potable-disk/batch53_data';
        elseif ispc
            pptSavePath = 'P:\BatchData\batch53';
        end
        %
    end
    %
    Anminfo = SessInfoExtraction(tline);
    cTunPlotPath = fullfile(tline,'Tunning_fun_plot_New1s','Curve fitting plots','NewLog_fit_test_new');
   
    BehavDataPath = fullfile(tline,'RandP_data_plots','Behav_fit plot.png');
    TunROIColorPlotPath = fullfile(cTunPlotPath,'Tuning ROIs summary plots.png');
    CategROIColorPlotPath = fullfile(cTunPlotPath,'Categ ROIs summary plots.png');
    TunROIBFDisPath = fullfile(cTunPlotPath,'Tuning ROI BF distribution plots.png');
    nROIfiles = dir(fullfile(cTunPlotPath,'Log Fit test Save ROI*.png'));
    
    ColoredBFPlotsTaskPath = fullfile(tline,'Tunning_fun_plot_New1s',...
        'Tuned ROI fixedRange grayCP plot','Task TunROI BF colormap save.png');
    ColoredBFPlotsPassPath = fullfile(tline,'Tunning_fun_plot_New1s',...
        'Tuned ROI fixedRange grayCP plot','Passive TunROI BF colormap save.png');

    pptFullfile = fullfile(pptSavePath,PPTname);
    if ~exist(pptFullfile,'file')
        NewFileExport = 1;
    else
        NewFileExport = 0;
    end
    if  m == 1
        if NewFileExport
            exportToPPTX('new','Dimensions',[16,9],'Author','XinYu','Comments','Export of tunning curve plot data');
        else
            exportToPPTX('open',pptFullfile);
        end
    end
    %
    exportToPPTX('addslide');
    exportToPPTX('addnote',tline);
    try
         Datas = load(fullfile(cTunPlotPath,'TypeSavedData.mat'),'TunROITaskDatas','CtgROITaskDatas');
        nTunROIs = size(Datas.TunROITaskDatas,2);
        nCatgROIs = size(Datas.CtgROITaskDatas,2);
        exportToPPTX('addtext',sprintf('nROIs = %d\nTfrac %.3f, CFrac %.3f',length(nROIfiles),nTunROIs/length(nROIfiles),nCatgROIs/length(nROIfiles)...
            ),'Position',[2 0 4 1],'FontSize',20);
    catch
        exportToPPTX('addtext',sprintf('nROIs = %d',length(nROIfiles)),'Position',[2 0 2 1],'FontSize',20);
    end
    try
        exportToPPTX('addpicture',imread(TunROIColorPlotPath),'Position',[0 1 7 2.62]);
%         IsErrorExist = 1;
    catch
        IsErrorExist = 1;
    end
    try
        exportToPPTX('addpicture',imread(CategROIColorPlotPath),'Position',[0 3.7 7 2.62]);
    catch
        IsErrorExist = 1;
    end
    try
        exportToPPTX('addpicture',imread(TunROIBFDisPath),'Position',[0 6.35 3.1 2.6]);
        exportToPPTX('addpicture',imread(ColoredBFPlotsTaskPath),'Position',[7 2 4.5 3.82]);
        exportToPPTX('addpicture',imread(ColoredBFPlotsPassPath),'Position',[11.5 2 4.5 3.82]);
        
    catch
        IsErrorExist = 1;
    end
    exportToPPTX('addpicture',imread(BehavDataPath),'Position',[3.5 6.35 3.47 2.6]);

    exportToPPTX('addtext','Task','Position',[9 1 1 1],'FontSize',20);
    exportToPPTX('addtext','Pass','Position',[14 1 1 1],'FontSize',20);

    exportToPPTX('addtext',sprintf('Batch:%s Anm:%s \nDate:%s Field:%s\n',...
        Anminfo.BatchNum,Anminfo.AnimalNum,Anminfo.SessionDate,Anminfo.TestNum),...
        'Position',[11 7 4 2],'FontSize',20);
    if IsErrorExist
        fprintf('Session %d do not have enough plots.\n',cSess);
    end
    m = m + 1;
    
end
saveName = exportToPPTX('saveandclose',pptFullfile);

%%
clearvars -except NormSessPathTask
m = 1;
nSession = length(NormSessPathTask);
CusMap = blue2red_2(32,0.8);

for cSess = 1 : nSession
    tline = NormSessPathTask{cSess};
    if isempty(strfind(tline,'NO_Correction\mode_f_change'))
        continue;
    end
    try
    % passive tuning frequency colormap plot
    load(fullfile(tline,'Tunning_fun_plot_New1s','TunningDataSave.mat'));
    load(fullfile(tline,'CSessionData.mat'),'behavResults','smooth_data','start_frame','frame_rate');
    cTunFitDataPath = fullfile(tline,'Tunning_fun_plot_New1s','Curve fitting plots','NewLog_fit_test_new','NewCurveFitsave.mat');
    cTunFitDataUsed = load(cTunFitDataPath,'IsTunedROI');
    
    cd(fullfile(tline,'Tunning_fun_plot_New1s'));
%     RespDataStrc = load(fullfile(pwd,'Curve fitting plots','NewCurveFitsave.mat'));
%     RespInds = RespDataStrc.ROIisResponsive;
%     ROI_IsSigResp_script
    [~,EndInds] = regexp(tline,'result_save');
    ROIposfilePath = tline(1:EndInds);
    ROIposfilePosi = dir(fullfile(ROIposfilePath,'ROIinfo*.mat'));
    ROIdataStrc = load(fullfile(ROIposfilePath,ROIposfilePosi(1).name));
    if isfield(ROIdataStrc,'ROIinfoBU')
        ROIinfoData = ROIdataStrc.ROIinfoBU;
    elseif isfield(ROIdataStrc,'ROIinfo')
        ROIinfoData = ROIdataStrc.ROIinfo(1);
    else
        error('No ROI information file detected, please check current session path.');
    end
    
    BehavBoundfile = load(fullfile(tline,'RandP_data_plots','boundary_result.mat'));
    BehavBoundData = BehavBoundfile.boundary_result.Boundary - 1;
    BehavCorr = BehavBoundfile.boundary_result.StimCorr;
    
    if ~isdir('Tuned ROI BF plot')
        mkdir('Tuned ROI BF plot');
    end
    cd('Tuned ROI BF plot');
    
%     GroupStimsNum = floor(length(BehavCorr)/2);
%     BehavOctaves = log2(double(BehavBoundfile.boundary_result.StimType)/16000);
%     FreqStrs = cellstr(num2str(BehavBoundfile.boundary_result.StimType(:)/1000,'%.1f'));
%     
    
    % ###############################################################################
    % extract passive session maxium responsive frequency index
    UsedOctaveInds = ~(abs(PassFreqOctave) > 1);
    UsedOctave = PassFreqOctave(UsedOctaveInds);
    UsedOctave = UsedOctave(:);
    UsedOctaveData = PassTunningfun(UsedOctaveInds,:);
    nROIs = size(UsedOctaveData,2);
    [MaxAmp,maxInds] = max(UsedOctaveData);
    PassMaxOct = zeros(nROIs,1);
    for cROI = 1 : nROIs
        PassMaxOct(cROI) = UsedOctave(maxInds(cROI));
    end
%     ROIsigResp = RespInds;
    RespROIInds = logical(cTunFitDataUsed.IsTunedROI);
%     RespROIInds = logical(ROIsigResp);
%     modeFreqInds = MaxIndsOctave(RespROIInds) == mode(MaxIndsOctave(RespROIInds));
%     [PassClusterInterMean,PassRandMean,hhf] =  Within2BetOrRandRatio(DisMatrix(RespROIInds,RespROIInds),modeFreqInds,'Rand');
%     saveas(hhf,'Passive Rand_vs_intermodeROIs distance ratio distribution');
%     saveas(hhf,'Passive Rand_vs_intermodeROIs distance ratio distribution','png');
%     close(hhf);
    AllPassMaxOcts = PassMaxOct;
    PassFreqStrs = cellstr(num2str(BoundFreq*(2.^UsedOctave(:))/1000,'%.1f'));
    BoundFreqIndex = find(UsedOctave > BehavBoundData,1,'first');
    WithBoundyTick = [UsedOctave(1:BoundFreqIndex-1);BehavBoundData;UsedOctave(BoundFreqIndex:end)];
    WithBoundyTickLabel = [PassFreqStrs(1:BoundFreqIndex-1);'BehavBound';PassFreqStrs(BoundFreqIndex:end)];
    NonRespROIInds = ~RespROIInds;
    %
        cPrcvalue = 0;
        %
        PrcThres = prctile(MaxAmp,cPrcvalue);
        cROIinds = MaxAmp >= PrcThres; 
        GrayNonRespROIs = cROIinds(:) & NonRespROIInds(:);
        ColorRespROIs = cROIinds(:) & ~NonRespROIInds(:);
        
        % plot the responsive ROIs with color indicates tuning octave
        AllMasks = ROIinfoData.ROImask(ColorRespROIs);
        PassMaxOct = AllPassMaxOcts(ColorRespROIs);
        nROIs = length(AllMasks);
        SumROImask = double(AllMasks{1});
        SumROIcolormask = SumROImask * PassMaxOct(1);
        for cROI = 2 : nROIs
            cROINewMask = double(AllMasks{cROI});
            TempSumMask = SumROImask + cROINewMask;
            OverLapInds = find(TempSumMask > 1);
            if ~isempty(OverLapInds)
                cROINewMask(OverLapInds) = 0;
            end
            SumROImask = double(TempSumMask > 0);
            SumROIcolormask = SumROIcolormask + cROINewMask * PassMaxOct(cROI);
        end
        
        if sum(GrayNonRespROIs)
            % generate the non-responsive ROIs, gray map
            AllMasksNonrp = ROIinfoData.ROImask(GrayNonRespROIs);
    %         PassMaxOct = AllPassMaxOcts(GrayNonRespROIs);
            nROIsNonrp = length(AllMasksNonrp);
            SumROImaskNonrp = double(AllMasksNonrp{1});
            SumROIcolormaskNonrp = SumROImaskNonrp * 0.1;
            for cROI = 2 : nROIsNonrp
                cROINewMask = double(AllMasksNonrp{cROI});
                TempSumMask = SumROImaskNonrp + cROINewMask;
                OverLapInds = find(TempSumMask > 1);
                if ~isempty(OverLapInds)
                    cROINewMask(OverLapInds) = 0;
                end
                SumROImaskNonrp = double(TempSumMask > 0);
                SumROIcolormaskNonrp = SumROIcolormaskNonrp + cROINewMask * 0.1;
            end
        else
            SumROImaskNonrp = zeros(size(SumROImask));
            SumROIcolormaskNonrp = zeros(size(SumROImask));
        end
        %
        hColor = figure('position',[30 100 530 450]);
        ax1=axes;
        h_backf=imagesc(SumROIcolormask,[-1 1]);
        Cpos=get(ax1,'position');
        view(2);
        ax2=axes;
        h_frontf=imagesc(SumROIcolormaskNonrp,[-0.5 0.2]);
        set(h_frontf,'alphadata',SumROImaskNonrp~=0);
        set(h_backf,'alphadata',SumROImask~=0);
        linkaxes([ax1,ax2]);
        ax2.Visible = 'off';
        ax2.XTick = [];
        ax2.YTick = [];
        colormap(ax2,'gray');
        colormap(ax1,CusMap);
        set(ax1,'box','off');
        axis(ax1, 'off');
        
        % alpha(h_frontf,0.4);
        set([ax1,ax2],'position',Cpos);
        hBar = colorbar(ax1,'westoutside');
        set(hBar,'position',get(hBar,'position').*[0.7 1 0.5 0.6]+[0.06 0.2 0 0],'TickLength',0);
        set(hBar,'ytick',[-1 1],'yticklabel',{'8','32'});
        title(hBar,'kHz')
        title(sprintf('Prc%d map',cPrcvalue));
        h_axes = axes('position', hBar.Position, 'ylim', hBar.Limits, 'color', 'none', 'visible','off');
        hl = line(h_axes.XLim, BehavBoundData*[1 1], 'color', 'k', 'parent', h_axes,'LineWidth',4);
        ModeTunedOctaves = mode(PassMaxOct);
        h2 = line(h_axes.XLim, ModeTunedOctaves*[1 1], 'color', 'r', 'parent', h_axes,'LineWidth',4);
        % boundary line position
        LineStartPositionB = [hBar.Position(1),(BehavBoundData-hBar.Limits(1))/diff(hBar.Limits)*hBar.Position(4)+hBar.Position(2)];
        % mode line position
        LineStartPositionM = [hBar.Position(1),(ModeTunedOctaves-hBar.Limits(1))/diff(hBar.Limits)*hBar.Position(4)+hBar.Position(2)];
        BoundArrowx = [LineStartPositionB(1)-0.06,LineStartPositionB(1)];
        BoundArrowy = [LineStartPositionB(2),LineStartPositionB(2)];
        ModeArrowx = [LineStartPositionM(1)-0.06,LineStartPositionM(1)];
        ModeArrowy = [LineStartPositionM(2),LineStartPositionM(2)];
        if ModeTunedOctaves < BehavBoundData
            TextBoundDim = [LineStartPositionB(1)-0.18 LineStartPositionB(2)-0.05 0.2 0.1];
            TextModeDim = [LineStartPositionM(1)-0.18 LineStartPositionM(2)-0.05 0.2 0.1];
            annotation('arrow',BoundArrowx,BoundArrowy,'Color','k','Linewidth',2);
            annotation('arrow',ModeArrowx,ModeArrowy,'Color','r','Linewidth',2);
            annotation('textbox',TextBoundDim,'String',{'Behavior';'Boundary'},'FitBoxToText','on','EdgeColor','none',...
                'Color','k','HorizontalAlignment','left','VerticalAlignment','middle');
            annotation('textbox',TextModeDim,'String',{'Prefer';'Frequency'},'FitBoxToText','on','EdgeColor','none',...
                'Color','r','HorizontalAlignment','left','VerticalAlignment','middle');
%             BoundArrowx = [LineStartPositionB(1)-0.03,LineStartPositionB(1)];
%             BoundArrowy = [LineStartPositionB(2)+0.1,LineStartPositionB(2)];
%             if BoundArrowy(1)> 1
%                 BoundArrowy(1) = 1;
%             end
%             ModeArrowx = [LineStartPositionM(1)-0.03,LineStartPositionM(1)];
%             ModeArrowy = [LineStartPositionM(2)-0.1,LineStartPositionM(2)];
%             if ModeArrowy(1) < 0
%                 ModeArrowy(1) = 0;
%             end
%             annotation('textarrow',BoundArrowx,BoundArrowy,'String','BehavBound','Color','r','LineWidth',2);
%             annotation('textarrow',ModeArrowx,ModeArrowy,'String','ModeFreq','Color','m','LineWidth',2);
        else
            TextBoundDim = [LineStartPositionB(1)-0.18 LineStartPositionB(2)-0.05 0.2 0.1];
            TextModeDim = [LineStartPositionM(1)-0.18 LineStartPositionM(2)-0.05 0.2 0.1];
            annotation('arrow',BoundArrowx,BoundArrowy,'Color','k','Linewidth',2);
            annotation('arrow',ModeArrowx,ModeArrowy,'Color','r','Linewidth',2);
            annotation('textbox',TextBoundDim,'String',{'Behavior';'Boundary'},'FitBoxToText','on','EdgeColor','none',...
                'Color','k','HorizontalAlignment','left','VerticalAlignment','middle');
            annotation('textbox',TextModeDim,'String',{'Prefer';'Frequency'},'FitBoxToText','on','EdgeColor','none',...
                'Color','r','HorizontalAlignment','left','VerticalAlignment','middle');
%             BoundArrowx = [LineStartPositionB(1)-0.03,LineStartPositionB(1)];
%             BoundArrowy = [LineStartPositionB(2)-0.1,LineStartPositionB(2)];
%             if BoundArrowy(1) < 0
%                 BoundArrowy(1) = 0;
%             end
%             ModeArrowx = [LineStartPositionM(1)-0.03,LineStartPositionM(1)];
%             ModeArrowy = [LineStartPositionM(2)+0.1,LineStartPositionM(2)];
%             if ModeArrowy(1) > 1
%                 ModeArrowy(1) = 1;
%             end
%             annotation('textarrow',BoundArrowx,BoundArrowy,'String','BehavBound','Color','r','LineWidth',2);
%             annotation('textarrow',ModeArrowx,ModeArrowy,'String','ModeFreq','Color','m','LineWidth',2);
        end
        set(ax1,'position',get(ax1,'position')+[0.1 0 0 0])
        set(ax2,'position',get(ax2,'position')+[0.1 0 0 0])
   
%
        saveas(hColor,sprintf('Passive top Prc%d colormap save',100-cPrcvalue));
        saveas(hColor,sprintf('Passive top Prc%d colormap save',100-cPrcvalue),'png');
        close(hColor);
        %
    PassROITunedOctave = AllPassMaxOcts;
    PassOctaves = UsedOctave;
    Octaves = unique(AllPassMaxOcts);
    PassOctaveTypeNum = zeros(length(PassOctaves),1);
    for n = 1 : length(PassOctaves)
        PassOctaveTypeNum(n) = sum(AllPassMaxOcts == PassOctaves(n));
    end

    %
    % extract task session maxium responsive frequency index
    % UsedOctaveInds = ~(abs(PassFreqOctave) > 1);
    UsedOctave = TaskFreqOctave;
    UsedOctave = UsedOctave(:);
    UsedOctaveData = CorrTunningFun;
    nROIs = size(UsedOctaveData,2);
    [MaxAmp,maxInds] = max(UsedOctaveData);
    TaskMaxOct = zeros(nROIs,1);
    for cROI = 1 : nROIs
        TaskMaxOct(cROI) = UsedOctave(maxInds(cROI));
    end

    %
    AllTaskMaxOcts = TaskMaxOct;
    TaskFreqStrs = cellstr(num2str(BoundFreq*(2.^UsedOctave(:))/1000,'%.1f'));
    BoundFreqIndex = find(UsedOctave > BehavBoundData,1,'first');
    WithBoundyTick = [UsedOctave(1:BoundFreqIndex-1);BehavBoundData;UsedOctave(BoundFreqIndex:end)];
    WithBoundyTickLabel = [TaskFreqStrs(1:BoundFreqIndex-1);'BehavBound';TaskFreqStrs(BoundFreqIndex:end)];
    NonRespROIInds = ~RespROIInds;
%
        cPrcvalue = 0;
        PrcThres = prctile(MaxAmp,cPrcvalue);
        cROIinds = MaxAmp >= PrcThres; 
        
        
        ColorRespROIs = cROIinds(:) & ~NonRespROIInds(:);
        GrayNonRespROIs = cROIinds(:) & NonRespROIInds(:);
        
        % responsive ROI inds
        AllMasks = ROIinfoData.ROImask(ColorRespROIs);
        TaskMaxOct = AllTaskMaxOcts(ColorRespROIs);
        nROIs = length(AllMasks);
        SumROImask = double(AllMasks{1});
        SumROIcolormask = SumROImask * TaskMaxOct(1);
        for cROI = 2 : nROIs
            cROINewMask = double(AllMasks{cROI});
            TempSumMask = SumROImask + cROINewMask;
            OverLapInds = find(TempSumMask > 1);
            if ~isempty(OverLapInds)
                cROINewMask(OverLapInds) = 0;
            end
            SumROImask = double(TempSumMask > 0);
            SumROIcolormask = SumROIcolormask + cROINewMask * TaskMaxOct(cROI);
        end
        
        % non-responsive ROI colormap generation
        AllMasksNonrp = ROIinfoData.ROImask(GrayNonRespROIs);
%         TaskMaxOct = AllTaskMaxOcts(GrayNonRespROIs);
        nROIsNonrp = length(AllMasksNonrp);
        SumROImaskNonrp = double(AllMasksNonrp{1});
        SumROIcolormaskNonrp = SumROImaskNonrp * 0.1;
        for cROI = 2 : nROIsNonrp
            cROINewMask = double(AllMasksNonrp{cROI});
            TempSumMask = SumROImaskNonrp + cROINewMask;
            OverLapInds = find(TempSumMask > 1);
            if ~isempty(OverLapInds)
                cROINewMask(OverLapInds) = 0;
            end
            SumROImaskNonrp = double(TempSumMask > 0);
            SumROIcolormaskNonrp = SumROIcolormaskNonrp + cROINewMask * 0.1;
        end
        %
         hColor = figure('position',[30 500 530 450]);
        ax1=axes;
        h_backf=imagesc(SumROIcolormask,[-1 1]);
        Cpos=get(ax1,'position');
        view(2);
        ax2=axes;
        h_frontf=imagesc(SumROIcolormaskNonrp,[-0.5 0.2]);
        set(h_frontf,'alphadata',SumROImaskNonrp~=0);
        set(h_backf,'alphadata',SumROImask~=0);
        linkaxes([ax1,ax2]);
        ax2.Visible = 'off';
        ax2.XTick = [];
        ax2.YTick = [];
        colormap(ax2,'gray');
        colormap(ax1,CusMap);
        set(ax1,'box','off');
        axis(ax1, 'off');
        
        % alpha(h_frontf,0.4);
        set([ax1,ax2],'position',Cpos);
        hBar = colorbar(ax1,'westoutside');
        set(hBar,'position',get(hBar,'position').*[0.7 1 0.5 0.6]+[0.06 0.2 0 0],'TickLength',0);
        set(hBar,'ytick',[-1 1],'yticklabel',{'8','32'});
        title(hBar,'kHz')
        title(sprintf('Prc%d map',cPrcvalue));
        h_axes = axes('position', hBar.Position, 'ylim', hBar.Limits, 'color', 'none', 'visible','off');
        hl = line(h_axes.XLim, BehavBoundData*[1 1], 'color', 'k', 'parent', h_axes,'LineWidth',4);
        ModeTunedOctaves = mode(TaskMaxOct);
        h2 = line(h_axes.XLim, ModeTunedOctaves*[1 1], 'color', 'r', 'parent', h_axes,'LineWidth',4);
        % boundary line position
        LineStartPositionB = [hBar.Position(1),(BehavBoundData-hBar.Limits(1))/diff(hBar.Limits)*hBar.Position(4)+hBar.Position(2)];
        % mode line position
        LineStartPositionM = [hBar.Position(1),(ModeTunedOctaves-hBar.Limits(1))/diff(hBar.Limits)*hBar.Position(4)+hBar.Position(2)];
        BoundArrowx = [LineStartPositionB(1)-0.06,LineStartPositionB(1)];
        BoundArrowy = [LineStartPositionB(2),LineStartPositionB(2)];
        ModeArrowx = [LineStartPositionM(1)-0.06,LineStartPositionM(1)];
        ModeArrowy = [LineStartPositionM(2),LineStartPositionM(2)];
        if ModeTunedOctaves < BehavBoundData
            TextBoundDim = [LineStartPositionB(1)-0.18 LineStartPositionB(2)-0.05 0.2 0.1];
            TextModeDim = [LineStartPositionM(1)-0.18 LineStartPositionM(2)-0.05 0.2 0.1];
            annotation('arrow',BoundArrowx,BoundArrowy,'Color','k','Linewidth',2);
            annotation('arrow',ModeArrowx,ModeArrowy,'Color','r','Linewidth',2);
            annotation('textbox',TextBoundDim,'String',{'Behavior';'Boundary'},'FitBoxToText','on','EdgeColor','none',...
                'Color','k','HorizontalAlignment','left','VerticalAlignment','middle');
            annotation('textbox',TextModeDim,'String',{'Prefer';'Frequency'},'FitBoxToText','on','EdgeColor','none',...
                'Color','r','HorizontalAlignment','left','VerticalAlignment','middle');
%             BoundArrowx = [LineStartPositionB(1)-0.03,LineStartPositionB(1)];
%             BoundArrowy = [LineStartPositionB(2)+0.1,LineStartPositionB(2)];
%             if BoundArrowy(1)> 1
%                 BoundArrowy(1) = 1;
%             end
%             ModeArrowx = [LineStartPositionM(1)-0.03,LineStartPositionM(1)];
%             ModeArrowy = [LineStartPositionM(2)-0.1,LineStartPositionM(2)];
%             if ModeArrowy(1) < 0
%                 ModeArrowy(1) = 0;
%             end
%             annotation('textarrow',BoundArrowx,BoundArrowy,'String','BehavBound','Color','r','LineWidth',2);
%             annotation('textarrow',ModeArrowx,ModeArrowy,'String','ModeFreq','Color','m','LineWidth',2);
        else
            TextBoundDim = [LineStartPositionB(1)-0.18 LineStartPositionB(2)-0.05 0.2 0.1];
            TextModeDim = [LineStartPositionM(1)-0.18 LineStartPositionM(2)-0.05 0.2 0.1];
            annotation('arrow',BoundArrowx,BoundArrowy,'Color','k','Linewidth',2);
            annotation('arrow',ModeArrowx,ModeArrowy,'Color','r','Linewidth',2);
            annotation('textbox',TextBoundDim,'String',{'Behavior';'Boundary'},'FitBoxToText','on','EdgeColor','none',...
                'Color','k','HorizontalAlignment','left','VerticalAlignment','middle');
            annotation('textbox',TextModeDim,'String',{'Prefer';'Frequency'},'FitBoxToText','on','EdgeColor','none',...
                'Color','r','HorizontalAlignment','left','VerticalAlignment','middle');
%             BoundArrowx = [LineStartPositionB(1)-0.03,LineStartPositionB(1)];
%             BoundArrowy = [LineStartPositionB(2)-0.1,LineStartPositionB(2)];
%             if BoundArrowy(1) < 0
%                 BoundArrowy(1) = 0;
%             end
%             ModeArrowx = [LineStartPositionM(1)-0.03,LineStartPositionM(1)];
%             ModeArrowy = [LineStartPositionM(2)+0.1,LineStartPositionM(2)];
%             if ModeArrowy(1) > 1
%                 ModeArrowy(1) = 1;
%             end
%             annotation('textarrow',BoundArrowx,BoundArrowy,'String','BehavBound','Color','r','LineWidth',2);
%             annotation('textarrow',ModeArrowx,ModeArrowy,'String','ModeFreq','Color','m','LineWidth',2);
        end
        set(ax1,'position',get(ax1,'position')+[0.1 0 0 0])
        set(ax2,'position',get(ax2,'position')+[0.1 0 0 0])
%
        saveas(hColor,sprintf('Task top Prc%d colormap save',100-cPrcvalue));
        saveas(hColor,sprintf('Task top Prc%d colormap save',100-cPrcvalue),'png');
        close(hColor);
    catch
        fprintf('Error occurs at session %d.\n',cSess);
    end
end

%% import ppt files with full ROIs BF
clearvars -except NormSessPathTask
m = 1;
nSession = length(NormSessPathTask);

for cSess = 1 : nSession
    tline = NormSessPathTask{cSess};
    IsErrorExist = 0;
    %
    if m == 1
        %
        %                 PPTname = input('Please input the name for current PPT file:\n','s');
        PPTname = 'Celltype_response_Fullcolorplot_1s';
        if isempty(strfind(PPTname,'.ppt'))
            PPTname = [PPTname,'.pptx'];
        end
        %                 pptSavePath = uigetdir(pwd,'Please select the path used for ppt file savege');
        if ismac
            pptSavePath = '/Volumes/XIN-Yu-potable-disk/batch53_data';
        elseif ispc
            pptSavePath = 'S:\BatchData\batch55';
        end
        %
    end
    %
    Anminfo = SessInfoExtraction(tline);
    cTunPlotPath = fullfile(tline,'Tunning_fun_plot_New1s','Curve fitting plots','NewLog_fit_test_new');
   
    BehavDataPath = fullfile(tline,'RandP_data_plots','Behav_fit plot.png');
    TunROIColorPlotPath = fullfile(cTunPlotPath,'Tuning ROIs summary plots.png');
    CategROIColorPlotPath = fullfile(cTunPlotPath,'Categ ROIs summary plots.png');
    TunROIBFDisPath = fullfile(cTunPlotPath,'Tuning ROI BF distribution plots.png');
    nROIfiles = dir(fullfile(cTunPlotPath,'Log Fit test Save ROI*.png'));
    
    ColoredBFPlotsTaskPath = fullfile(tline,'Tunning_fun_plot_New1s','NMTuned Meanfreq colormap plot','Task top Prc100 colormap save.png');
    ColoredBFPlotsPassPath = fullfile(tline,'Tunning_fun_plot_New1s','NMTuned Meanfreq colormap plot','Passive top Prc100 colormap save.png');

    pptFullfile = fullfile(pptSavePath,PPTname);
    if ~exist(pptFullfile,'file')
        NewFileExport = 1;
    else
        NewFileExport = 0;
    end
    if  m == 1
        if NewFileExport
            exportToPPTX('new','Dimensions',[16,9],'Author','XinYu','Comments','Export of tunning curve plot data');
        else
            exportToPPTX('open',pptFullfile);
        end
    end
    %
    exportToPPTX('addslide');
    exportToPPTX('addnote',tline);
    try
         Datas = load(fullfile(cTunPlotPath,'TypeSavedData.mat'),'TunROITaskDatas','CtgROITaskDatas');
        nTunROIs = size(Datas.TunROITaskDatas,2);
        nCatgROIs = size(Datas.CtgROITaskDatas,2);
        exportToPPTX('addtext',sprintf('nROIs = %d\nTfrac %.3f, CFrac %.3f',length(nROIfiles),nTunROIs/length(nROIfiles),nCatgROIs/length(nROIfiles)...
            ),'Position',[2 0 4 1],'FontSize',20);
    catch
        exportToPPTX('addtext',sprintf('nROIs = %d',length(nROIfiles)),'Position',[2 0 2 1],'FontSize',20);
    end
    try
        exportToPPTX('addpicture',imread(TunROIColorPlotPath),'Position',[0 1 7 2.62]);
%         IsErrorExist = 1;
    catch
        IsErrorExist = 1;
    end
    try
        exportToPPTX('addpicture',imread(CategROIColorPlotPath),'Position',[0 3.7 7 2.62]);
    catch
        IsErrorExist = 1;
    end
    try
        exportToPPTX('addpicture',imread(TunROIBFDisPath),'Position',[0 6.35 3.1 2.6]);
        exportToPPTX('addpicture',imread(ColoredBFPlotsTaskPath),'Position',[7 2 4.5 3.82]);
        exportToPPTX('addpicture',imread(ColoredBFPlotsPassPath),'Position',[11.5 2 4.5 3.82]);
        
    catch
        IsErrorExist = 1;
    end
    exportToPPTX('addpicture',imread(BehavDataPath),'Position',[3.5 6.35 3.47 2.6]);

    exportToPPTX('addtext','Task','Position',[9 1 1 1],'FontSize',20);
    exportToPPTX('addtext','Pass','Position',[14 1 1 1],'FontSize',20);

    exportToPPTX('addtext',sprintf('Batch:%s Anm:%s \nDate:%s Field:%s\n',...
        Anminfo.BatchNum,Anminfo.AnimalNum,Anminfo.SessionDate,Anminfo.TestNum),...
        'Position',[11 7 4 2],'FontSize',20);
    if IsErrorExist
        fprintf('Session %d do not have enough plots.\n',cSess);
    end
    m = m + 1;
    
end
saveName = exportToPPTX('saveandclose',pptFullfile);
