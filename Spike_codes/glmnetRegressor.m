function [ExplainVarStrc, RegressorCoefs, RegressorPreds] = ...
    glmnetRegressor(Y, Predictors, cvfolds, varargin)

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

IsShufCal = 1;
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
fullmodel_explain_var = zeros(cvfolds,1);
PartialMd_coefs = cell(cvfolds,NumofPredictorTypes,2);
PartialMd_explain_var = zeros(cvfolds,NumofPredictorTypes,2);
fullmodel_pred_datas = zeros(length(Y),1,'single');
PartialMD_pred_datas = zeros(length(Y),NumofPredictorTypes,2,'single');
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
    IdxMinDevianceLambda = Y_fitinfo.IndexMinDeviance;  % Y_fitinfo.LambdaMinDeviance
    Y_Coefs = [Y_fitinfo.Intercept(IdxMinDevianceLambda);B(:,IdxMinDevianceLambda)];
    fullmodel_coefs{cfold} = Y_Coefs;
    
    testPredictorMtx = predictorMtx_full(TesInds,:);
    Y_pred = glmval(Y_Coefs, testPredictorMtx, 'identity');
    cv_full_explainVar = 1 - sum((Y(TesInds) - Y_pred(:)).^2)/...
        sum((Y(TesInds) - mean(Y(TesInds))).^2);
    
    fullmodel_pred_datas(TesInds) = Y_pred;
    fullmodel_explain_var(cfold) = cv_full_explainVar;
    
    if IsShufCal
        FoldshufVarExplains{cfold} = modelshufthres(predictorMtx_full(TrnInds,:),Y(TrnInds), Y_fitinfo.LambdaMinDeviance, alpha,...
            testPredictorMtx, Y(TesInds));
    end
    %%
    parfor cpredictor = 1 : NumofPredictorTypes
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
            IdxMinDevLambda_prt = Y_fitinfo_Prt.IndexMinDeviance;
            PartialMd_coefs{cfold,cpredictor,cCal} = [Y_fitinfo_Prt.Intercept(IdxMinDevLambda_prt);...
                BPrt(:,IdxMinDevLambda_prt)]; 
            
            Y_partial_pred = glmval(PartialMd_coefs{cfold,cpredictor,cCal},...
                predictorMtx_full(TesInds,cCal_pred_inds), 'identity');
            cv_partial_expVar = 1 - sum((Y_partial_pred(:) - Y(TesInds)).^2)/...
                sum((Y(TesInds) - mean(Y(TesInds))).^2);
            
            PartialMd_explain_var(cfold,cpredictor,cCal) = cv_partial_expVar;
            PartialMD_pred_datas(TesInds,cpredictor,cCal) = Y_partial_pred;
        end
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


