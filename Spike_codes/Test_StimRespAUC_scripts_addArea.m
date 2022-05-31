% cclr
% ksfolder = pwd;
ksfolder = strrep(cSessFolder,'F:\','E:\NPCCGs\');
clearvars ProbNPSess StimRespAUC ExistField_ClusIDs
% if exist(fullfile(ksfolder,'AnovanAnA','TemporalAUCdataSave.mat'),'file')
%     return;
% end
dataSaveNames = fullfile(ksfolder,'AnovanAnA','StimrespAUCdataSave.mat');
% if exist(dataSaveNames,'file')
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
%%
AreaIndexStrc = load(fullfile(ksfolder,'SessAreaIndexData.mat'));
AllFieldNames = fieldnames(AreaIndexStrc.SessAreaIndexStrc);
UsedNames = AllFieldNames(1:end-1);
ExistAreaNames = UsedNames(AreaIndexStrc.SessAreaIndexStrc.UsedAbbreviations);

if strcmpi(ExistAreaNames(end),'Others')
    ExistAreaNames(end) = [];
end
CompExistAreaNames = ExistAreaNames;
if any(strcmpi(ExistAreaNames,'MOs'))
   MosAreaInds = find(strcmpi(ExistAreaNames,'MOs'));
   CompExistAreaNames{MosAreaInds} = 'MOs';
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
    NewAddAreaNames = [];
    Num_newAddAreaNums = 0;
end
%%
Numfieldnames = length(ExistAreaNames);
oExistField_ClusIDs = [];
oAreaUnitNumbers = zeros(Numfieldnames,1);
for cA = 1 : Numfieldnames
    cA_Clus_IDs = AreaIndexStrc.SessAreaIndexStrc.(ExistAreaNames{cA}).MatchUnitRealIndex;
    cA_clus_inds = AreaIndexStrc.SessAreaIndexStrc.(ExistAreaNames{cA}).MatchedUnitInds;
    oExistField_ClusIDs = [oExistField_ClusIDs;[cA_Clus_IDs,cA_clus_inds]]; % real Clus_IDs and Clus indexing inds
    oAreaUnitNumbers(cA) = numel(cA_clus_inds);
end

% calculate extra area units numbers
AddFieldNames = length(NewAddAreaNames);
AddField_ClusIDs = [];
AddAreaUnitNumbers = zeros(AddFieldNames,1);
for ccA = 1 : AddFieldNames
   cA_Clus_IDs = NewSessAreaStrc.SessAreaIndexStrc.(NewAddAreaNames{ccA}).MatchUnitRealIndex;
   cA_clus_inds = NewSessAreaStrc.SessAreaIndexStrc.(NewAddAreaNames{ccA}).MatchedUnitInds;
   AddField_ClusIDs = [AddField_ClusIDs;[cA_Clus_IDs,cA_clus_inds]]; % real Clus_IDs and Clus indexing inds
   AddAreaUnitNumbers(ccA) = numel(cA_clus_inds);
end 
    

%%
SeqAreaUnitNums = [oAreaUnitNumbers;AddAreaUnitNumbers];
AccumedUnitNums = [0;cumsum([oAreaUnitNumbers;AddAreaUnitNumbers])];
SeqAreaNames = [ExistAreaNames;NewAddAreaNames];
SeqFieldClusIDs = [oExistField_ClusIDs;AddField_ClusIDs];

%%
if isempty(AddField_ClusIDs)
    fprintf('No target region units within current session.\n');
    return;
end
CalUnitInds = AddField_ClusIDs(:,2);
NumCaledUnits = length(CalUnitInds);

SPTimeBinSize = ProbNPSess.USedbin;
StimOnsetBin = ProbNPSess.TriggerStartBin{ProbNPSess.CurrentSessInds};

SMBinDataMtxUsed = SMBinDataMtx(:,CalUnitInds,:);
BlockSectionInfo = Bev2blockinfoFun(behavResults);  
RevFreqs = BlockSectionInfo.BlockFreqTypes(logical(BlockSectionInfo.IsFreq_asReverse));

BaselineRespDatas = mean(SMBinDataMtxUsed(:,:,1:StimOnsetBin-1),3);

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

freqTypes = unique(NMTrFreqs);
NumFreqs = length(freqTypes);
FreqIndsAll = cell(NumFreqs,2); % control block types as baseline is different at different blocktypes
for cf = 1 : NumFreqs
    FreqIndsAll{cf,1} = NMTrFreqs == freqTypes(cf) & NMTrBlockTypes == 0;
    FreqIndsAll{cf,2} = NMTrFreqs == freqTypes(cf) & NMTrBlockTypes == 1;
end

RevFreqTrInds = double(ismember(NMTrFreqs, RevFreqs));

clearvars ProbNPSess SMBinDataMtx
%% processing binned datas
t1 = tic;
StimRespWin = 0.5; % seconds after stimlulus onset
StimRespWin2Bin = round(StimRespWin/SPTimeBinSize(2));
%
 
    UnitRespData = mean(SMBinDataMtxUsed(TrNMInds,:,StimOnsetBin:(StimOnsetBin+StimRespWin2Bin)),3);
    
    StimRespAUC = cell(NumCaledUnits, 1);
    parfor cU = 1 : NumCaledUnits
        cU_data = (UnitRespData(:,cU));
        cU_baselineData = BaselineRespDatas(:,cU);
        
        cFreqAUC_thres = zeros(NumFreqs,6);
        for cf = 1 : NumFreqs
            cfLabels_1 = FreqIndsAll{cf,1};
            NumLabels = sum(cfLabels_1);
            cf_calData = cU_data(cfLabels_1);
            cf_baseData = cU_baselineData(cfLabels_1);
            CalDataAll = [cf_calData;cf_baseData];
            CalDataLabels = [ones(NumLabels,1);zeros(NumLabels,1)];
            
            [cAUC_1, cIsMeanRev_1] = AUC_fast_utest(CalDataAll, CalDataLabels);
            [~,~,AUCthresValue_1] = ROCSiglevelGeneNew([CalDataAll, CalDataLabels],500,0,0.01);
            
            % second block types
            cfLabels_2 = FreqIndsAll{cf,2};
            NumLabels2 = sum(cfLabels_2);
            cf_calData2 = cU_data(cfLabels_2);
            cf_baseData2 = cU_baselineData(cfLabels_2);
            CalDataAll2 = [cf_calData2;cf_baseData2];
            CalDataLabels2 = [ones(NumLabels2,1);zeros(NumLabels2,1)];
            
            [cAUC_2, cIsMeanRev_2] = AUC_fast_utest(CalDataAll2, CalDataLabels2);
            [~,~,AUCthresValue_2] = ROCSiglevelGeneNew([CalDataAll2, CalDataLabels2],500,0,0.01);
            
            cFreqAUC_thres(cf,:) = [cAUC_1, cIsMeanRev_1,AUCthresValue_1,cAUC_2, cIsMeanRev_2,AUCthresValue_2];
        end
        StimRespAUC(cU,:) = {cFreqAUC_thres};
        
    end


disp(toc(t1));

%% load old data
OldDatas = load(dataSaveNames,'StimRespAUC');
StimRespAUC = [OldDatas.StimRespAUC;StimRespAUC];
AreaUnitNumbers = SeqAreaUnitNums;
% AccumedUnitNums = AccumedUnitNums;
ExistField_ClusIDs = SeqFieldClusIDs;
%%
save(dataSaveNames,'AreaUnitNumbers','AccumedUnitNums','ExistField_ClusIDs','StimRespAUC','-v7.3');

%%
% close;
% cU = 128;
% unit1TempAUC = AllUnit_temporalAUC(:,cU);
% unit1AllStimAUCs = cellfun(@(x) (mean(x(:,[1,4]),2))',unit1TempAUC,'un',0);
% unit1AllStimAUCmtx = cell2mat(unit1AllStimAUCs);
% unit1AllStimAUCsThres = cellfun(@(x) (mean(x(:,[3,6]),2))',unit1TempAUC,'un',0);
% unit1AllStimAUCThresmtx = cell2mat(unit1AllStimAUCsThres);
% 
% % SMMaxTraces = conv(max(unit1AllStimAUCmtx,[],2),SmoothWin,'same');
% 
% figure;
% hold on
% plot(CalWinTimes,mean(unit1AllStimAUCmtx,2),'m')
% % plot(CalWinTimes,SMMaxTraces,'c')
% plot(CalWinTimes,mean(unit1AllStimAUCThresmtx,2),'k')
% % plot(unit1AllStimAUCmtx,'m')


