clearvars -except NormSessPathTask
nSessPath = length(NormSessPathTask); % NormSessPathTask  NormSessPathPass
TunDataCellAll = cell(nSessPath,5);
CategDataCellAll = cell(nSessPath,6);
for cSess = 1 : nSessPath

%     cSessPath = 'S:\BatchData\batch53\20180818\anm05\test01\im_data_reg_cpu\result_save\plot_save\Type5_f0_calculation\NO_Correction\mode_f_change';
    cSessPath = NormSessPathTask{cSess};
    cTuningDataPath = fullfile(cSessPath,'Tunning_fun_plot_New1s','TunningDataSave.mat');
    cTunFitDataPath = fullfile(cSessPath,'Tunning_fun_plot_New1s','Curve fitting plots','NewLog_fit_test_new','NewCurveFitsave.mat');
    cd(fullfile(cSessPath,'Tunning_fun_plot_New1s','Curve fitting plots','NewLog_fit_test_new'));
    cTunDataUsed = load(cTuningDataPath);
    cTunFitDataUsed = load(cTunFitDataPath,'IsTunedROI','BehavBoundResult','IsCategROI');
    %
    SessBehavBound = cTunFitDataUsed.BehavBoundResult;
    TaskROIBFAll = cTunDataUsed.TaskFreqOctave;
    PassROIBFAll = cTunDataUsed.PassFreqOctave;
    cSessTaskFreqs = (2.^cTunDataUsed.TaskFreqOctave)*cTunDataUsed.BoundFreq;
    cSessPassFreqs = (2.^cTunDataUsed.PassFreqOctave)*cTunDataUsed.BoundFreq;
    
    if length(cSessTaskFreqs) ~= length(cSessPassFreqs)
        continue;
    end
    TunROIInds = find(cTunFitDataUsed.IsTunedROI);
    TunROINum = length(TunROIInds);
    TunROITaskDatas = cTunDataUsed.CorrTunningFun(:,TunROIInds);
    TunROIPassDatas = cTunDataUsed.PassTunningfun(:,TunROIInds);

    [~,TunDataTaskPeakInds] = max(TunROITaskDatas);
    [~,TunDataPassPeakInds] = max(TunROIPassDatas);

    TaskTunROIOctaves = zeros(TunROINum,1);
    PassTunROIOctaves = zeros(TunROINum,1);
    for cR = 1 : TunROINum
        TaskTunROIOctaves(cR) = cTunDataUsed.TaskFreqOctave(TunDataTaskPeakInds(cR));
        PassTunROIOctaves(cR) = cTunDataUsed.PassFreqOctave(TunDataPassPeakInds(cR));
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
    ylabel('Freq (kHz)');
    xlabel('# ROIs');
    title('Task Tuning');
    set(gca,'FontSize',14);

    subplot(122)
    imagesc(PassZSTunData,[-1.5 1.5]);
    set(gca,'ytick',1:numel(PassFreqs),'yticklabel',PassFreqStrs);
    ylabel('Freq (kHz)');
    xlabel('# ROIs');
    title('Passove Tuning');
    set(gca,'FontSize',14);

    saveas(huf,'Tuning ROIs summary plots');
    saveas(huf,'Tuning ROIs summary plots','png');
    close(huf);

    % plots for categorical ROIs
    CategROIs = find(cTunFitDataUsed.IsCategROI);
    CategROINum = length(CategROIs);
    CtgROITaskDatas = cTunDataUsed.CorrTunningFun(:,CategROIs);
    CtgROIPassDatas = cTunDataUsed.PassTunningfun(:,CategROIs);

    Nor_CtgROITaskDatas = (CtgROITaskDatas - repmat(min(CtgROITaskDatas),numel(PassFreqs),1))./...
        (repmat(max(CtgROITaskDatas),numel(PassFreqs),1) - repmat(min(CtgROITaskDatas),numel(PassFreqs),1));
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
    xlabel('Freq (kHz)');
    ylabel('# ROIs');
    title('Task Tuning');
    set(gca,'FontSize',14);

    subplot(122)
    imagesc(PreferPassData',[0 1]);
    set(gca,'xtick',1:numel(PassFreqs),'xticklabel',PassFreqStrs);
    xlabel('Freq (kHz)');
    ylabel('# ROIs');
    title('Passove Tuning');
    set(gca,'FontSize',14);
%
    saveas(huCtgf,'Categ ROIs summary plots');
    saveas(huCtgf,'Categ ROIs summary plots','png');
    close(huCtgf);
    
    TunDataCellAll{cSess,1} = cTunFitDataUsed.IsTunedROI;
    TunDataCellAll{cSess,2} = TaskROIBFAll;
    TunDataCellAll{cSess,3} = TaskTunROIOctaves;
    TunDataCellAll{cSess,4} = PassROIBFAll;
    TunDataCellAll{cSess,5} = PassTunROIOctaves;
    TunDataCellAll{cSess,6} = TunROITaskDatas;
    TunDataCellAll{cSess,7} = TunROIPassDatas;
    TunDataCellAll{cSess,8} = SessBehavBound;
    
    CategDataCellAll{cSess,1} = cTunFitDataUsed.IsCategROI;
    CategDataCellAll{cSess,2} = CtgROITaskDatas;
    CategDataCellAll{cSess,3} = CtgROIPassDatas;
    CategDataCellAll{cSess,4} = PreferSideData;
    CategDataCellAll{cSess,5} = PreferPassData;
    CategDataCellAll{cSess,6} = TaskFreqs;
    
    save TypeSavedData.mat  TaskOctTypes PassOctTypes TaskTunROIOctaves PassTunROIOctaves ...
        TunROITaskDatas TunROIPassDatas CtgROITaskDatas CtgROIPassDatas PreferSideData ...
        PreferPassData TaskFreqs PassFreqs TunROIInds CategROIs TaskROIBFAll PassROIBFAll SessBehavBound -v7.3
    
end

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
        PPTname = 'Celltype_response_colorplot';
        if isempty(strfind(PPTname,'.ppt'))
            PPTname = [PPTname,'.pptx'];
        end
        %                 pptSavePath = uigetdir(pwd,'Please select the path used for ppt file savege');
        if ismac
            pptSavePath = '/Volumes/XIN-Yu-potable-disk/batch53_data';
        elseif ispc
            pptSavePath = 'S:\BatchData\batch53';
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
        exportToPPTX('addpicture',imread(TunROIColorPlotPath),'Position',[0 1 10 3.75]);
%         IsErrorExist = 1;
    catch
        IsErrorExist = 1;
    end
    try
        exportToPPTX('addpicture',imread(CategROIColorPlotPath),'Position',[0 5 10 3.75]);
    catch
        IsErrorExist = 1;
    end
    try
        exportToPPTX('addpicture',imread(TunROIBFDisPath),'Position',[10.5 0 4 3.37]);
    catch
        IsErrorExist = 1;
    end
    exportToPPTX('addpicture',imread(BehavDataPath),'Position',[10.5 3.5 4 3]);

    exportToPPTX('addtext',sprintf('Batch:%s Anm:%s \nDate:%s Field:%s\n',...
        Anminfo.BatchNum,Anminfo.AnimalNum,Anminfo.SessionDate,Anminfo.TestNum),...
        'Position',[11 7 4 2],'FontSize',20);
    if IsErrorExist
        fprintf('Session %d do not have enough plots.\n',cSess);
    end
    m = m + 1;
    
end
saveName = exportToPPTX('saveandclose',pptFullfile);
