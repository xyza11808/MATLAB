
% close
% cROI = 6;
% ROI1Data = squeeze(f_percent_change(:,cROI,:));
% ROI1Trace = reshape(ROI1Data',[],1);
% figure;plot(ROI1Trace)
% f_percent_change = f_percent_change;
%%
nnspike = Fluo2SpikeConstrainOOpsi(SelectData,[],[],frame_rate,2);
save EstimatedSPDataAR2.mat nnspike SelectData SelectSArray frame_rate -v7.3
%%
% close
% cROI = 196;
% ROI1Data = squeeze(f_percent_change(:,cROI,:));
% ROI1Trace = reshape(ROI1Data',[],1);

% figure;
% % hold on
% plot(ROI1Trace,'k');
% yyaxis right
% plot(ROISPTrace,'r')

%
% [~,SortInds] = sort(SelectSArray);
% figure;imagesc(ROISPData(SortInds,:))

%
Time_Win = 0.3;
FrameWin = round(Time_Win * frame_rate);
OnsetFrame = frame_rate;
OffsetFrame = frame_rate+FrameWin;


% figure;
% imagesc(RespMtx(SortInds,:))

%
nTrials = length(SelectSArray);
FreqTypes = unique(SelectSArray);
nFreqs = length(FreqTypes);
FreqMtxInds = double(repmat(SelectSArray,1,nFreqs) == repmat(FreqTypes',nTrials,1));
FreqMtxOnOffMtx = zeros(nTrials*2,nFreqs*2);
FreqMtxOnOffMtx(1:nTrials,1:nFreqs) = FreqMtxInds;
FreqMtxOnOffMtx((1:nTrials)+nTrials,(1:nFreqs)+nFreqs) = FreqMtxInds;

%
%     close
%     figure;
%     plot(CoefUseds(2:end),'ko','linewidth',1.6)
options = glmnetSet;
options.alpha = 0.9;
options.nlambda = 110;
nROIs = size(SelectData,2);

ROICoefData = cell(nROIs,1);
% for loop for each ROI
for cROI = 1 : nROIs
    ROISPData = squeeze(nnspike(:,cROI,:));
    ROISPTrace = reshape(ROISPData',[],1);

    OnsetTrResp = mean(ROISPData(:,OnsetFrame+1:OnsetFrame+FrameWin),2);
    OffTrResp = mean(ROISPData(:,OffsetFrame+1:OffsetFrame+FrameWin),2);
    RespMtx = [OnsetTrResp,OffTrResp];

    TotalRespMtx = RespMtx(:);

    nRepeats = 5;
    AllRepeatData = cell(nRepeats,3);
    for cRepeat = 1 : nRepeats

        nFolds = 5;
        cc = cvpartition(nTrials,'kFold',nFolds);
        FoldCoefs = cell(nFolds,1);
        FoldDev = zeros(nFolds,1);
        FoldTestPred = cell(nFolds,2);
        for cf = 1 : nFolds
            TrainInds = find(cc.training(cf));
            BlankInds = false(nTrials*2,1);
            BlankInds(TrainInds) = true;
            BlankInds(TrainInds+nTrials) = true;

            TrainFreqParas = FreqMtxOnOffMtx(BlankInds,:);
            TrainRespVec = TotalRespMtx(BlankInds);
            TestFreqParas = FreqMtxOnOffMtx(~BlankInds,:);
            TestRespVec = TotalRespMtx(~BlankInds);

            cvmdfit = cvglmnet(TrainFreqParas,TrainRespVec,'poisson',options,[],20);
            CoefUseds = cvglmnetCoef(cvmdfit,'lambda_1se');
            FoldCoefs{cf} = (CoefUseds(2:end))';
            FoldDev(cf) = max(cvmdfit.glmnet_fit.dev);

            PredTestData = cvglmnetPredict(cvmdfit,TestFreqParas,'lambda_1se','response');
            FoldTestPred{cf,1} = PredTestData;
            FoldTestPred{cf,2} = TestRespVec;
        end

        AllRepeatData{cRepeat,1} = cell2mat(FoldCoefs);
        AllRepeatData{cRepeat,2} = FoldDev;
        AllRepeatData{cRepeat,3} = FoldTestPred;

    %     FoldCoefMtx = cell2mat(FoldCoefs);
    %     figure;
    %     imagesc(abs(FoldCoefMtx))
    end
    
    ROICoefData{cROI} = AllRepeatData;
    
end
%%
% Extract Coef Data
ROIAboveThresSummary = cell(nROIs,2);
for cr = 1 : nROIs
    %
    crCoef = ROICoefData{cr};
    crCoefMtx = cell2mat(crCoef(:,1));
    
    AvgCoefData = mean(abs(crCoefMtx));
    crCoefAboveThres = double(mean(abs(crCoefMtx) > 0.1) >= 1);
    crAboveThresIndex = find(crCoefAboveThres);
    [AboveThresIndsCoefAvg,AboveThresIndsSortSeq] = sort(AvgCoefData(crAboveThresIndex),'descend');
    AboveThresIndsSort = crAboveThresIndex(AboveThresIndsSortSeq);
    
    ROIAboveThresSummary{cr,1} = AboveThresIndsSort;
    ROIAboveThresSummary{cr,2} = AboveThresIndsCoefAvg;
   %
end

save ROIglmCoefSave.mat ROIAboveThresSummary FreqTypes -v7.3

