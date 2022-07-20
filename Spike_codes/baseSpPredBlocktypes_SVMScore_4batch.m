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
logRegressorProbofBlock = cell(NumExistAreas,5);
for cArea = 1 : NumExistAreas
    
    cUsedAreas = ExistAreas_Names{cArea};
    if isempty(SessAreaIndexStrc.(cUsedAreas))
        error('Something wrong, no unit was found in the input channel position file.');
    end
    cAUnitInds = SessAreaIndexStrc.(cUsedAreas).MatchedUnitInds;
    SMBinDataMtx = SMBinDataMtxRaw(:,cAUnitInds,:);
    
    NumberOfUnits = length(cAUnitInds); % number of units will be used for population decoding
    
    [TrNum, unitNum, BinNum] = size(SMBinDataMtx);

    TriggerAlignBin = ProbNPSess.TriggerStartBin{ProbNPSess.CurrentSessInds};
    halfBaselineWinInds = round((TriggerAlignBin-1)/2);
    BaselineResp_First = mean(SMBinDataMtx(:,:,1:halfBaselineWinInds),3);
    BaselineResp_Last = mean(SMBinDataMtx(:,:,(halfBaselineWinInds+1):(TriggerAlignBin-1)),3);

    % RespTimeWin = round(1/ProbNPSess.USedbin(2));
    % BaselineResp_First = mean(SMBinDataMtx(:,:,(TriggerAlignBin+1):(TriggerAlignBin+RespTimeWin)),3);

    BlockSectionInfo = Bev2blockinfoFun(behavResults);
    %
%     zsbaselineData = zscore(BaselineResp_First);

    BlockTypesAll = double(behavResults.BlockType(:));
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
    
    UsedDataInds = find(behavResults.Action_choice(:) ~= 2);
    GrWithinIndsSet = seqpartitionFun(UsedDataInds);
    % use each test set to predict a score value and then calculate the 
    
    
    % pValue = 1./(1+exp(-1.*MatrixScore));


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
    [xcf,lags,bounds] = crosscorr(predProb4Revfreqs,NMRevFreqChoice,'NumLags',50,'NumSTD',3);
    hf3 = figure; 
    crosscorr(predProb4Revfreqs,NMRevFreqChoice,'NumLags',50,'NumSTD',3);

    logRegressorProbofBlock(cArea,:) = {{BTrain,dev,statsTrain}, PredProbNew, NMRevFreqChoice, NMRevFreqIndedx,{xcf,lags,bounds}};
    
    logregressorSaveName = fullfile(fullsavePath,sprintf('Area_%s logregressor prob plot save',cUsedAreas));
    saveas(lhf2,logregressorSaveName);
    saveas(lhf2,logregressorSaveName,'png');
    close(lhf2);
    
    CrossCoefSaveName = fullfile(fullsavePath,sprintf('Area_%s Crosscoef plot save',cUsedAreas));
    saveas(hf3,CrossCoefSaveName);
    saveas(hf3,CrossCoefSaveName,'png');
    close(hf3);
    
end

save(fullfile(fullsavePath,'PopudecodingDatas.mat'), 'logRegressorProbofBlock', 'SVMDecodingAccuracy', 'SVMDecodingAccu_strs', ...
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
