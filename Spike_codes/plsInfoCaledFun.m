function [NumCol_infos, TestPredAccu, Repeatpctvar,ShufScores] = plsInfoCaledFun(RespDataUsedMtx, TrTypes,MaxPlsDim)
% the trial type labels should only be 1 and 2, this function will not be
% checked to speed-up calculation

nTrs = size(RespDataUsedMtx,1);
% MaxPlsDim = 25; %min(25,MaxROINum);
Repeat = 500;
ShufRepeatNum = 4;
NumCol_infos = zeros(MaxPlsDim,2,Repeat);
TestPredAccu = zeros(MaxPlsDim,2,Repeat);
Repeatpctvar = zeros(MaxPlsDim,2,Repeat);
ShufScores = zeros(Repeat,MaxPlsDim,2,ShufRepeatNum);
TrainBaseAll = false(nTrs,1);
parfor cR = 1 : Repeat
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
    [~,~,~,~,~,PLSPctVar,~,stats] = plsregress(...
        RespDataUsedMtx(pls_training_Inds,:),TrTypes(pls_training_Inds),MaxPlsDim);
    Repeatpctvar(:,:,cR) = PLSPctVar';
    
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
        [DisScore,MdPerfs,~,~] = LDAclassifierFun(Merge_xScores, MergeTypesLabels, {TrainInds,TestInds},[],1);
        NumCol_infos(cCol,:,cR) = DisScore;
        TestPredAccu(cCol,:,cR) = MdPerfs;
        
        ShufInds = rand(ShufRepeatNum,numel(MergeTypesLabels));
        for cShuf = 1 : ShufRepeatNum
            [~, Inds] = sort(ShufInds(cShuf,:));
            [DisScore,~,~,~] = LDAclassifierFun(Merge_xScores, MergeTypesLabels(Inds), {TrainInds,TestInds},[],1);
            ShufScores(cR,cCol,:,cShuf) = DisScore;
            
        end
    end
end
