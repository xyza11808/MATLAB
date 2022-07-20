function [ExplainVarStrc, RegressorCoefs, RegressorPreds] = ...
    lassoelasticRegressor(Y, Predictors, cvfolds, varargin)

% function used to calcualte the task response regression coefficient, also
% calculate single and ommit certain task parameter R-squares

if size(Y,2) ~= 1
    Y = Y(:);
end

if ~iscell(Predictors)
    Predictors = {Predictors};
end
Predictor_Part_size = cellfun(@(x) size(x,2),Predictors);

NumofPredictorTypes = length(Predictors);

if ~exist('cvfolds','var') || isempty(cvfolds)
    cvfolds = 1;
end
Numofobservations = length(Y);

IsShufCal = 0;
if nargin > 3
    if ~isempty(varargin{1})
        IsShufCal = varargin{1};
    end
end

% full model dataset
predictorMtx_full = cat(2,Predictors{:});

alpha = 0.5;
lambda = 2.^(-12:0.4:-1);
opts = statset('UseParallel',false);

regressor_alone_idx = mat2cell(1:size(predictorMtx_full,2),1,Predictor_Part_size);
regressor_omitted_idx = cellfun(@(x) setdiff(1:size(predictorMtx_full,2),x), ...
    mat2cell(1:size(predictorMtx_full,2),1,Predictor_Part_size),'uni',false);

warning off
fullmodel_coefs = cell(cvfolds,1);
fullmodel_explain_var = zeros(cvfolds,2);
PartialMd_coefs = cell(cvfolds,NumofPredictorTypes,3);
PartialMd_explain_var = zeros(cvfolds,NumofPredictorTypes,3);
fullmodel_pred_datas = zeros(length(Y),1,'single');
PartialMD_pred_datas = zeros(length(Y),NumofPredictorTypes,3,'single');
FoldshufVarExplains = cell(cvfolds,1); 
% seperate whole datasets into train and tests
for cfold = 1 : cvfolds
    if cvfolds > 1
        if cfold == 1
            cv = cvpartition(Numofobservations,'kFold',cvfolds);
        end
        TrnInds = cv.training(cfold);
        TesInds = cv.test(cfold);
    else
        sampleIndex = randsample(Numofobservations,round(Numofobservations*0.8));
        TrnInds = false(Numofobservations,1);
        TrnInds(sampleIndex) = true;
        TesInds = ~TrnInds;
    end
    
    [B, Y_fitinfo] = lassoglm(predictorMtx_full(TrnInds,:),Y(TrnInds),'normal',...
        'Alpha',alpha,'CV',5,'Lambda',lambda,'RelTol',1e-2,'MaxIter',100,'Options',opts);
%     lassoPlot(B,Y_fitinfo,'plottype','CV'); 
    [TrainDevExplain, Test_explainVar, Y_pred, Y_Coefs] = ...
        EVcalfun(Y_fitinfo, B, Y(TrnInds), Y(TesInds), predictorMtx_full(TesInds,:));
    
    fullmodel_coefs{cfold} = Y_Coefs;
    fullmodel_pred_datas(TesInds) = Y_pred;
    fullmodel_explain_var(cfold,:) = [Test_explainVar, TrainDevExplain];
    
    if IsShufCal
        FoldshufVarExplains{cfold} = modelshufthres(predictorMtx_full(TrnInds,:),Y(TrnInds), Y_fitinfo.LambdaMinDeviance, alpha,...
            testPredictorMtx, Y(TesInds));
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
                [BPrt, Y_fitinfo_Prt] = lassoglm(predictorMtx_full(TrnInds,cCal_pred_inds),...
                    Y(TrnInds),'normal','Alpha',alpha,...
                     'CV',5,'Lambda',lambda,'RelTol',1e-2,'MaxIter',100,'Options',opts);
                [~,cv_partial_expVar,Y_partial_pred,cp_coefs] = ...
                    EVcalfun(Y_fitinfo_Prt, BPrt, Y(TrnInds), Y(TesInds), predictorMtx_full(TesInds,cCal_pred_inds));
                
                PartialMd_coefs{cfold,cpredictor,cCal} = cp_coefs;
                PartialMd_explain_var(cfold,cpredictor,cCal) = cv_partial_expVar;
                PartialMD_pred_datas(TesInds,cpredictor,cCal) = Y_partial_pred;
                
                % calculate residue fitting if perform
                % omitted_index_fitting
                if cCal == 1
                    % calculate single predictor fitting used residues
                    Y_predTrain = glmval(cp_coefs, predictorMtx_full(TrnInds,cCal_pred_inds), 'identity');
                    Residue_train = Y(TrnInds) - Y_predTrain;
                    Residue_test = Y(TesInds) - Y_partial_pred;
                    ResiAloneIndex = regressor_alone_idx{cpredictor};
                    
                    [BResi, Y_fitinfo_Resi] = lassoglm(predictorMtx_full(TrnInds,ResiAloneIndex),...
                        Residue_train,'normal','Alpha',alpha,...
                         'CV',5,'Lambda',lambda,'RelTol',1e-2,'MaxIter',100,'Options',opts);
                    [~,cv_partial_expVarR,Y_partial_predR,cp_coefsR] = ...
                        EVcalfun(Y_fitinfo_Resi, BResi, Residue_train, Residue_test, predictorMtx_full(TesInds,ResiAloneIndex));
                    
                    PartialMd_coefs{cfold,cpredictor,3} = cp_coefsR;
                    PartialMd_explain_var(cfold,cpredictor,3) = cv_partial_expVarR;
                    PartialMD_pred_datas(TesInds,cpredictor,3) = Y_partial_predR;
                end
                
            end
        end
    else
        PartialMD_pred_datas(TesInds,:,:) = mean(Y(TesInds));
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

% shuffled variance explaination calculation
function ReShuf_explainVar = modelshufthres(predictor, data, lambda, alpha,...
    predictor_test, data_test)
% num of repeats is 500, then calculate a threshold

numRepeats = 100;
ReShuf_explainVar = zeros(numRepeats,1);
ShufRandDatas = rand(size(predictor,1),numRepeats,'single');

parfor cR = 1 : numRepeats
    [~,randInds] = sort(ShufRandDatas(:,cR));
    [B, NewYFit] = lassoglm(predictor(randInds,:), data,'normal',...
        'Alpha',alpha,'lambda',lambda,'RelTol',1e-2,'MaxIter',100);
    predCoefs = [NewYFit.Intercept;B];
    
    Y_pred = glmval(predCoefs, predictor_test,'identity');
    
    ReShuf_explainVar(cR) = 1 - sum((data_test(:) - Y_pred(:)).^2)/...
        sum((data_test - mean(data_test)).^2);
    
end

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

