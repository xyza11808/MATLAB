% cclr
% ksfolder = pwd;
ksfolder = strrep(cSessFolder,'F:\','E:\NPCCGs\');
clearvars ProbNPSess AllUnit_temporalAUC ExistField_ClusIDs
% if exist(fullfile(ksfolder,'AnovanAnA','TemporalAUCdataSave.mat'),'file')
%     return;
% end
dataSaveNames = fullfile(ksfolder,'AnovanAnA','StimTempAUCdataSave.mat');
if exist(dataSaveNames,'file')
    return;
end

load(fullfile(ksfolder,'NPClassHandleSaved.mat'));

ProbNPSess.CurrentSessInds = strcmpi('Task',ProbNPSess.SessTypeStrs);

% transfromed into trial-by-units-by-bin matrix
SMBinDataMtx = permute(cat(3,ProbNPSess.TrigData_Bin{ProbNPSess.CurrentSessInds}{:,1}),[1,3,2]); 
if ~isempty(ProbNPSess.SurviveInds)
    SMBinDataMtx = SMBinDataMtx(:,ProbNPSess.SurviveInds,:);
end
SMBinDataMtxRaw = SMBinDataMtx;

AreaIndexStrc = load(fullfile(ksfolder,'SessAreaIndexData.mat'));
AllFieldNames = fieldnames(AreaIndexStrc.SessAreaIndexStrc);
UsedNames = AllFieldNames(1:end-1);
ExistAreaNames = UsedNames(AreaIndexStrc.SessAreaIndexStrc.UsedAbbreviations);

if strcmpi(ExistAreaNames(end),'Others')
    ExistAreaNames(end) = [];
end
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
DataBinTimeWin = 0.05; %seconds
winGoesStep = 0.01; %seconds, moving steps, partially overlapped windows 
calDataBinSize = DataBinTimeWin/SPTimeBinSize(2);
calDataStepBin = winGoesStep/SPTimeBinSize(2);
OverAllUsedTime = 5; % seconds, used time length for each trial, this time including prestim periods
TotalCalcuNumber = (OverAllUsedTime/SPTimeBinSize(2))/calDataStepBin - (calDataBinSize - calDataStepBin);
CaledStartBin = ceil(calDataBinSize/2);
CaledStimOnsetBin = StimOnsetBin - CaledStartBin + 1;
SmoothWin = hann(calDataBinSize*2-1);
SmoothWin = SmoothWin/sum(SmoothWin);

CalWinTimes = (((1:TotalCalcuNumber)-CaledStimOnsetBin) * winGoesStep)';
AllUnit_temporalAUC = cell(TotalCalcuNumber, NumCaledUnits);
%
parfor cCalWin = 1 : TotalCalcuNumber
    cCal_startInds = (cCalWin -1)*calDataStepBin + 1;
    cCal_endInds = cCal_startInds + calDataBinSize - 1;
    UsedDataWin = cCal_startInds:cCal_endInds;
    UnitRespData = mean(SMBinDataMtxUsed(TrNMInds,:,UsedDataWin),3);
    
    TemporalAUC = cell(NumCaledUnits, 1);
    for cU = 1 : NumCaledUnits
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
            [~,~,AUCthresValue_1] = ROCSiglevelGeneNew([CalDataAll, CalDataLabels],100,0,0.01);
            
            % second block types
            cfLabels_2 = FreqIndsAll{cf,2};
            NumLabels2 = sum(cfLabels_2);
            cf_calData2 = cU_data(cfLabels_2);
            cf_baseData2 = cU_baselineData(cfLabels_2);
            CalDataAll2 = [cf_calData2;cf_baseData2];
            CalDataLabels2 = [ones(NumLabels2,1);zeros(NumLabels2,1)];
            
            [cAUC_2, cIsMeanRev_2] = AUC_fast_utest(CalDataAll2, CalDataLabels2);
            [~,~,AUCthresValue_2] = ROCSiglevelGeneNew([CalDataAll2, CalDataLabels2],100,0,0.01);
            
            cFreqAUC_thres(cf,:) = [cAUC_1, cIsMeanRev_1,AUCthresValue_1,cAUC_2, cIsMeanRev_2,AUCthresValue_2];
        end
        TemporalAUC(cU,:) = {cFreqAUC_thres};
        
    end
    AllUnit_temporalAUC(cCalWin,:) = TemporalAUC;
end

disp(toc(t1));

%%
save(dataSaveNames,'AreaUnitNumbers','AccumedUnitNums','ExistField_ClusIDs','CaledStimOnsetBin',...
    'winGoesStep','TotalCalcuNumber','AllUnit_temporalAUC','CalWinTimes','-v7.3');

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


