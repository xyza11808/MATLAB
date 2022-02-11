
ProbNPSess.CurrentSessInds = strcmpi('Task',ProbNPSess.SessTypeStrs);
SMBinDataMtx = permute(cat(3,ProbNPSess.TrigData_Bin{ProbNPSess.CurrentSessInds}{:,1}),[1,3,2]); % transfromed into trial-by-units-by-bin matrix


if ~isempty(ProbNPSess.SurviveInds)
    SMBinDataMtx = SMBinDataMtx(:,ProbNPSess.SurviveInds,:);
end
SMBinDataMtxRaw = SMBinDataMtx;

cAUnitInds = SessAreaIndexStrc.VL.MatchedUnitInds;
SMBinDataMtx = SMBinDataMtxRaw(:,cAUnitInds,:);

NumberOfUnits = length(cAUnitInds); % number of units will be used for population decoding

[TrNum, unitNum, BinNum] = size(SMBinDataMtx);

TriggerAlignBin = ProbNPSess.TriggerStartBin{ProbNPSess.CurrentSessInds};
halfBaselineWinInds = round((TriggerAlignBin-1)/2);
BaselineResp_First = mean(SMBinDataMtx(:,:,1:halfBaselineWinInds),3);
BaselineResp_Last = mean(SMBinDataMtx(:,:,(halfBaselineWinInds+1):(TriggerAlignBin-1)),3);

%%

% BlockTypesAll
% BaselineResp_First/BaselineResp_Last
NMTrInds = behavResults.Action_choice(:) ~= 2;
DataInds = find(NMTrInds);

BlockSectionInfo = Bev2blockinfoFun(behavResults);
BlockTypesAll = double(behavResults.BlockType(:));

RevFreqs = BlockSectionInfo.BlockFreqTypes(logical(BlockSectionInfo.IsFreq_asReverse));
TrialFreqsAll = double(behavResults.Stim_toneFreq(:));
TrialAnmChoice = double(behavResults.Action_choice(:));
TrialAnmChoice(TrialAnmChoice == 2) = NaN;
IsRevFreqs = ismember(TrialFreqsAll,RevFreqs);
RevFreqInds = find(IsRevFreqs);
RevFreqChoices = TrialAnmChoice(RevFreqInds);

GrWithinIndsSet = seqpartitionFun(DataInds);

NumFolders = size(GrWithinIndsSet,1);
AllMds = cell(NumFolders,1);
FolderPerfs = zeros(NumFolders,2);
for cCVPartition = 1 : NumFolders
    cCV_asTest_inds = [GrWithinIndsSet{cCVPartition,1};GrWithinIndsSet{cCVPartition,2}];
    GrWithinIndsSetRest = GrWithinIndsSet;
    GrWithinIndsSetRest(cCVPartition,:) = [];
    cCV_Train_Inds = cell2mat(GrWithinIndsSetRest(:,1));
    cCV_ModelValid_Inds = cell2mat(GrWithinIndsSetRest(:,2));
    
    cmd = fitcsvm(BaselineResp_First(cCV_Train_Inds,:), BlockTypesAll(cCV_Train_Inds));
    md_ValidSet_pred = predict(cmd, BaselineResp_First(cCV_ModelValid_Inds,:));
    md_ValidSet_perf = mean(md_ValidSet_pred == BlockTypesAll(cCV_ModelValid_Inds));
    
    md_testSet_pred = predict(cmd, BaselineResp_First(cCV_asTest_inds,:));
    md_testSet_perf = mean(md_testSet_pred == BlockTypesAll(cCV_asTest_inds));
    
    FolderPerfs(cCVPartition,:) = [md_ValidSet_perf, md_testSet_perf];
    AllMds{cCVPartition} = cmd;
    
end

%%

[~, UsedMDInds] = min(FolderPerfs(:,2));
PredBlockTypes = predict(AllMds{UsedMDInds}, BaselineResp_Last);
AllTestDataInds = DataInds(cell2mat(GrWithinIndsSet(:,2)));

[TestDataPred_blockType, TestDataPred_TypeScores] = predict(AllMds{UsedMDInds}, BaselineResp_First(AllTestDataInds,:)); % Used the second score column 
TestDataReal_blockType = BlockTypesAll(AllTestDataInds);

TestData_choices = TrialAnmChoice(AllTestDataInds);
TestData_IsRevFreqs = IsRevFreqs(AllTestDataInds);

%%

NMRevfreqInds = ~isnan(RevFreqChoices);
NMRevFreqIndedx = RevFreqInds(NMRevfreqInds);
NMRevFreqChoice = RevFreqChoices(NMRevfreqInds);
NMRevFreqAllFreqs = TrialFreqsAll(NMRevFreqIndedx);
NMRevFreqBlockTypes = BlockTypesAll(NMRevFreqIndedx);

%%
NMRevFreq_PredType = PredBlockTypes(NMRevFreqIndedx);
hf = figure;
hold on
plot(1-smooth(NMRevFreqChoice,5),'k','linewidth',1.4);
plot(smooth(NMRevFreqBlockTypes,5),'m','linewidth',1.4);
plot(smooth(NMRevFreq_PredType,5),'b','linewidth',1.4);

%%
h2f = figure;
hold on
plot(1-smooth(TestData_choices(TestData_IsRevFreqs),5),'k','linewidth',1.4);
plot(smooth(TestDataReal_blockType(TestData_IsRevFreqs),5),'m','linewidth',1.4);
plot(smooth(TestDataPred_blockType(TestData_IsRevFreqs),5),'b','linewidth',1.4);

%%
TestRevFreq_Choice = TestData_choices(TestData_IsRevFreqs);
TestRevFreq_RealBT = TestDataReal_blockType(TestData_IsRevFreqs);
TestRevFreq_PredBT = TestDataPred_TypeScores(TestData_IsRevFreqs, 2);

LChoiceInds = find(TestRevFreq_Choice == 0);
RChoiceInds = find(TestRevFreq_Choice == 1);

h3f = figure;
hold on
plot(LChoiceInds, TestRevFreq_RealBT(LChoiceInds),'bo');
plot(RChoiceInds, TestRevFreq_RealBT(RChoiceInds),'ro');

plot(LChoiceInds, TestRevFreq_PredBT(LChoiceInds),'b*');
plot(RChoiceInds, TestRevFreq_PredBT(RChoiceInds),'r*');





