function [ExplainVarStrc, RegressorCoefs, RegressorPreds,UsedCompoValues] = ...
    rrr_lassoelasticRegressor(Y, Predictors, cvfolds, varargin)

% function used to calcualte the task response regression coefficient, also
% calculate single and ommit certain task parameter R-squares
% same as lassoelasticRegressor, but use a reduced-rank regressor approach
% to decrease overfitting fraction


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

EvarStepThres = 1e-5; % if the var change reach threshold, stop component search
UsedRankComponent = 2:50; % crossvalid to find optimal component numbers
if nargin > 3
    if ~isempty(varargin{1})
        UsedRankComponent = varargin{1}{1};
        EvarStepThres = varargin{1}{1};
    end
end

% full model dataset
predictorMtx_full = cat(2,Predictors{:});

% find reduced ranks
[~,b,~] = CanonCor2all({Y},{predictorMtx_full});
% unknown reason could cause b values into complex format, check and just
% use the real part to avoid lassofit error
if ~isreal(b)
    b = real(b);
end

alpha = 0.5;
lambda = 2.^(-12:0.4:-1);
opts = statset('UseParallel',false);

regressor_alone_idx = mat2cell(1:size(predictorMtx_full,2),1,Predictor_Part_size);
regressor_omitted_idx = cellfun(@(x) setdiff(1:size(predictorMtx_full,2),x), ...
    mat2cell(1:size(predictorMtx_full,2),1,Predictor_Part_size),'uni',false);

warning off
if length(UsedRankComponent) > 1
    % loop through all component numbers
    NumComponents = length(UsedRankComponent);
    rrmExplainVar = nan(NumComponents,1);
    for cCompInds = 1 : NumComponents

        PredMtx_WeightMtx = predictorMtx_full * b(:,1:UsedRankComponent(cCompInds));
        ccExplainVar = zeros(cvfolds, 1);
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

            [B, Y_fitinfo] = lassoglm(PredMtx_WeightMtx(TrnInds,:),Y(TrnInds),'normal',...
                'Alpha',alpha,'CV',5,'Lambda',lambda,'RelTol',1e-2,'MaxIter',100,'Options',opts);
        %     lassoPlot(B,Y_fitinfo,'plottype','CV'); 
            IdxMinDevianceLambda = Y_fitinfo.IndexMinDeviance;  % Y_fitinfo.LambdaMinDeviance
            Y_Coefs = [Y_fitinfo.Intercept(IdxMinDevianceLambda);B(:,IdxMinDevianceLambda)];

            testPredictorMtx = PredMtx_WeightMtx(TesInds,:);
            Y_pred = glmval(Y_Coefs, testPredictorMtx, 'identity');

            % overfitting can be observed by a negtive cv_full_explainVar values
            cv_full_explainVar = 1 - sum((Y(TesInds) - Y_pred(:)).^2)/...
                sum((Y(TesInds) - mean(Y(TesInds))).^2);

            ccExplainVar(cfold) = cv_full_explainVar;
        end

        rrmExplainVar(cCompInds) = mean(ccExplainVar);
        if cCompInds > 1
            if abs(rrmExplainVar(cCompInds)) - rrmExplainVar(cCompInds-1) <= EvarStepThres
                break;
            end
        end     
    end
    
    [~, maxInds] = max(rrmExplainVar);
    UsedCompoValues = UsedRankComponent(maxInds);
else
    UsedCompoValues = UsedRankComponent;
end

rrm_predMtx = predictorMtx_full * b(:,1:UsedCompoValues);

fullmodel_coefs = cell(cvfolds,1);
fullmodel_explain_var = zeros(cvfolds,2);
PartialMd_coefs = cell(cvfolds,NumofPredictorTypes,2);
PartialMd_explain_var = zeros(cvfolds,NumofPredictorTypes,2);
fullmodel_pred_datas = zeros(length(Y),1,'single');
PartialMD_pred_datas = zeros(length(Y),NumofPredictorTypes,2,'single');
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
    
    [B, Y_fitinfo] = lassoglm(rrm_predMtx(TrnInds,:),Y(TrnInds),'normal',...
        'Alpha',alpha,'CV',5,'Lambda',lambda,'RelTol',1e-2,'MaxIter',100,'Options',opts);
%     lassoPlot(B,Y_fitinfo,'plottype','CV'); 
    IdxMinDevianceLambda = Y_fitinfo.IndexMinDeviance;  % Y_fitinfo.LambdaMinDeviance
    Y_Coefs = [Y_fitinfo.Intercept(IdxMinDevianceLambda);B(:,IdxMinDevianceLambda)];
    fullmodel_coefs{cfold} = Y_Coefs;
    TrainNullDev = sum((Y(TrnInds) - mean(Y(TrnInds))).^2);
    % the training devEvr is used to calculate overfit ratio, which is.
    % (CV_train - CV_test)/CV_train, CV is the variance explained. This is
    % called "overfit-explained variance"
    TrainDevExplain = 1 - Y_fitinfo.Deviance(IdxMinDevianceLambda)/TrainNullDev;
    
    testPredictorMtx = rrm_predMtx(TesInds,:);
    Y_pred = glmval(Y_Coefs, testPredictorMtx, 'identity');
    
    % overfitting can be observed by a negtive cv_full_explainVar values
    cv_full_explainVar = 1 - sum((Y(TesInds) - Y_pred(:)).^2)/...
        sum((Y(TesInds) - mean(Y(TesInds))).^2);
    
    fullmodel_pred_datas(TesInds) = Y_pred;
    fullmodel_explain_var(cfold,:) = [cv_full_explainVar, TrainDevExplain];
    
    
    %%
    for cpredictor = 1 : NumofPredictorTypes
        for cCal = 1 : 2
            switch cCal
                case 1
                    cCal_pred_inds = regressor_omitted_idx{cpredictor};
                case 2
                    cCal_pred_inds = regressor_alone_idx{cpredictor};
            end
            
            % recal a reduced rank for current predictor
            cRegPredData = predictorMtx_full(:,cCal_pred_inds);
            if size(cRegPredData,2) <= 5
                cCal_rrm_predMtx = cRegPredData;
            else
                [~,b2,~] = CanonCor2all({Y},{cRegPredData});
                if ~isreal(b2)
                    b2 = real(b2);
                end
                MaxCompNums = size(cRegPredData,2);
                
                CompSerials = 2:min(MaxCompNums,30);
                NumSerialNums = length(CompSerials);
                % CV defined component number calculation
                CompExVarAlls = nan(NumSerialNums,1);
                for cComInds = 1 : NumSerialNums
                    cComp_predMtx = cRegPredData * b2(:,1:CompSerials(cComInds));
                    [BPrt, Y_fitinfo_Prt] = lassoglm(cComp_predMtx(TrnInds,:),...
                        Y(TrnInds),'normal','Alpha',alpha,...
                         'CV',5,'Lambda',lambda,'RelTol',1e-2,'MaxIter',100,'Options',opts);
                    IdxMinDevLambda_prt = Y_fitinfo_Prt.IndexMinDeviance;
                    PartialMd_coefs{cfold,cpredictor,cCal} = [Y_fitinfo_Prt.Intercept(IdxMinDevLambda_prt);...
                        BPrt(:,IdxMinDevLambda_prt)]; 

                    Y_partial_pred = glmval(PartialMd_coefs{cfold,cpredictor,cCal},...
                        cComp_predMtx(TesInds,:), 'identity');
                    CompExVarAlls(cComInds) = 1 - sum((Y_partial_pred(:) - Y(TesInds)).^2)/...
                        sum((Y(TesInds) - mean(Y(TesInds))).^2);
                    if cComInds > 1
                        if abs(CompExVarAlls(cComInds) - CompExVarAlls(cComInds-1)) <= EvarStepThres
                            break;
                        end
                    end
                end
                [~,maxInds] = max(CompExVarAlls);
                cCal_rrm_predMtx = cRegPredData * b2(:,1:CompSerials(maxInds));
            end
            
            [BPrt, Y_fitinfo_Prt] = lassoglm(cCal_rrm_predMtx(TrnInds,:),...
                Y(TrnInds),'normal','Alpha',alpha,...
                 'CV',5,'Lambda',lambda,'RelTol',1e-2,'MaxIter',100,'Options',opts);
            IdxMinDevLambda_prt = Y_fitinfo_Prt.IndexMinDeviance;
            PartialMd_coefs{cfold,cpredictor,cCal} = [Y_fitinfo_Prt.Intercept(IdxMinDevLambda_prt);...
                BPrt(:,IdxMinDevLambda_prt)]; 
            
            Y_partial_pred = glmval(PartialMd_coefs{cfold,cpredictor,cCal},...
                cCal_rrm_predMtx(TesInds,:), 'identity');
            cv_partial_expVar = 1 - sum((Y_partial_pred(:) - Y(TesInds)).^2)/...
                sum((Y(TesInds) - mean(Y(TesInds))).^2);
            
            PartialMd_explain_var(cfold,cpredictor,cCal) = cv_partial_expVar;
            PartialMD_pred_datas(TesInds,cpredictor,cCal) = Y_partial_pred;
        end
    end
%%
end


ExplainVarStrc.fullmodel_explain_var = fullmodel_explain_var;
ExplainVarStrc.PartialMd_explain_var = PartialMd_explain_var;

RegressorCoefs.fullmodel_coefs = fullmodel_coefs;
RegressorCoefs.PartialMd_coefs = PartialMd_coefs;

RegressorPreds.fullmodel_pred_datas = fullmodel_pred_datas;
RegressorPreds.PartialMD_pred_datas = PartialMD_pred_datas;

warning on



