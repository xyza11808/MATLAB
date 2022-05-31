% cclr
% ksfolder = pwd;
ksfolder = strrep(cSessFolder,'F:\','E:\NPCCGs\');
clearvars ProbNPSess AllUnit_temporalAUC ExistField_ClusIDs AllUnit_temporalAUC AccumedUnitNums
% if exist(fullfile(ksfolder,'AnovanAnA','TemporalAUCdataSave.mat'),'file')
%     return;
% end

AreaIndexStrc = load(fullfile(ksfolder,'SessAreaIndexData.mat'));
AllFieldNames = fieldnames(AreaIndexStrc.SessAreaIndexStrc);
UsedNames = AllFieldNames(1:end-1);
ExistAreaNames = UsedNames(AreaIndexStrc.SessAreaIndexStrc.UsedAbbreviations);
if any(strcmpi(ExistAreaNames,'MOs'))
   MosAreaInds = find(strcmpi(ExistAreaNames,'MOs'));
   CompExistAreaNames = ExistAreaNames;
   CompExistAreaNames{MosAreaInds} = 'MOs';
end
if strcmpi(ExistAreaNames(end),'Others')
    ExistAreaNames(end) = [];
end
NumExistAreas = length(ExistAreaNames);

NewSessAreaStrc = load(fullfile(ksfolder,'SessAreaIndexDataNew.mat'));
NewAdd_AllfieldNames = fieldnames(NewSessAreaStrc.SessAreaIndexStrc);
NewAdd_ExistAreasInds = find(NewSessAreaStrc.SessAreaIndexStrc.UsedAbbreviations);
NewAdd_ExistAreaNames = NewAdd_AllfieldNames(NewAdd_ExistAreasInds);
if strcmpi(NewAdd_ExistAreaNames(end),'Others')
    NewAdd_ExistAreaNames(end) = [];
end
NewAdd_NumExistAreas = length(NewAdd_ExistAreaNames);

%%
if NewAdd_NumExistAreas > NumExistAreas
    % new area exists
    OldSessExistInds = ismember(NewAdd_ExistAreaNames, CompExistAreaNames);
    NewAddAreaNames = NewAdd_ExistAreaNames(~OldSessExistInds);
    Num_newAddAreaNums = length(NewAddAreaNames);
else
    return;
end
ExistAreaNamesAll = [ExistAreaNames;NewAddAreaNames];

%%

load(fullfile(ksfolder,'NPClassHandleSaved.mat'));
% 
ProbNPSess.CurrentSessInds = strcmpi('Task',ProbNPSess.SessTypeStrs);

% transfromed into trial-by-units-by-bin matrix
SMBinDataMtx = permute(cat(3,ProbNPSess.TrigData_Bin{ProbNPSess.CurrentSessInds}{:,1}),[1,3,2]); 
if ~isempty(ProbNPSess.SurviveInds)
    SMBinDataMtx = SMBinDataMtx(:,ProbNPSess.SurviveInds,:);
end
SMBinDataMtxRaw = SMBinDataMtx;


%%
% old session unit numbers
ONumfieldnames = length(ExistAreaNames);
OExistField_ClusIDs = [];
OAreaUnitNumbers = zeros(ONumfieldnames,1);
for cA = 1 : ONumfieldnames
    cA_Clus_IDs = AreaIndexStrc.SessAreaIndexStrc.(ExistAreaNames{cA}).MatchUnitRealIndex;
    cA_clus_inds = AreaIndexStrc.SessAreaIndexStrc.(ExistAreaNames{cA}).MatchedUnitInds;
    OExistField_ClusIDs = [OExistField_ClusIDs;[cA_Clus_IDs,cA_clus_inds]]; % real Clus_IDs and Clus indexing inds
    OAreaUnitNumbers(cA) = numel(cA_clus_inds);
end
%% 
dataSaveNames = fullfile(ksfolder,'AnovanAnA','TemporalAUCdataSave.mat');
oldData = load(dataSaveNames);

OldSavedUnitNums = sum(OAreaUnitNumbers)+1;
%%
oldData.AllUnit_temporalAUC(:,OldSavedUnitNums:end,:) = [];

%%
Numfieldnames = length(NewAddAreaNames);
ExistField_ClusIDs = [];
AreaUnitNumbers = zeros(Numfieldnames,1);
for cA = 1 : Numfieldnames
    cA_Clus_IDs = NewSessAreaStrc.SessAreaIndexStrc.(NewAddAreaNames{cA}).MatchUnitRealIndex;
    cA_clus_inds = NewSessAreaStrc.SessAreaIndexStrc.(NewAddAreaNames{cA}).MatchedUnitInds;
    ExistField_ClusIDs = [ExistField_ClusIDs;[cA_Clus_IDs,cA_clus_inds]]; % real Clus_IDs and Clus indexing inds
    AreaUnitNumbers(cA) = numel(cA_clus_inds);
end
% AccumedUnitNums = [1;cumsum(AreaUnitNumbers)];


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

clearvars ProbNPSess SMBinDataMtx
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

%% merge datas together
% AreaUnitNumbers = [oldData.AreaUnitNumbers;AreaUnitNumbers];
% AccumedUnitNums = cumsum([1;AreaUnitNumbers]);
AllUnit_temporalAUC = cat(2,oldData.AllUnit_temporalAUC,AllUnit_temporalAUC);
% ExistField_ClusIDs = [oldData.ExistField_ClusIDs;ExistField_ClusIDs];

AreaUnitNumbers = [OAreaUnitNumbers;AreaUnitNumbers];
AccumedUnitNums = cumsum([1;AreaUnitNumbers]);
ExistField_ClusIDs = [OExistField_ClusIDs;ExistField_ClusIDs];

%%

save(dataSaveNames,'AreaUnitNumbers','AccumedUnitNums','ExistField_ClusIDs','CaledStimOnsetBin',...
    'winGoesStep','TotalCalcuNumber','AllUnit_temporalAUC','-v7.3');




