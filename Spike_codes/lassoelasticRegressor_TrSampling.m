function [ExplainVarStrc, RegressorCoefs, RegressorPreds] = ...
    lassoelasticRegressor_TrSampling(Y, Predictors, cvfolds, trainFrac, varargin)

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
    cvfolds = 100;
end

IsShufCal = 0;
if nargin > 4
    if ~isempty(varargin{1})
        IsShufCal = varargin{1};
    end
end

alpha = 0.5;
lambda = 2.^(-12:0.4:-1);
opts = statset('UseParallel',false);

regressor_alone_idx = mat2cell(1:TotalpredictorSize,1,Predictor_Part_size);
regressor_omitted_idx = cellfun(@(x) setdiff(1:TotalpredictorSize,x), ...
    mat2cell(1:TotalpredictorSize,1,Predictor_Part_size),'uni',false);


warning off
fullmodel_coefs = cell(cvfolds,1);
fullmodel_explain_var = zeros(cvfolds,2);
PartialMd_coefs = cell(cvfolds,NumofPredictorTypes,3);
PartialMd_explain_var = zeros(cvfolds,NumofPredictorTypes,3);
fullmodel_pred_datas = cell(length(Y),1);
PartialMD_pred_datas = cell(length(Y),NumofPredictorTypes,3);
FoldshufVarExplains = cell(cvfolds,1); 

Numoftrials = length(Y);
TrainTrNum = round(Numoftrials*trainFrac);
TrainTrInds_base = false(Numoftrials, 1);
% seperate whole datasets into train and tests
for cfold = 1 : cvfolds
    
    cfold_trainTrs = randsample(Numoftrials, TrainTrNum);
    cTrainTrInds = TrainTrInds_base;
    cTrainTrInds(cfold_trainTrs) = true;
    cTestTrInds = ~cTrainTrInds;
    
    % get train data
    TrainYData = cat(1, Y{cTrainTrInds});
    Train_xData_C = cellfun(@(x) cat(1,x{cTrainTrInds}),Predictors,'un',0);
    predictorMtx_train = cat(2,Train_xData_C{:});
    
    testYData = cat(1, Y{cTestTrInds});
    Test_xData_C = cellfun(@(x) cat(1,x{cTestTrInds}),Predictors,'un',0);
    predictorMtx_test = cat(2,Test_xData_C{:});
    
    [B, Y_fitinfo] = lassoglm(predictorMtx_train,TrainYData,'normal',...
        'Alpha',alpha,'CV',5,'Lambda',lambda,'RelTol',1e-2,'MaxIter',100,'Options',opts);
%     lassoPlot(B,Y_fitinfo,'plottype','CV'); 
    [TrainDevExplain, Test_explainVar, Y_pred, Y_Coefs] = ...
        EVcalfun(Y_fitinfo, B, TrainYData, testYData, predictorMtx_test);
    
    fullmodel_coefs{cfold} = Y_Coefs;
    fullmodel_pred_datas(cTestTrInds) = dataVec2Cell(Y_pred,Y(cTestTrInds));
    fullmodel_explain_var(cfold,:) = [Test_explainVar, TrainDevExplain];
    
    if IsShufCal
        FoldshufVarExplains{cfold} = modelshufthres(predictorMtx_train,TrainYData, Y_fitinfo.LambdaMinDeviance, alpha,...
            predictorMtx_test, testYData);
    end
    %%
    if mean(fullmodel_explain_var(cfold,:)) > 0.01 % increase calculation speed
        for cpredictor = 1 : NumofPredictorTypes
            for cCal = 1 : 2
                switch cCal
                    case 1
                        cCal_pred_inds = regressor_omitted_idx{cpredictor};
                    case 2
                        cCal_pred_inds = regressor_alone_idx{cpredictor};
                end

    %             Y_partial_fits = glmnet(predictorMtx_full(TrnInds,cCal_pred_inds),...
    %                 Y(TrnInds),'gaussian',opts);
                [BPrt, Y_fitinfo_Prt] = lassoglm(predictorMtx_train(:,cCal_pred_inds),...
                    TrainYData,'normal','Alpha',alpha,...
                     'CV',5,'Lambda',lambda,'RelTol',1e-2,'MaxIter',100,'Options',opts);
                [~,cv_partial_expVar,Y_partial_pred,cp_coefs] = ...
                    EVcalfun(Y_fitinfo_Prt, BPrt, TrainYData, testYData, predictorMtx_test(:,cCal_pred_inds));
                
                PartialMd_coefs{cfold,cpredictor,cCal} = cp_coefs;
                PartialMd_explain_var(cfold,cpredictor,cCal) = cv_partial_expVar;
                PartialMD_pred_datas(cTestTrInds,cpredictor,cCal) = dataVec2Cell(Y_partial_pred, Y(cTestTrInds));
                
                % calculate residue fitting if perform
                % omitted_index_fitting
                if cCal == 1
                    % calculate single predictor fitting used residues
                    Y_predTrain = glmval(cp_coefs, predictorMtx_train(:,cCal_pred_inds), 'identity');
                    Residue_train = TrainYData - Y_predTrain;
                    Residue_test = testYData - Y_partial_pred;
                    ResiAloneIndex = regressor_alone_idx{cpredictor};
                    
                    [BResi, Y_fitinfo_Resi] = lassoglm(predictorMtx_train(:,ResiAloneIndex),...
                        Residue_train,'normal','Alpha',alpha,...
                         'CV',5,'Lambda',lambda,'RelTol',1e-2,'MaxIter',100,'Options',opts);
                    [~,cv_partial_expVarR,Y_partial_predR,cp_coefsR] = ...
                        EVcalfun(Y_fitinfo_Resi, BResi, Residue_train, Residue_test, predictorMtx_test(:,ResiAloneIndex));
                    
                    PartialMd_coefs{cfold,cpredictor,3} = cp_coefsR;
                    PartialMd_explain_var(cfold,cpredictor,3) = cv_partial_expVarR;
                    PartialMD_pred_datas(cTestTrInds,cpredictor,3) = dataVec2Cell(Y_partial_predR, Y(cTestTrInds));
                end
                
            end
        end
    else
        PartialMD_pred_datas(cTestTrInds,:,:) = mean(testYData);
    end
%%
end

ExplainVarStrc.fullmodel_explain_var = fullmodel_explain_var;
ExplainVarStrc.fullmodel_ShufEVar = FoldshufVarExplains;
ExplainVarStrc.PartialMd_explain_var = PartialMd_explain_var;

RegressorCoefs.fullmodel_coefs = fullmodel_coefs;
RegressorCoefs.PartialMd_coefs = PartialMd_coefs;

RegressorPreds.fullmodel_pred_datas = fullmodel_pred_datas;
RegressorPreds.PartialMD_pred_datas = PartialMD_pred_datas;

warning on

function [TrainDevExplain, Test_explainVar, Y_pred, Y_Coefs] = ...
    EVcalfun(FitInfo, B, TrainY, TestY, TestX)
%
IdxMinDevianceLambda = FitInfo.IndexMinDeviance;  % Y_fitinfo.LambdaMinDeviance
Y_Coefs = [FitInfo.Intercept(IdxMinDevianceLambda);B(:,IdxMinDevianceLambda)];

TrainNullDev = sum((TrainY - mean(TrainY)).^2);
% the training devEvr is used to calculate overfit ratio, which is.
% (CV_train - CV_test)/CV_train, CV is the variance explained. This is
% called "overfit-explained variance"
TrainDevExplain = 1 - FitInfo.Deviance(IdxMinDevianceLambda)/TrainNullDev;

% testPredictorMtx = predictorMtx_full(TesInds,:);
Y_pred = glmval(Y_Coefs, TestX, 'identity');

% overfitting can be observed by a negtive cv_full_explainVar values
Test_explainVar = 1 - sum((TestY - Y_pred(:)).^2)/...
    sum((TestY - mean(TestY)).^2);



function dataCell = dataVec2Cell(datadVec,TemplateCell)
CellEleSize = cellfun(@numel, TemplateCell);
dataCell = mat2cell(datadVec, CellEleSize);





