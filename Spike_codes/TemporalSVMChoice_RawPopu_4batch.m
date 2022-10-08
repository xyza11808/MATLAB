
clearvars SessAreaIndexStrc AreaTypeDecTrainsets FrameAccu  AreaChoiceSVMaccu

% load('Chnlocation.mat');

% load(fullfile(ksfolder,'SessAreaIndexDataAligned.mat'));
% if isempty(fieldnames(SessAreaIndexStrc.ACAv)) && isempty(fieldnames(SessAreaIndexStrc.ACAd))...
%          && isempty(fieldnames(SessAreaIndexStrc.ACA))
%     return;
% end
load(fullfile(ksfolder,'NPClassHandleSaved.mat'));

ProbNPSess.CurrentSessInds = strcmpi('Task',ProbNPSess.SessTypeStrs);
OutDataStrc = ProbNPSess.TrigPSTH_Ext([-1 4],[300 100],ProbNPSess.StimAlignedTime{ProbNPSess.CurrentSessInds});
NewBinnedDatas = permute(cat(3,OutDataStrc.TrigData_Bin{:,1}),[1,3,2]);
NumFrameBins = size(NewBinnedDatas,3);

%% find target cluster inds and IDs
% ksfolder = pwd;

NewSessAreaStrc = load(fullfile(ksfolder,'SessAreaIndexDataAligned.mat'));
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
%
USedAreas = cell2mat(ExistField_ClusIDs(:,3)) < 1;
if sum(USedAreas)
    ExistField_ClusIDs(USedAreas,:) = [];
    AreaUnitNumbers(USedAreas) = [];
    Numfieldnames = Numfieldnames - sum(USedAreas);
    NewAdd_ExistAreaNames(USedAreas) = [];
end

BlockTypesAll = double(behavResults.BlockType(:));
%%
SavedFolderPathName = 'ChoiceSVMperf_ana';

fullsavePath = fullfile(ksfolder, SavedFolderPathName);
% if isfolder(fullsavePath)
%     rmdir(fullsavePath,'s');
% end
%
% rmdir(fullsavePath,'s');
if ~isfolder(fullsavePath)
    mkdir(fullsavePath);
end

ActionInds = double(behavResults.Action_choice(:));
NMTrInds = ActionInds ~= 2;
NMTrActs = ActionInds(NMTrInds);
NumNMTrs = sum(NMTrInds);

ChoiceRespData = mean(NewBinnedDatas(NMTrInds,:,OutDataStrc.TriggerStartBin+(1:15)),3);
BaselineData = mean(NewBinnedDatas(NMTrInds,:,1:(OutDataStrc.TriggerStartBin-1)),3);
BaseSubData = ChoiceRespData - BaselineData;

TrialFreqsAll = double(behavResults.Stim_toneFreq(:));
BlockSectionInfo = Bev2blockinfoFun(behavResults);
RevFreqs = BlockSectionInfo.BlockFreqTypes(logical(BlockSectionInfo.IsFreq_asReverse));
RevFreqInds = (ismember(TrialFreqsAll,RevFreqs));
NMRevFreqIndsRaw = RevFreqInds(NMTrInds);
NonRevFreqIndsRaw = ~NMRevFreqIndsRaw;
NMTrFreqsAll = TrialFreqsAll(NMTrInds);
BlockTypeAll = double(behavResults.BlockType(:));
NMBlockTypes = BlockTypeAll(NMTrInds);

NMRevTrChoices = NMTrActs(NMRevFreqIndsRaw);
NonRevTrChoices = NMTrActs(NonRevFreqIndsRaw);

NonRevTr_C0Num = sum(NonRevTrChoices == 0);
NonRevTr_C1Num = sum(NonRevTrChoices == 1);

NonRevTrBaseSubData = BaseSubData(NonRevFreqIndsRaw,:);
NMRevTrBaseSubData = BaseSubData(NMRevFreqIndsRaw,:);
NonRevTrChoiceRespData = ChoiceRespData(NonRevFreqIndsRaw,:);
NumRepeat = 40;
AreaChoiceSVMaccu = zeros(Numfieldnames, NumRepeat, 3);
FrameAccu = zeros(Numfieldnames, NumRepeat, NumFrameBins,2);
FrameChoiceProb = zeros(Numfieldnames, NumRepeat, NumFrameBins,8);
% for cType = 1 : 2
for cArea = 1 : Numfieldnames
    cUsedAreas = NewAdd_ExistAreaNames{cArea};
    cAUnits = ExistField_ClusIDs{cArea,2};
    
    for cR = 1 : NumRepeat
        % training using NonRevTrials
        if NonRevTr_C0Num > NonRevTr_C1Num
            NonRevTr_C0Index = find(NonRevTrChoices == 0);
            UsedRevInds = randsample(NonRevTr_C0Num, NonRevTr_C1Num);
            UsedNonRevTr_C0Index = NonRevTr_C0Index(UsedRevInds);
            UsedNonRevTr_C1Index = find(NonRevTrChoices == 1);
            
        else
            NonRevTr_C1Index = find(NonRevTrChoices == 1);
            UsedRevInds = randsample(NonRevTr_C1Num, NonRevTr_C0Num);
            UsedNonRevTr_C1Index = NonRevTr_C1Index(UsedRevInds);
            UsedNonRevTr_C0Index = find(NonRevTrChoices == 0);
        end
        OverAllUsedInds = [UsedNonRevTr_C0Index(:);UsedNonRevTr_C1Index(:)];
        OverAllUsedTrNum = length(OverAllUsedInds);
        UsedNonRevTrChoiceAll = NonRevTrChoices(OverAllUsedInds);
        UsedNonRevBaseSubData = NonRevTrBaseSubData(OverAllUsedInds,:);
        
        % using nonReversing trials from baseline substracted data
        NonRevChoiceMD = fitcsvm(UsedNonRevBaseSubData(:,cAUnits), UsedNonRevTrChoiceAll);
        MDselfLoss = kfoldLoss(crossval(NonRevChoiceMD));
        
        rng('shuffle');
        ShufMD = fitcsvm(UsedNonRevBaseSubData(:,cAUnits), UsedNonRevTrChoiceAll(randperm(OverAllUsedTrNum)));
        
        % check model performance with testing reversing trials
        [RevTrChoicePred, predscores] = predict(NonRevChoiceMD,NMRevTrBaseSubData(:,cAUnits));
        RevTrChoicePredAccu = mean(NMRevTrChoices == RevTrChoicePred);
        
        ShufPreds = predict(ShufMD,NMRevTrBaseSubData(:,cAUnits));
        ShufPredAccu = mean(NMRevTrChoices == ShufPreds);
        
        AreaChoiceSVMaccu(cArea,cR,:) = [1-MDselfLoss, RevTrChoicePredAccu, ShufPredAccu];
        % tesing with raw response datas
        FramePredAccu = zeros(NumFrameBins,2);
        FramePredChoice = zeros(NumFrameBins,8);
        for cframe = 1 : NumFrameBins
            RespDataUsedMtxAll = NewBinnedDatas(NMTrInds,cAUnits,cframe);
            RawRespDataAllTrPred = predict(NonRevChoiceMD,RespDataUsedMtxAll);
            
            cRawResp_RevTrPredAccu = (RawRespDataAllTrPred(NMRevFreqIndsRaw) == NMTrActs(NMRevFreqIndsRaw));
            cRawResp_NonRevTrPredAccu = (RawRespDataAllTrPred(NonRevFreqIndsRaw) == NMTrActs(NonRevFreqIndsRaw));
            
            FramePredAccu(cframe,:) = [mean(cRawResp_RevTrPredAccu), mean(cRawResp_NonRevTrPredAccu)];
            
            % calculate Choice preference according to block types
            cRawResp_RevTrPredChoice_BL = RawRespDataAllTrPred(NMRevFreqIndsRaw & NMBlockTypes == 0 & NMTrActs == 0);
            cRawResp_RevTrPredChoice_BH = RawRespDataAllTrPred(NMRevFreqIndsRaw & NMBlockTypes == 1 & NMTrActs == 0);
            cRawResp_NRevTrPredChoice_BL = RawRespDataAllTrPred(NonRevFreqIndsRaw & NMBlockTypes == 0 & NMTrActs == 0);
            cRawResp_NRevTrPredChoice_BH = RawRespDataAllTrPred(NonRevFreqIndsRaw & NMBlockTypes == 1 & NMTrActs == 0);
            
            cRawResp_RevTrPredChoice_BL1 = RawRespDataAllTrPred(NMRevFreqIndsRaw & NMBlockTypes == 0 & NMTrActs == 1);
            cRawResp_RevTrPredChoice_BH1 = RawRespDataAllTrPred(NMRevFreqIndsRaw & NMBlockTypes == 1 & NMTrActs == 1);
            cRawResp_NRevTrPredChoice_BL1 = RawRespDataAllTrPred(NonRevFreqIndsRaw & NMBlockTypes == 0 & NMTrActs == 1);
            cRawResp_NRevTrPredChoice_BH1 = RawRespDataAllTrPred(NonRevFreqIndsRaw & NMBlockTypes == 1 & NMTrActs == 1);
            
            FramePredChoice(cframe,:) = [mean(cRawResp_RevTrPredChoice_BL),...
                mean(cRawResp_RevTrPredChoice_BH),mean(cRawResp_NRevTrPredChoice_BL),...
                mean(cRawResp_NRevTrPredChoice_BH),mean(cRawResp_RevTrPredChoice_BL1),...
                mean(cRawResp_RevTrPredChoice_BH1),mean(cRawResp_NRevTrPredChoice_BL1),...
                mean(cRawResp_NRevTrPredChoice_BH1)];
            
        end
        
        FrameAccu(cArea,cR,:,:) = FramePredAccu;
        FrameChoiceProb(cArea,cR,:,:) = FramePredChoice;
    end
    
end

AreaChoiceSVM_Avg = squeeze(mean(AreaChoiceSVMaccu,2));
AreaChoiceSVM_Thres = squeeze(prctile(AreaChoiceSVMaccu(:,:,3),95,2));

RepeatAvgFrameAccu = squeeze(mean(FrameAccu,2));
RepeatAvgFrameChoiceP = squeeze(mean(FrameChoiceProb,2));

% end
%%
save(fullfile(fullsavePath,'ChoiceSVMperfs_Data.mat'), 'FrameAccu', 'AreaChoiceSVMaccu', 'FrameChoiceProb',...
    'ExistField_ClusIDs', 'NewAdd_ExistAreaNames','AreaUnitNumbers','OutDataStrc',...
    'AreaChoiceSVM_Avg','RepeatAvgFrameAccu','RepeatAvgFrameChoiceP','AreaChoiceSVM_Thres','-v7.3');


%%
% figure('position',[50 450 780 360])
% cA = 7;
% cAChoicePData = squeeze(RepeatAvgFrameChoiceP(cA,:,:));
% % boxWin = ones(5,1)/5;
% % SMcAChoicePData = conv2(cAChoicePData,boxWin,'same');
% 
% FullFrameNum = size(cAChoicePData,1);
% % UsedInds = 3:(FullFrameNum-3);
% UsedInds = 1:FullFrameNum;
% % red colors indicate NonReversal trials
% subplot(121)
% hold on
% plot(cAChoicePData(UsedInds,1),'Color',[.7 .7 .7]);
% plot(cAChoicePData(UsedInds,3),'Color','k');
% plot(cAChoicePData(UsedInds,2),'Color',[1 0.4 0.4]);
% plot(cAChoicePData(UsedInds,4),'Color','r');
% line([11 11],[0 1],'linewidth',1.2,'Color','m','linestyle','--');
% title(sprintf('Left Choice, cA = %s',NewAdd_ExistAreaNames{cA}));
% 
% subplot(122)
% hold on
% plot(cAChoicePData(UsedInds,5),'Color',[.7 .7 .7]);
% plot(cAChoicePData(UsedInds,7),'Color','k');
% plot(cAChoicePData(UsedInds,6),'Color',[1 0.4 0.4]);
% plot(cAChoicePData(UsedInds,8),'Color','r');
% line([11 11],[0 1],'linewidth',1.2,'Color','m','linestyle','--');
% % title('Right Choice')
% title(sprintf('Right Choice, cA = %s',NewAdd_ExistAreaNames{cA}));
