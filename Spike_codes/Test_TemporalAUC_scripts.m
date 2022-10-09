% cclr
% ksfolder = pwd;
% ksfolder = strrep(cSessFolder,'F:\','E:\NPCCGs\');
clearvars ProbNPSess AllUnit_temporalAUC ExistField_ClusIDs AllUnit_temporalAUC AccumedUnitNums
% if exist(fullfile(ksfolder,'AnovanAnA','TemporalAUCdataSave.mat'),'file')
%     return;
% end
load(fullfile(ksfolder,'NPClassHandleSaved.mat'));

ProbNPSess.CurrentSessInds = strcmpi('Task',ProbNPSess.SessTypeStrs);

% transfromed into trial-by-units-by-bin matrix
SMBinDataMtx = permute(cat(3,ProbNPSess.TrigData_Bin{ProbNPSess.CurrentSessInds}{:,1}),[1,3,2]); 
if ~isempty(ProbNPSess.SurviveInds)
    SMBinDataMtx = SMBinDataMtx(:,ProbNPSess.SurviveInds,:);
end
SMBinDataMtxRaw = SMBinDataMtx;

AreaIndexStrc = load(fullfile(ksfolder,'SessAreaIndexDataAligned.mat'));
AllFieldNames = fieldnames(AreaIndexStrc.SessAreaIndexStrc);
UsedNames = AllFieldNames(1:end-1);
ExistAreaNames = UsedNames(AreaIndexStrc.SessAreaIndexStrc.UsedAbbreviations);

if strcmpi(ExistAreaNames(end),'Others')
    ExistAreaNames(end) = [];
end
ExistAreaNamesAll = ExistAreaNames;
%%
Numfieldnames = length(ExistAreaNames);
ExistField_ClusIDs = [];
AreaUnitNumbers = zeros(Numfieldnames,1);
for cA = 1 : Numfieldnames
    cA_Clus_IDs = AreaIndexStrc.SessAreaIndexStrc.(ExistAreaNames{cA}).MatchUnitRealIndex;
    cA_clus_inds = AreaIndexStrc.SessAreaIndexStrc.(ExistAreaNames{cA}).MatchedUnitInds;
    ExistField_ClusIDs = [ExistField_ClusIDs;[cA_Clus_IDs,cA_clus_inds]]; % real Clus_IDs and Clus indexing inds
    AreaUnitNumbers(cA) = numel(cA_clus_inds);
end
AccumedUnitNums = [1;cumsum(AreaUnitNumbers)];

%%
SeqAreaUnitNums = AreaUnitNumbers;
AccumedUnitNums = [0;cumsum(AreaUnitNumbers)];
SeqAreaNames = ExistAreaNames;
SeqFieldClusIDs = ExistField_ClusIDs;

%%
if isempty(ExistField_ClusIDs)
    fprintf('No target region units within current session.\n');
    return;
end
CalUnitInds = ExistField_ClusIDs(:,2);
NumCaledUnits = length(CalUnitInds);

SPTimeBinSize = ProbNPSess.USedbin;
StimOnsetBin = ProbNPSess.TriggerStartBin{ProbNPSess.CurrentSessInds};

SMBinDataMtxUsed = SMBinDataMtx(:,CalUnitInds,:);
BlockSectionInfo = Bev2blockinfoFun(behavResults);  
RevFreqs = BlockSectionInfo.BlockFreqTypes(logical(BlockSectionInfo.IsFreq_asReverse));

%%

ActionChoices = double(behavResults.Action_choice(:));
TrNMInds = ActionChoices ~= 2;

TrFreqs = double(behavResults.Stim_toneFreq(:));
TrBlockTypes = double(behavResults.BlockType(:));
TrAnsTimes = double(behavResults.Time_answer(:));
TrStimOnsets = double(behavResults.Time_stimOnset(:));
TrAnsAfterStimOnsetTime = TrAnsTimes - TrStimOnsets;
% adding other behavior model fitting results latter

NMTrChoices = ActionChoices(TrNMInds);
NMTrFreqs =TrFreqs(TrNMInds);
NMTrBlockTypes = TrBlockTypes(TrNMInds);
NMAnsTimeAFOnset = TrAnsAfterStimOnsetTime(TrNMInds);

RevFreqTrInds = double(ismember(NMTrFreqs, RevFreqs));

% clearvars ProbNPSess SMBinDataMtx
%% processing binned datas
t1 = tic;
DataBinTimeWin = 0.05; %seconds
winGoesStep = 0.01; %seconds, moving steps, partially overlapped windows 
calDataBinSize = DataBinTimeWin/SPTimeBinSize(2);
calDataStepBin = winGoesStep/SPTimeBinSize(2);
OverAllUsedTime = 5; % seconds, used time length for each trial, this time including prestim periods
TotalCalcuNumber = (OverAllUsedTime/SPTimeBinSize(2))/calDataStepBin - (calDataBinSize - calDataStepBin);
CaledStartBin = ceil(calDataBinSize/2);
CaledStimOnsetBin = StimOnsetBin - CaledStartBin + 1;
SmoothWin = hann(calDataBinSize*2+1);
SmoothWin = SmoothWin/sum(SmoothWin);

TotalUnitNumbers = (((1:TotalCalcuNumber)-CaledStimOnsetBin) * winGoesStep)';
AllUnit_temporalAUC = cell(TotalCalcuNumber, NumCaledUnits, 2);
%%
parfor cCalWin = 1 : TotalCalcuNumber
    cCal_startInds = (cCalWin -1)*calDataStepBin + 1;
    cCal_endInds = cCal_startInds + calDataBinSize - 1;
    UsedDataWin = cCal_startInds:cCal_endInds;
    UnitRespData = mean(SMBinDataMtxUsed(TrNMInds,:,UsedDataWin),3);
    
    TemporalAUC = cell(NumCaledUnits, 2);
    for cU = 1 : NumCaledUnits
        cU_data = (UnitRespData(:,cU));
        Datas = zeros(3,1);
        
        [cAUC_1, cIsMeanRev_1] = AUC_fast_utest(cU_data, NMTrBlockTypes);
        [~,~,AUCthresValue_1] = ROCSiglevelGeneNew([cU_data, NMTrBlockTypes],500,0,0.01);
        
        [cAUC_2, cIsMeanRev_2] = AUC_fast_utest(cU_data, NMTrChoices);
        [~,~,AUCthresValue_2] = ROCSiglevelGeneNew([cU_data, NMTrChoices],500,0,0.01);
        
        TemporalAUC(cU,:) = {[cAUC_1, cIsMeanRev_1,AUCthresValue_1],...
            [cAUC_2, cIsMeanRev_2, AUCthresValue_2]};
        
    end
    AllUnit_temporalAUC(cCalWin,:,:) = TemporalAUC;
end

disp(toc(t1));

%%
dataSaveNames = fullfile(ksfolder,'AnovanAnA','TemporalAUCdataSave.mat');
save(dataSaveNames,'SeqAreaUnitNums','AccumedUnitNums','SeqFieldClusIDs','CaledStimOnsetBin',...
    'winGoesStep','TotalCalcuNumber','AllUnit_temporalAUC','SeqAreaNames','-v7.3');




