clear
clc
[fn,fp,fi] = uigetfile('*.txt','Please select the compasison session path file');
if ~fi
    return;
end
fPath = fullfile(fp,fn);
%%
fid = fopen(fPath);
tline = fgetl(fid);
SessPathAll = {};
m = 1;
while ischar(tline)
    
    if ~isempty(strfind(tline,'NO_Correction\mode_f_change'))
        SessPathAll{m,1} = tline;
        
        [~,EndInds] = regexp(tline,'test\d{2,3}');
        cPassDataUpperPath = fullfile(sprintf('%srf',tline(1:EndInds)),'im_data_reg_cpu','result_save');
        
        [~,InfoDataEndInds] = regexp(tline,'result_save');
        PassPathline = fullfile(sprintf('%srf%s',tline(1:EndInds),tline(EndInds+1:InfoDataEndInds)),'plot_save','NO_Correction');
        SessPathAll{m,2} = PassPathline;
        
        m = m + 1;
    end
    tline = fgetl(fid);
end

%% performing paired stimulus decoding
nSession = size(SessPathAll,1);
IsSessUsed = zeros(nSession,1);
isPairedStimPred = 0;
parpool('local',10);
for cSess = 1 : nSession
    %%
    
    c832Path = SessPathAll{cSess,1};
    cPassSessPath = SessPathAll{cSess,2};
    fprintf('Processing Session %d...\n',cSess);
    cd(c832Path);
    
    clearvars behavResults data_aligned frame_rate
    load('CSessionData.mat');
    
    Sess832ROIIndexFile = fullfile(c832Path,'Tunning_fun_plot_New1s','SelectROIIndex.mat');
    Sess832BehavStrc = load(fullfile(c832Path,'RandP_data_plots','boundary_result.mat'));
    TaskFreqs = Sess832BehavStrc.boundary_result.StimType;
    TaskFreqCorrs = Sess832BehavStrc.boundary_result.StimCorr;
    TaskFreqTrFrac = Sess832BehavStrc.boundary_result.Typenumbers/sum(Sess832BehavStrc.boundary_result.Typenumbers);
    
    PassUsedIndsfile = fullfile(cPassSessPath,'PassFreqUsedInds.mat');
%     if ~exist(PassUsedIndsfile,'file')
% %         return;
%         continue;
%     end
    PassUsedIndsStrc = load(PassUsedIndsfile);
    IsSessUsed(cSess) = 1;
%     if sum(~PassUsedIndsStrc.PassTrInds)
        
        TaskBehavBound = double(min(behavResults.Stim_toneFreq)) * 2;
        if exist(Sess832ROIIndexFile,'file')
            cSess832DataStrc = load(Sess832ROIIndexFile);
            CommonROINum = min(numel(cSess832DataStrc.ROIIndex));
            CommonROIIndex = cSess832DataStrc.ROIIndex(1:CommonROINum);
        else
            CommonROINum = size(data_aligned,2);
            CommonROIIndex = true(CommonROINum,1);
        end
        %
        UsedROIInds = CommonROIIndex;
        TaskCoefFile = load(fullfile(c832Path,'SigSelectiveROIInds.mat'));
        TAnsRespROIs = false(CommonROINum,1);
        TAnsRespROIs(unique([TaskCoefFile.LAnsMergedInds;TaskCoefFile.RAnsMergedInds])) = true;
        UsedROIInds(TAnsRespROIs) = false; % excluding all answer ROIs
        UsedROIBase = false(numel(UsedROIInds),1);
        % loading all categorical ROI inds
    %     cTunFitDataPath = fullfile(c832Path,'Tunning_fun_plot_New1s','Curve fitting plotsNew','NewLog_fit_test_new','NewCurveFitsave.mat');
    %     cTunFitDataUsed = load(cTunFitDataPath,'IsTunedROI','BehavBoundResult','IsCategROI');
        cTunFitDataPath = fullfile(c832Path,'Tunning_fun_plot_New1s','PickedCategROIs.mat');
        cTunFitDataUsed = load(cTunFitDataPath);
        cCalCategROIInds = load(fullfile(c832Path,'Tunning_fun_plot_New1s','Curve fitting plots',...
            'NewLog_fit_test_new','TypeSavedData.mat'),'CategROIs');
        CombineCategROIs = unique([cTunFitDataUsed.CategROIInds(:);cCalCategROIInds.CategROIs]);
        NonAnsCategROIInds = UsedROIBase;
        NonAnsCategROIInds(CombineCategROIs) = true;
    %     NonAnsCategROIInds = logical(cTunFitDataUsed.IsCategROI);
        NonAnsCategROIInds(TAnsRespROIs) = false;
        if ~sum(NonAnsCategROIInds)
            warning('No sensory defined category selective ROI exists.\n');
            % continue;
        end
        NonAnsCategROIs = find(NonAnsCategROIInds);
        NonAnsCategUsedROIs = NonAnsCategROIs(logical(UsedROIInds(NonAnsCategROIs)));
        NonCategUsedROIs = UsedROIInds;
        NonCategUsedROIs(NonAnsCategUsedROIs) = false;
        AllNonCategROIIndex = find(NonCategUsedROIs);

    %    
        if ~isdir('NoCatgROI_PopuChoicePred_New')
            mkdir('NoCatgROI_PopuChoicePred_New');
        end
        cd('NoCatgROI_PopuChoicePred_New');
        nRepeats = 20;
        nCategROIs = length(NonAnsCategUsedROIs);
        nNonCategROIs = length(AllNonCategROIIndex);

        NoCategPopu_UsedROIs = UsedROIBase;
        NoCategPopu_UsedROIs(AllNonCategROIIndex) = true;
        ccUsedROIInds = NoCategPopu_UsedROIs;
%         isRepeat = 0;
        %%
        TrChoice_Pred_script
        TaskNoCategPredAccu = StimPerfAll;
        clearvars StimPerfAll

        CategPopuAccuDataAlls = cell(nRepeats,1);
        MergedIndsAll = cell(nRepeats,1);
%         isRepeat = 1;
        for cRepeat = 1 : nRepeats
            % popudecoding with category selective ROIs
            usedNonCategROIInds = randsample(nNonCategROIs,nNonCategROIs - nCategROIs);
            MergedInds = [NonAnsCategUsedROIs;AllNonCategROIIndex(usedNonCategROIInds)];
            MergedIndsAll{cRepeat} = MergedInds;

            cCategROIInds = UsedROIBase;
            cCategROIInds(MergedInds) = true;
            ccUsedROIInds = cCategROIInds;
            TrChoice_Pred_script
            CategPopuAccuDataAlls{cRepeat} = StimPerfAll;
            clearvars StimPerfAll
        end
        %
        save CategPredAccuSave.mat CategPopuAccuDataAlls TaskNoCategPredAccu MergedIndsAll -v7.3

        % Passive session
        clearvars SelectData SelectSArray
        cd(cPassSessPath);
        load('rfSelectDataSet.mat');

        if ~isdir('./Categ_PassChoice_Pred_New/')
            mkdir('./Categ_PassChoice_Pred_New/');
        end
        cd('./Categ_PassChoice_Pred_New/');
        
        PassUsedTrInds = PassUsedIndsStrc.PassTrInds;
        %
%         isRepeat = 0;
        ccUsedROIInds = NoCategPopu_UsedROIs;
        PassChoicePred_script;
        PassNoCategPredAccu = PassStimPerfAll;

        PassCategPopuPredAlls = cell(nRepeats,1);
%         isRepeat = 1;
        for cRepeat = 1 : nRepeats
            % popudecoding with category selective ROIs
    %         usedNonCategROIInds = randsample(nNonCategROIs,nNonCategROIs - nCategROIs);
    %         MergedInds = [NonAnsCategUsedROIs;AllNonCategROIIndex(usedNonCategROIInds)];
            MergedInds = MergedIndsAll{cRepeat};
            clearvars PredAccuMtx

            cCategROIInds = UsedROIBase;
            cCategROIInds(MergedInds) = true;
            ccUsedROIInds = cCategROIInds;

            PassChoicePred_script
            PassCategPopuPredAlls{cRepeat} = PassStimPerfAll;
        end
        save CategPassPredAccuSave.mat PassCategPopuPredAlls PassNoCategPredAccu -v7.3
        %
%         PassSelectTrFreqs = SelectSArray(PassUsedTrInds);
%         PassFreqTypes = unique(PassSelectTrFreqs);
%         nPassFreqs = length(PassFreqTypes);
%         PassFreqPredFracMtx = zeros(nPassFreqs,3);
%         for cff = 1 : nPassFreqs
%             cfInds = PassSelectTrFreqs == PassFreqTypes(cff);
%             cfPassCorrMtx = PassNoCategPredAccu(:,cfInds);
%             [~,NearTaskPassCorrInds] = min(abs(PassFreqTypes(cff) - TaskFreqs));
%             NearTaskPassCorr = TaskFreqCorrs(NearTaskPassCorrInds);
% 
%             PassFreqPredFracMtx(cff,:) = [mean(cfPassCorrMtx(:)),NearTaskPassCorr,TaskFreqTrFrac(NearTaskPassCorrInds)];
%         end
%     end
    %
end

%% 
clearvars -except SessPathAll
nSession = size(SessPathAll,1);
SessChoicePredAccu = cell(nSession,4);
SessChoicePredAccuAllFreq = cell(nSession,4);
SessAvgChoiceAccuAll = cell(nSession,1);
SessAvgChoiceDisAccu = cell(nSession,4);
PassTrNum = zeros(nSession,1);
%%
for cSess = 1 : nSession
    %
%     cSess = 3;
    IsTaskExtraFreq = 0;
    c832Path = SessPathAll{cSess,1};
    cPassSessPath = SessPathAll{cSess,2};
    fprintf('Processing Session %d...\n',cSess);
    cd(c832Path);
    
    TaskChoicePredfile = fullfile(c832Path,'NoCatgROI_PopuChoicePred_New','CategPredAccuSave.mat');
    PassChoicePredfile = fullfile(cPassSessPath,'Categ_PassChoice_Pred_New','CategPassPredAccuSave.mat');
    load(fullfile(cPassSessPath,'rfSelectDataSet.mat'),'SelectSArray');
    %
    TaskChoicePredStrc = load(TaskChoicePredfile);
    PassChoicePredStrc = load(PassChoicePredfile);
    
    Sess832BehavStrc = load(fullfile(c832Path,'RandP_data_plots','boundary_result.mat'));
    TaskFreqs = Sess832BehavStrc.boundary_result.StimType(:);
    TaskFreqCorrs = Sess832BehavStrc.boundary_result.StimCorr;
    TaskFreqTrFrac = Sess832BehavStrc.boundary_result.Typenumbers/sum(Sess832BehavStrc.boundary_result.Typenumbers);
    
    PassUsedIndsfile = load(fullfile(cPassSessPath,'PassFreqUsedInds.mat'));
    PassUsedFreqs = SelectSArray(PassUsedIndsfile.PassTrInds);
    PassUsedFreqTypes = unique(PassUsedFreqs);
    PassTrNum(cSess) = numel(PassUsedFreqs)/numel(PassUsedFreqTypes);
    if numel(TaskFreqs) ~= numel(PassUsedFreqTypes)
        IsTaskExtraFreq = 1;
        ExCentInds = true(numel(TaskFreqs),1);
        ExCentInds(ceil(numel(TaskFreqs)/2)) = false;
        TaskFreqs = TaskFreqs(ExCentInds);
        warning('The task frequency dimension is different from passive used freqs');
%         continue;
    end
    %
    if IsTaskExtraFreq
        TNoCategPredAccu = TaskChoicePredStrc.TaskNoCategPredAccu(:,ExCentInds,ExCentInds);
    else
        TNoCategPredAccu = TaskChoicePredStrc.TaskNoCategPredAccu;
    end
    PNoCategPredAccu = PassChoicePredStrc.PassNoCategPredAccu;
    AvgTaskNoCatgErro = squeeze(mean(TNoCategPredAccu));
    AvgTaskNoCatgAccu = (AvgTaskNoCatgErro + AvgTaskNoCatgErro');
    CenterChanceMtx = diag(0.5*ones(numel(TaskFreqs),1));
    AvgTaskNoCatgAccu = 1 - (AvgTaskNoCatgAccu + CenterChanceMtx);
    
    %
    if IsTaskExtraFreq
        TaskWIthCategRErroCell = cellfun(@(x) squeeze(mean(x(:,ExCentInds,ExCentInds))),TaskChoicePredStrc.CategPopuAccuDataAlls,'uniformOutput',false);
    else
        TaskWIthCategRErroCell = cellfun(@(x) squeeze(mean(x)),TaskChoicePredStrc.CategPopuAccuDataAlls,'uniformOutput',false);
    end
    TaskWIthCategRErromtx = cat(3,TaskWIthCategRErroCell{:});
    TaskWIthCategRMtxMean = squeeze(mean(TaskWIthCategRErromtx,3));
    TaskWIthCategRMtxErro = TaskWIthCategRMtxMean + TaskWIthCategRMtxMean';
    TaskWIthCategRMtxAccu = 1 - (TaskWIthCategRMtxErro + CenterChanceMtx);
%     TWithCategPredMtxAll = cat(3,TWithCategPredAccu{:});
%     PWithCategPredMtxAll = cat(3,PWithCategPredAccu{:});
    % processing passive data
    PassNoCategErro = squeeze(mean(PNoCategPredAccu));
    PassNoCategErroMtx = PassNoCategErro + PassNoCategErro';
    PassNoCategAccu = 1 - (PassNoCategErroMtx + CenterChanceMtx);
    
    PassWithCategErrCell = cellfun(@(x) squeeze(mean(x)),PassChoicePredStrc.PassCategPopuPredAlls,'uniformOutput',false);
    PassWithCategErrMtx = cat(3,PassWithCategErrCell{:});
    PassWithCategErrMtxAvg = squeeze(mean(PassWithCategErrMtx,3));
    PassWithCategAccuMtx = 1 - (PassWithCategErrMtxAvg + PassWithCategErrMtxAvg' + CenterChanceMtx);
    
    % Extract choice accuracy according to freq distance
    if size(AvgTaskNoCatgAccu,1) == 6
        UsedInds = 1:6;
    elseif size(AvgTaskNoCatgAccu,1) == 7
        UsedInds = [1 2 3 5 6 7];
    else
        UsedInds = [1 2 3 6 7 8];
    end
    %
    SessChoicePredAccu{cSess,1} = PassNoCategAccu(UsedInds,UsedInds);
    SessChoicePredAccu{cSess,2} = AvgTaskNoCatgAccu(UsedInds,UsedInds);
    SessChoicePredAccu{cSess,3} = PassWithCategAccuMtx(UsedInds,UsedInds);
    SessChoicePredAccu{cSess,4} = TaskWIthCategRMtxAccu(UsedInds,UsedInds);
    SessChoicePredAccuAllFreq(cSess,:) = {PassNoCategAccu,AvgTaskNoCatgAccu,PassWithCategAccuMtx,TaskWIthCategRMtxAccu};
    
    DisAccuTaskNoCatg = Mtx2DisAccuFun(AvgTaskNoCatgAccu,UsedInds);
    DisAccuTaskWithCatg = Mtx2DisAccuFun(TaskWIthCategRMtxAccu,UsedInds);
    DisAccuPassNoCatg = Mtx2DisAccuFun(PassNoCategAccu,UsedInds);
    DisAccuPassWithCatg = Mtx2DisAccuFun(PassWithCategAccuMtx,UsedInds);
    
    %
    SummarizedData = [DisAccuTaskNoCatg.WinAccu,DisAccuTaskNoCatg.BetAccu,...
        DisAccuTaskWithCatg.WinAccu,DisAccuTaskWithCatg.BetAccu,...
        DisAccuPassNoCatg.WinAccu,DisAccuPassNoCatg.BetAccu,...
        DisAccuPassWithCatg.WinAccu,DisAccuPassWithCatg.BetAccu];
    SessAvgChoiceAccuAll{cSess,1} = mean(SummarizedData);
    SessAvgChoiceDisAccu(cSess,:) = {DisAccuTaskNoCatg,DisAccuTaskWithCatg,DisAccuPassNoCatg,DisAccuPassWithCatg};
    
    % plot current session results
    SessDisp = {'PassNoCatg','TaskNoCatg','PassWiCatg','TaskWiCatg'};
    TaskUsedFreqs = TaskFreqs(UsedInds);
    PassUsedFreqs = PassUsedFreqTypes(UsedInds);
    TaskFreqStrs = cellstr(num2str(TaskUsedFreqs/1000,'%.1f'));
    PassFreqStrs = cellstr(num2str(PassUsedFreqs/1000,'%.1f'));
    hf = figure('position',[2000 100 500 390]);
    for cAx = 1 : 4
        subplot(2,2,cAx);
        imagesc(SessChoicePredAccu{cSess,cAx},[0.5 1]);
        set(gca,'xtick',1:6,'ytick',1:6);
        if mod(cAx,2)  % passive session
            set(gca,'xticklabel',PassFreqStrs,'yticklabel',PassFreqStrs);
            ylabel('Freq (kHz)');
        else
            set(gca,'xticklabel',TaskFreqStrs,'yticklabel',TaskFreqStrs);
        end
        if cAx > 2
            xlabel('Freq (kHz)');
        end
        title(SessDisp{cAx});
    end
    %
    cd('NoCatgROI_PopuChoicePred');
    saveas(hf,'PopuCategAccu plots save');
    saveas(hf,'PopuCategAccu plots save','png');
    saveas(hf,'PopuCategAccu plots save','pdf');
    close(hf);
    %
end
%% compare with or without categROI accuracy for task session
% error rate correction
% TypeLabels = {'TaskNCWin','TaskNCBet','TaskWCWin','TaskWCBet','PassNCWin','PassNCBet','PassWCWin','PassWCBet'};
CoefMtx = cell2mat(SessAvgChoiceAccuAll);
hNewf = FourColDataPlots(CoefMtx(:,1:4),{'NCWinT','NCBetT','WCWinT','WCBetT'},{'r','k','m','k'});
% ylabel('Distance (Oct.)')
[~,p_12] = ttest(CoefMtx(:,1),CoefMtx(:,2));
GroupSigIndication([1,2],max(CoefMtx(:,1:2)),p_12,hNewf);
[~,p_34] = ttest(CoefMtx(:,3),CoefMtx(:,4));
GroupSigIndication([3,4],max(CoefMtx(:,3:4)),p_34,hNewf);

%% compare with or without categROI accuracy for Pass session
% without error rate correction
CoefMtx = cell2mat(SessAvgChoiceAccuAll);
UsedCoefMtx = CoefMtx(:,5:8);
hNewf = FourColDataPlots(UsedCoefMtx,{'NCWinP','NCBetP','WCWinP','WCBetP'},{'r','k','m','k'});
% ylabel('Distance (Oct.)')
[~,p_12] = ttest(UsedCoefMtx(:,1),UsedCoefMtx(:,2));
GroupSigIndication([1,2],max(UsedCoefMtx(:,1:2)),p_12,hNewf);
[~,p_34] = ttest(UsedCoefMtx(:,3),UsedCoefMtx(:,4));
GroupSigIndication([3,4],max(UsedCoefMtx(:,3:4)),p_34,hNewf);

%% compare with categROI accuracy Compared between passive and task session
% error rate correction
CoefMtx = cell2mat(SessAvgChoiceAccuAll);
UsedCoefMtx = CoefMtx(:,[3,4,7,8]);
hNewf = FourColDataPlots(UsedCoefMtx,{'WCWinT','WCBetT','WCWinP','WCBetP'},{'r','k','m','k'});
UsedMtxMean = mean(UsedCoefMtx);
UsedMtxstd = std(UsedCoefMtx);
% ylabel('Distance (Oct.)')
[~,p_12] = ttest(UsedCoefMtx(:,1),UsedCoefMtx(:,2));
GroupSigIndication([1,2],max(UsedCoefMtx(:,1:2)),p_12,hNewf);
[~,p_34] = ttest(UsedCoefMtx(:,3),UsedCoefMtx(:,4));
GroupSigIndication([3,4],max(UsedCoefMtx(:,3:4)),p_34,hNewf);
[~,p_13] = ttest(UsedCoefMtx(:,1),UsedCoefMtx(:,3));
GroupSigIndication([1,3],max(UsedCoefMtx(:,[1,3])),p_13,hNewf,1.3);
[~,p_24] = ttest(UsedCoefMtx(:,2),UsedCoefMtx(:,4));
GroupSigIndication([2,4],max(UsedCoefMtx(:,[2,4])),p_24,hNewf,1.4);
set(gca,'ylim',[0.5 1.5],'ytick',[0.5 1])
text(1:4,0.55*ones(4,1),cellstr(num2str(UsedMtxMean(:),'%.4f')));
text(1:4,0.5*ones(4,1),cellstr(num2str(UsedMtxstd(:),'%.4f')));

%% compare without categROI accuracy Compared between passive and task session
% without error rate correction
CoefMtx = cell2mat(SessAvgChoiceAccuAll);
UsedCoefMtx = CoefMtx(:,[1,2,5,6]);
hNewf = FourColDataPlots(UsedCoefMtx,{'NCWinT','NCBetT','NCWinP','NCBetP'},{'r','k','m','k'});
% ylabel('Distance (Oct.)')
[~,p_12] = ttest(UsedCoefMtx(:,1),UsedCoefMtx(:,2));
GroupSigIndication([1,2],max(UsedCoefMtx(:,1:2)),p_12,hNewf);
[~,p_34] = ttest(UsedCoefMtx(:,3),UsedCoefMtx(:,4));
GroupSigIndication([3,4],max(UsedCoefMtx(:,3:4)),p_34,hNewf);

%% plot the averaged population decoding result
PassNoCategAll = cat(3,SessChoicePredAccu{:,1});
TaskNoCategAll = cat(3,SessChoicePredAccu{:,2});
TaskWiCategAll = cat(3,SessChoicePredAccu{:,4});
PassWiCategAll = cat(3,SessChoicePredAccu{:,3});
PassNoCategAllAvg = squeeze(mean(PassNoCategAll,3));
TaskNoCategAllAvg = squeeze(mean(TaskNoCategAll,3));
PassWiCategAllAvg = squeeze(mean(PassWiCategAll,3));
TaskWiCategAllAvg = squeeze(mean(TaskWiCategAll,3));
figure('position',[2000 100 500 390])
subplot(2,2,1)
imagesc(PassNoCategAllAvg,[0.5 1])
title('PassNoCatg');
subplot(2,2,2);
imagesc(TaskNoCategAllAvg,[0.5 1])
title('TaskNoCatg');
subplot(2,2,3);
imagesc(PassWiCategAllAvg,[0.5 1])
title('PassWiCatg');
subplot(2,2,4);
imagesc(TaskWiCategAllAvg,[0.5 1])
title('TaskWiCatg');
%%
% TaskWiCategAccuDisCurve = diag(TaskWiCategAllAvg,-1);
% PassWiCategAccuDisCurve = diag(PassWiCategAllAvg,-1);
% figure;hold on
% plot(TaskWiCategAccuDisCurve,'r')
% plot(PassWiCategAccuDisCurve,'k')
%   PassWiCategAll  TaskWiCategAll
nSessUsed = size(TaskWiCategAll,3);
nPairedTaskDataAll = zeros(nSessUsed,size(TaskWiCategAll,1) - 1);
nPairedPassDataAll = zeros(nSessUsed,size(TaskWiCategAll,1) - 1);
for cSs = 1 : nSessUsed
    cSesTask = squeeze(TaskWiCategAll(:,:,cSs));
    cSessPass = squeeze(PassWiCategAll(:,:,cSs));
    cTaskDiag = diag(cSesTask,-1);
    cPassDiag = diag(cSessPass,-1);
    nPairedTaskDataAll(cSs,:) = cTaskDiag;
    nPairedPassDataAll(cSs,:) = cPassDiag;
end

OuterInds = [1,2,4,5];
TaskPassPAll = zeros(numel(OuterInds),2);
for cInds = 1 : numel(OuterInds)
    cCompInds = OuterInds(cInds);
    [~,pTask] = ttest(nPairedTaskDataAll(:,cCompInds),nPairedTaskDataAll(:,3));
    [~,pPass] = ttest(nPairedPassDataAll(:,cCompInds),nPairedPassDataAll(:,3));
    TaskPassPAll(cInds,:) = [pTask,pPass];
end

TaskAccuData = mean(nPairedTaskDataAll);
TaskAccustd = std(nPairedTaskDataAll);
TaskAccusem = TaskAccustd/sqrt(nSessUsed);
PassAccuData = mean(nPairedPassDataAll);
PassAccustd = std(nPairedPassDataAll);
PassAccusem = PassAccustd/sqrt(nSessUsed);
hf = figure('position',[100 100 380 300]);
hold on
errorbar(1:5,PassAccuData,PassAccusem,'Color',[.7 .7 .7],'linewidth',1.5);
errorbar(1:5,TaskAccuData,TaskAccusem,'Color',[1 0.7 0.2],'linewidth',1.5);
text(OuterInds,ones(numel(OuterInds),1),cellstr(num2str(TaskPassPAll(:,1),'%.4f')),'Color',[1 0.7 0.2]);
text(OuterInds,ones(numel(OuterInds),1)*1.05,cellstr(num2str(TaskPassPAll(:,2),'%.4f')),'Color',[0.4 0.4 0.4]);
text(1:5,ones(5,1)*0.95,cellstr(num2str(TaskAccuData(:),'%.4f')),'Color',[1 0.7 0.2]);
text(1:5,ones(5,1)*0.9,cellstr(num2str(TaskAccustd(:),'%.4f')),'Color',[1 0.7 0.2]);
text(1:5,ones(5,1)*0.7,cellstr(num2str(PassAccuData(:),'%.4f')),'Color',[0.4 0.4 0.4]);
text(1:5,ones(5,1)*0.65,cellstr(num2str(PassAccustd(:),'%.4f')),'Color',[0.4 0.4 0.4]);

set(gca,'ylim',[0.6 1.1],'xlim',[0.7 5.3],'ytick',0.7:0.1:1);
set(gca,'xtick',1:5,'xticklabel',cellstr(num2str((1:5)','Pair%d')));

%% summarize the eight frequencies session data
SessFreqTypes = cellfun(@(x) size(x,1),SessChoicePredAccuAllFreq(:,1));
EightSounds = SessFreqTypes == 8;
CategTypeDataCell = cell(4,1);
titleStrs = {'PassNoCatg','TaskNoCatg','PassWiCatg','TaskWiCatg'};
hEightf = figure('position',[2000 100 500 390]);
for cSess = 1 : 4
    SessChoiceRawData = SessChoicePredAccuAllFreq(EightSounds,cSess);
    SessChoiceEightAccu = cat(3,SessChoiceRawData{:});
    SessChoiceEightAccuAvg = squeeze(mean(SessChoiceEightAccu,3));
    CategTypeDataCell{cSess} = SessChoiceEightAccuAvg;
    
    subplot(2,2,cSess);
    imagesc(SessChoiceEightAccuAvg,[0.5 1]);
    title(titleStrs{cSess});
end


%%
nSession = size(SessPathAll,1);

for cSess = 1 : nSession
    %
    c832Path = SessPathAll{cSess,1};
    cPassSessPath = SessPathAll{cSess,2};
    fprintf('Processing Session %d...\n',cSess);
    cd(c832Path);
    
%     TaskChoicePredfile = fullfile(c832Path,'NoCatgROI_PopuChoicePred','CategPredAccuSave.mat');
%     PassChoicePredfile = fullfile(cPassSessPath,'Categ_PassChoice_Pred','CategPassPredAccuSave.mat');
    PassFreqsStrc = load(fullfile(cPassSessPath,'rfSelectDataSet.mat'),'SelectSArray');
    
    PassFreqTypes = unique(PassFreqsStrc.SelectSArray);
    
%     TaskChoicePredStrc = load(TaskChoicePredfile);
%     PassChoicePredStrc = load(PassChoicePredfile);
    
    Sess832BehavStrc = load(fullfile(c832Path,'RandP_data_plots','boundary_result.mat'));
    TaskFreqs = Sess832BehavStrc.boundary_result.StimType;
    TaskFreqCorrs = Sess832BehavStrc.boundary_result.StimCorr;
    TaskFreqTrFrac = Sess832BehavStrc.boundary_result.Typenumbers/sum(Sess832BehavStrc.boundary_result.Typenumbers);
    
    disp(TaskFreqs);
%     disp('\n');
    disp(PassFreqTypes');
%     disp('\n');
    PassUsedIndsTr = input('Please select pass used inds:\n','s');
    PassPassUsedInds = str2num(PassUsedIndsTr);
    if numel(PassPassUsedInds) == 1 && PassPassUsedInds > 0
        PassIndsAll = find(true(numel(PassFreqTypes),1));
        PassTrInds = true(numel(PassFreqsStrc.SelectSArray),1);
    elseif numel(PassPassUsedInds) > 1
        PassIndsAll = PassPassUsedInds;
        nUsedInds = numel(PassIndsAll);
        PassTrInds = false(numel(PassFreqsStrc.SelectSArray),1);
        for cInds = 1 : nUsedInds
            cIndsTrInds = PassFreqsStrc.SelectSArray == PassFreqTypes(PassIndsAll(cInds));
            PassTrInds(cIndsTrInds) = true;
        end
    elseif isempty(PassPassUsedInds)
        PassIndsAll = [];
        PassTrInds = [];
    else
        warning('Unkown input types.\n');
        PassIndsAll = [];
        PassTrInds = [];
    end
    
    cd(cPassSessPath);
    if ~isempty(PassTrInds)
        save PassFreqUsedInds.mat PassIndsAll PassTrInds -v7.3
    end
    %
end

%% single cell AUC calculation 
nSession = size(SessPathAll,1);
IsSessUsed = zeros(nSession,1);
for cSess = 1 : nSession
    %
    c832Path = SessPathAll{cSess,1};
    cPassSessPath = SessPathAll{cSess,2};
    fprintf('Processing Session %d...\n',cSess);
    cd(c832Path);
    if exist(fullfile(c832Path,'UsedROI_AUC','Stim_time_Align','ROC_Left2Right_result','ROC_score.mat'),'file') || ...
            exist(fullfile(c832Path,'UsedROI_AUC','Stim_time_Align','ROC_Left2Right_result','ROC_scoreNew.mat'),'file')
        continue;
    end
        
        
    clearvars behavResults smooth_data
    load('CSessionData.mat');
    
    Sess832ROIIndexFile = fullfile(c832Path,'Tunning_fun_plot_New1s','SelectROIIndex.mat');
    Sess832BehavStrc = load(fullfile(c832Path,'RandP_data_plots','boundary_result.mat'));
    TaskFreqs = Sess832BehavStrc.boundary_result.StimType;
    TaskFreqCorrs = Sess832BehavStrc.boundary_result.StimCorr;
    TaskFreqTrFrac = Sess832BehavStrc.boundary_result.Typenumbers/sum(Sess832BehavStrc.boundary_result.Typenumbers);
    
    PassUsedIndsfile = fullfile(cPassSessPath,'PassFreqUsedInds.mat');
    TrialTypes = behavResults.Trial_Type(:);
    PassUsedIndsStrc = load(PassUsedIndsfile);
    IsSessUsed(cSess) = 1;
        
        TaskBehavBound = double(min(behavResults.Stim_toneFreq)) * 2;
        if exist(Sess832ROIIndexFile,'file')
            cSess832DataStrc = load(Sess832ROIIndexFile);
            CommonROINum = min(numel(cSess832DataStrc.ROIIndex));
            CommonROIIndex = cSess832DataStrc.ROIIndex(1:CommonROINum);
        else
            CommonROINum = size(data_aligned,2);
            CommonROIIndex = true(CommonROINum,1);
        end
        %
        UsedROIInds = logical(CommonROIIndex);
        if ~isdir('./UsedROI_AUC/')
            mkdir('./UsedROI_AUC/');
        end
        cd('./UsedROI_AUC/');
        ROC_check(smooth_data(:,UsedROIInds,:),TrialTypes,start_frame,frame_rate,1,'Stim_time_Align');
        
        % Passive session
        clearvars SelectData SelectSArray
        cd(cPassSessPath);
        load('rfSelectDataSet.mat');
        
        PassUsedTrInds = logical(PassUsedIndsStrc.PassTrInds);
        %
        if ~isdir('./UsedROI_AUC/')
            mkdir('./UsedROI_AUC/');
        end
        cd('./UsedROI_AUC/');
        ROC_check(SelectData(PassUsedTrInds,UsedROIInds,:),SelectSArray(PassUsedTrInds)>TaskBehavBound,...
            frame_rate,frame_rate,1,'Stim_time_Align_select');
        save UsedTaskROIInds.mat UsedROIInds -v7.3
        
end
%% summarize single neuron AUC data 
nSession = size(SessPathAll,1);
SessAUCDataAll = cell(nSession,4);
for cSess = 1 : nSession
    %
    c832Path = SessPathAll{cSess,1};
    cPassSessPath = SessPathAll{cSess,2};
    fprintf('Processing Session %d...\n',cSess);
    cd(c832Path);
    try
        cTaskSessDataStrc = load(fullfile(c832Path,'UsedROI_AUC','Stim_time_Align','ROC_Left2Right_result','ROC_scoreNew.mat'));
        cPassSessDataStrc = load(fullfile(cPassSessPath,'UsedROI_AUC','Stim_time_Align','ROC_Left2Right_result','ROC_scoreNew.mat')); 
    catch
        cTaskSessDataStrc = load(fullfile(c832Path,'UsedROI_AUC','Stim_time_Align','ROC_Left2Right_result','ROC_score.mat'));
        cPassSessDataStrc = load(fullfile(cPassSessPath,'UsedROI_AUC','Stim_time_Align_select','ROC_Left2Right_result','ROC_score.mat')); 
    end
    
    TaskAUCABS = cTaskSessDataStrc.ROCarea;
    TaskAUCABS(logical(cTaskSessDataStrc.ROCRevert)) = 1 - TaskAUCABS(logical(cTaskSessDataStrc.ROCRevert));
    
    PassAUCABS = cPassSessDataStrc.ROCarea;
    PassAUCABS(logical(cPassSessDataStrc.ROCRevert)) = 1 - PassAUCABS(logical(cPassSessDataStrc.ROCRevert));
    if numel(TaskAUCABS) ~= numel(PassAUCABS)
        warning('Current tasl and passive session have different number of ROIs');
    end
    
    SessAUCDataAll(cSess,:) = {TaskAUCABS(:),PassAUCABS(:),cTaskSessDataStrc.ROCShufflearea(:),cPassSessDataStrc.ROCShufflearea(:)};
    %
    
end


%%
% % copy used data out for running code at another computer
CopiedFPath = 'F:\TempData';
nSession = size(SessPathAll,1);
IsSessUsed = zeros(nSession,1);
for cSess = 5 : nSession
    c832Path = SessPathAll{cSess,1};
    cPassSessPath = SessPathAll{cSess,2};
    fprintf('Processing Session %d...\n',cSess);
    cd(c832Path);
    
%     TaskTargetPath = fullfile(CopiedFPath,sprintf('Session_%d',cSess),'Task');
%     PassTargetPath = fullfile(CopiedFPath,sprintf('Session_%d',cSess),'Pass');
    TaskTargetPath = fullfile(CopiedFPath,sprintf('Session_%d',cSess),'Task','NoCatgROI_PopuChoicePred','CategPredAccuSave.mat');
    PassTargetPath = fullfile(CopiedFPath,sprintf('Session_%d',cSess),'Pass','Categ_PassChoice_Pred','CategPassPredAccuSave.mat');
    
%     if ~isdir(TaskTargetPath)
%         mkdir(TaskTargetPath);
%     end
%     if ~isdir(PassTargetPath)
%         mkdir(PassTargetPath);
%     end
    
    % copy task data
%     copyfile(fullfile(c832Path,'Tunning_fun_plot_New1s','Curve fitting plots','NewLog_fit_test_new','TypeSavedData.mat'),TaskTargetPath,'f');
    copyfile(TaskTargetPath,fullfile(c832Path,'NoCatgROI_PopuChoicePred'),'f');
%     copyfile(fullfile(c832Path,'Tunning_fun_plot_New1s','SelectROIIndex.mat'),TaskTargetPath,'f');
%     copyfile(fullfile(c832Path,'RandP_data_plots','boundary_result.mat'),TaskTargetPath,'f');
%     copyfile('SigSelectiveROIInds.mat',TaskTargetPath,'f');
%     copyfile(fullfile(c832Path,'Tunning_fun_plot_New1s','PickedCategROIs.mat'),TaskTargetPath,'f');
%     
%     % copy passive data
    copyfile(PassTargetPath,fullfile(cPassSessPath,'Categ_PassChoice_Pred'),'f');
%     copyfile(fullfile(cPassSessPath,'rfSelectDataSet.mat'),PassTargetPath,'f');
end

%%
%% performing choice decoding decoding
nSession = size(SessPathAll,1);
IsSessUsed = zeros(nSession,1);
% parpool('local',10);
isPairedStimPred = 0;
for cSess = 1 : nSession
    %
    c832Path = SessPathAll{cSess,1};
    cPassSessPath = SessPathAll{cSess,2};
    fprintf('Processing Session %d...\n',cSess);
    cd(c832Path);
    
    clearvars behavResults data_aligned frame_rate
    load('CSessionData.mat');
    
    Sess832ROIIndexFile = fullfile(c832Path,'Tunning_fun_plot_New1s','SelectROIIndex.mat');
    Sess832BehavStrc = load(fullfile(c832Path,'RandP_data_plots','boundary_result.mat'));
    TaskFreqs = Sess832BehavStrc.boundary_result.StimType;
    TaskFreqCorrs = Sess832BehavStrc.boundary_result.StimCorr;
    TaskFreqTrFrac = Sess832BehavStrc.boundary_result.Typenumbers/sum(Sess832BehavStrc.boundary_result.Typenumbers);
    
    PassUsedIndsfile = fullfile(cPassSessPath,'PassFreqUsedInds.mat');
%     if ~exist(PassUsedIndsfile,'file')
% %         return;
%         continue;
%     end
    PassUsedIndsStrc = load(PassUsedIndsfile);
    IsSessUsed(cSess) = 1;
%     if sum(~PassUsedIndsStrc.PassTrInds)
        
        TaskBehavBound = double(min(behavResults.Stim_toneFreq)) * 2;
        if exist(Sess832ROIIndexFile,'file')
            cSess832DataStrc = load(Sess832ROIIndexFile);
            CommonROINum = min(numel(cSess832DataStrc.ROIIndex));
            CommonROIIndex = cSess832DataStrc.ROIIndex(1:CommonROINum);
        else
            CommonROINum = size(data_aligned,2);
            CommonROIIndex = true(CommonROINum,1);
        end
        %
        UsedROIInds = CommonROIIndex;
        TaskCoefFile = load(fullfile(c832Path,'SigSelectiveROIInds.mat'));
        TAnsRespROIs = false(CommonROINum,1);
        TAnsRespROIs(unique([TaskCoefFile.LAnsMergedInds;TaskCoefFile.RAnsMergedInds])) = true;
        UsedROIInds(TAnsRespROIs) = false; % excluding all answer ROIs
        UsedROIBase = false(numel(UsedROIInds),1);
        % loading all categorical ROI inds
    %     cTunFitDataPath = fullfile(c832Path,'Tunning_fun_plot_New1s','Curve fitting plotsNew','NewLog_fit_test_new','NewCurveFitsave.mat');
    %     cTunFitDataUsed = load(cTunFitDataPath,'IsTunedROI','BehavBoundResult','IsCategROI');
        cTunFitDataPath = fullfile(c832Path,'Tunning_fun_plot_New1s','PickedCategROIs.mat');
        cTunFitDataUsed = load(cTunFitDataPath);
        cCalCategROIInds = load(fullfile(c832Path,'Tunning_fun_plot_New1s','Curve fitting plots',...
            'NewLog_fit_test_new','TypeSavedData.mat'),'CategROIs');
        CombineCategROIs = unique([cTunFitDataUsed.CategROIInds(:);cCalCategROIInds.CategROIs]);
        NonAnsCategROIInds = UsedROIBase;
        NonAnsCategROIInds(CombineCategROIs) = true;
    %     NonAnsCategROIInds = logical(cTunFitDataUsed.IsCategROI);
        NonAnsCategROIInds(TAnsRespROIs) = false;
        if ~sum(NonAnsCategROIInds)
            warning('No sensory defined category selective ROI exists.\n');
            % continue;
        end
        NonAnsCategROIs = find(NonAnsCategROIInds);
        NonAnsCategUsedROIs = NonAnsCategROIs(logical(UsedROIInds(NonAnsCategROIs)));
        NonCategUsedROIs = UsedROIInds;
        NonCategUsedROIs(NonAnsCategUsedROIs) = false;
        AllNonCategROIIndex = find(NonCategUsedROIs);

    %    
        if ~isdir('NoCatgROI_RealChoicePredSave')
            mkdir('NoCatgROI_RealChoicePredSave');
        end
        cd('NoCatgROI_RealChoicePredSave');
        nRepeats = 20;
        nCategROIs = length(NonAnsCategUsedROIs);
        nNonCategROIs = length(AllNonCategROIIndex);

        NoCategPopu_UsedROIs = UsedROIBase;
        NoCategPopu_UsedROIs(AllNonCategROIIndex) = true;
        ccUsedROIInds = NoCategPopu_UsedROIs;
        isRepeat = 0;
        
        TrChoice_Pred_script
        TaskNoCategChoicePredAccu = RepeatPredAccu;
        clearvars RepeatPredAccu

        CategChoiceAccuDataAlls = cell(nRepeats,1);
        MergedIndsAll = cell(nRepeats,1);
        isRepeat = 1;
        for cRepeat = 1 : nRepeats
            % popudecoding with category selective ROIs
            usedNonCategROIInds = randsample(nNonCategROIs,nNonCategROIs - nCategROIs);
            MergedInds = [NonAnsCategUsedROIs;AllNonCategROIIndex(usedNonCategROIInds)];
            MergedIndsAll{cRepeat} = MergedInds;

            cCategROIInds = UsedROIBase;
            cCategROIInds(MergedInds) = true;
            ccUsedROIInds = cCategROIInds;
            TrChoice_Pred_script
            CategChoiceAccuDataAlls{cRepeat} = RepeatPredAccu;
            clearvars StimPerfAll
        end
        %
        save CategPredAccuSave.mat CategChoiceAccuDataAlls TaskNoCategChoicePredAccu MergedIndsAll -v7.3

        % Passive session
        clearvars SelectData SelectSArray
        cd(cPassSessPath);
        load('rfSelectDataSet.mat');

        if ~isdir('./NoCatgROI_RealChoicePredSave/')
            mkdir('./NoCatgROI_RealChoicePredSave/');
        end
        cd('./NoCatgROI_RealChoicePredSave/');
        
        PassUsedTrInds = PassUsedIndsStrc.PassTrInds;
        %
        isRepeat = 0;
        ccUsedROIInds = NoCategPopu_UsedROIs;
        PassChoicePred_script;
        PassNoCatgChoicePredAccu = PassRepeatPredAccu;

        PassCategChoicePredAlls = cell(nRepeats,1);
        isRepeat = 1;
        for cRepeat = 1 : nRepeats
            % popudecoding with category selective ROIs
    %         usedNonCategROIInds = randsample(nNonCategROIs,nNonCategROIs - nCategROIs);
    %         MergedInds = [NonAnsCategUsedROIs;AllNonCategROIIndex(usedNonCategROIInds)];
            MergedInds = MergedIndsAll{cRepeat};
            clearvars PassRepeatPredAccu

            cCategROIInds = UsedROIBase;
            cCategROIInds(MergedInds) = true;
            ccUsedROIInds = cCategROIInds;

            PassChoicePred_script
            PassCategChoicePredAlls{cRepeat} = PassRepeatPredAccu;
        end
        save CategPassPredAccuSave.mat PassCategChoicePredAlls PassNoCatgChoicePredAccu -v7.3
        %
%         PassSelectTrFreqs = SelectSArray(PassUsedTrInds);
%         PassFreqTypes = unique(PassSelectTrFreqs);
%         nPassFreqs = length(PassFreqTypes);
%         PassFreqPredFracMtx = zeros(nPassFreqs,3);
%         for cff = 1 : nPassFreqs
%             cfInds = PassSelectTrFreqs == PassFreqTypes(cff);
%             cfPassCorrMtx = PassNoCategPredAccu(:,cfInds);
%             [~,NearTaskPassCorrInds] = min(abs(PassFreqTypes(cff) - TaskFreqs));
%             NearTaskPassCorr = TaskFreqCorrs(NearTaskPassCorrInds);
% 
%             PassFreqPredFracMtx(cff,:) = [mean(cfPassCorrMtx(:)),NearTaskPassCorr,TaskFreqTrFrac(NearTaskPassCorrInds)];
%         end
%     end
    %
end
%%
nSession = size(SessPathAll,1);
SessAccuDataAlls = cell(nSession,4);
IsSessUsed = ones(nSession,1);
PassTrNum = zeros(nSession,1);
% parpool('local',10);
for cSess = 1 : nSession
    %
%     cSess = 1;
    c832Path = SessPathAll{cSess,1};
    cPassSessPath = SessPathAll{cSess,2};
    fprintf('Processing Session %d...\n',cSess);
    cd(c832Path);
    
    TaskChoicePredfile = fullfile(c832Path,'NoCatgROI_RealChoicePredSave','CategPredAccuSave.mat');
    PassChoicePredfile = fullfile(cPassSessPath,'NoCatgROI_RealChoicePredSave','CategPassPredAccuSave.mat');
    load(fullfile(cPassSessPath,'rfSelectDataSet.mat'),'SelectSArray');
    %
    TaskChoicePredStrc = load(TaskChoicePredfile);
    PassChoicePredStrc = load(PassChoicePredfile);
    
    Sess832BehavStrc = load(fullfile(c832Path,'RandP_data_plots','boundary_result.mat'));
    TaskFreqs = Sess832BehavStrc.boundary_result.StimType(:);
    TaskFreqCorrs = Sess832BehavStrc.boundary_result.StimCorr;
    TaskFreqTrFrac = Sess832BehavStrc.boundary_result.Typenumbers/sum(Sess832BehavStrc.boundary_result.Typenumbers);
    
    PassUsedIndsfile = load(fullfile(cPassSessPath,'PassFreqUsedInds.mat'));
    PassUsedFreqs = SelectSArray(PassUsedIndsfile.PassTrInds);
    PassUsedFreqTypes = unique(PassUsedFreqs);
    PassTrNum(cSess) = numel(PassUsedFreqs)/numel(PassUsedFreqTypes);
    if numel(TaskFreqs) ~= numel(PassUsedFreqTypes)
        IsTaskExtraFreq = 1;
        ExCentInds = true(numel(TaskFreqs),1);
        ExCentInds(ceil(numel(TaskFreqs)/2)) = false;
        TaskFreqs = TaskFreqs(ExCentInds);
        warning('The task frequency dimension is different from passive used freqs');
        IsSessUsed(cSess) = 0;
        continue;
    end
    
    %
    TaskAccuCellAll = cellfun(@(x) x(:,2),TaskChoicePredStrc.CategChoiceAccuDataAlls,'uniformOutput',false);
    TaskAccuAllValues = cell2mat(TaskAccuCellAll);
    TaskNoCatgAccuAll = TaskChoicePredStrc.TaskNoCategChoicePredAccu(:,2);
    PassNoCatgAccuAll = PassChoicePredStrc.PassNoCatgChoicePredAccu(:,2);
    PassAccuCellAll = cellfun(@(x) x(:,2),PassChoicePredStrc.PassCategChoicePredAlls,'uniformOutput',false);
    PassAccuAllValues = cell2mat(PassAccuCellAll);
    
    SessAccuDataAlls(cSess,:) = {TaskAccuAllValues,TaskNoCatgAccuAll,PassAccuAllValues,PassNoCatgAccuAll};
    %
end

%%
SessTaskAccuDatas = cellfun(@mean,SessAccuDataAlls(:,1));
SessTaskNoCatgAccuData = cellfun(@mean,SessAccuDataAlls(:,2));
SessPassAccuDatas = cellfun(@mean,SessAccuDataAlls(:,3));
SessPassNoCatgAccuData = cellfun(@mean,SessAccuDataAlls(:,4));

IsNanInds = isnan(SessTaskAccuDatas);
SessTaskUsedAccu = SessTaskAccuDatas(~IsNanInds);
SessTaskNoCatgUsedAccu = SessTaskNoCatgAccuData(~IsNanInds);
SessPassUsedAccu = SessPassAccuDatas(~IsNanInds);
SessPassNoCatgAccu = SessPassNoCatgAccuData(~IsNanInds);



