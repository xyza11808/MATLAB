clearvars SessAreaIndexStrc ProbNPSess cAUnitInds BaselineResp_First BaselineResp_Last
load(fullfile(ksfolder,'NPClassHandleSaved.mat'))
% load('Chnlocation.mat');
load(fullfile(ksfolder,'SessAreaIndexData.mat'));
% if isempty(ProbNPSess.ChannelAreaStrs)
%     ProbNPSess.ChannelAreaStrs = {ChnArea_indexes,ChnArea_Strings(:,3)};
% end
%%
ProbNPSess.CurrentSessInds = strcmpi('Task',ProbNPSess.SessTypeStrs);
% TimeWin = [-1.5,8]; % time window used to calculate the psth, usually includes before and after trigger time, in seconds
% Smoothbin = [50,10]; %
% ProbNPSess = ProbNPSess.TrigPSTH(TimeWin, Smoothbin, double(behavResults.Time_stimOnset(:)));
% save(fullfile(pwd,'ks2_5','NPClassHandleSaved.mat'),'ProbNPSess', 'PassSoundDatas', 'behavResults', '-v7.3');

SMBinDataMtx = permute(cat(3,ProbNPSess.TrigData_Bin{ProbNPSess.CurrentSessInds}{:,1}),[1,3,2]); % transfromed into trial-by-units-by-bin matrix


if ~isempty(ProbNPSess.SurviveInds)
    SMBinDataMtx = SMBinDataMtx(:,ProbNPSess.SurviveInds,:);
end
SMBinDataMtxRaw = SMBinDataMtx;
% SMBinDataMtxRaw = SMBinDataMtx(:,:,:);

Allfieldnames = fieldnames(SessAreaIndexStrc);
ExistAreas_Indexes = find(SessAreaIndexStrc.UsedAbbreviations);
ExistAreas_Names = Allfieldnames(SessAreaIndexStrc.UsedAbbreviations);
NumExistAreas = length(ExistAreas_Names);
if NumExistAreas< 1
    return;
end
%%
SavedFolderPathName = 'BaselinePredofBlocktype';

fullsavePath = fullfile(ksfolder, SavedFolderPathName);
if ~isfolder(fullsavePath)
    mkdir(fullsavePath);
end


SVMDecodingAccu_strs = {'SVMaccuracy','ShufAccu','SVMmodel','UsedUnitInds(NotRealIndex)'};
SVMDecodingAccuracy = cell(NumExistAreas,4);
logRegressorProb_strs = {'logregressorMD', 'Predprob','NMFreqChoice','NMFreqTrialIndex','CrossCoefValues'};
SVMSCoreProbofBlock = cell(NumExistAreas,5);
for cArea = 1 : NumExistAreas
    
    cUsedAreas = ExistAreas_Names{cArea};
    if isempty(SessAreaIndexStrc.(cUsedAreas))
        error('Something wrong, no unit was found in the input channel position file.');
    end
    cAUnitInds = SessAreaIndexStrc.(cUsedAreas).MatchedUnitInds;
    
    SMBinDataMtx = SMBinDataMtxRaw(:,cAUnitInds,:);
    
    NumberOfUnits = length(cAUnitInds); % number of units will be used for population decoding
    
    %%
    TriggerAlignBin = ProbNPSess.TriggerStartBin{ProbNPSess.CurrentSessInds};
    BaselineResp_All = mean(SMBinDataMtx(:,:,1:TriggerAlignBin-1),3);
    
    BlockSectionInfo = Bev2blockinfoFun(behavResults);
    BlockTypesAll = double(behavResults.BlockType(:));
    RevFreqs = BlockSectionInfo.BlockFreqTypes(logical(BlockSectionInfo.IsFreq_asReverse));
    TrialFreqsAll = double(behavResults.Stim_toneFreq(:));
    TrialAnmChoice = double(behavResults.Action_choice(:));
    NMTrialIndex = find(TrialAnmChoice ~= 2);
    
    NumofFolds = 10;
    GrWithinIndsSet = seqpartitionFun(NMTrialIndex, NumofFolds); % default partition fraction
    %%
    TrPredBlockTypes = cell(NumofFolds,3); % PredInds, PredType, PredScore
    Trmdperfs = zeros(NumofFolds,2);
    MDbetas = cell(NumofFolds,2); % model prediction coefs
    for cfold = 1 : NumofFolds
        cFoldInds = (GrWithinIndsSet(cfold,:))';
        
        AllTrIndsBack = GrWithinIndsSet;
        AllTrIndsBack(cfold,:) = [];
        TrainInds = cell2mat(AllTrIndsBack(:,1)); % for model training
        MDPerfInds = cell2mat(AllTrIndsBack(:,2)); % for model performance evaluating
        PerdTrInds = cell2mat(cFoldInds(:)); % predicting the rest datas
        
        mdl = fitcsvm(BaselineResp_All(TrainInds,:),BlockTypesAll(TrainInds));
        mdEvaluates = predict(mdl, BaselineResp_All(MDPerfInds,:));
        MDPerfs = mean(mdEvaluates == BlockTypesAll(MDPerfInds));
        
        [mdPredTypes, PredScores] = predict(mdl, BaselineResp_All(PerdTrInds,:)); % predDatas
        PredPerfs = mean(mdPredTypes == BlockTypesAll(PerdTrInds));
        
        Trmdperfs(cfold,:) = [MDPerfs, PredPerfs];
        
        TrPredBlockTypes(cfold,:) = {PerdTrInds,mdPredTypes,PredScores(:,1)};
    end
    %%
    fprintf('Model self lost is %.4f.\n',mean(Trmdperfs(:,1)));
    fprintf('Model TestData lost is %.4f.\n',mean(Trmdperfs(:,2)));
    
    AllUsedTrInds = cell2mat(TrPredBlockTypes(:,1));
    AllUsedTrPredScores = cell2mat(TrPredBlockTypes(:,3));
    PredScore2Prob = 1./(1+exp(-1.*AllUsedTrPredScores)); % 
    
    % %% predict block type using SVM classifier
    % PredProbNew = 1 - predict(mdl,BaselineResp_Last); % the result was minused by 1 to adapted for choice direction

    % plot the behavior result on top
    UsedTrFreqs = TrialFreqsAll(AllUsedTrInds);
    UsedTrChoices = TrialAnmChoice(AllUsedTrInds);
    RevFreqInds = ismember(UsedTrFreqs,RevFreqs);
    
    RevFreqChoices = UsedTrChoices(RevFreqInds);
    RevFreqRealInds = AllUsedTrInds(RevFreqInds);
    RevFreqPredProb = PredScore2Prob(RevFreqInds);
    
    [SortRevFreqRealIndex, SortInds] = sort(RevFreqRealInds);
    SortRevFreqChoices = RevFreqChoices(SortInds);
    SortRevFreqPredProb = RevFreqPredProb(SortInds);
    

    lhf2 = figure;
    hold on
    hl1 = plot(SortRevFreqRealIndex,smooth(SortRevFreqPredProb,5),'b','linewidth',1);
    hl2 = plot(SortRevFreqRealIndex,smooth(SortRevFreqChoices,5),'Color',[0.9 0.6 0.2],'linewidth',1);
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
    title(sprintf('Area(%s) SVMaccu = %.4f, unitNum = %d',cUsedAreas,mean(Trmdperfs(:,2)), numel(cAUnitInds)));
    
    % time-lagged correlation plot
    [xcf,lags,bounds] = crosscorr(SortRevFreqPredProb,SortRevFreqChoices,'NumLags',40,'NumSTD',3);
    hf3 = figure; 
    crosscorr(SortRevFreqPredProb,SortRevFreqChoices,'NumLags',40,'NumSTD',3);

    SVMSCoreProbofBlock(cArea,:) = {{BTrain,dev,statsTrain}, PredProbNew, NMRevFreqChoice, NMRevFreqIndedx,{xcf,lags,bounds}};
    
    SVMSCoreSaveName = fullfile(fullsavePath,sprintf('Area_%s SVMSCore prob plot save',cUsedAreas));
    saveas(lhf2,SVMSCoreSaveName);
    saveas(lhf2,SVMSCoreSaveName,'png');
    close(lhf2);
    
    CrossCoefSaveName = fullfile(fullsavePath,sprintf('Area_%s SVNSCore Crosscoef plot save',cUsedAreas));
    saveas(hf3,CrossCoefSaveName);
    saveas(hf3,CrossCoefSaveName,'png');
    close(hf3);
    
end

save(fullfile(fullsavePath,'PopudecodingDatas.mat'), 'SVMSCoreProbofBlock', 'SVMDecodingAccuracy', 'SVMDecodingAccu_strs', ...
    'logRegressorProb_strs', 'ExistAreas_Names', '-v7.3');

%% ROC test for each unit
[TrNum, unitNum, BinNum] = size(SMBinDataMtxRaw);

TriggerAlignBin = ProbNPSess.TriggerStartBin{ProbNPSess.CurrentSessInds};
halfBaselineWinInds = round((TriggerAlignBin-1)/2);
BaselineResp_First = mean(SMBinDataMtxRaw(:,:,1:halfBaselineWinInds),3);

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
% AllSessFolderPathfile = 'H:\file_from_N\Documents\me\projects\NP_reversaltask\processed_ksfolder_paths.xlsx';
% % AllSessFolderPathfile = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\processed_ksfolder_paths.xlsx';
% sortingcode_string = 'ks2_5';
% 
% SessionFoldersC = readcell(AllSessFolderPathfile,'Range','A:A',...
%         'Sheet',1);
% SessionFolders = SessionFoldersC(2:end);
% NumprocessedNPSess = length(SessionFolders);
% 
% %%
% 
% for cfff = 1 : NumprocessedNPSess
%     
% %     ksfolder = fullfile(NPsessionfolders{cfff},sortingcode_string);
%     ksfolder = fullfile(strrep(SessionFolders{cfff}(2:end-1),'F:','I:\ksOutput_backup'),sortingcode_string);
%     fprintf('Processing session %d...\n', cfff);
%     baselineSpikePredBlocktypes_4batch;
% end

