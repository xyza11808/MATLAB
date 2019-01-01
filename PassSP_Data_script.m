
% close
% cROI = 6;
% ROI1Data = squeeze(f_percent_change(:,cROI,:));
% ROI1Trace = reshape(ROI1Data',[],1);
% figure;plot(ROI1Trace)
% f_percent_change = f_percent_change;
%%
% if exist('EstimatedSPDataAR2.mat','file')  && exist('ROIglmCoefSave.mat','file')
% %     return;
% end
nnspike = Fluo2SpikeConstrainOOpsi(SelectData,[],[],frame_rate,2);
save EstimatedSPDatafilter.mat nnspike SelectData SelectSArray frame_rate -v7.3
% load('EstimatedSPDatafilter.mat');
load('rfSelectDataSet.mat','SelectData');
% load('EstimatedSPDataAR2.mat','nnspike');
% SP data plots for preview
% FreqTypes = unique(SelectSArray);
% nFreqs = numel(FreqTypes);
% cfMeanData = zeros(nFreqs,size(nnspike,2),size(nnspike,3));
% for cf = 1 : nFreqs
%     cfInds = SelectSArray == FreqTypes(cf);
%     cfData = nnspike(cfInds,:,:);
%     MeancfData = squeeze(mean(cfData));
%     cfMeanData(cf,:,:) = MeancfData;
% end
% 
% 
% %%
% cROI = 84;
% cRData = squeeze(cfMeanData(:,cROI,:));
% figure;
% imagesc(cRData)

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

FrameDurStrc = load('rfSelectDataSet.mat','sound_array');
FrameDurData = round(FrameDurStrc.sound_array(:,3)/1000*frame_rate);

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
nTrials = size(SelectData,1);
IsVariedDur = 0;
if length(unique(FrameDurData)) > 2
    IsVariedDur = 1;
end
ROICoefData = cell(nROIs,1);
ROIOnOffFResp = zeros(nROIs,nFreqs*2);
% for loop for each ROI
for cROI = 1 : nROIs
    %
    ROISPData = squeeze(nnspike(:,cROI,:));
    ROISPTrace = reshape(ROISPData',[],1);
    cROIRawData = squeeze(SelectData(:,cROI,:));
    
    OnsetTrResp = mean(ROISPData(:,OnsetFrame+1:OnsetFrame+FrameWin),2);
    OnsetTrFReap = mean(cROIRawData(:,OnsetFrame+1:OnsetFrame+FrameWin),2);
    if IsVariedDur
       TempRespData = zeros(nTrials,FrameWin); 
       TempFRespData = zeros(nTrials,FrameWin); 
       for cTr = 1 : nTrials
           TempRespData(cTr,:) = ROISPData(cTr,FrameDurData(cTr)+1:FrameDurData(cTr)+FrameWin);
           TempFRespData(cTr,:) = cROIRawData(cTr,FrameDurData(cTr)+1:FrameDurData(cTr)+FrameWin);
       end
       OffTrResp = mean(TempRespData,2);
       OffFTrResp = mean(TempFRespData,2);
    else
        OffTrResp = mean(ROISPData(:,OffsetFrame+1:OffsetFrame+FrameWin),2);
        OffFTrResp = mean(cROIRawData(:,OffsetFrame+1:OffsetFrame+FrameWin),2);
    end
    RespMtx = [OnsetTrResp,OffTrResp];
    
    
    for cFreqs = 1 : nFreqs
        cFreqsInds = SelectSArray == FreqTypes(cFreqs);
        ROIOnOffFResp(cROI,cFreqs) = mean(OnsetTrFReap(cFreqsInds));
        ROIOnOffFResp(cROI,cFreqs+nFreqs) = mean(OffFTrResp(cFreqsInds));
    end
        
%
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
PassBFInds = zeros(nROIs,1); % zeros indicates no significant tuning
for cr = 1 : nROIs
    %
    crCoef = ROICoefData{cr};
    crCoefMtx = cell2mat(crCoef(:,1));
    cROIResp = ROIOnOffFResp(cr,:);
    
    AvgCoefData = mean(abs(crCoefMtx));
    crCoefAboveThres = double(mean(abs(crCoefMtx) > 0.4) >= 0.6);
    crCoefAboveThres(cROIResp < 10) = 0;
    
    AvgCoefInds = mean(crCoefMtx);
    NegRespInds = AvgCoefInds < 0; % exclude negtive response value, which may just caused by negtive response
    crCoefAboveThres(NegRespInds) = 0;
    
    if sum(crCoefAboveThres)
        TempCoefs = AvgCoefInds;
        TempCoefs(~crCoefAboveThres) = 0;

        TempCoefIndex = zeros(2,nFreqs);
        TempCoefIndex(1,1:end) = TempCoefs(1:nFreqs);
        TempCoefIndex(2,1:end) = TempCoefs(1+nFreqs:end);
        TempCoefIndex = max(TempCoefIndex);
        [~,BFCoefIndex] = max(TempCoefIndex);
        PassBFInds(cr) = BFCoefIndex;

        crAboveThresIndex = find(crCoefAboveThres);
        [AboveThresIndsCoefAvg,AboveThresIndsSortSeq] = sort(AvgCoefData(crAboveThresIndex),'descend');
        AboveThresIndsSort = crAboveThresIndex(AboveThresIndsSortSeq);
    
        ROIAboveThresSummary{cr,1} = AboveThresIndsSort;
        ROIAboveThresSummary{cr,2} = AboveThresIndsCoefAvg;
    end
    
    %
   %
end
%%
save ROIglmCoefSave.mat ROIAboveThresSummary FreqTypes PassBFInds ROICoefData ROIOnOffFResp -v7.3

