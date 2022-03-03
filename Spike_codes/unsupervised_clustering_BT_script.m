
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


%%
AreaVLDatas = SMBinDataMtxRaw(:,SessAreaIndexStrc.Others.MatchedUnitInds,:); % change the used area str names
TriggerAlignBin = ProbNPSess.TriggerStartBin{ProbNPSess.CurrentSessInds};
BaselineResp_All = mean(AreaVLDatas(:,:,1:TriggerAlignBin-1),3);


BlockTypesAll = double(behavResults.BlockType(:));
ChoiceAlls = double(behavResults.Action_choice(:));
AllTrFreqs = double(behavResults.Stim_toneFreq(:));

NMTrialInds = ChoiceAlls ~= 2;
NMBlockTypes = BlockTypesAll(NMTrialInds);
NMChoices = ChoiceAlls(NMTrialInds);
NMTrFreqs = AllTrFreqs(NMTrialInds);

BlockSectionInfo = Bev2blockinfoFun(behavResults);

RevFreqs = BlockSectionInfo.BlockFreqTypes(logical(BlockSectionInfo.IsFreq_asReverse));
RevFreqInds = ismember(NMTrFreqs,RevFreqs);

[Coeffs,Score,~,~,Explained,mu] = pca(BaselineResp_All(NMTrialInds,:)); % Miss trial will be projected into same space afterwards
%%

% using the first two PCs for clustering
MaxUsedPCNums = size(Score,2);
TotalVarExplained = cumsum(Explained);

UsedPC_kmeans_clusID = cell(MaxUsedPCNums,2);
for cUsedPC = 1 : MaxUsedPCNums
    UsedScores = Score(:,1:cUsedPC);

    [idx, Centers] = kmeans(UsedScores,2,'Replicates',10, 'MaxIter',1000);
    UsedPC_kmeans_clusID(cUsedPC,:) = {idx, Centers};

end
%%
IndexMtx = cell2mat((UsedPC_kmeans_clusID(:,1))');
RevFreq_Choices = NMChoices(RevFreqInds);
RevFreq_ClusIDs = IndexMtx(RevFreqInds,:) - 1;

[r,p] = corr(RevFreq_ClusIDs, RevFreq_Choices);
%%
UsedInds = 3;

figure;
hold on
plot(smooth(RevFreq_Choices,5),'k','linewidth',1.5);
plot(1-smooth(RevFreq_ClusIDs(:,UsedInds),5),'b','linewidth',1.5);



