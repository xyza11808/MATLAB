
clearvars CalResults OutDataStrc ExistField_ClusIDs

% ksfolder = strrep(cSessFolder,'F:\','E:\NPCCGs\');
% ksfolder = pwd;
load(fullfile(ksfolder,'NPClassHandleSaved.mat'));

%% find target cluster inds and IDs
NewSessAreaStrc = load(fullfile(ksfolder,'SessAreaIndexDataNew.mat'));
NewAdd_AllfieldNames = fieldnames(NewSessAreaStrc.SessAreaIndexStrc);
NewAdd_ExistAreasInds = find(NewSessAreaStrc.SessAreaIndexStrc.UsedAbbreviations);
NewAdd_ExistAreaNames = NewAdd_AllfieldNames(NewAdd_ExistAreasInds);
if strcmpi(NewAdd_ExistAreaNames(end),'Others')
    NewAdd_ExistAreaNames(end) = [];
end
NewAdd_NumExistAreas = length(NewAdd_ExistAreaNames);

Numfieldnames = length(NewAdd_ExistAreaNames);
ExistField_ClusIDs = cell(Numfieldnames,4);
AreaUnitNumbers = zeros(NewAdd_NumExistAreas,1);
for cA = 1 : Numfieldnames
    cA_Clus_IDs = NewSessAreaStrc.SessAreaIndexStrc.(NewAdd_ExistAreaNames{cA}).MatchUnitRealIndex;
    cA_clus_inds = NewSessAreaStrc.SessAreaIndexStrc.(NewAdd_ExistAreaNames{cA}).MatchedUnitInds;
    ExistField_ClusIDs(cA,:) = {cA_Clus_IDs,cA_clus_inds,numel(cA_clus_inds) > 5,...
        NewAdd_ExistAreaNames{cA}}; % real Clus_IDs and Clus indexing inds
    AreaUnitNumbers(cA) = numel(cA_clus_inds);
    
end

USedAreas = cell2mat(ExistField_ClusIDs(:,3)) < 1;
if sum(USedAreas)
    ExistField_ClusIDs(USedAreas,:) = [];
    AreaUnitNumbers(USedAreas) = [];
    Numfieldnames = Numfieldnames - sum(USedAreas);
    NewAdd_ExistAreaNames(USedAreas) = [];
end
%%

ProbNPSess.CurrentSessInds = strcmpi('Task',ProbNPSess.SessTypeStrs);

% TaskTrigOnTimes = ProbNPSess.UsedTrigOnTime{ProbNPSess.CurrentSessInds};
% 
% BeforeFirstTrigLen = 10; % seconds
% AfterLastTrigLen = 30; % seconds
% TaskUsedTimeScale = [TaskTrigOnTimes(1) - BeforeFirstTrigLen,...
%     TaskTrigOnTimes(end) + AfterLastTrigLen];
% TotalBinSpikeLen = diff(TaskUsedTimeScale);
% TaskTrigTimeAligns = TaskTrigOnTimes - TaskTrigOnTimes(1) + BeforeFirstTrigLen;
% TotalTrialNum = length(TaskTrigTimeAligns); % number of trials in total
% 
% UsedUnitIDs_All = cell2mat(ExistField_ClusIDs(:,1));
% UsedClusInds = ismember(ProbNPSess.SpikeClus, UsedUnitIDs_All);
% UsedSpTimes = ProbNPSess.SpikeTimes > TaskUsedTimeScale(1) & ...
%     ProbNPSess.SpikeTimes < TaskUsedTimeScale(2);

% UsedClusPos = ProbNPSess.SpikeClus(UsedClusInds & UsedSpTimes);
% UsedSPTimes = ProbNPSess.SpikeTimes(UsedClusInds & UsedSpTimes) - ...
%     TaskTrigOnTimes(1) + BeforeFirstTrigLen; % realigned to first trigger on time

% SMBinDataMtx = permute(cat(3,ProbNPSess.TrigData_Bin{ProbNPSess.CurrentSessInds}{:,1}),[1,3,2]);
% if ~isempty(ProbNPSess.SurviveInds)
%     SMBinDataMtx = SMBinDataMtx(:,ProbNPSess.SurviveInds,:);
% end
OutDataStrc = ProbNPSess.TrigPSTH_Ext([-1 5],[300 100],ProbNPSess.StimAlignedTime{ProbNPSess.CurrentSessInds});
NewBinnedDatas = permute(cat(3,OutDataStrc.TrigData_Bin{:,1}),[1,3,2]);
% SMBinDataMtxRaw = SMBinDataMtx;
% clearvars ProbNPSess
BlockSectionInfo = Bev2blockinfoFun(behavResults);

%% calculate event evoked response
AnsTimes = round((behavResults.Time_answer - behavResults.Time_stimOnset)/1000/0.1); % bins
UsedNMTrInds = AnsTimes > 0;
NMAnsTimeBin = AnsTimes(UsedNMTrInds);

BaselineResp = mean(NewBinnedDatas(UsedNMTrInds,:,1:OutDataStrc.TriggerStartBin-1),3);
StimRespWin = 0.5/0.1; 
StimOnResp = mean(NewBinnedDatas(UsedNMTrInds,:,(OutDataStrc.TriggerStartBin-1):(OutDataStrc.TriggerStartBin+StimRespWin)),3);

ChoiceRespWin = 1/0.1;
ChoiceRespData1 = zeros(size(NewBinnedDatas,1),size(NewBinnedDatas,2),ChoiceRespWin);
% ChoiceRespData2 = zeros(size(NewBinnedDatas,1),size(NewBinnedDatas,2),ChoiceRespWin);
for cUTr = 1:sum(UsedNMTrInds)
    cUTr_AnsTimeBin1 = NMAnsTimeBin(cUTr)+OutDataStrc.TriggerStartBin-1;
    ChoiceRespData1(cUTr,:,:) = NewBinnedDatas(cUTr,:,cUTr_AnsTimeBin1:(cUTr_AnsTimeBin1+ChoiceRespWin-1));
    
%     cUTr_AnsTimeBin2 = NMAnsTimeBin(cUTr)+OutDataStrc.TriggerStartBin+ChoiceRespWin;
%     ChoiceRespData2(cUTr,:,:) = NewBinnedDatas(cUTr,:,cUTr_AnsTimeBin2:(cUTr_AnsTimeBin2+ChoiceRespWin-1));
end
ChoiceResps1 = mean(ChoiceRespData1,3);
% ChoiceResps2 = mean(ChoiceRespData2,3);


%%
NumCalculations = (Numfieldnames-1)*Numfieldnames/2;
EventRespCalResults = cell(NumCalculations,3);
EventRespCalAreaIndsANDName = cell(NumCalculations,4);
ks = 1;
for cAr = 1 : Numfieldnames
    for cAr2 = cAr+1 : Numfieldnames
        % baseline
        Area1_binned_datas = BaselineResp(:,ExistField_ClusIDs{cAr,2});
        Area2_binned_datas = BaselineResp(:,ExistField_ClusIDs{cAr2,2});
        
        [A_base,B_base,R_base] = canoncorr(Area1_binned_datas,Area2_binned_datas); % U = (X - mean(X))*A; V = (Y - mean(Y))*B; R(x) = corrcoef(U(:,1),V(:,1));
        
        % stimulus
        Area1_binned_datas = StimOnResp(:,ExistField_ClusIDs{cAr,2});
        Area2_binned_datas = StimOnResp(:,ExistField_ClusIDs{cAr2,2});
        
        [A_stim,B_stim,R_stim] = canoncorr(Area1_binned_datas,Area2_binned_datas); % U = (X - mean(X))*A; V = (Y - mean(Y))*B; R(1) = corrcoef(U(:,1),V(:,1));
        
        % choice1
        Area1_binned_datas = ChoiceResps1(:,ExistField_ClusIDs{cAr,2});
        Area2_binned_datas = ChoiceResps1(:,ExistField_ClusIDs{cAr2,2});
        
        [A_choice1,B_choice1,R_choice1] = canoncorr(Area1_binned_datas,Area2_binned_datas);
        
%         % choice 2
%         Area1_binned_datas = ChoiceResps2(:,ExistField_ClusIDs{cAr,2});
%         Area2_binned_datas = ChoiceResps2(:,ExistField_ClusIDs{cAr2,2});
%         
%         [A_choice2,B_choice2,R_choice2] = canoncorr(Area1_binned_datas,Area2_binned_datas);
        
        
        EventRespCalResults(ks,:) = {{A_base,B_base,R_base},{A_stim,B_stim,R_stim},...
            {A_choice1,B_choice1,R_choice1}}; %{A_choice2,B_choice2,R_choice2}
        EventRespCalAreaIndsANDName(ks,:) = {ExistField_ClusIDs{cAr,2},ExistField_ClusIDs{cAr2,2},...
            NewAdd_ExistAreaNames{cAr},NewAdd_ExistAreaNames{cAr2}};
        ks = ks + 1;
    end
end

EventDatas = {BaselineResp,StimOnResp,ChoiceResps1}; %,ChoiceResps2
EventStrs = {'Baseline','Stim','Choice1'}; %,'Choice2'

%%

NumTimeBins = size(NewBinnedDatas,3);
IsCalTypeEmpty = cellfun(@isempty,EventRespCalResults(1,:));
EventRespCalResultsRaw = EventRespCalResults;
EventRespCalResults(:,IsCalTypeEmpty) = [];
[NumofCalculations, TypeCalculations] = size(EventRespCalResults);
% TypeCalculations = size(EventRespCalResults,2);

cBinTypeFixedCoefs = zeros(NumofCalculations,TypeCalculations,NumTimeBins);
for cBin = 1 : NumTimeBins
    cBinData = NewBinnedDatas(:,:,cBin);
    for cTypeCal = 1 : TypeCalculations
        for cCalNum = 1 : NumofCalculations
            cCal1_data_raw = NewBinnedDatas(:,EventRespCalAreaIndsANDName{cCalNum,1},cBin);
            cCal2_data_raw = NewBinnedDatas(:,EventRespCalAreaIndsANDName{cCalNum,2},cBin);
            
            if isempty(EventRespCalResults{cCalNum,cTypeCal})
                cBinTypeFixedCoefs(cCalNum, cTypeCal, cBin) = NaN;
            else
                cCal1_coef_A = EventRespCalResults{cCalNum,cTypeCal}{1};
                cCal2_coef_B = EventRespCalResults{cCalNum,cTypeCal}{2};
                U = (cCal1_data_raw - mean(cCal1_data_raw)) * cCal1_coef_A;
                V = (cCal2_data_raw - mean(cCal2_data_raw)) * cCal2_coef_B;

                cBinCoef = corr(U(:,1),V(:,1));
                cBinTypeFixedCoefs(cCalNum, cTypeCal, cBin) = cBinCoef;
            end
        end
    end
    
end



%%
% TimeBinSize = single(0.05);
% 
% % unique and binned cluster spikes through the whole session
% UsedClusNum = size(UsedUnitIDs_All,1);
% BinEdges = 0:TimeBinSize:TotalBinSpikeLen;
% BinCenters = BinEdges(1:end-1) + TimeBinSize/2;
% NumofSPcounts = numel(BinCenters);
% BinnedSPdatas = zeros(UsedClusNum,NumofSPcounts,'single');
% for cClus = 1 : UsedClusNum
%     cClusSPCounts = histcounts(UsedSPTimes(UsedClusPos == UsedUnitIDs_All(cClus,1)),...
%         BinEdges);
%     BinnedSPdatas(cClus, :) = cClusSPCounts;
% end
% BinnedSPdatas = BinnedSPdatas./nanstd(BinnedSPdatas,[],2);
% 
% %% extract blocktypes to tiral times info
% BlockSectionInfo = Bev2blockinfoFun(behavResults);
% % TotalTrialNum
% BTDataBin = zeros(1, NumofSPcounts,'single');
% for cB = 1 : length(BlockSectionInfo.BlockTypes)
%     cBlockTrialInds = BlockSectionInfo.BlockTrScales(cB,:);
%     if cB == 1
%         cB_startTrTime = 0;
%     else
%         cB_startTrTime = TaskTrigTimeAligns(cBlockTrialInds(1));
%     end
%     cB_endTrTime = TaskTrigTimeAligns(cBlockTrialInds(2)+1) - TimeBinSize;
%     BTDataBin(1,BinEdges(1:end-1) >= cB_startTrTime & BinEdges(1:end-1) < cB_endTrTime) = ...
%         BlockSectionInfo.BlockTypes(cB);
% end
% if BlockSectionInfo.BlockTrScales(end,2) < TotalTrialNum
%     % extra block trial exists, but not longer longer enough to be included
%     % as another block
%     UsedBlockEndInds = TaskTrigTimeAligns(BlockSectionInfo.BlockTrScales(end,2)+1);
%     BTDataBin(1,BinEdges(1:end-1) > UsedBlockEndInds) = 1 - BlockSectionInfo.BlockTypes(end);
% end
% % BTDataBin(2,:) = 1 - BTDataBin(1,:);
% Behav_stimOnset = single(behavResults.Time_stimOnset(:))/1000; % seconds
% Behav_SessStimOnTime = Behav_stimOnset + TaskTrigTimeAligns(:);

%% define center block trInds for training
% CenterTrUsedWins = [-60,60]; % block center used trial windows
% SessBin_trainInds = false(NumofSPcounts,2);
% for cB = 1 : length(BlockSectionInfo.BlockTypes)
%     cBlockTrialScales = BlockSectionInfo.BlockTrScales(cB,:);
%     BlockCenterInds = round(mean(cBlockTrialScales));
%     TrainWinTrs = BlockCenterInds + CenterTrUsedWins;
%     TrainTr_trigTimes = TaskTrigTimeAligns([TrainWinTrs(1),(TrainWinTrs(2)+1)]) - [0;TimeBinSize]; % using whole time win datas as training inds
%     TrainTr_2Bin = round((TrainTr_trigTimes/TimeBinSize));
%     SessBin_trainInds(TrainTr_2Bin(1):TrainTr_2Bin(2),1) = true;
%     
%     % using only baseline bins for training
%     TrainTr_TrigBinAll = round(TaskTrigTimeAligns(TrainWinTrs(1):TrainWinTrs(2))/TimeBinSize);
%     TrainTr_StimOnTimeAll = round(Behav_SessStimOnTime(TrainWinTrs(1):TrainWinTrs(2))/TimeBinSize);
%     for cTT = 1 : numel(TrainTr_TrigBinAll)
%         SessBin_trainInds((TrainTr_TrigBinAll(cTT)+1):TrainTr_StimOnTimeAll(cTT),2) = true;
%     end
% end

% %% population decoding for each group units within same area
% % BinCenters
% UnitInds_perPopu = cellfun(@numel,ExistField_ClusIDs(:,2));
% AreaUnitScaleInds = cumsum([1;UnitInds_perPopu]);
% UsedTrainDataType = 2;
% for cA = 3 : 3%Numfieldnames
%     cAInds = AreaUnitScaleInds(cA):(AreaUnitScaleInds(cA+1)-1);
% %     cA_UnitDatas = BinnedSPdatas(cAInds,:);
%     cA_UnitResp_training = BinnedSPdatas(cAInds,SessBin_trainInds(:,UsedTrainDataType));
%     cA_TrBT_training = BTDataBin(1,SessBin_trainInds(:,UsedTrainDataType));
%     
%     fitMD = fitcsvm(cA_UnitResp_training',cA_TrBT_training');
%     cA_UnitResp_test = BinnedSPdatas(cAInds,~SessBin_trainInds(:,UsedTrainDataType));
%     cA_TrBT_test = BTDataBin(1,~SessBin_trainInds(:,UsedTrainDataType));
%     [PredBT, PredBTScore] = predict(fitMD, cA_UnitResp_test');
% %     Score2Prob = 1./(1 + exp(-PredBTScore));
%     Score2Prob = PredBTScore;
%     disp(kfoldLoss(crossval(fitMD)));
% end
% 
% 
% %%
% figure;
% hold on
% plot(BinCenters(~SessBin_trainInds(:,1)),cA_TrBT_test,'k*');
% plot(BinCenters(~SessBin_trainInds(:,1)),smooth(PredBT,15),'bo');

%% joint-correlation analysis
% if isempty(gcp('nocreate'))
%     parpool('local',6);
% end
tic
NumCalculations = (Numfieldnames-1)*Numfieldnames/2;
CalResults = cell(NumCalculations,5);
NumRepeats = 100;
TrialNums = size(NewBinnedDatas,1);
SampleTrNums = round(TrialNums*0.8);
RandIndsData = rand(SampleTrNums,NumCalculations,NumRepeats);
sampleInds = rand(TrialNums,NumCalculations,NumRepeats);

k = 1;
for cAr = 1 : Numfieldnames
    for cAr2 = cAr+1 : Numfieldnames
        
        % repeated sampling of 80% of all trials
        jPECC_val_Rep = cell(NumRepeats,2);
        parfor cRepeat = 1 : NumRepeats
            RandsampleV = sampleInds(:,k,cRepeat);
            RandsampleMore = RandsampleV(RandsampleV > 0.1);
            RandsampleMoreIndex = find(RandsampleV > 0.1);
            [~,RandsampleII] = sort(RandsampleMore);
            RandSampleShufIndex = RandsampleMoreIndex(RandsampleII);
            cR_sample_Index = RandSampleShufIndex(1:SampleTrNums);
            
%             Area1_binned_datas = permute(NewBinnedDatas(cR_sample_Index,ExistField_ClusIDs{cAr,2},:),[1,3,2]);
%             Area2_binned_datas = permute(NewBinnedDatas(cR_sample_Index,ExistField_ClusIDs{cAr2,2},:),[1,3,2]);
            Area1_binned_datas = NewBinnedDatas(cR_sample_Index,ExistField_ClusIDs{cAr,2},:);
            Area2_binned_datas = NewBinnedDatas(cR_sample_Index,ExistField_ClusIDs{cAr2,2},:);
            
            [jPECC_val, ~] = jPECC(Area1_binned_datas,Area2_binned_datas,...
                5,[],5);
            
            
            [~, TrialShufInds] = sort(RandIndsData(:,k,cRepeat));
            [jPECC_shuf, ~] = jPECC(Area1_binned_datas(TrialShufInds,:,:),Area2_binned_datas,...
                5,[],5);
            jPECC_val_Rep(cRepeat,:) = {jPECC_val,jPECC_shuf};
        end
            
            
        CalResults(k,:) = {jPECC_val_Rep(:,1), jPECC_val_Rep(:,2), ...
            NewAdd_ExistAreaNames{cAr},NewAdd_ExistAreaNames{cAr2},...
            [numel(ExistField_ClusIDs{cAr,1}),numel(ExistField_ClusIDs{cAr2,1})]};
        k = k + 1;
    end
end
disp(toc);
%%
Savepath = fullfile(ksfolder,'jeccAnA');
if ~isfolder(Savepath)
    mkdir(Savepath);
end
dataSavePath = fullfile(Savepath,'JeccDataNew.mat');

save(dataSavePath,'CalResults','EventRespCalResults','OutDataStrc','EventDatas','EventStrs',...
    'ExistField_ClusIDs','NewAdd_ExistAreaNames','-v7.3')
%%
% CalTimeBinNums = [min(OutDataStrc.BinCenters),max(OutDataStrc.BinCenters)];
% StimOnBinTime = 0; %OutDataStrc.BinCenters(OutDataStrc.TriggerStartBin);
% cCalInds = 10;
% cCalIndsPopuSize = CalResults{cCalInds,5};
% 
% figure;
% hold on
% 
% imagesc(OutDataStrc.BinCenters,OutDataStrc.BinCenters, CalResults{cCalInds,1});
% line(CalTimeBinNums,CalTimeBinNums,'Color','w','linewidth',1.8);
% line(CalTimeBinNums,[StimOnBinTime StimOnBinTime],'Color','m','linewidth',1.5);
% line([StimOnBinTime StimOnBinTime],CalTimeBinNums,'Color','m','linewidth',1.5);
% xlabel(['Time(s) ',CalResults{cCalInds,3},num2str(cCalIndsPopuSize(1),', n = %d')]);
% ylabel(['Time(s) ',CalResults{cCalInds,4},num2str(cCalIndsPopuSize(2),', n = %d')]);


