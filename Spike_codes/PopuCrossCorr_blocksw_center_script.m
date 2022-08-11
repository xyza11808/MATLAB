
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

OutDataStrc = ProbNPSess.TrigPSTH_Ext([-1 5],[300 100],ProbNPSess.StimAlignedTime{ProbNPSess.CurrentSessInds});
NewBinnedDatas = permute(cat(3,OutDataStrc.TrigData_Bin{:,1}),[1,3,2]);
NewBinnedDatas = NewBinnedDatas;% + eye()
BlockSectionInfo = Bev2blockinfoFun(behavResults);
% SMBinDataMtxRaw = SMBinDataMtx;
% clearvars ProbNPSess
TrialIsMiss = double(behavResults.Action_choice(:)) == 2;
TrialFreqs = double(behavResults.Stim_toneFreq(:));
TrialIsCorrect = double(behavResults.Action_choice(:)) == double(behavResults.Trial_Type(:));
RevFreqTypes = BlockSectionInfo.BlockFreqTypes(logical(BlockSectionInfo.IsFreq_asReverse));
TrialIsRevInds = ismember(TrialFreqs,RevFreqTypes);

NumBlocks = length(BlockSectionInfo.BlockLens);

%% joint-correlation analysis
% if isempty(gcp('nocreate'))
%     parpool('local',6);
% end
tic
NumCalculations = (Numfieldnames-1)*Numfieldnames/2;
CalResults = cell(NumCalculations,5);

BlockUsedTrLength = 70;
k = 1;
for cAr = 1 : Numfieldnames
    for cAr2 = cAr+1 : Numfieldnames
        
        BlockStartANDEndjecc = cell(NumBlocks,6,2);
        for cB = 1 : NumBlocks
            cB_length = BlockSectionInfo.BlockLens(cB);
            if cB_length < 160
                continue;
            end
            cB_start = BlockSectionInfo.BlockTrScales(cB,1);
            TrialInds_firsthalf = cB_start:(cB_start+BlockUsedTrLength-1);
            TrialInds_lasthalf = (cB_start+cB_length-BlockUsedTrLength):(cB_start+cB_length-1);
            % calculate correlation using first half data
            TrFirsthalf_missInds = TrialIsMiss(TrialInds_firsthalf);
            Area1_binned_datas1 = NewBinnedDatas(TrialInds_firsthalf(~TrFirsthalf_missInds),ExistField_ClusIDs{cAr,2},:);
            Area2_binned_datas1 = NewBinnedDatas(TrialInds_firsthalf(~TrFirsthalf_missInds),ExistField_ClusIDs{cAr2,2},:);
            
            [jPECC_val1, jPECC_p1] = jPECC(Area1_binned_datas1,Area2_binned_datas1,...
                5,[],5);
            
            % calculation using last half datas
            TrLasthalf_missInds = TrialIsMiss(TrialInds_lasthalf);
            Area1_binned_datas2 = NewBinnedDatas(TrialInds_lasthalf(~TrLasthalf_missInds),ExistField_ClusIDs{cAr,2},:);
            Area2_binned_datas2 = NewBinnedDatas(TrialInds_lasthalf(~TrLasthalf_missInds),ExistField_ClusIDs{cAr2,2},:);
            
            [jPECC_val2, jPECC_p2] = jPECC(Area1_binned_datas2,Area2_binned_datas2,...
                5,[],5);
            
            % calculation using RevTrial and NonRevTrial datas from the
            % first half
            FirstHalf_IsRevInds = TrialIsRevInds(TrialInds_firsthalf) & ~TrFirsthalf_missInds;
            if sum(FirstHalf_IsRevInds) < 20
                jPECC_val3 = [];
                jPECC_p3 = [];
            else
                Area1_binned_datas3 = NewBinnedDatas(TrialInds_firsthalf(FirstHalf_IsRevInds),ExistField_ClusIDs{cAr,2},:);
                Area2_binned_datas3 = NewBinnedDatas(TrialInds_firsthalf(FirstHalf_IsRevInds),ExistField_ClusIDs{cAr2,2},:);
                
                [jPECC_val3, jPECC_p3] = jPECC(Area1_binned_datas3,Area2_binned_datas3,...
                    5,[],5);
            end
            % nonRev Trials
            FirstHalf_IsNonRevInds = ~TrialIsRevInds(TrialInds_firsthalf) & ~TrFirsthalf_missInds;
            if sum(~FirstHalf_IsRevInds) < 20
                jPECC_val4 = [];
                jPECC_p4 = [];
            else
                Area1_binned_datas4 = NewBinnedDatas(TrialInds_firsthalf(FirstHalf_IsNonRevInds),ExistField_ClusIDs{cAr,2},:);
                Area2_binned_datas4 = NewBinnedDatas(TrialInds_firsthalf(FirstHalf_IsNonRevInds),ExistField_ClusIDs{cAr2,2},:);
                
                [jPECC_val4, jPECC_p4] = jPECC(Area1_binned_datas4,Area2_binned_datas4,...
                    5,[],5);
            end
            
            % calculation using RevTrial and NonRevTrial datas from the
            % last half
            LastHalf_IsRevInds = TrialIsRevInds(TrialInds_lasthalf) & ~TrLasthalf_missInds;
            if sum(LastHalf_IsRevInds) < 20
                jPECC_val5 = [];
                jPECC_p5 = [];
            else
                Area1_binned_datas5 = NewBinnedDatas(TrialInds_lasthalf(LastHalf_IsRevInds),ExistField_ClusIDs{cAr,2},:);
                Area2_binned_datas5 = NewBinnedDatas(TrialInds_lasthalf(LastHalf_IsRevInds),ExistField_ClusIDs{cAr2,2},:);
                
                [jPECC_val5, jPECC_p5] = jPECC(Area1_binned_datas5,Area2_binned_datas5,...
                    5,[],5);
            end
            % nonRev Trials
            LastHalf_IsNonRevInds = ~TrialIsRevInds(TrialInds_lasthalf) & ~TrLasthalf_missInds;
            if sum(~LastHalf_IsNonRevInds) < 20
                jPECC_val6 = [];
                jPECC_p6 = [];
            else
                Area1_binned_datas6 = NewBinnedDatas(TrialInds_lasthalf(LastHalf_IsNonRevInds),ExistField_ClusIDs{cAr,2},:);
                Area2_binned_datas6 = NewBinnedDatas(TrialInds_lasthalf(LastHalf_IsNonRevInds),ExistField_ClusIDs{cAr2,2},:);
                
                [jPECC_val6, jPECC_p6] = jPECC(Area1_binned_datas6,Area2_binned_datas6,...
                    5,[],5);
            end
            
            BlockStartANDEndjecc(cB,:,1) = {jPECC_val1,jPECC_val2,jPECC_val3,jPECC_val4,jPECC_val5,jPECC_val6};
            BlockStartANDEndjecc(cB,:,2) = {jPECC_p1,jPECC_p2,jPECC_p3,jPECC_p4,jPECC_p5,jPECC_p6};
            
        end
        CalResults(k,:) = {BlockStartANDEndjecc(:,:,1), BlockStartANDEndjecc(:,:,2), ...
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

save(dataSavePath,'CalResults','OutDataStrc',...
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


