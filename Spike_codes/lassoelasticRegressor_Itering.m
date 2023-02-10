function varargout = ...
    lassoelasticRegressor_Itering(Y, Predictors, cvfolds, varargin)

% this function performs random sampling on trials to calculate final EVars
% so the Y and predictor input must be cell array with a length of total
% used trial numbers. CVfolds should be larger than normally used
% cross-validation number, beacause here this value is more likely be a
% repeat numbers

if ~iscell(Y)
    warning('Y must be a cell array.');
    return;
end
if ~iscell(Predictors)
    warning('Predictors must be a cell array.');
    return;
end

if size(Y,2) ~= 1
    Y = Y(:);
end

NumofPredictorTypes = length(Predictors); % each elements is full trial datas for one predictor type
SizeProbeDatas = cellfun(@(x) x{1},Predictors,'un',0);
Predictor_Part_size = cellfun(@(x) size(x,2),SizeProbeDatas);
TotalpredictorSize = sum(Predictor_Part_size);

if ~exist('cvfolds','var') || isempty(cvfolds)
    cvfolds = 5;
end

alpha = 0.5;
lambda = 2.^(-15:0.4:-1);
opts = statset('UseParallel',false);

regressor_alone_idx = mat2cell(1:TotalpredictorSize,1,Predictor_Part_size);

regressor_CumsumInds = [0,cumsum(Predictor_Part_size)];

% regressor_omitted_idx = cellfun(@(x) setdiff(1:TotalpredictorSize,x), ...
%     mat2cell(1:TotalpredictorSize,1,Predictor_Part_size),'uni',false);

PredictorsRaw = Predictors;
warning off
IterNums = 5;
% InitCoefsFactor = [1,1,1];
AllCoefFactor = zeros(IterNums+1, NumofPredictorTypes);
AllCoefFactor(1,:) = ones(1,NumofPredictorTypes);

AllIterPreds = cell(IterNums,2);
AllIterCoefs = cell(IterNums,2);
AllIterEVars = cell(IterNums,2);
for iters = 1 : IterNums % two-step itering
cIterCoefFactor = num2cell(AllCoefFactor(iters,:));
Numoftrials = length(Y);
% TrainTrNum = round(Numoftrials*trainFrac);
% TrainTrInds_base = false(Numoftrials, 1);
cv = cvpartition(Numoftrials,'kFold',cvfolds);
% seperate whole datasets into train and tests

% step 1, fit parameters with coef fixed
iterStep1Preds = cell(length(Y),2);
iterStep1Coefs = cell(cvfolds,1);
iterStep1EVars = zeros(cvfolds, 3);
for cfold = 1 : cvfolds
    
    cTrainTrInds = cv.training(cfold);
    cTestTrInds = cv.test(cfold);
    
    % get train data
    TrainYData = single(cat(1, Y{cTrainTrInds}));
    Train_xData_C = cellfun(@(x,y) cat(1,x{cTrainTrInds})*y,Predictors,cIterCoefFactor,'un',0);
    predictorMtx_train = cat(2,Train_xData_C{:});
    
    testYData = single(cat(1, Y{cTestTrInds}));
    Test_xData_C = cellfun(@(x,y) cat(1,x{cTestTrInds})*y,Predictors,cIterCoefFactor,'un',0);
    predictorMtx_test = cat(2,Test_xData_C{:});
    
    % random split datas into 90/10 prctile, this sampling allows the row
    % connections between columns being randomlized to allow a stable fit,
    % do know exactly why but this random split will do the trick
    RSlogiInds = false(numel(TrainYData),1);
    RSInds = randsample(numel(TrainYData), round(numel(TrainYData)*0.9));
    RSlogiInds(RSInds) = true;
    [B, Y_fitinfo] = lassoglm(predictorMtx_train(RSInds,:),TrainYData(RSInds),'normal',...
        'Alpha',alpha,'CV',5,'Lambda',lambda,'RelTol',1e-2,'MaxIter',200,'Options',opts);
    [~, TrainValid_Var, ~, ~] = ...
        EVcalfun(Y_fitinfo, B, TrainYData(RSlogiInds), TrainYData(~RSlogiInds), predictorMtx_train(~RSlogiInds,:));
    
%     lassoPlot(B,Y_fitinfo,'plottype','CV'); 
    [TrainDevExplain, Test_explainVar, Y_pred, Y_Coefs] = ...
        EVcalfun(Y_fitinfo, B, TrainYData, testYData, predictorMtx_test);
    iterStep1EVars(cfold,:) = [TrainDevExplain, Test_explainVar,TrainValid_Var];
    iterStep1Preds(cTestTrInds,1) = dataVec2Cell(Y_pred,Y(cTestTrInds));
    iterStep1Preds{cTestTrInds,2} = cTestTrInds;
    iterStep1Coefs{cfold} = Y_Coefs;
    
end
if mean(iterStep1EVars(:,2)) < 0.02
    break;
end
AllCoefs = cat(2,iterStep1Coefs{:});
AllIterCoefsUsed = mean(AllCoefs(2:end,:),2);

NewPredictors = cell(1,NumofPredictorTypes);
% calculate the response for each predictor using averaged coefs
for ctype = 1 : NumofPredictorTypes
    cTypeCoefs = AllIterCoefsUsed(regressor_CumsumInds(ctype)+1:regressor_CumsumInds(ctype+1)); %vec
    cTypeRatio = cIterCoefFactor{ctype};
    NewPredictors{ctype} = cellfun(@(x) x*cTypeCoefs*cTypeRatio, Predictors{ctype},'un',0);
end
% step 2, varied coefficients
cv2 = cvpartition(Numoftrials,'kFold',cvfolds);
iterStep2Preds = cell(length(Y),2);
iterStep2Coefs = cell(cvfolds,1);
iterStep2EVars = zeros(cvfolds, 2);
for cfold = 1 : cvfolds
    
    cTrainTrInds = cv2.training(cfold);
    cTestTrInds = cv2.test(cfold);
    
    % get train data
    TrainYData = cat(1, Y{cTrainTrInds});
    Train_xData_C = cellfun(@(x) cat(1,x{cTrainTrInds}),NewPredictors,'un',0);
    predictorMtx_train = cat(2,Train_xData_C{:});
    
    testYData = cat(1, Y{cTestTrInds});
    Test_xData_C = cellfun(@(x) cat(1,x{cTestTrInds}),NewPredictors,'un',0);
    predictorMtx_test = cat(2,Test_xData_C{:});
    
    [B2, Y_fitinfo2] = lassoglm(predictorMtx_train,TrainYData,'normal',...
        'Alpha',alpha,'CV',5,'Lambda',lambda,'RelTol',1e-2,'MaxIter',100,'Options',opts);
%     lassoPlot(B,Y_fitinfo,'plottype','CV'); 
    [TrainDevExplain, Test_explainVar, Y_pred, Y_Coefs2] = ...
        EVcalfun(Y_fitinfo2, B2, TrainYData, testYData, predictorMtx_test);
    iterStep2EVars(cfold,:) = [TrainDevExplain, Test_explainVar];
    iterStep2Preds(cTestTrInds,1) = dataVec2Cell(Y_pred,Y(cTestTrInds));
    iterStep2Preds{cTestTrInds,2} = cTestTrInds;
    iterStep2Coefs{cfold} = Y_Coefs2;
end

AllCoefs2 = cat(2,iterStep2Coefs{:});
AllIterCoefsUsed2 = mean(AllCoefs2(2:end,:),2);
AllIterCoefsUsed2(AllIterCoefsUsed2 < 1e-5) = 1; % exclude low values
AllCoefFactor(iters+1,:) = AllIterCoefsUsed2 .* AllCoefFactor(iters,:)';

AllIterPreds(iters,:) = {iterStep1Preds, iterStep2Preds};
AllIterCoefs(iters,:) = {iterStep1Coefs, iterStep2Coefs};
AllIterEVars(iters,:) = {iterStep1EVars, iterStep2EVars};

end

varargout = {AllIterPreds,AllIterCoefs,AllIterEVars,AllCoefFactor};
%     %%
%     if mean(fullmodel_explain_var(cfold,:)) > 0.01 % increase calculation speed
%         for cpredictor = 1 : NumofPredictorTypes
%             for cCal = 1 : 2
%                 switch cCal
%                     case 1
%                         cCal_pred_inds = regressor_omitted_idx{cpredictor};
%                     case 2
%                         cCal_pred_inds = regressor_alone_idx{cpredictor};
%                 end
% 
%     %             Y_partial_fits = glmnet(predictorMtx_full(TrnInds,cCal_pred_inds),...
%     %                 Y(TrnInds),'gaussian',opts);
%                 [BPrt, Y_fitinfo_Prt] = lassoglm(predictorMtx_train(:,cCal_pred_inds),...
%                     TrainYData,'normal','Alpha',alpha,...
%                      'CV',5,'Lambda',lambda,'RelTol',1e-2,'MaxIter',100,'Options',opts);
%                 [~,cv_partial_expVar,Y_partial_pred,cp_coefs] = ...
%                     EVcalfun(Y_fitinfo_Prt, BPrt, TrainYData, testYData, predictorMtx_test(:,cCal_pred_inds));
%                 
%                 PartialMd_coefs{cfold,cpredictor,cCal} = cp_coefs;
%                 PartialMd_explain_var(cfold,cpredictor,cCal) = cv_partial_expVar;
%                 PartialMD_pred_datas(cTestTrInds,cpredictor,cCal) = dataVec2Cell(Y_partial_pred, Y(cTestTrInds));
%                 
%                 % calculate residue fitting if perform
%                 % omitted_index_fitting
%                 if cCal == 1
%                     % calculate single predictor fitting used residues
%                     Y_predTrain = glmval(cp_coefs, predictorMtx_train(:,cCal_pred_inds), 'identity');
%                     Residue_train = TrainYData - Y_predTrain;
%                     Residue_test = testYData - Y_partial_pred;
%                     ResiAloneIndex = regressor_alone_idx{cpredictor};
%                     
%                     [BResi, Y_fitinfo_Resi] = lassoglm(predictorMtx_train(:,ResiAloneIndex),...
%                         Residue_train,'normal','Alpha',alpha,...
%                          'CV',5,'Lambda',lambda,'RelTol',1e-2,'MaxIter',100,'Options',opts);
%                     [~,cv_partial_expVarR,Y_partial_predR,cp_coefsR] = ...
%                         EVcalfun(Y_fitinfo_Resi, BResi, Residue_train, Residue_test, predictorMtx_test(:,ResiAloneIndex));
%                     
%                     PartialMd_coefs{cfold,cpredictor,3} = cp_coefsR;
%                     PartialMd_explain_var(cfold,cpredictor,3) = cv_partial_expVarR;
%                     PartialMD_pred_datas(cTestTrInds,cpredictor,3) = dataVec2Cell(Y_partial_predR, Y(cTestTrInds));
%                 end
%                 
%             end
%         end
%     else
%         PartialMD_pred_datas(cTestTrInds,:,:) = mean(testYData);
%     end
%
function [TrainDevExplain, Test_explainVar, Y_pred, Y_Coefs] = ...
    EVcalfun(FitInfo, B, TrainY, TestY, TestX)
%
IdxMinDevianceLambda = FitInfo.Index1SE;  % Y_fitinfo.LambdaMinDeviance
Y_Coefs = [FitInfo.Intercept(IdxMinDevianceLambda);B(:,IdxMinDevianceLambda)];

TrainNullDev = sum((TrainY - mean(TrainY)).^2);
% the training devEvr is used to calculate overfit ratio, which is.
% (CV_train - CV_test)/CV_train, CV is the variance explained. This is
% called "overfit-explained variance"
TrainDevExplain = 1 - FitInfo.Deviance(IdxMinDevianceLambda)/TrainNullDev;

% testPredictorMtx = predictorMtx_full(TesInds,:);
Y_pred = glmval(Y_Coefs, TestX, 'identity');

% overfitting can be observed by a negtive Test_explainVar values
Test_explainVar = 1 - sum((TestY - Y_pred(:)).^2)/...
    sum((TestY - mean(TestY)).^2);



function dataCell = dataVec2Cell(datadVec,TemplateCell)
CellEleSize = cellfun(@numel, TemplateCell);
dataCell = mat2cell(datadVec, CellEleSize);





