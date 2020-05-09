% Ref: Fundamental bounds on the fidelity of sensory cortical coding
ActionInds = double(behavResults.Action_choice(:));
ActTrs = ActionInds(ActionInds ~= 2);
TrTypesAll = double(behavResults.Trial_Type(:));
TrTypes = TrTypesAll(ActionInds ~= 2);

% RespDataMtx = mean(data_aligned(:,:,30:59),3)/100;
RespDataMtx = mean(data_aligned(:,:,59:90),3)/100;
RespDataUsedMtx = RespDataMtx(ActionInds ~= 2,:);

%%
nTrs = length(TrTypes);

% [Xloadings,Yloadings,Xscores,Yscores,betaPLS10,PLSPctVar] = plsregress(...
% 	X,y,10);
MaxPlsDim = 50;
Repeat = 100;
NumCol_infos = zeros(Repeat,MaxPlsDim,2);
SVMLossAll = zeros(Repeat,MaxPlsDim,2);
for cR = 1 : Repeat
%     TrainInds = randsample(nTrs,round(nTrs/2));
    cc = cvpartition(nTrs,'kFold',3);
    TrainBaseAll = false(nTrs,1);
    pls_training_Inds = TrainBaseAll;
    pls_training_Inds(cc.training(1)) = true;
    
    FI_training_Inds = TrainBaseAll;
    FI_training_Inds(cc.training(2)) = true;
    
    Final_test_Inds = TrainBaseAll;
    Final_test_Inds(cc.training(3)) = true;
    
%     [T,P,U,Q,B,W] = pls(RespDataUsedMtx(pls_training_Inds,:),ActTrs(pls_training_Inds));
%     % T     score matrix of X
%     % P     loading matrix of X
%     % U     score matrix of Y
%     % Q     loading matrix of Y
%     % B     matrix of regression coefficient
%     % W     weight matrix of X
%     %
    [Xloadings,Yloadings,Xscores,Yscores,betaPLS10,PLSPctVar,MSE,stats] = plsregress(...
             RespDataUsedMtx(pls_training_Inds,:),ActTrs(pls_training_Inds),MaxPlsDim);
    
    FI_training_Data = RespDataUsedMtx(FI_training_Inds,:);
    FI_training_x0 = bsxfun(@minus, FI_training_Data, mean(FI_training_Data,1));
    Final_test_Data = RespDataUsedMtx(Final_test_Inds,:);
    Final_test_x0 = bsxfun(@minus, Final_test_Data, mean(Final_test_Data,1));
    
    FI_training_xScore = FI_training_x0 * stats.W;
    FI_training_TrTypes = TrTypes(FI_training_Inds);
    Final_test_xScore = Final_test_x0 * stats.W;
    Final_test_TrTypes = TrTypes(Final_test_Inds);
    
    for cCol = 1 : MaxPlsDim
        
        [ddRaw,~,~,TrainWeight] = PopuFICal_fun(FI_training_xScore(:,1:cCol),FI_training_TrTypes);
        FI_trainmd = fitcsvm(FI_training_xScore(:,1:cCol),FI_training_TrTypes);
        FI_trainloss = 1 - kfoldLoss(crossval(FI_trainmd));
        
        [ddTest,~,~,~] =  PopuFICal_fun(Final_test_xScore(:,1:cCol),Final_test_TrTypes,TrainWeight);
        Final_testmd = fitcsvm(FI_training_xScore(:,1:cCol),FI_training_TrTypes);
        Final_testloss = 1 - kfoldLoss(crossval(Final_testmd));
        NumCol_infos(cR,cCol,:) = [ddRaw,ddTest];
        
        SVMLossAll(cR,cCol,:) = [FI_trainloss,Final_testloss];
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
FI_Mean_all = squeeze(mean(NumCol_infos,1));
figure;plot(FI_Mean_all)

%%
SVMLoss_avg = squeeze(mean(SVMLossAll,1));
figure;plot(SVMLoss_avg)

