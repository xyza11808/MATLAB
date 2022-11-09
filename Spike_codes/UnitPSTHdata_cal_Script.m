
load(fullfile(ksfolder,'NewClassHandle2.mat'));
ProbNPSess = NewNPClusHandle;
ProbNPSess.CurrentSessInds = strcmpi('Task',ProbNPSess.SessTypeStrs);
if isempty(ProbNPSess.SpikeTimes)
    ProbNPSess.SpikeTimes = double(ProbNPSess.SpikeTimeSample)/30000;
end
OutDataStrc = ProbNPSess.TrigPSTH_Ext([-1 4],[300 100],ProbNPSess.StimAlignedTime{ProbNPSess.CurrentSessInds});
NewBinnedDatas = permute(cat(3,OutDataStrc.TrigData_Bin{:,1}),[1,3,2]);
NumFrameBins = size(NewBinnedDatas,3);

OnsetBin = OutDataStrc.TriggerStartBin - 1;
BaselineResp = mean(NewBinnedDatas(:,:,1:OnsetBin),3);
BaseLineEndInds = OutDataStrc.TriggerStartBin - 1;
%% find target cluster inds and IDs

NewSessAreaStrc = load(fullfile(ksfolder,'SessAreaIndexDataNewAlign2.mat'));
NewAdd_AllfieldNames = fieldnames(NewSessAreaStrc.SessAreaIndexStrc);
NewAdd_ExistAreasInds = find(NewSessAreaStrc.SessAreaIndexStrc.UsedAbbreviations);
NewAdd_ExistAreaNames = NewAdd_AllfieldNames(NewAdd_ExistAreasInds);
if strcmpi(NewAdd_ExistAreaNames(end),'Others')
    NewAdd_ExistAreaNames(end) = [];
end
NewAdd_NumExistAreas = length(NewAdd_ExistAreaNames);

Numfieldnames = length(NewAdd_ExistAreaNames);
ExistField_ClusIDs = cell(Numfieldnames,4);
AreaUnitNumbers = zeros(NewAdd_NumExistAreas,1);
for cA = 1 : Numfieldnames
    cA_Clus_IDs = NewSessAreaStrc.SessAreaIndexStrc.(NewAdd_ExistAreaNames{cA}).MatchUnitRealIndex;
    cA_clus_inds = NewSessAreaStrc.SessAreaIndexStrc.(NewAdd_ExistAreaNames{cA}).MatchedUnitInds;
    ExistField_ClusIDs(cA,:) = {cA_Clus_IDs,cA_clus_inds,numel(cA_clus_inds) > 5,...
        repmat(NewAdd_ExistAreaNames(cA),numel(cA_clus_inds),1)}; % real Clus_IDs and Clus indexing inds
    AreaUnitNumbers(cA) = numel(cA_clus_inds);
    
end
%%
% USedAreas = cell2mat(ExistField_ClusIDs(:,3)) < 1;
% if sum(USedAreas)
%     ExistField_ClusIDs(USedAreas,:) = [];
%     AreaUnitNumbers(USedAreas) = [];
%     Numfieldnames = Numfieldnames - sum(USedAreas);
%     NewAdd_ExistAreaNames(USedAreas) = [];
% end

BlockSectionInfo = Bev2blockinfoFun(behavResults);

UsedBlockInds = 1 : BlockSectionInfo.BlockTrScales(end,2);
ActionChoices = double(behavResults.Action_choice(:));
TrFreqs = double(behavResults.Stim_toneFreq(:));
TrBlockTypes = double(behavResults.BlockType(:));
TrRewardTime = double(behavResults.Time_reward(:));

UsedTrInds_Choices = ActionChoices(UsedBlockInds);
UsedTrInds_NMInds = find(UsedTrInds_Choices ~= 2);
UsedTrInds_NMChoice = UsedTrInds_Choices(UsedTrInds_NMInds);
UsedTrInds_NMFreqs = TrFreqs(UsedTrInds_NMInds);
UsedTrInds_NMBTs = TrBlockTypes(UsedTrInds_NMInds);
UsedTrInds_NMRT = TrRewardTime(UsedTrInds_NMInds);

FreqTypes = unique(UsedTrInds_NMFreqs);
FreqTypeNum = length(FreqTypes);
%%
UsedAreaUnitInds = cat(1,ExistField_ClusIDs{:,2});
UsedAreaUnitIDs = cat(1,ExistField_ClusIDs{:,1});
UsedAreaUnitAreas = cat(1,ExistField_ClusIDs{:,4});

NumUsedUnits = length(UsedAreaUnitInds);
UnitPSTHdataAll = cell(NumUsedUnits, 5);
for cU = 1 : NumUsedUnits
    cU_Inds = UsedAreaUnitInds(cU);
    cU_BinDatas = squeeze(NewBinnedDatas(UsedTrInds_NMInds,cU_Inds,:));
    % only correct trials will be used for psth calculation, but error
    % trials will also be saved
    
    cU_psthDatas = zeros(FreqTypeNum,4,NumFrameBins);
    cU_psthSEMs = zeros(FreqTypeNum,4,NumFrameBins);
    cU_TypeTrNum = zeros(FreqTypeNum,4);
    for cf = 1 : FreqTypeNum
        cf_freq = FreqTypes(cf);
        
        % low boundary block trials calculation
        % correct trials only
        cf_low_Correct_Inds = UsedTrInds_NMFreqs == cf_freq & UsedTrInds_NMBTs == 0 & UsedTrInds_NMRT > 0;
        [cf_low_Correct_TrNum,cf_low_Correct_Avg,cf_low_Correct_SEM] = ...
            AvgSEMdataCal(cU_BinDatas(cf_low_Correct_Inds,:),NumFrameBins);
        
        % error trials cal
        cf_low_Error_Inds = UsedTrInds_NMFreqs == cf_freq & UsedTrInds_NMBTs == 0 & UsedTrInds_NMRT == 0;
        [cf_low_Error_TrNum,cf_low_Error_Avg,cf_low_Error_SEM] = ...
            AvgSEMdataCal(cU_BinDatas(cf_low_Error_Inds,:),NumFrameBins);
        
        % High boundary block trials calculation
        % correct trials only
        cf_high_Correct_Inds = UsedTrInds_NMFreqs == cf_freq & UsedTrInds_NMBTs == 1 & UsedTrInds_NMRT > 0;
        [cf_high_Correct_TrNum,cf_high_Correct_Avg,cf_high_Correct_SEM] = ...
            AvgSEMdataCal(cU_BinDatas(cf_high_Correct_Inds,:),NumFrameBins);
        
        % error trials cal
        cf_high_Error_Inds = UsedTrInds_NMFreqs == cf_freq & UsedTrInds_NMBTs == 1 & UsedTrInds_NMRT == 0;
        [cf_high_Error_TrNum,cf_high_Error_Avg,cf_high_Error_SEM] = ...
            AvgSEMdataCal(cU_BinDatas(cf_high_Error_Inds,:),NumFrameBins);
        
        cU_psthDatas(cf,:,:) = [cf_low_Correct_Avg;cf_low_Error_Avg;...
            cf_high_Correct_Avg;cf_high_Error_Avg];
        cU_psthSEMs(cf,:,:) = [cf_low_Correct_SEM;cf_low_Error_SEM;...
            cf_high_Correct_SEM;cf_high_Error_SEM];
        
        cU_TypeTrNum(cf,:) = [cf_low_Correct_TrNum;cf_low_Error_TrNum;...
            cf_high_Correct_TrNum;cf_high_Error_TrNum];
        
    end
    %
    cUBaseLineData = cU_psthDatas(:,:,1:BaseLineEndInds);
    cU_LowCorrBase = squeeze(cUBaseLineData(:,1,:));
    cU_HighCorrBase = squeeze(cUBaseLineData(:,3,:));
    cU_LowCorrBaseMedian = median(cU_LowCorrBase(:));
    cU_HighCorrBaseMedian = median(cU_HighCorrBase(:));
    cU_LowCorrAdj = ((squeeze(cU_psthDatas(:,1,:)))' - mean(cU_LowCorrBase'))'+cU_LowCorrBaseMedian;
    cU_HighCorrAdj = ((squeeze(cU_psthDatas(:,3,:)))' - mean(cU_HighCorrBase'))'+cU_HighCorrBaseMedian;
    
    cU_psthDatas(:,1,:) = cU_LowCorrAdj;
    cU_psthDatas(:,3,:) = cU_HighCorrAdj;
    %
    UnitPSTHdataAll(cU,:) = {cU_psthDatas, cU_psthSEMs, cU_TypeTrNum, UsedAreaUnitIDs(cU), UsedAreaUnitAreas{cU}};
    
end

%%
% sess unit PSTH data expension
UsedUnitNum = size(UnitPSTHdataAll,1);
PSTHframeBins = size(UnitPSTHdataAll{1,1},3);
ExpendTraceAll = cell(UsedUnitNum,7);
for cU = 1 : UsedUnitNum
    
    cU_lowCorr_AvgData = (squeeze(UnitPSTHdataAll{cU,1}(:,1,:)))';
    cU_lowErro_AvgData = (squeeze(UnitPSTHdataAll{cU,1}(:,2,:)))';
    cU_highCorr_AvgData = (squeeze(UnitPSTHdataAll{cU,1}(:,3,:)))';
    cU_highErro_AvgData = (squeeze(UnitPSTHdataAll{cU,1}(:,4,:)))';

    % expend all freq and blocks
    cU_ExpendTrace = [cU_lowCorr_AvgData(:);cU_highCorr_AvgData(:)];

    cU_lowCorr_SEMData = (squeeze(UnitPSTHdataAll{cU,2}(:,1,:)))';
    cU_lowErro_SEMData = (squeeze(UnitPSTHdataAll{cU,2}(:,2,:)))';
    cU_highCorr_SEMData = (squeeze(UnitPSTHdataAll{cU,2}(:,3,:)))';
    cU_highErro_SEMData = (squeeze(UnitPSTHdataAll{cU,2}(:,4,:)))';
    
    cU_SEM_expend = [cU_lowCorr_SEMData(:);cU_highCorr_SEMData(:)];
    
    % expend all error trials
    cU_ErroExpendTrace = [cU_lowErro_AvgData(:);cU_highErro_AvgData(:)];
    cU_SEMErroTrace = [cU_lowErro_SEMData(:);cU_highErro_SEMData(:)];
     
    ExpendTraceAll(cU,:) = {cU_ExpendTrace',cU_SEM_expend',cU_ErroExpendTrace',cU_SEMErroTrace',...
        UnitPSTHdataAll{cU,3},UnitPSTHdataAll{cU,4},UnitPSTHdataAll{cU,5}};
    
end
% UnitPSTHMtx = cat(1,ExpendTraceAll{:,1});
% UnitPSTHzs = zscore(UnitPSTHMtx,0,2);
% AreaStrs = ExpendTraceAll(:,end);

%%

DataSavePath = fullfile(ksfolder,'SessPSTHdataSaveNew2.mat');
save(DataSavePath,'UnitPSTHdataAll','ExistField_ClusIDs','FreqTypes','Numfieldnames',...
    'NewAdd_ExistAreaNames', 'AreaUnitNumbers','OutDataStrc','BlockSectionInfo',...
    'ExpendTraceAll','NumFrameBins','-v7.3');

%%

% %% test with tsne clustering
% figure('position',[100 100 1200 840])
% Perplexitys = 40;
% nPCs = 100;
% Algorithm = 'barneshut'; %'barneshut' for N > 1000 % 'exact' for small N
% Exag = 12;
% rng('shuffle') % for fair comparison
% Y = tsne(UnitPSTHzs,'Algorithm',Algorithm,'Distance','correlation','Perplexity',Perplexitys,...
%     'NumPCAComponents',nPCs,'Exaggeration',Exag);
% subplot(2,2,1)
% gscatter(Y(:,1),Y(:,2),AreaStrs)
% title('correlation')
% 
% rng('shuffle') % for fair comparison
% Y = tsne(UnitPSTHzs,'Algorithm',Algorithm,'Distance','cosine','Perplexity',Perplexitys,...
%     'NumPCAComponents',nPCs,'Exaggeration',Exag);
% subplot(2,2,2)
% gscatter(Y(:,1),Y(:,2),AreaStrs)
% title('Cosine')
% 
% rng('shuffle') % for fair comparison
% Y = tsne(UnitPSTHzs,'Algorithm',Algorithm,'Distance','chebychev','Perplexity',Perplexitys,...
%     'NumPCAComponents',nPCs,'Exaggeration',Exag);
% subplot(2,2,3)
% gscatter(Y(:,1),Y(:,2),AreaStrs)
% title('Chebychev')
% 
% rng('shuffle') % for fair comparison
% Y = tsne(UnitPSTHzs,'Algorithm',Algorithm,'Distance','euclidean','Perplexity',Perplexitys,...
%     'NumPCAComponents',nPCs,'Exaggeration',Exag);
% subplot(2,2,4)
% gscatter(Y(:,1),Y(:,2),AreaStrs)
% title('Euclidean')

