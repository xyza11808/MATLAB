clearvars SessAreaIndexStrc ProbNPSess cAUnitInds BaselineResp_All RelagCoefsAll Allxcf Alllags Lags LagCoefMtx
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
% if NumExistAreas< 1
%     return;
% end
%%
SavedFolderPathName = 'BaselinePredofBlocktypeSVM';

fullsavePath = fullfile(ksfolder, SavedFolderPathName);
if ~isfolder(fullsavePath)
    mkdir(fullsavePath);
end

TargetAreaUnits = false(size(SMBinDataMtxRaw,2),1);

% SVMDecodingAccu_strs = {'SVMScores','mdperfs','RevfreqInds','PredBTANDRealChoice','CrossCoefValues'};
% SVMDecodingAccuracy = cell(NumExistAreas,4);
SVMSCoreProb_strs = {'SVMScores','mdperfs','RevfreqInds','PredBTANDRealChoice','CrossCoefValues','UnitNumber','SampledecodLags'};
SVMSCoreProbofBlock = cell(NumExistAreas,7);
SampleScore2ProbAlls = cell(NumExistAreas,1);
AreaPredInfo = cell(NumExistAreas, 2);
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
    %
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
    %
    TrPredBlockTypes = cell(NumofFolds,6); % PredInds, PredType, PredScore
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
        
        TrPredBlockTypes(cfold,:) = {PerdTrInds,mdPredTypes,PredScores(:,1),BlockTypesAll(PerdTrInds),mdl.Beta,mdl.Bias};
    end
    %
    fprintf('Model self lost is %.4f.\n',1-mean(Trmdperfs(:,1)));
    fprintf('Model TestData lost is %.4f.\n',1-mean(Trmdperfs(:,2)));
    
    AllUsedTrInds = cell2mat(TrPredBlockTypes(:,1));
    AllUsedTrPredScores = cell2mat(TrPredBlockTypes(:,3));
    AllUsedTrPredTypes = cell2mat(TrPredBlockTypes(:,2));
    AllUsedTrRealTypes = cell2mat(TrPredBlockTypes(:,4));
    AreaPredInfo{cArea,1} = MutInfo(AllUsedTrPredTypes, AllUsedTrRealTypes);
    PredScore2Prob = 1./(1+exp(-1.*AllUsedTrPredScores)); % 
    %
    % %% predict block type using SVM classifier
    % PredProbNew = 1 - predict(mdl,BaselineResp_Last); % the result was minused by 1 to adapted for choice direction

    % plot the behavior result on top
    UsedTrFreqs = TrialFreqsAll(AllUsedTrInds);
    UsedTrChoices = TrialAnmChoice(AllUsedTrInds);
    RevFreqInds = ismember(UsedTrFreqs,RevFreqs);
    
    RevFreqChoices = UsedTrChoices(RevFreqInds);
    RevFreqRealInds = AllUsedTrInds(RevFreqInds);
    RevFreqPredProb = PredScore2Prob(RevFreqInds);
%     RevFreqPredProb = AllUsedTrPredTypes(RevFreqInds);
    
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
    [Allxcf,Alllags,Allbounds] = crosscorr(SortRevFreqPredProb,SortRevFreqChoices,'NumLags',40,'NumSTD',3);
    [~, AllPeakInds] = max(Allxcf);
    hf3 = figure; 
    crosscorr(SortRevFreqPredProb,SortRevFreqChoices,'NumLags',40,'NumSTD',3);

    
    %
    SVMSCoreSaveName = fullfile(fullsavePath,sprintf('Area_%s SVMSCore prob plot save',cUsedAreas));
    saveas(lhf2,SVMSCoreSaveName);
    saveas(lhf2,SVMSCoreSaveName,'png');
    close(lhf2);
    
    CrossCoefSaveName = fullfile(fullsavePath,sprintf('Area_%s SVMSCore Crosscoef plot save',cUsedAreas));
    saveas(hf3,CrossCoefSaveName);
    saveas(hf3,CrossCoefSaveName,'png');
    close(hf3);
    
    %
    if NumberOfUnits > 25
        nRepeats = 100;
        sampleNumber = round(NumberOfUnits*0.8);
        SampleScore2Prob = randomUnitPrediction(BaselineResp_All(NMTrialIndex,:), BlockTypesAll(NMTrialIndex), sampleNumber, nRepeats);
        AreaPredInfo{cArea,2} = cell2mat(SampleScore2Prob(:,5)); % sample unit decoding info
        NMTrialFreqs = TrialFreqsAll(NMTrialIndex);
        NMTrialChoice = TrialAnmChoice(NMTrialIndex);

        Re_RevFreqInds = ismember(NMTrialFreqs,RevFreqs);
        Re_RevFreqChoices = NMTrialChoice(Re_RevFreqInds);
        %
        RelagCoefsAll = cell(nRepeats, 3);
        for cR = 1 : nRepeats
           cRInds = SampleScore2Prob{cR,2};
           cRScoreProbs = SampleScore2Prob{cR,1};
           [SortTrialIndex, SInds] = sort(cRInds);
           cRScoreProbs = cRScoreProbs(SInds);

           cR_RevFreq_scoreProbs = cRScoreProbs(Re_RevFreqInds);
           [xcf,lags,bounds] = crosscorr(cR_RevFreq_scoreProbs,Re_RevFreqChoices,'NumLags',40,'NumSTD',3);

           RelagCoefsAll(cR,:) = {xcf,lags,bounds}; 
        end
        LagCoefMtx = (cell2mat((RelagCoefsAll(:,1))'))';
        Lags = RelagCoefsAll{1,2};

        LagCoefAvgs = mean(LagCoefMtx);
        LagCoefSEMs = std(LagCoefMtx)/sqrt(nRepeats)*5;

        lags_patch_x = [Lags;flipud(Lags)];
        lags_patch_y = ([LagCoefAvgs-LagCoefSEMs,fliplr(LagCoefAvgs+LagCoefSEMs)])';
        hhf = figure('position',[100 100 420 360]);
        hold on
        patch(lags_patch_x,lags_patch_y,1,'FaceColor',[.4 .4 .4],'EdgeColor','none');
        hl1 = plot(Lags, LagCoefAvgs, 'k', 'linewidth', 1.5);

        hl2 = plot(Alllags, Allxcf, 'r', 'linewidth', 1.4);
        xlabel('Trial Lags');
        ylabel('Coefs');
        legend([hl1,hl2],{'Randsample(5SEM)','AllUnit'},'Location','South','box','off');
        set(gca,'box','off');
        [~, samplePeakInds] = max(LagCoefAvgs);
        title(sprintf('SamplePeakLag = %d, AllPeakLag = %d', Lags(samplePeakInds), Lags(AllPeakInds)));
        
        USCrossCoefSaveName = fullfile(fullsavePath,sprintf('Area_%s UnitSample Crosscoef plot save',cUsedAreas));
        saveas(hhf,USCrossCoefSaveName);
        saveas(hhf,USCrossCoefSaveName,'png');
        close(hhf);
    else
        Lags = [];
        LagCoefMtx = [];
        SampleScore2Prob = [];
        AreaPredInfo{cArea,2} = [];
    end
    SampleScore2ProbAlls(cArea) = {SampleScore2Prob};
    SVMSCoreProbofBlock(cArea,:) = {TrPredBlockTypes, Trmdperfs, SortRevFreqRealIndex, ...
        [SortRevFreqPredProb, SortRevFreqChoices],{Allxcf,Alllags,Allbounds},NumberOfUnits,...
        {Lags, LagCoefMtx}};
end

save(fullfile(fullsavePath,'PopudecodingDatas.mat'), 'SVMSCoreProbofBlock', ...
    'SVMSCoreProb_strs', 'ExistAreas_Names', 'SampleScore2ProbAlls', 'AreaPredInfo', '-v7.3');

% %% ROC test for each unit
% [TrNum, unitNum, BinNum] = size(SMBinDataMtxRaw);
% 
% TriggerAlignBin = ProbNPSess.TriggerStartBin{ProbNPSess.CurrentSessInds};
% halfBaselineWinInds = round((TriggerAlignBin-1)/2);
% BaselineResp_First = mean(SMBinDataMtxRaw(:,:,1:halfBaselineWinInds),3);
% 
% AUCValuesAll = zeros(unitNum,3);
% smoothed_baseline_resp = zeros(size(BaselineResp_First));
% for cUnit = 1 : unitNum
%     cUnitDatas = BaselineResp_First(:,cUnit);
%     [AUC, IsMeanRev] = AUC_fast_utest(cUnitDatas, BlockTypesAll);
%     
%     [~,~,SigValues] = ROCSiglevelGeneNew([cUnitDatas, BlockTypesAll],500,1,0.001);
%     AUCValuesAll(cUnit,:) = [AUC, IsMeanRev, SigValues];
%     
%     smoothed_baseline_resp(:,cUnit) = smooth(cUnitDatas,7);
% end
% 
% %% plot all AUC values
% [AUCvalues, SortInds] = sort(AUCValuesAll(:,1));
% SortedSiglevels = AUCValuesAll(SortInds,3);
% IsAUCSigInds = AUCvalues > SortedSiglevels;
% AUCIndex = 1 : numel(AUCvalues);
% h4f = figure;
% hold on
% plot(AUCIndex(IsAUCSigInds),AUCvalues(IsAUCSigInds),'ko','linewidth',1.4,'MarkerSize',10);
% plot(AUCIndex(~IsAUCSigInds),AUCvalues(~IsAUCSigInds),'o','linewidth',1.4,'MarkerSize',10,'MarkerEdgeColor',[.7 .7 .7]);
% title(sprintf('SigAUCfrac = %.4f',mean(IsAUCSigInds)));
% xlabel('Units');
% ylabel('AUC');
% set(gca,'ylim',[0.2 1],'ytick',[0.5 1])
% %%
% 
% save(fullfile(fullsavePath,'SingleUnitAUC.mat'), 'AUCValuesAll', 'smoothed_baseline_resp', '-v7.3');
% AUCSaveName = fullfile(fullsavePath,'Unit AUC distributions');
% saveas(h4f,AUCSaveName);
% saveas(h4f,AUCSaveName,'png');
% close(h4f);


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

