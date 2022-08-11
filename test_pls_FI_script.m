% Ref: Fundamental bounds on the fidelity of sensory cortical coding

%
OutDataStrc = ProbNPSess.TrigPSTH_Ext([-1 5],[300 100],ProbNPSess.StimAlignedTime{ProbNPSess.CurrentSessInds});
NewBinnedDatas = permute(cat(3,OutDataStrc.TrigData_Bin{:,1}),[1,3,2]);


%% find target cluster inds and IDs
ksfolder = pwd;

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
ActionInds = double(behavResults.Action_choice(:));
NMTrInds = ActionInds ~= 2;
ActTrs = ActionInds(NMTrInds);
TrTypesAll = double(behavResults.Action_choice(:)); % Action_choice / BlockType
TrTypes = TrTypesAll(NMTrInds);

% % % RespDataMtx = mean(data_aligned(:,:,59:90),3)/100;
% % % RespDataUsedMtx = RespDataMtx(ActionInds ~= 2,:);
% RespDataUsedMtx = NewBinnedDatas(NMTrInds,ExistField_ClusIDs{3,2},OutDataStrc.TriggerStartBin+(1:20));
AllUnits = cat(1,ExistField_ClusIDs{:,2});
RespDataUsedMtx = NewBinnedDatas(NMTrInds,AllUnits,OutDataStrc.TriggerStartBin+(1:20));
RespDataUsedMtx = mean(RespDataUsedMtx,3);
MaxROINum = size(RespDataUsedMtx,2);

% LabelMtx = reshape((repmat(TrTypes(:),1,size(RespDataUsedMtx,3)))',[],1);
% TemporalMergeRespData = reshape(permute(RespDataUsedMtx,[2,3,1]),MaxROINum,[])';
% TrTypes = LabelMtx;
% RespDataUsedMtx = TemporalMergeRespData;

%%


nTrs = length(TrTypes);

% [Xloadings,Yloadings,Xscores,Yscores,betaPLS10,PLSPctVar] = plsregress(...
% 	X,y,10);
MaxPlsDim = min(50,MaxROINum);
Repeat = 50;
NumCol_infos = zeros(Repeat,MaxPlsDim,2);
SVMLossAll = zeros(Repeat,MaxPlsDim,2);
TrainBaseAll = false(nTrs,1);
for cR = 1 : Repeat
%     TrainInds = randsample(nTrs,round(nTrs/2));
    cc = cvpartition(nTrs,'kFold',3);
    
    pls_training_Inds = TrainBaseAll;
    pls_training_Inds(cc.test(1)) = true;
    
    FI_training_Inds = TrainBaseAll;
    FI_training_Inds(cc.test(2)) = true;
    
    Final_test_Inds = TrainBaseAll;
    Final_test_Inds(cc.test(3)) = true;
    
%     [T,P,U,Q,B,W] = pls(RespDataUsedMtx(pls_training_Inds,:),ActTrs(pls_training_Inds));
%     % T     score matrix of X
%     % P     loading matrix of X
%     % U     score matrix of Y
%     % Q     loading matrix of Y
%     % B     matrix of regression coefficient
%     % W     weight matrix of X
%     %
    [Xloadings,Yloadings,Xscores,Yscores,betaPLS10,PLSPctVar,MSE,stats] = plsregress(...
             RespDataUsedMtx(pls_training_Inds,:),TrTypes(pls_training_Inds),MaxPlsDim);
    
    FI_training_Data = RespDataUsedMtx(FI_training_Inds,:);
    FI_training_x0 = bsxfun(@minus, FI_training_Data, mean(FI_training_Data,1));
    Final_test_Data = RespDataUsedMtx(Final_test_Inds,:);
    Final_test_x0 = bsxfun(@minus, Final_test_Data, mean(Final_test_Data,1));
    
    FI_training_xScore = FI_training_x0 * stats.W;
    FI_training_TrTypes = TrTypes(FI_training_Inds);
    Final_test_xScore = Final_test_x0 * stats.W;
    Final_test_TrTypes = TrTypes(Final_test_Inds);
    
    for cCol = 1 : MaxPlsDim
        
%         [ddRaw,~,~,TrainWeight] = PopuFICal_fun(FI_training_xScore(:,1:cCol),FI_training_TrTypes);
%         FI_trainmd = fitcsvm(FI_training_xScore(:,1:cCol),FI_training_TrTypes);
%         FI_trainloss = 1 - kfoldLoss(crossval(FI_trainmd));
%         
%         [ddTest,~,~,~] =  PopuFICal_fun(Final_test_xScore(:,1:cCol),Final_test_TrTypes,TrainWeight);
%         TestDataPredTypes = predict(FI_trainmd, Final_test_xScore(:,1:cCol));
%         Final_testloss = mean(TestDataPredTypes == Final_test_TrTypes(:));
%         NumCol_infos(cR,cCol,:) = [ddRaw,ddTest];
%         SVMLossAll(cR,cCol,:) = [FI_trainloss,Final_testloss];
        
        MergeTypesLabels = [FI_training_TrTypes;Final_test_TrTypes];
        Merge_xScores = [FI_training_xScore(:,1:cCol);Final_test_xScore(:,1:cCol)];
        MergeAllSampleNums = numel(MergeTypesLabels);
        TrainInds = false(MergeAllSampleNums,1);
        TrainInds(1:numel(FI_training_TrTypes)) = true;
        TestInds = ~TrainInds;
        [DisScore,MdPerfs,~,~] = LDAclassifierFun(Merge_xScores, MergeTypesLabels, {TrainInds,TestInds});
        NumCol_infos(cR,cCol,:) = DisScore;
        SVMLossAll(cR,cCol,:) = MdPerfs;
        
    end
end

% T(:,1) = RespDataUsedMtx(pls_training_Inds,:) * W(:,1);
% xx1 = RespDataUsedMtx(pls_training_Inds,:) - T(:,1) * P(:,1)';
% yy = xx1 * W(:,2);
% xx2 = xx1 - T(:,2) * P(:,2)';
% yy = xx2 * W(:,3);

%%
VarExp = cumsum(100*PLSPctVar(1,:));
figure;plot(VarExp)

%%
SVMLoss_avg = squeeze(mean(SVMLossAll,1));
FIDiffDatas = diff(SVMLoss_avg(:,2));
UsedPCnums = find(FIDiffDatas < 0.5,1,'first');

figure;plot(SVMLoss_avg)
hold on
plot(UsedPCnums,SVMLoss_avg(UsedPCnums,:),'ro')

%%
FI_Mean_all = squeeze(mean(NumCol_infos,1));
figure;plot(FI_Mean_all)

% FIDiffDatas = diff(FI_Mean_all(:,2));
% UsedPCnums = find(FIDiffDatas < 0.01,1,'first')+1;
hold on
plot(UsedPCnums,FI_Mean_all(UsedPCnums,:),'ro')


