% test of the calculation of the CCG values

SMBinDataMtx_pass = permute(cat(3,ProbNPSess.TrigData_Bin{ProbNPSess.CurrentSessInds}{:,1}),[1,3,2]);

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

SessSPTimesUsed = SessSPTimes(ProbNPSess.SurviveInds,NMTrInds);

[UnitNums, TrNums] = size(SessSPTimesUsed);

TrialTimeScale = [-1.0,3.0]; %ProbNPSess.psthTimeWin{ProbNPSess.CurrentSessInds};
[binnedSPAll, SpikeCounts] = cellfun(@(x) Sptime2bins(x,0.001,TrialTimeScale),...
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

%%
TauValueScale = [-500,500];
totalCalNumber = NumCaledUnits*(NumCaledUnits-1)/2;
cSess = 1;
AllPairedUnit_CCGs = cell(totalCalNumber,3);
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
parfor cInds = 1 : totalCalNumber
    
    cInds_unitInds = CombinedUnitInds(cInds,:);
    unit1Inds = CalUnitInds(cInds_unitInds(:,1));
    unit2Inds = CalUnitInds(cInds_unitInds(:,2));
    
%     Data_2_cells_1 = (binnedSPAll(unit1Inds,:))';
%     Cell1Data_Mtx = cat(1,Data_2_cells_1{:});
%     Data_2_cells_2 = (binnedSPAll(unit2Inds,:))';
%     Cell2Data_Mtx = cat(1,Data_2_cells_2{:});
    Cell1Data_Mtx = squeeze(BinnedSPMtx(unit1Inds,:,:));
    Cell2Data_Mtx = squeeze(BinnedSPMtx(unit2Inds,:,:));
    
    Cell1FR = spFireRate(unit1Inds);
    Cell2FR = spFireRate(unit2Inds);
    %
    TauValuesAll = TauValueScale(1):TauValueScale(2);
    NumTauValues = length(TauValuesAll);

    TauCCGs = zeros(NumTauValues,1);
    jitterAllCCGs = zeros(NumTauValues,1);
    
    for cTau = 1 : NumTauValues
        cTauValue = TauValuesAll(cTau);
        TauCCGs(cTau) = mean(CCG_cal_fun(Cell1Data_Mtx, Cell2Data_Mtx,cTauValue,Cell1FR,Cell2FR,UniqueTrTypeIndex));
        
        Cell1_DataJitter = CCG_jitterFun(Cell1Data_Mtx,25);
        Cell2_DataJitter = CCG_jitterFun(Cell2Data_Mtx,25);
        
        jitterAllCCGs(cTau) = mean(CCG_cal_fun(Cell1_DataJitter, Cell2_DataJitter,cTauValue,Cell1FR,Cell2FR,UniqueTrTypeIndex));
        
    end
    
    %
    AllPairedUnit_CCGs(cInds, :) = {[unit1Inds,unit2Inds], TauCCGs, jitterAllCCGs};
    if mod(k,10) == 0
        Progress = cInds/totalCalNumber;
        waitbar(Progress,f,sprintf('Session %d, Processing %.2f of all calculation...',cSess, Progress));
    end
end


disp(toc(t));
waitbar(1,f,'Calculation complete!');
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




