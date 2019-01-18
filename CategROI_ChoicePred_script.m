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

%%
nSession = size(SessPathAll,1);
IsSessUsed = zeros(nSession,1);
parpool('local',10);
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
        %
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
SessAvgChoiceAccuAll = cell(nSession,1);
SessAvgChoiceDisAccu = cell(nSession,4);
%%
for cSess = 1 : nSession
    %
    c832Path = SessPathAll{cSess,1};
    cPassSessPath = SessPathAll{cSess,2};
    fprintf('Processing Session %d...\n',cSess);
    cd(c832Path);
    
    TaskChoicePredfile = fullfile(c832Path,'NoCatgROI_PopuChoicePred','CategPredAccuSave.mat');
    PassChoicePredfile = fullfile(cPassSessPath,'Categ_PassChoice_Pred','CategPassPredAccuSave.mat');
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
    if numel(TaskFreqs) ~= numel(PassUsedFreqTypes)
        warning('The task frequency dimension is different from passive used freqs');
        continue;
    end
    TNoCategPredAccu = TaskChoicePredStrc.TaskNoCategPredAccu;
    PNoCategPredAccu = PassChoicePredStrc.PassNoCategPredAccu;
    
    AvgTaskNoCatgErro = squeeze(mean(TNoCategPredAccu));
    AvgTaskNoCatgAccu = (AvgTaskNoCatgErro + AvgTaskNoCatgErro');
    CenterChanceMtx = diag(0.5*ones(numel(TaskFreqs),1));
    AvgTaskNoCatgAccu = 1 - (AvgTaskNoCatgAccu + CenterChanceMtx);
    
    %
    TaskWIthCategRErroCell = cellfun(@(x) squeeze(mean(x)),TaskChoicePredStrc.CategPopuAccuDataAlls,'uniformOutput',false);
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
% ylabel('Distance (Oct.)')
[~,p_12] = ttest(UsedCoefMtx(:,1),UsedCoefMtx(:,2));
GroupSigIndication([1,2],max(UsedCoefMtx(:,1:2)),p_12,hNewf);
[~,p_34] = ttest(UsedCoefMtx(:,3),UsedCoefMtx(:,4));
GroupSigIndication([3,4],max(UsedCoefMtx(:,3:4)),p_34,hNewf);

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

