
clearvars ProbNPSess UnitUsedCoefs UnitFitmds_All
load(fullfile(cSessFolder,'NPClassHandleSaved.mat'));

%%

ProbNPSess.CurrentSessInds = strcmpi('Task',ProbNPSess.SessTypeStrs);
% TimeWin = [-1.5,8]; % time window used to calculate the psth, usually includes before and after trigger time, in seconds
% Smoothbin = [50,10]; %
% ProbNPSess = ProbNPSess.TrigPSTH(TimeWin, Smoothbin, double(behavResults.Time_stimOnset(:)));
% save(fullfile(pwd,'ks2_5','NPClassHandleSaved.mat'),'ProbNPSess', 'PassSoundDatas', 'behavResults', '-v7.3');

SMBinDataMtx = permute(cat(3,ProbNPSess.TrigData_Bin{ProbNPSess.CurrentSessInds}{:,1}),[1,3,2]); % transfromed into trial-by-units-by-bin matrix
ExcludedInds = (behavResults.Action_choice(:) == 2);
SMBinDataMtxRaw = SMBinDataMtx;
if ~isempty(ProbNPSess.SurviveInds)
    SMBinDataMtx = SMBinDataMtx(:,ProbNPSess.SurviveInds,:);
end
SMBinDataMtx = SMBinDataMtx(~ExcludedInds,:,:);
[TrNum, unitNum, BinNum] = size(SMBinDataMtx);

%%

BlockSectionInfo = Bev2blockinfoFun(behavResults);
RevFreqs = BlockSectionInfo.BlockFreqTypes(logical(BlockSectionInfo.IsFreq_asReverse));
TrialFreqsAll = double(behavResults.Stim_toneFreq(:));
TrialAnmChoice = double(behavResults.Action_choice(:));
TrialAnmChoice(TrialAnmChoice == 2) = NaN;
RevFreqInds = find(ismember(TrialFreqsAll,RevFreqs));
RevFreqChoices = TrialAnmChoice(RevFreqInds);
NMRevfreqInds = ~isnan(RevFreqChoices);
NMRevFreqIndedx = RevFreqInds(NMRevfreqInds);
NMRevFreqChoice = RevFreqChoices(NMRevfreqInds);

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

% load(fullfile(cSessFolder,'BaselinePredofBlocktype','SingleUnitAUC.mat'));

%%

figure;
hold on
yyaxis left
plot(smoothed_baseline_resp(:,31),'Color','b','linewidth',1.2)
BlockSectionInfo = Bev2blockinfoFun(behavResults);
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
ylabel('Baseline FR');

yyaxis right
plot(NMRevFreqIndedx,1-smooth(NMRevFreqChoice,7),'Color',[0.9 0.6 0.2],'linewidth',1.5);
ylabel('RevFreq choice');

set(gca,'xlim',[0 size(smoothed_baseline_resp,1)]);
xlabel('# Trials');




