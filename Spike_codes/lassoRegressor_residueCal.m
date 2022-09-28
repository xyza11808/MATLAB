function [PredANDResidueDataCell, Eventmodel_explain_var, EventResidue] = ...
    lassoRegressor_residueCal(Y, Predictors, cvfolds, varargin)

% function used to calcualte the task response regression coefficient, also
% calculate single and ommit certain task parameter R-squares

if size(Y,2) ~= 1
    Y = Y(:);
end

if ~iscell(Predictors)
    Predictors = {Predictors};
end

NumofPredictorTypes = length(Predictors);

if ~exist('cvfolds','var') || isempty(cvfolds)
    cvfolds = 1;
end
Numofobservations = length(Y);

alpha = 0.5;
lambda = 2.^(-14:0.4:-2);
opts = statset('UseParallel',false);

PredANDResidueDataCell = cell(NumofPredictorTypes,1);
% calculate the residue matrix for each factors
EventResidue = cell(NumofPredictorTypes,cvfolds,3);
Eventmodel_explain_var = cell(NumofPredictorTypes,cvfolds,3);
for cEvent = 1 : NumofPredictorTypes
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
        
        [B, Y_fitinfo] = lassoglm(Predictors{cEvent}(TrnInds,:),Y(TrnInds),'normal',...
            'Alpha',alpha,'CV',5,'Lambda',lambda,'RelTol',1e-2,'MaxIter',100,'Options',opts);
        %     lassoPlot(B,Y_fitinfo,'plottype','CV');
        [TrainDevExplain, Test_explainVar, Y_pred, Y_Coefs] = ...
            EVcalfun(Y_fitinfo, B, Y(TrnInds), Y(TesInds), Predictors{cEvent}(TesInds,:));
        
        Eventmodel_explain_var(cEvent,cfold,:) = {Test_explainVar, TrainDevExplain, Y_Coefs};
        EventResidue(cEvent,cfold,:) = {TesInds, Y(TesInds) - Y_pred,Y_pred};
    end
    cEventResiAll = squeeze(EventResidue(cEvent,:,:));
    TestIndsAll = cellfun(@(x) find(x),cEventResiAll(:,1),'un',0);
    AllYTestInds = cat(1,TestIndsAll{:});
    AllResidues = cat(1,cEventResiAll{:,2});
    AllPreds = cat(1,cEventResiAll{:,3});
    
    PredANDResidueDataMtx = zeros(Numofobservations,2,'single');
    if length(AllYTestInds) ~= Numofobservations
        error('Predction data assignment is wrong! The assigned length is %d, but the target length is %d.',...
            length(AllYTestInds), Numofobservations);
    end
    PredANDResidueDataMtx(AllYTestInds,1) = AllPreds;
    PredANDResidueDataMtx(AllYTestInds,2) = AllResidues + max(AllPreds); % add back the baseline firing rate values, avoid negtive values
    
    PredANDResidueDataCell(cEvent) = {PredANDResidueDataMtx};
end
warning on


%%
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
%                 [BPrt, Y_fitinfo_Prt] = lassoglm(predictorMtx_full(TrnInds,cCal_pred_inds),...
%                     Y(TrnInds),'normal','Alpha',alpha,...
%                      'CV',5,'Lambda',lambda,'RelTol',1e-2,'MaxIter',100,'Options',opts);
%                 [~,cv_partial_expVar,Y_partial_pred,cp_coefs] = ...
%                     EVcalfun(Y_fitinfo_Prt, BPrt, Y(TrnInds), Y(TesInds), predictorMtx_full(TesInds,cCal_pred_inds));
%
%                 PartialMd_coefs{cfold,cpredictor,cCal} = cp_coefs;
%                 PartialMd_explain_var(cfold,cpredictor,cCal) = cv_partial_expVar;
%                 PartialMD_pred_datas(TesInds,cpredictor,cCal) = Y_partial_pred;
%
%                 % calculate residue fitting if perform
%                 % omitted_index_fitting
%                 if cCal == 1
%                     % calculate single predictor fitting used residues
%                     Y_predTrain = glmval(cp_coefs, predictorMtx_full(TrnInds,cCal_pred_inds), 'identity');
%                     Residue_train = Y(TrnInds) - Y_predTrain;
%                     Residue_test = Y(TesInds) - Y_partial_pred;
%                     ResiAloneIndex = regressor_alone_idx{cpredictor};
%
%                     [BResi, Y_fitinfo_Resi] = lassoglm(predictorMtx_full(TrnInds,ResiAloneIndex),...
%                         Residue_train,'normal','Alpha',alpha,...
%                          'CV',5,'Lambda',lambda,'RelTol',1e-2,'MaxIter',100,'Options',opts);
%                     [~,cv_partial_expVarR,Y_partial_predR,cp_coefsR] = ...
%                         EVcalfun(Y_fitinfo_Resi, BResi, Residue_train, Residue_test, predictorMtx_full(TesInds,ResiAloneIndex));
%
%                     PartialMd_coefs{cfold,cpredictor,3} = cp_coefsR;
%                     PartialMd_explain_var(cfold,cpredictor,3) = cv_partial_expVarR;
%                     PartialMD_pred_datas(TesInds,cpredictor,3) = Y_partial_predR;
%                 end
%
%             end
%         end
%     else
%         PartialMD_pred_datas(TesInds,:,:) = mean(Y(TesInds));
%     end
% %%
% end





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

