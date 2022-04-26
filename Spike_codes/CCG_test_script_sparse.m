% test of the calculation of the CCG values

% SMBinDataMtx_pass = permute(cat(3,ProbNPSess.TrigData_Bin{ProbNPSess.CurrentSessInds}{:,1}),[1,3,2]);
clearvars AllPairedUnit_CCGs CombinedUnitInds 
NewSaveFolderPos = strrep(ksfolder,'F:\','E:\NPCCGs\');
if ~isfolder(NewSaveFolderPos)
    mkdir(NewSaveFolderPos);
end

savename = fullfile(NewSaveFolderPos,'PairedUnitCCGs.mat');
% if exist(savename,'file')
%     fprintf('Session %d already processed...\n',cfff);
%     return;
% end

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
binSize = 0.001;
TrialTimeScale = [-1.0,3.0]; %ProbNPSess.psthTimeWin{ProbNPSess.CurrentSessInds};
[binnedSPAll, SpikeCounts] = cellfun(@(x) Sptime2bins(x,binSize,TrialTimeScale),...
    SessSPTimesUsed,'UniformOutput',false);
spFireRate = mean(cell2mat(SpikeCounts),2)/diff(TrialTimeScale);
BinnedSPMtx = cell2mat(cellfun(@(x)reshape(x,[1,1,numel(x)]),binnedSPAll,'un',0));
BinnedSPMtx_cell = mat2cell(BinnedSPMtx,ones(size(BinnedSPMtx,1),1),size(BinnedSPMtx,2),size(BinnedSPMtx,3));
BinnedSPMtx_sCell = cellfun(@(x) sparse(squeeze(x)),BinnedSPMtx_cell,'un',0);
JitterWindow = 25/(binSize*1000);
JitterSPMtx_sCell = cellfun(@(x) CCG_jitterFun(x,JitterWindow),BinnedSPMtx_sCell,'un',0);
JitterSPMtx_sCell2 = cellfun(@(x) CCG_jitterFun(x,JitterWindow),JitterSPMtx_sCell,'un',0);
JitterSPMtx_sCell3 = cellfun(@(x) CCG_jitterFun(x,JitterWindow),JitterSPMtx_sCell2,'un',0);
% BinnedSPMtx = cat(3,binnedSPAll{:,:});
%%
clearvars SessSPTimes ProbNPSess Sptime2bins binnedSPAll BinnedSPMtx_cell BinnedSPMtx JitterSPMtx_sCell2
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
if isempty(ExistField_ClusIDs)
    fprintf('No target region units within current session.\n');
    return;
end
CalUnitInds = ExistField_ClusIDs(:,2);
NumCaledUnits = length(CalUnitInds);

%%
TauValueScale = [-800,800];
totalCalNumber = NumCaledUnits*((NumCaledUnits-1)/2+1);
cSess = cfff;

TrialTime = diff(TrialTimeScale);
CombinedUnitInds = zeros(totalCalNumber,2);
t = tic;
f = waitbar(0,sprintf('Session %d, Calculation Start...',cSess));
k = 1;
for cUsedUnit = 1 : NumCaledUnits
    for cUnit = (cUsedUnit):NumCaledUnits
        CombinedUnitInds(k,:) = [cUsedUnit, cUnit];
        k = k + 1;
    end
end
%%
p = gcp('nocreate'); % If no pool, do not create new one.
if isempty(p)
    parpool('local',6); 
end

%%
BatchSize = 300;
NumofBatches = ceil(totalCalNumber/BatchSize);
AllPairedUnit_CCGs = cell(NumofBatches,3);
t1 = tic;
for cInds = 1 : NumofBatches % totalCalNumber
    cB_inds_start = (cInds-1) * BatchSize + 1;
    cB_inds_end = min(cInds * BatchSize, totalCalNumber);
    cB_caledInds = cB_inds_start:cB_inds_end;
    cInds_unitInds = CombinedUnitInds(cB_caledInds,:);
    unit1Inds = CalUnitInds(cInds_unitInds(:,1));
    unit2Inds = CalUnitInds(cInds_unitInds(:,2));
    
%     Data_2_cells_1 = (binnedSPAll(unit1Inds,:))';
%     Cell1Data_Mtx = cat(1,Data_2_cells_1{:});
%     Data_2_cells_2 = (binnedSPAll(unit2Inds,:))';
%     Cell2Data_Mtx = cat(1,Data_2_cells_2{:});
    NumBatchUnit = numel(unit1Inds);
    Cell1Data_SparseCell = BinnedSPMtx_sCell(unit1Inds);  %cell(NumBatchUnit,1);
    Cell2Data_SparseCell = BinnedSPMtx_sCell(unit2Inds);  %cell(NumBatchUnit,1);
    
    Cell1DataJitterData = JitterSPMtx_sCell(unit1Inds);
    Cell2DataJitterData = JitterSPMtx_sCell3(unit2Inds);
    
%     for cU = 1 : NumBatchUnit
%         Cell1Data_SparseCell{cU} = sparse(squeeze(BinnedSPMtx(unit1Inds(cU),:,:)));
%         Cell2Data_SparseCell{cU} = sparse(squeeze(BinnedSPMtx(unit2Inds(cU),:,:)));
%     end
    
    Cell1FR = spFireRate(unit1Inds);
    Cell2FR = spFireRate(unit2Inds);
    %
    TauValuesAll = TauValueScale(1):TauValueScale(2);
    NumTauValues = length(TauValuesAll);

    TauCCGs = zeros(NumTauValues,NumBatchUnit,TotalTrTypes);
    jitterAllCCGs = zeros(NumTauValues,NumBatchUnit,TotalTrTypes);
    %
    parfor cTau = 1 : NumTauValues
        cTauValue = TauValuesAll(cTau);
        for cBU = 1 : NumBatchUnit
            Cell1Data_Mtx = Cell1Data_SparseCell{cBU};
            Cell2Data_Mtx = Cell2Data_SparseCell{cBU};
            TauCCGs(cTau,cBU,:) = CCG_cal_fun(Cell1Data_Mtx, Cell2Data_Mtx,cTauValue,Cell1FR(cBU),...
                Cell2FR(cBU),UniqueTrTypeIndex);

            Cell1_DataJitter = Cell1DataJitterData{cBU};
            Cell2_DataJitter = Cell2DataJitterData{cBU};

            jitterAllCCGs(cTau,cBU,:) = CCG_cal_fun(Cell1_DataJitter, Cell2_DataJitter,cTauValue,...
                Cell1FR(cBU),Cell2FR(cBU),UniqueTrTypeIndex);
        end
    end
    %
    clearvars Cell1Data_SparseCell Cell2Data_SparseCell Cell1DataJitterData Cell2DataJitterData
    %
    AllPairedUnit_CCGs(cInds, :) = {[unit1Inds,unit2Inds], TauCCGs, jitterAllCCGs};
%     if mod(k,10) == 0
        Progress = cInds/NumofBatches;
        waitbar(Progress,f,sprintf('Session %d, Processing %.2f%% of all calculation...',cSess, Progress*100));
%     end
end


disp(toc(t1));
waitbar(1,f,'Calculation complete!');
pause(1);
close(f);


save(savename,'AllPairedUnit_CCGs', 'ExistField_ClusIDs', 'CombinedUnitInds', 'TauValuesAll','-v7.3');


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




