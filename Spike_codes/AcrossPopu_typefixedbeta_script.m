
clearvars NewAdd_ExistAreaNames OutDataStrc ExistField_ClusIDs cBinTypeFixedCoefs

% ksfolder = strrep(cSessFolder,'F:\','E:\NPCCGs\');
% ksfolder = pwd;
load(fullfile(ksfolder,'NPClassHandleSaved.mat'),'behavResults');
Savepath = fullfile(ksfolder,'jeccAnA');
dataSavePath = fullfile(Savepath,'TypeFixedJECC_DataCorr.mat');

JeccDataNew_path = fullfile(Savepath,'JeccDataNew.mat');
load(JeccDataNew_path,'ExistField_ClusIDs','OutDataStrc','NewAdd_ExistAreaNames');
% %% find target cluster inds and IDs
% NewSessAreaStrc = load(fullfile(ksfolder,'SessAreaIndexDataNew.mat'));
% NewAdd_AllfieldNames = fieldnames(NewSessAreaStrc.SessAreaIndexStrc);
% NewAdd_ExistAreasInds = find(NewSessAreaStrc.SessAreaIndexStrc.UsedAbbreviations);
% NewAdd_ExistAreaNames = NewAdd_AllfieldNames(NewAdd_ExistAreasInds);
% if strcmpi(NewAdd_ExistAreaNames(end),'Others')
%     NewAdd_ExistAreaNames(end) = [];
% end
% NewAdd_NumExistAreas = length(NewAdd_ExistAreaNames);
% 
% Numfieldnames = length(NewAdd_ExistAreaNames);
% ExistField_ClusIDs = cell(Numfieldnames,4);
% AreaUnitNumbers = zeros(NewAdd_NumExistAreas,1);
% for cA = 1 : Numfieldnames
%     cA_Clus_IDs = NewSessAreaStrc.SessAreaIndexStrc.(NewAdd_ExistAreaNames{cA}).MatchUnitRealIndex;
%     cA_clus_inds = NewSessAreaStrc.SessAreaIndexStrc.(NewAdd_ExistAreaNames{cA}).MatchedUnitInds;
%     ExistField_ClusIDs(cA,:) = {cA_Clus_IDs,cA_clus_inds,numel(cA_clus_inds) > 5,...
%         NewAdd_ExistAreaNames{cA}}; % real Clus_IDs and Clus indexing inds
%     AreaUnitNumbers(cA) = numel(cA_clus_inds);
%     
% end
% 
% USedAreas = cell2mat(ExistField_ClusIDs(:,3)) < 1;
% if sum(USedAreas)
%     ExistField_ClusIDs(USedAreas,:) = [];
%     AreaUnitNumbers(USedAreas) = [];
%     Numfieldnames = Numfieldnames - sum(USedAreas);
%     NewAdd_ExistAreaNames(USedAreas) = [];
% end
%%

% ProbNPSess.CurrentSessInds = strcmpi('Task',ProbNPSess.SessTypeStrs);

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
% OutDataStrc = ProbNPSess.TrigPSTH_Ext([-1 5],[300 100],ProbNPSess.StimAlignedTime{ProbNPSess.CurrentSessInds});
NewBinnedDatas = permute(cat(3,OutDataStrc.TrigData_Bin{:,1}),[1,3,2]);
% SMBinDataMtxRaw = SMBinDataMtx;
% clearvars ProbNPSess
BlockSectionInfo = Bev2blockinfoFun(behavResults);
RevFreqs = BlockSectionInfo.BlockFreqTypes(logical(BlockSectionInfo.IsFreq_asReverse));
RevFreq_trInds = ismember(behavResults.Stim_toneFreq(:),RevFreqs);

%% calculate event evoked response
AnsTimes = round((double(behavResults.Time_answer - behavResults.Time_stimOnset))/1000/0.1); % bins
UsedNMTrInds = AnsTimes > 0;
NMAnsTimeBin = AnsTimes(UsedNMTrInds);
NMRevFreq_trInds = RevFreq_trInds(UsedNMTrInds);


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
Numfieldnames = length(NewAdd_ExistAreaNames);
NumCalculations = (Numfieldnames-1)*Numfieldnames/2;

CaledTrInds_Alls = {true(size(NMRevFreq_trInds)),NMRevFreq_trInds,~NMRevFreq_trInds};
CaledTrInds_Str = {'AllTrials','RevTrials','NonRevTrs'};
EventRespCalResults = cell(NumCalculations,3,3);
EventRespCalAreaIndsANDName = cell(NumCalculations,4);

ks = 1;
for cAr = 1 : Numfieldnames
    for cAr2 = cAr+1 : Numfieldnames
        for cInds = 1 : 3
            cUsedTrInds = CaledTrInds_Alls{cInds};
            % baseline
            Area1_binned_datas = BaselineResp(cUsedTrInds,ExistField_ClusIDs{cAr,2});
            Area2_binned_datas = BaselineResp(cUsedTrInds,ExistField_ClusIDs{cAr2,2});

            [A_base,B_base,R_base] = canoncorr(Area1_binned_datas,Area2_binned_datas); % U = (X - mean(X))*A; V = (Y - mean(Y))*B; R(x) = corrcoef(U(:,1),V(:,1));

            % stimulus
            Area1_binned_datas = StimOnResp(cUsedTrInds,ExistField_ClusIDs{cAr,2});
            Area2_binned_datas = StimOnResp(cUsedTrInds,ExistField_ClusIDs{cAr2,2});

            [A_stim,B_stim,R_stim] = canoncorr(Area1_binned_datas,Area2_binned_datas); % U = (X - mean(X))*A; V = (Y - mean(Y))*B; R(1) = corrcoef(U(:,1),V(:,1));

            % choice1
            Area1_binned_datas = ChoiceResps1(cUsedTrInds,ExistField_ClusIDs{cAr,2});
            Area2_binned_datas = ChoiceResps1(cUsedTrInds,ExistField_ClusIDs{cAr2,2});

            [A_choice1,B_choice1,R_choice1] = canoncorr(Area1_binned_datas,Area2_binned_datas);

    %         % choice 2
    %         Area1_binned_datas = ChoiceResps2(:,ExistField_ClusIDs{cAr,2});
    %         Area2_binned_datas = ChoiceResps2(:,ExistField_ClusIDs{cAr2,2});
    %         
    %         [A_choice2,B_choice2,R_choice2] = canoncorr(Area1_binned_datas,Area2_binned_datas);


            EventRespCalResults(ks,:,cInds) = {{A_base,B_base,R_base},{A_stim,B_stim,R_stim},...
                {A_choice1,B_choice1,R_choice1}}; %{A_choice2,B_choice2,R_choice2}
        end
        EventRespCalAreaIndsANDName(ks,:) = {ExistField_ClusIDs{cAr,2},ExistField_ClusIDs{cAr2,2},...
            NewAdd_ExistAreaNames{cAr},NewAdd_ExistAreaNames{cAr2}};
        ks = ks + 1;
    end
end

%%

NumTimeBins = size(NewBinnedDatas,3);
IsCalTypeEmpty = cellfun(@isempty,EventRespCalResults(1,:,1));
EventRespCalResultsRaw = EventRespCalResults;
EventRespCalResults(:,IsCalTypeEmpty,:) = [];
[NumofCalculations, TypeCalculations,~] = size(EventRespCalResults);
% TypeCalculations = size(EventRespCalResults,2);

cBinTypeFixedCoefs = zeros(NumofCalculations,TypeCalculations,3,NumTimeBins);
for cBin = 1 : NumTimeBins
    cBinData = NewBinnedDatas(:,:,cBin);
    for cTypeCal = 1 : TypeCalculations
        for cCalNum = 1 : NumofCalculations
            for cTrInds = 1 : 3
                cCal1_data_raw = NewBinnedDatas(CaledTrInds_Alls{cTrInds},EventRespCalAreaIndsANDName{cCalNum,1},cBin);
                cCal2_data_raw = NewBinnedDatas(CaledTrInds_Alls{cTrInds},EventRespCalAreaIndsANDName{cCalNum,2},cBin);

                if isempty(EventRespCalResults{cCalNum,cTypeCal,cTrInds})
                    cBinTypeFixedCoefs(cCalNum, cTypeCal, cTrInds, cBin) = NaN;
                else
                    cCal1_coef_A = EventRespCalResults{cCalNum,cTypeCal,cTrInds}{1};
                    cCal2_coef_B = EventRespCalResults{cCalNum,cTypeCal,cTrInds}{2};
                    U = (cCal1_data_raw - mean(cCal1_data_raw)) * cCal1_coef_A;
                    V = (cCal2_data_raw - mean(cCal2_data_raw)) * cCal2_coef_B;

                    cBinCoef = corr(U(:,1),V(:,1));
                    cBinTypeFixedCoefs(cCalNum, cTypeCal, cTrInds, cBin) = cBinCoef;
                end
            end
        end
    end
    
end

%%

save(dataSavePath,'cBinTypeFixedCoefs','EventRespCalAreaIndsANDName','EventRespCalResults','CaledTrInds_Str','-v7.3');
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


