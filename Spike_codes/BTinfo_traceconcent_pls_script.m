
SavedFolderPathName = 'ChoiceANDBT_LDAinfo_ana';
fullsavePath = fullfile(ksfolder, SavedFolderPathName);
AlreadyCaledDatas = load(fullfile(fullsavePath,'LDAinfo_FreqwiseScoresAllUnit.mat'),'ExistField_ClusIDs',...
    'NewAdd_ExistAreaNames','AreaUnitNumbers', 'AreaProcessDatas','OutDataStrc');

load(fullfile(ksfolder,'NewClassHandle2.mat'),'behavResults');
%% some preprocessing
NewBinnedDatas = permute(cat(3,AlreadyCaledDatas.OutDataStrc.TrigData_Bin{:,1}),[1,3,2]);
OnsetBin = AlreadyCaledDatas.OutDataStrc.TriggerStartBin;

% behavior datas
BlockSectionInfo = Bev2blockinfoFun(behavResults);

ActionInds = double(behavResults.Action_choice(:));
NMTrInds = ActionInds(1:BlockSectionInfo.BlockTrScales(end,2)) ~= 2;
ActTrs = ActionInds(NMTrInds);

NMActionChoices = ActionInds(NMTrInds);
BlockTypeAll = double(behavResults.BlockType(:));
NMBlockTypes = BlockTypeAll(NMTrInds);

NMBlockTypeLabels = NMBlockTypes + 1;
NMActionChoices = NMActionChoices + 1;

NMBlockIndex = cumsum([1;abs(diff(NMBlockTypes))]);

% AllTrInds = {double(behavResults.Action_choice(:)),double(behavResults.BlockType(:))};
TrialFreqsAll = double(behavResults.Stim_toneFreq(:));

RevFreqs = BlockSectionInfo.BlockFreqTypes(BlockSectionInfo.IsFreq_asReverse>0);
RevFreqInds = (ismember(TrialFreqsAll,RevFreqs));
NMRevFreqIndsRaw = RevFreqInds(NMTrInds);
NMTrFreqsAll = TrialFreqsAll(NMTrInds);

FreqTypes = unique(NMTrFreqsAll);
FreqTypeNum = length(FreqTypes);

% find fieldnames
AllNameStrs = AlreadyCaledDatas.NewAdd_ExistAreaNames;
AllAreaUnitInds = AlreadyCaledDatas.ExistField_ClusIDs;
AllAreaUnitNums = cellfun(@numel,AllAreaUnitInds(:,2));
ExcludeAreaInds = AllAreaUnitNums >= 5;

UsedArea_strs = AllNameStrs(ExcludeAreaInds);
UsedUnitNums = AllAreaUnitNums(ExcludeAreaInds);
UsedUnitInds = AllAreaUnitInds(ExcludeAreaInds,:);
NumUsedAreas = length(UsedArea_strs);
%% precalculations
RawResponseData = NewBinnedDatas(NMTrInds,:,:);
[nmTrNum, UnitNums, FrameNum] = size(RawResponseData);
BaselineAvgDatas = mean(RawResponseData(:,:,1:OnsetBin-1),3);
BaselineSubData = RawResponseData - repmat(BaselineAvgDatas,1,1,FrameNum);

BaselineWin = 1:OnsetBin-1;
AfterRespWin = [0:0.1:1.4]/AlreadyCaledDatas.OutDataStrc.USedbin(2)+OnsetBin;
%%
AreaInfos_Af = cell(NumUsedAreas, 8);
AreaInfos_base = cell(NumUsedAreas, 8);
for cA = 1 : NumUsedAreas
    cA_UnitInds = UsedUnitInds{cA,2};
    cA_UnitData_Raw = RawResponseData(:,cA_UnitInds,:);
    cA_UnitData_Sub = BaselineSubData(:,cA_UnitInds,:);
    
    % decoding using afterward responses
    cA_AfDataConcent_Raw = reshape(permute(cA_UnitData_Raw(:,:,AfterRespWin),[1,3,2]),nmTrNum,[]);
    cA_AfDataConcent_Sub = reshape(permute(cA_UnitData_Sub(:,:,AfterRespWin),[1,3,2]),nmTrNum,[]);
    
    [cA_Af_Raw_BTInfo, cA_Af_Raw_PredAccu, cA_Af_Rawpctvar, ShufInfo_raw] = plsInfoCaledFun(cA_AfDataConcent_Raw, NMBlockTypeLabels,20);
    [cA_Af_Sub_BTInfo, cA_Af_Sub_PredAccu, cA_Af_Subpctvar, ShufInfo_sub] = plsInfoCaledFun(cA_AfDataConcent_Sub, NMBlockTypeLabels,20);
    
    % decoding using baseline datas
    cA_baseDataConcent_Raw = reshape(permute(cA_UnitData_Raw(:,:,BaselineWin),[1,3,2]),nmTrNum,[]);
    cA_baseDataConcent_Sub = reshape(permute(cA_UnitData_Sub(:,:,BaselineWin),[1,3,2]),nmTrNum,[]);
    
    [cA_base_Raw_BTInfo, cA_base_Raw_PredAccu, cA_base_Rawpctvar, baseShufInfo_raw] = plsInfoCaledFun(cA_baseDataConcent_Raw, NMBlockTypeLabels,20);
    [cA_base_Sub_BTInfo, cA_base_Sub_PredAccu, cA_base_Subpctvar, baseShufInfo_sub] = plsInfoCaledFun(cA_baseDataConcent_Sub, NMBlockTypeLabels,20);
    
    
    AfShufThres_raw = zeros(20,2,2); % the last two is 99 prctile thres and 95 prctile thres
    AfShufThres_sub = zeros(20,2,2); 
    baseShufThres_raw = zeros(20,2,2); 
    baseShufThres_sub = zeros(20,2,2); 
    for cComp = 1 : 20
        for cType = 1 : 2
            cShufData_Raw = ShufInfo_raw(:,cComp,cType,:);
            AfShufThres_raw(cComp,cType,:) = prctile(cShufData_Raw(:),[99, 95]);
            
            cShufData_Sub = ShufInfo_sub(:,cComp,cType,:);
            AfShufThres_sub(cComp,cType,:) = prctile(cShufData_Sub(:),[99, 95]);
            
            cbaseShufData_Raw = baseShufInfo_raw(:,cComp,cType,:);
            baseShufThres_raw(cComp,cType,:) = prctile(cbaseShufData_Raw(:),[99, 95]);
            
            cbaseShufData_sub = baseShufInfo_sub(:,cComp,cType,:);
            baseShufThres_sub(cComp,cType,:) = prctile(cbaseShufData_sub(:),[99, 95]);
            
        end
    end
    
    AreaInfos_Af(cA,:) = {mean(cA_Af_Raw_BTInfo,3), mean(cA_Af_Raw_PredAccu,3), mean(cA_Af_Rawpctvar,3), AfShufThres_raw...
        mean(cA_Af_Sub_BTInfo,3), mean(cA_Af_Sub_PredAccu,3), mean(cA_Af_Subpctvar,3),AfShufThres_sub};
    AreaInfos_base(cA,:) = {mean(cA_base_Raw_BTInfo,3), mean(cA_base_Raw_PredAccu,3), mean(cA_base_Rawpctvar,3), baseShufThres_raw...
        mean(cA_base_Sub_BTInfo,3), mean(cA_base_Sub_PredAccu,3), mean(cA_base_Subpctvar,3),baseShufThres_sub};
end
%%
CalSaveDatafile = (fullfile(fullsavePath,'plsInfoDataSave_BT.mat'));
save(CalSaveDatafile,'AreaInfos_Af','AreaInfos_base','UsedArea_strs','UsedUnitNums','UsedUnitInds','NMActionChoices',...
    'NMBlockTypeLabels','NMTrInds','-v7.3');


%%
% close;
% cA = 1;
% cA_Str = UsedArea_strs{cA};
% hf = figure('position',[100 100 540 240]);
% subplot(121)
% hold on
% hl1 = plot(AreaInfos_Af{cA,1}(:,2),'Color','k','linewidth',1.5);
% hl1_1 = plot(AreaInfos_Af{cA,4}(:,2,1),'Color',[.7 .7 .7],'linewidth',1,'linestyle','--');
% hl2 = plot(AreaInfos_Af{cA,5}(:,2),'Color','r','linewidth',1.5);
% hl2_2 = plot(AreaInfos_Af{cA,8}(:,2,1),'Color',[0.8 0.2 0.2],'linewidth',1,'linestyle','--');
% set(gca,'xlim',[0 21]);
% xlabel('Num pls compnents');
% ylabel('Choice Info');
% title(sprintf('pls crossValid info (%s) After',cA_Str));
% legend([hl1 hl1_1 hl2 hl2_2],{'Raw','RawShuf','BaseSub','BSubShuf'},'location','east',...
%     'autoupdate','off','FontSize',6);
% 
% cA_Str = UsedArea_strs{cA};
% % hf = figure('position',[100 100 360 240]);
% subplot(122)
% hold on
% hl1 = plot(AreaInfos_base{cA,1}(:,2),'Color','k','linewidth',1.5);
% hl1_1 = plot(AreaInfos_base{cA,4}(:,2,1),'Color',[.7 .7 .7],'linewidth',1,'linestyle','--');
% hl2 = plot(AreaInfos_base{cA,5}(:,2),'Color','r','linewidth',1.5);
% hl2_2 = plot(AreaInfos_base{cA,8}(:,2,1),'Color',[0.8 0.2 0.2],'linewidth',1,'linestyle','--');
% set(gca,'xlim',[0 21]);
% xlabel('Num pls compnents');
% ylabel('Choice Info');
% title(sprintf('pls crossValid info (%s) Base',cA_Str));
% legend([hl1 hl1_1 hl2 hl2_2],{'Raw','RawShuf','BaseSub','BSubShuf'},'location','east',...
%     'autoupdate','off','FontSize',6);



