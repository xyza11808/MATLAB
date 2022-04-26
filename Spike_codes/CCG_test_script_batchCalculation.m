% test of the calculation of the CCG values

% SMBinDataMtx_pass = permute(cat(3,ProbNPSess.TrigData_Bin{ProbNPSess.CurrentSessInds}{:,1}),[1,3,2]);

%% extract spike time and calculate the firing rate and binned spike times
load(fullfile(ksfolder,'NPClassHandleSaved.mat'));
ProbNPSess.CurrentSessInds = strcmpi('task',ProbNPSess.SessTypeStrs);
SessSPTimes = ProbNPSess.TrTrigSpikeTimes{ProbNPSess.CurrentSessInds};

TrChoices = double(behavResults.Action_choice(:));
TrFreqTypes = double(behavResults.Stim_toneFreq(:));
TrBlockTypes = double(behavResults.BlockType(:));
NMTrInds = TrChoices ~= 2;
NMTrFreqs = TrFreqTypes(NMTrInds);
FreqTypes = unique(NMTrFreqs);
NMTrBTs = TrBlockTypes(NMTrInds);
BTTypes = unique(NMTrBTs);
TotalTypeNums = numel(FreqTypes) * numel(BTTypes);

UniqueTrTypeIndex = zeros(length(NMTrFreqs),1);
k = 1;
for cF = 1 : numel(FreqTypes)
    for cB = 1 : numel(BTTypes)
        ccTypeInds = NMTrFreqs == FreqTypes(cF) & NMTrBTs == BTTypes(cB);
        UniqueTrTypeIndex(ccTypeInds) = k;
        k = k + 1;
    end
end
TotalTrTypes = numel(FreqTypes) * numel(BTTypes);

SessSPTimesUsed = SessSPTimes(ProbNPSess.SurviveInds,NMTrInds);

[UnitNums, TrNums] = size(SessSPTimesUsed);
binTimeLen = 0.001;
TrialTimeScale = [-0.5,3.0]; %ProbNPSess.psthTimeWin{ProbNPSess.CurrentSessInds};
[binnedSPAll, SpikeCounts] = cellfun(@(x) Sptime2bins(x,binTimeLen,TrialTimeScale),...
    SessSPTimesUsed,'UniformOutput',false);
spFireRate = mean(cell2mat(SpikeCounts),2)/diff(TrialTimeScale);
BinnedSPMtx=cell2mat(cellfun(@(x)reshape(x,[1,1,numel(x)]),binnedSPAll,'un',0));
% BinnedSPMtx = cat(3,binnedSPAll{:,:});
%%
clearvars SessSPTimes ProbNPSess Sptime2bins binnedSPAll
% CalUnitInds = find(spFireRate >= 2); % only use unit firing rate larger than 2Hz
% NumCaledUnits = length(CalUnitInds);

%%
% find valid clusters within target areas
AreaIndexStrc = load(fullfile(ksfolder,'SessAreaIndexData.mat'));
AllFieldNames = fieldnames(AreaIndexStrc.SessAreaIndexStrc);
UsedNames = AllFieldNames(1:end-1);
ExistAreaNames = UsedNames(AreaIndexStrc.SessAreaIndexStrc.UsedAbbreviations);

if strcmpi(ExistAreaNames(end),'Others')
    ExistAreaNames(end) = [];
end

Numfieldnames = length(ExistAreaNames);
ExistField_ClusIDs = [];
for cA = 1 : Numfieldnames
    cA_Clus_IDs = AreaIndexStrc.SessAreaIndexStrc.(ExistAreaNames{cA}).MatchUnitRealIndex;
    cA_clus_inds = AreaIndexStrc.SessAreaIndexStrc.(ExistAreaNames{cA}).MatchedUnitInds;
    ExistField_ClusIDs = [ExistField_ClusIDs;[cA_Clus_IDs,cA_clus_inds]]; % real Clus_IDs and Clus indexing inds
end
CalUnitInds = ExistField_ClusIDs(:,2);
NumCaledUnits = length(CalUnitInds);
BinnedSPMtx = permute(BinnedSPMtx,[2,3,1]);
Caled_BinnedSPMtx = BinnedSPMtx(:,:,CalUnitInds);
clearvars BinnedSPMtx
Binned_JitterSPMtx = zeros(size(Caled_BinnedSPMtx));
JitterWindow = ceil(25/(binTimeLen*1000));
for cUsedUnit = 1 : NumCaledUnits
    cUnitData = Caled_BinnedSPMtx(:,:,cUsedUnit);
    Binned_JitterSPMtx(:,:,cUsedUnit) = CCG_jitterFun(cUnitData,JitterWindow);
end


%%
TauValueScale = [-500,500];
totalCalNumber = NumCaledUnits*(NumCaledUnits-1)/2;
cSess = 1;

TrialTime = diff(TrialTimeScale);
CombinedUnitInds = zeros(totalCalNumber,2);
t = tic;
f = waitbar(0,sprintf('Session %d, Calculation Start...',cSess));
k = 1;
for cUsedUnit = 1 : NumCaledUnits
    for cUnit = (cUsedUnit+1):NumCaledUnits
        CombinedUnitInds(k,:) = [cUsedUnit, cUnit];
        k = k + 1;
    end
end
%%
BatchSize = 40;
NumofBatches = ceil(totalCalNumber/BatchSize);
t1 = tic;
% AllPairedUnit_CCGs = cell(NumofBatches,3);
for cInds = 201 : NumofBatches % totalCalNumber
    cB_inds_start = (cInds-1) * BatchSize + 1;
    cB_inds_end = min(cInds * BatchSize, totalCalNumber);
    cB_caledInds = cB_inds_start:cB_inds_end;
    cInds_unitInds = CombinedUnitInds(cB_caledInds,:);
    unit1Inds = cInds_unitInds(:,1);
    unit2Inds = cInds_unitInds(:,2);
    
%     Data_2_cells_1 = (binnedSPAll(unit1Inds,:))';
%     Cell1Data_Mtx = cat(1,Data_2_cells_1{:});
%     Data_2_cells_2 = (binnedSPAll(unit2Inds,:))';
%     Cell2Data_Mtx = cat(1,Data_2_cells_2{:});
    Cell1Data_Mtx = permute(Caled_BinnedSPMtx(:,:,unit1Inds),[3,1,2]);
    Cell2Data_Mtx = permute(Caled_BinnedSPMtx(:,:,unit2Inds),[3,1,2]);
    Cell1JitterMtx = permute(Binned_JitterSPMtx(:,:,unit1Inds),[3,1,2]);
    Cell2JitterMtx = permute(Binned_JitterSPMtx(:,:,unit2Inds),[3,1,2]);
    
    Cell1FR = spFireRate(unit1Inds);
    Cell2FR = spFireRate(unit2Inds);
    %
    TauValuesAll = TauValueScale(1):TauValueScale(2);
    NumTauValues = length(TauValuesAll);

    TauCCGs = zeros(NumTauValues,BatchSize,TotalTrTypes);
    jitterAllCCGs = zeros(NumTauValues,BatchSize,TotalTrTypes);
    %
    tic
    parfor cTau = 1 : NumTauValues
        %
        cTauValue = TauValuesAll(cTau);
        TauCCGs(cTau,:,:) = CCG_cal_fun(Cell1Data_Mtx, Cell2Data_Mtx,cTauValue,Cell1FR,Cell2FR,UniqueTrTypeIndex);
        
%         Cell1_DataJitter = CCG_jitterFun(Cell1Data_Mtx,25);
%         Cell2_DataJitter = CCG_jitterFun(Cell2Data_Mtx,25);
        
        jitterAllCCGs(cTau,:,:) = CCG_cal_fun(Cell1JitterMtx, Cell2JitterMtx,cTauValue,Cell1FR,Cell2FR,UniqueTrTypeIndex);
        %
    end
    toc;
    %
    AllPairedUnit_CCGs(cInds, :) = {[unit1Inds,unit2Inds], TauCCGs, jitterAllCCGs};

        Progress = cInds/NumofBatches;
        waitbar(Progress,f,sprintf('Session %d, Processing %.2f%% of all calculation...',cSess, Progress*100));

end


disp(toc(t1));
% waitbar(1,f,'Calculation complete!');
% pause(1);
% close(f);
%%
% figure('position',[2000, 200 1300 480]);
% subplot(121)
% hold on
% plot(TauValuesAll,TauCCGs, 'k-o')
% JitterAllAvg = mean(cell2mat(jitterAllCCGs));
% plot(TauValuesAll,JitterAllAvg,'r--o');
%
% subplot(122)
% plot(TauValuesAll,TauCCGs' -JitterAllAvg ,'k-o')

% unit1jitterCCG_Cell = cellfun(@mean,Unit1AllpairedCCGs(:,2),'UniformOutput',false);
% Unit_jitterCorrect_cell = cellfun(@(x,y) (x'-y),Unit1AllpairedCCGs(:,1),unit1jitterCCG_Cell,'UniformOutput',false);
% unit1CCG_mtx = cell2mat(Unit_jitterCorrect_cell);




