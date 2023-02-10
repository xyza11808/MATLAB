clearvars cAUnitInds BaselineResp_First BaselineResp_Last
% if isempty(ProbNPSess.ChannelAreaStrs)
%     ProbNPSess.ChannelAreaStrs = {ChnArea_indexes,ChnArea_Strings(:,3)};
% end
load(fullfile(ksfolder,'SessAreaIndexDataNewAlign.mat'));

load(fullfile(ksfolder,'NewClassHandle2.mat'));
ProbNPSess = NewNPClusHandle;
clearvars NewNPClusHandle
%%
ProbNPSess.CurrentSessInds = strcmpi('Task',ProbNPSess.SessTypeStrs);
% TimeWin = [-1.5,8]; % time window used to calculate the psth, usually includes before and after trigger time, in seconds
% Smoothbin = [50,10]; %
% ProbNPSess = ProbNPSess.TrigPSTH(TimeWin, Smoothbin, double(behavResults.Time_stimOnset(:)));
% save(fullfile(pwd,'ks2_5','NPClassHandleSaved.mat'),'ProbNPSess', 'PassSoundDatas', 'behavResults', '-v7.3');
fullData = cellfun(@full,ProbNPSess.TrigData_Bin{ProbNPSess.CurrentSessInds},'un',0);
SMBinDataMtx = permute(cat(3,fullData{:,1}),[1,3,2]); % transfromed into trial-by-units-by-bin matrix


if ~isempty(ProbNPSess.SurviveInds)
    SMBinDataMtx = SMBinDataMtx(:,ProbNPSess.SurviveInds,:);
end
SMBinDataMtxRaw = SMBinDataMtx;
% SMBinDataMtxRaw = SMBinDataMtx(:,:,:);

Allfieldnames = fieldnames(SessAreaIndexStrc);
ExistAreas_Indexes = find(SessAreaIndexStrc.UsedAbbreviations);
ExistAreas_Names = Allfieldnames(SessAreaIndexStrc.UsedAbbreviations);
ExistAreas_Names(strcmpi(ExistAreas_Names,'Others')) = [];
NumExistAreas = length(ExistAreas_Names);
BlockTypesAll = double(behavResults.BlockType(:));
if NumExistAreas< 1
    return;
end
%%
% % load('Chnlocation.mat');
% % try
%     load(fullfile(ksfolder,'SessAreaIndexDataNewAlign2.mat'));
% % catch
% %     load(fullfile(ksfolder,'SessAreaIndexData.mat'));
% % end
% % if isempty(fieldnames(SessAreaIndexStrc.ACAv)) && isempty(fieldnames(SessAreaIndexStrc.ACAd))...
% %          && isempty(fieldnames(SessAreaIndexStrc.ACA))
% %     return;
% % end
% % load(fullfile(ksfolder,'NPClassHandleSaved.mat'))
% load(fullfile(ksfolder,'NewClassHandle2.mat'))
% ProbNPSess = NewNPClusHandle;
% clearvars NewNPClusHandle
% % if isempty(ProbNPSess.ChannelAreaStrs)
% %     ProbNPSess.ChannelAreaStrs = {ChnArea_indexes,ChnArea_Strings(:,3)};
% % end
%
% ProbNPSess.CurrentSessInds = strcmpi('Task',ProbNPSess.SessTypeStrs);
% % TimeWin = [-1.5,8]; % time window used to calculate the psth, usually includes before and after trigger time, in seconds
% % Smoothbin = [50,10]; %
% % ProbNPSess = ProbNPSess.TrigPSTH(TimeWin, Smoothbin, double(behavResults.Time_stimOnset(:)));
% % save(fullfile(pwd,'ks2_5','NPClassHandleSaved.mat'),'ProbNPSess', 'PassSoundDatas', 'behavResults', '-v7.3');
% fullData = cellfun(@full,ProbNPSess.TrigData_Bin{ProbNPSess.CurrentSessInds},'un',0);
% SMBinDataMtx = permute(cat(3,fullData{:,1}),[1,3,2]); % transfromed into trial-by-units-by-bin matrix


% if ~isempty(ProbNPSess.SurviveInds)
%     SMBinDataMtx = SMBinDataMtx(:,ProbNPSess.SurviveInds,:);
% end
% SMBinDataMtxRaw = SMBinDataMtx;
% SMBinDataMtxRaw = SMBinDataMtx(:,:,:);
%%
Allfieldnames = fieldnames(SessAreaIndexStrc);
ExistAreas_Indexes = find(SessAreaIndexStrc.UsedAbbreviations);
ExistAreas_Names = Allfieldnames(SessAreaIndexStrc.UsedAbbreviations);
NumExistAreas = length(ExistAreas_Names);
if NumExistAreas< 1
    return;
end
BlockTypesAll = double(behavResults.BlockType(:));
%%
SavedFolderPathName = 'BaselinePredofBlocktype';

fullsavePath = fullfile(ksfolder, SavedFolderPathName);
if isfolder(fullsavePath)
    rmdir(fullsavePath,'s');
end
mkdir(fullsavePath);
 
TargetAreaUnits = false(size(SMBinDataMtxRaw,2),1);

SVMDecodingAccu_strs = {'SVMaccuracy','ShufAccu','SVMmodel','UsedUnitInds(NotRealIndex)'};
SVMDecodingAccuracy = cell(NumExistAreas,4);
logRegressorProb_strs = {'logregressorMD', 'Predprob','NMFreqChoice','NMFreqTrialIndex','CrossCoefValues'};
logRegressorProbofBlock = cell(NumExistAreas,5);
logRegressorUnitSampleDec = cell(NumExistAreas,2);
for cArea = 1 : NumExistAreas
    if cArea <= NumExistAreas
        cUsedAreas = ExistAreas_Names{cArea};
        if isempty(SessAreaIndexStrc.(cUsedAreas))
            error('Something wrong, no unit was found in the input channel position file.');
        end
        cAUnitInds = SessAreaIndexStrc.(cUsedAreas).MatchedUnitInds;
        SMBinDataMtx = SMBinDataMtxRaw(:,cAUnitInds,:);
    else
        cAUnitInds = find(~TargetAreaUnits);
        SMBinDataMtx = SMBinDataMtxRaw(:,cAUnitInds,:);
        cUsedAreas = 'OtherAreas';
    end
    NumberOfUnits = length(cAUnitInds); % number of units will be used for population decoding
    
    if NumberOfUnits == 0
        warning('All units were target area units.');
        continue;
    end
    
    [TrNum, ~, ~] = size(SMBinDataMtx);

    TriggerAlignBin = ProbNPSess.TriggerStartBin{ProbNPSess.CurrentSessInds};
    halfBaselineWinInds = round((TriggerAlignBin-1)/2);
    BaselineResp_First = mean(SMBinDataMtx(:,:,1:halfBaselineWinInds),3);
    BaselineResp_Last = mean(SMBinDataMtx(:,:,(halfBaselineWinInds+1):(TriggerAlignBin-1)),3);

    % RespTimeWin = round(1/ProbNPSess.USedbin(2));
    % BaselineResp_First = mean(SMBinDataMtx(:,:,(TriggerAlignBin+1):(TriggerAlignBin+RespTimeWin)),3);

    BlockSectionInfo = Bev2blockinfoFun(behavResults);
    %
%     zsbaselineData = zscore(BaselineResp_First);

    
    sampleInds = randsample(TrNum,round(TrNum*0.7));
    IsTrainingSet = false(TrNum,1);
    IsTrainingSet(sampleInds) = true;
    trainSet_resps = BaselineResp_First(IsTrainingSet,:);
    TrainSet_labels = BlockTypesAll(IsTrainingSet);
    TestSet_resps = BaselineResp_First(~IsTrainingSet,:);
    TestSet_labels = BlockTypesAll(~IsTrainingSet);

    mdl = fitcsvm(trainSet_resps,TrainSet_labels);
    CVmodel = crossval(mdl,'k',10);
    TrainErro = kfoldLoss(CVmodel,'mode','individual');

    fprintf('Model Crossval error lost is %.4f.\n',mean(TrainErro));
    predTestLabels = predict(mdl,TestSet_resps);
    PredictionAccu = mean(TestSet_labels == predTestLabels);

    %

    RepeatNum = 100;
    IsTrainingSet = false(TrNum,1);
    shufPredCorr = zeros(RepeatNum,1);
    parfor cR = 1 : RepeatNum
        shufBlocks = Vshuffle(BlockTypesAll);
        sampleInds = randsample(TrNum,round(TrNum*0.7));
        TrainInds = IsTrainingSet;
        TrainInds(sampleInds) = true;

        shuftrainSet_resps = BaselineResp_First(TrainInds,:);
        shufTrainSet_labels = shufBlocks(TrainInds);
        shufTestSet_resps = BaselineResp_First(~TrainInds,:);
        shufTestSet_labels = shufBlocks(~TrainInds);

        mdl_shuf = fitcsvm(shuftrainSet_resps,shufTrainSet_labels);

        predTestLabels = predict(mdl_shuf,shufTestSet_resps);
        shufPredCorr(cR) = mean(predTestLabels == shufTestSet_labels);

    end
    SVMDecodingAccuracy(cArea,:) = {PredictionAccu, shufPredCorr, mdl, cAUnitInds};
    
    % logistic regression classifier to predict block type 

    % MiddleTrainInds = round(mean(BlockSectionInfo.BlockTrScales,2))+(-80:80); %[120+(-60:60); 380+(-60:60)];
    % BlockInds = [BlockTypesAll(MiddleTrainInds(1,:)),BlockTypesAll(MiddleTrainInds(2,:))];
    % MiddleTrainInds = MiddleTrainInds';
    % MiddleRespData = BaselineResp_First(MiddleTrainInds(:),:);
    % MiddleBlockInds = BlockInds(:);
    % [BTrain,dev,statsTrain] = mnrfit(MiddleRespData,categorical(MiddleBlockInds));
    [BTrain,dev,statsTrain] = mnrfit(BaselineResp_First,categorical(BlockTypesAll(:)));
%     [pihat,dlow,dhi] = mnrval(BTrain,BaselineResp_First,statsTrain);
%     PredProb = pihat(:,1);

    %
    % MatrixWeight = BTrain(2:end);
    % %  ROIbias = (statsTrain.beta(2:end))';
    % MatrixScore = BaselineResp_Last * MatrixWeight + BTrain(1);
    % pValue = 1./(1+exp(-1.*MatrixScore));

    % pred new half dataset
    [pihatNew,dlowNew,dhiNew] = mnrval(BTrain,BaselineResp_Last,statsTrain);
    PredProbNew = pihatNew(:,1);

    % %% predict block type using SVM classifier
    % PredProbNew = 1 - predict(mdl,BaselineResp_Last); % the result was minused by 1 to adapted for choice direction

    % plot the behavior result on top
    RevFreqs = BlockSectionInfo.BlockFreqTypes(logical(BlockSectionInfo.IsFreq_asReverse));
    TrialFreqsAll = double(behavResults.Stim_toneFreq(:));
    TrialAnmChoice = double(behavResults.Action_choice(:));
    TrialAnmChoice(TrialAnmChoice == 2) = NaN;
    RevFreqInds = find(ismember(TrialFreqsAll,RevFreqs));
    RevFreqChoices = TrialAnmChoice(RevFreqInds);

    NMRevfreqInds = ~isnan(RevFreqChoices);
    NMRevFreqIndedx = RevFreqInds(NMRevfreqInds);
    NMRevFreqChoice = RevFreqChoices(NMRevfreqInds);

    lhf2 = figure;
    hold on
    hl1 = plot(smooth(PredProbNew,5),'b','linewidth',1);
    hl2 = plot(NMRevFreqIndedx,smooth(NMRevFreqChoice,9),'Color',[0.9 0.6 0.2],'linewidth',1);
    yaxiss = get(gca,'ylim');
    if size(BlockSectionInfo.BlockTrScales,1) == 1
        BlockEndInds = BlockSectionInfo.BlockTrScales(2);
    else
        BlockEndInds = BlockSectionInfo.BlockTrScales(1:end-1,2);
    end
    for cB = 1 : length(BlockEndInds)
        line([BlockEndInds(cB) BlockEndInds(cB)],yaxiss,...
            'Color','k','linewidth',1.2); 
    end
    set(gca,'ylim',[-0.05 1.1]);
    legend([hl1, hl2],{'PredProb','RevfreqChoice'},'location','northwest','box','off');
    title(sprintf('Area(%s) SVMaccu = %.4f, unitNum = %d',cUsedAreas,PredictionAccu, numel(cAUnitInds)));
    % time-lagged correlation plot
    predProb4Revfreqs = PredProbNew(NMRevFreqIndedx);
    [xcf,lags,bounds] = crosscorr(NMRevFreqChoice,predProb4Revfreqs,'NumLags',50,'NumSTD',3);
    hf3 = figure; 
    crosscorr(NMRevFreqChoice,predProb4Revfreqs,'NumLags',50,'NumSTD',3);

    logRegressorProbofBlock(cArea,:) = {{BTrain,dev,statsTrain}, PredProbNew, NMRevFreqChoice, NMRevFreqIndedx,{xcf,lags,bounds}};
    
    logregressorSaveName = fullfile(fullsavePath,sprintf('Area_%s logregressor prob plot save',cUsedAreas));
    saveas(lhf2,logregressorSaveName);
    saveas(lhf2,logregressorSaveName,'png');
    close(lhf2);
    
    CrossCoefSaveName = fullfile(fullsavePath,sprintf('Area_%s Crosscoef plot save',cUsedAreas));
    saveas(hf3,CrossCoefSaveName);
    saveas(hf3,CrossCoefSaveName,'png');
    close(hf3);
    
    [MaxCoefANDlag, RepeatUnitIndsANDbeta] = logisticFitUnitSampleFun(BaselineResp_First, ...
        BaselineResp_Last, [BlockTypesAll, TrialAnmChoice], round(NumberOfUnits*0.8), NMRevFreqIndedx);
    logRegressorUnitSampleDec(cArea,:) = {MaxCoefANDlag, RepeatUnitIndsANDbeta};
end
%%
save(fullfile(fullsavePath,'PopudecodingDatas.mat'), 'logRegressorProbofBlock', 'SVMDecodingAccuracy', 'SVMDecodingAccu_strs', ...
    'logRegressorProb_strs', 'ExistAreas_Names','logRegressorUnitSampleDec', '-v7.3');

%% ROC test for each unit
[TrNum, unitNum, BinNum] = size(SMBinDataMtxRaw);

TriggerAlignBin = ProbNPSess.TriggerStartBin{ProbNPSess.CurrentSessInds};
% halfBaselineWinInds = round((TriggerAlignBin-1)/2);
BaselineResp_First = mean(SMBinDataMtxRaw(:,:,1:TriggerAlignBin),3);

AUCValuesAll = zeros(unitNum,3);
smoothed_baseline_resp = zeros(size(BaselineResp_First));
for cUnit = 1 : unitNum
    cUnitDatas = BaselineResp_First(:,cUnit);
    [AUC, IsMeanRev] = AUC_fast_utest(cUnitDatas, BlockTypesAll);
    
    [~,~,SigValues] = ROCSiglevelGeneNew([cUnitDatas, BlockTypesAll],500,1,0.001);
    AUCValuesAll(cUnit,:) = [AUC, IsMeanRev, SigValues];
    
    smoothed_baseline_resp(:,cUnit) = smooth(cUnitDatas,7);
end

%% plot all AUC values
[AUCvalues, SortInds] = sort(AUCValuesAll(:,1));
SortedSiglevels = AUCValuesAll(SortInds,3);
IsAUCSigInds = AUCvalues > SortedSiglevels;
AUCIndex = 1 : numel(AUCvalues);
h4f = figure;
hold on
plot(AUCIndex(IsAUCSigInds),AUCvalues(IsAUCSigInds),'ko','linewidth',1.4,'MarkerSize',10);
plot(AUCIndex(~IsAUCSigInds),AUCvalues(~IsAUCSigInds),'o','linewidth',1.4,'MarkerSize',10,'MarkerEdgeColor',[.7 .7 .7]);
title(sprintf('SigAUCfrac = %.4f',mean(IsAUCSigInds)));
xlabel('Units');
ylabel('AUC');
set(gca,'ylim',[0.2 1],'ytick',[0.5 1])
%%

save(fullfile(fullsavePath,'SingleUnitAUC.mat'), 'AUCValuesAll', 'smoothed_baseline_resp', '-v7.3');
AUCSaveName = fullfile(fullsavePath,'Unit AUC distributions');
saveas(h4f,AUCSaveName);
saveas(h4f,AUCSaveName,'png');
close(h4f);
SMBinDataMtx = SMBinDataMtxRaw;
% ################################################################################################
% cclr
% AnmSess_sourcepath = 'F:\b107a08_ksoutput';
% 
% xpath = genpath(AnmSess_sourcepath);
% nameSplit = (strsplit(xpath,';'))';
% 
% if isempty(nameSplit{end})
%     nameSplit(end) = [];
% end
% % DirLength = length(nameSplit);
% % PossibleInds = cellfun(@(x) ~isempty(dir(fullfile(x,'*imec*.ap.bin'))),nameSplit);
% % PossDataPath = nameSplit(PossibleInds);
% sortingcode_string = 'ks2_5';
% % Find processed folders 
% ProcessedFoldInds = cellfun(@(x) exist(fullfile(x,sortingcode_string,'NPClassHandleSaved.mat'),'file') && ...
%    exist(fullfile(x,sortingcode_string,'SessAreaIndexData.mat'),'file') ,nameSplit);
% NPsessionfolders = nameSplit((ProcessedFoldInds>0));
% NumprocessedNPSess = length(NPsessionfolders);
% if NumprocessedNPSess < 1
%     warning('No valid NP session was found in current path.');
% end
% 
% %%
% 
% for cfff = 1 : NumprocessedNPSess
%     ksfolder = fullfile(NPsessionfolders{cfff},sortingcode_string);
%     baselineSpikePredBlocktypes_4batch;
% end

% ############################################################################

% % batched through all used sessions
% cclr
% 
% % AllSessFolderPathfile = 'K\Documents\me\projects\NP_reversaltask\processed_ksfolder_paths_new.xlsx';
% AllSessFolderPathfile = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\processed_ksfolder_paths_new.xlsx';
% sortingcode_string = 'ks2_5';
% 
% SessionFoldersC = readcell(AllSessFolderPathfile,'Range','A:A',...
%         'Sheet',1);
% SessionFolders = SessionFoldersC(2:end);
% NumprocessedNPSess = length(SessionFolders);
% 
% 
% %%
% for cfff = 1 : NumprocessedNPSess
%     
%     ksfolder = fullfile(SessionFolders{cfff},sortingcode_string);
%     cSessFolder = ksfolder;
% %     ksfolder = fullfile(strrep(SessionFolders{cfff},'F:','I:\ksOutput_backup'),sortingcode_string);
%     fprintf('Processing session %d...\n', cfff);
% % % %     OldFolderName = fullfile(cSessFolder,'BaselinePredofBlocktype');
% % % %     if isfolder(OldFolderName)
% % % % %         stats = rmdir(OldFolderName,'s');
% % % %         
% % % %         stats = movefile(OldFolderName,fullfile(cSessFolder,'Old_BaselinePredofBT'),'f');
% % % %         if ~stats
% % % %             error('Unable to delete folder in Session %d.',cfff);
% % % %         end
% % % %     end
%     OldFolderName = fullfile(cSessFolder,'UnitRespTypeCoef.mat');
%     if exist(OldFolderName,'file')
%         delete(OldFolderName);
%         
% %         stats = movefile(OldFolderName,fullfile(cSessFolder,'Old_BaselinePredofBT'),'f');
% %         if ~stats
% %             error('Unable to delete folder in Session %d.',cfff);
% %         end
%     end
%     
% %     baselineSpikePredBlocktypes_SVMProb;
% %     BlockType_Choice_decodingScript;
% %     baselineSpikePredBlocktypes_4batch;
% %     BT_Choice_decodingScript_trialtypeWise;
%     EventResp_avg_codes_tempErrorProcess;
% end