
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
load('rfSelectDataSet.mat','SelectData','frame_rate', 'sound_array', 'SelectInds','SelectSArray');
if exist('EstimatedSPDatafilter.mat','file')
    load('EstimatedSPDatafilter.mat');
else
    nnspike = Fluo2SpikeConstrainOOpsi(SelectData,[],[],frame_rate,2);
    save EstimatedSPDatafilter.mat nnspike SelectData SelectSArray frame_rate -v7.3
end
% load('EstimatedSPDatafilter.mat');
SelectSoundArray = sound_array(SelectInds,:);
SelectSoundIntensity = SelectSoundArray(:,2);
SoundIntensityType = unique(SelectSoundIntensity);
if numel(SoundIntensityType) > 1
    IsMultiDB = 1;
    IntensityTypeMtx = zeros(numel(SelectSoundIntensity), numel(SoundIntensityType));
    for cIntensity = 1 : numel(SoundIntensityType)
        IntensityTypeMtx(:, cIntensity) = double(SelectSoundIntensity == SoundIntensityType(cIntensity));
    end
else
    IsMultiDB = 0;
end
cSessPassTrInds = true(numel(SelectSArray),1);
if exist('PassFreqUsedInds.mat','file')
    UsedTrIndsStrc = load('PassFreqUsedInds.mat');
    if ~isempty(UsedTrIndsStrc.PassTrInds)
        cSessPassTrInds(~UsedTrIndsStrc.PassTrInds) = false;
    else
        return;
    end
end
UsedFreqArray = SelectSArray(cSessPassTrInds);
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
OffsetFrame = frame_rate+FrameDurData;


% figure;
% imagesc(RespMtx(SortInds,:))

%
nTrials = length(UsedFreqArray);
FreqTypes = unique(UsedFreqArray);
nFreqs = length(FreqTypes);
FreqTrNums = zeros(nFreqs, 1);
for cf = 1 : nFreqs
    FreqTrNums(cf) = sum(UsedFreqArray == FreqTypes(cf));
end
UsedFolds = min(FreqTrNums);
FreqMtxInds = double(repmat(UsedFreqArray,1,nFreqs) == repmat(FreqTypes',nTrials,1));
FreqMtxOnOffMtx = zeros(nTrials*2,nFreqs*2);
FreqMtxOnOffMtx(1:nTrials,1:nFreqs) = FreqMtxInds;
FreqMtxOnOffMtx((1:nTrials)+nTrials,(1:nFreqs)+nFreqs) = FreqMtxInds;
if IsMultiDB
    FreqMtxOnOffMtx = [FreqMtxOnOffMtx, [IntensityTypeMtx;IntensityTypeMtx]];
end
%
%     close
%     figure;
%     plot(CoefUseds(2:end),'ko','linewidth',1.6)
options = glmnetSet;
options.alpha = 0.9;
options.nlambda = 300;
options.standardize = false;

UsedSelectDatas = SelectData(cSessPassTrInds,:,:);
nROIs = size(UsedSelectDatas,2);
nTrials = size(UsedSelectDatas,1);
IsVariedDur = 0;
if length(unique(FrameDurData)) > 2
    IsVariedDur = 1;
end
ROICoefData = cell(nROIs,1);
ROIOnOffFResp = zeros(nROIs,nFreqs*2);
% cDes = designfilt('lowpassfir','PassbandFrequency',3,'StopbandFrequency',5,...
%                 'StopbandAttenuation', 60,'SampleRate',frame_rate,'DesignMethod','kaiserwin');

%% for loop for each ROI
ROIStds = zeros(nROIs,1);
for cROI = 1 : nROIs
    %%
%     cROI = 242;
    ROISPData = squeeze(nnspike(cSessPassTrInds,cROI,:));
    ROISPTrace = reshape(ROISPData',[],1);
%     ROISPNoiseThres = std(ROISPTrace(ROISPTrace>1e-6));
%     ROISPData(ROISPData < ROISPNoiseThres) = 0;
%     ROISPData = ROISPData * frame_rate;
    cROIRaw = squeeze(UsedSelectDatas(:,cROI,:));
    ROIStds(cROI) = mad(cROIRaw(:),1)*1.4826;
    cROIRaw2Trace = reshape(cROIRaw',[],1);
%     cROIRaw2TraceSM = smooth(cROIRaw2Trace,5,'sgolay',3);
    cROIRaw2TraceSM = smooth(cROIRaw2Trace,5);
    cROISMMtxData = (reshape(cROIRaw2TraceSM,size(cROIRaw,2),[]))';
    cROIRawData = cROISMMtxData;
    
    OnsetTrResp = mean(ROISPData(:,OnsetFrame+1:OnsetFrame+FrameWin),2);
    OnsetTrFReap = max(cROIRawData(:,OnsetFrame+1:OnsetFrame+FrameWin),[],2) - ...
        max(min(cROIRawData(:,OnsetFrame+1:OnsetFrame+FrameWin),[],2),0);
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
        OffFTrResp = max(cROIRawData(:,OffsetFrame+1:OffsetFrame+FrameWin),[],2) - ...
            max(min(cROIRawData(:,OnsetFrame+1:OffsetFrame+FrameWin),[],2),0);
    end
    RespMtx = [OnsetTrResp,OffTrResp];
    %
    
    for cFreqs = 1 : nFreqs
        cFreqsInds = UsedFreqArray == FreqTypes(cFreqs);
        ROIOnOffFResp(cROI,cFreqs) = mean(OnsetTrFReap(cFreqsInds));
        ROIOnOffFResp(cROI,cFreqs+nFreqs) = mean(OffFTrResp(cFreqsInds));
    end
        
%
    TotalRespMtx = RespMtx(:);
%     TotalRespMtx = TotalRespMtx/max(TotalRespMtx);
    
    nRepeats = 2;
    AllRepeatData = cell(nRepeats,3);
    for cRepeat = 1 : nRepeats

        nFolds = UsedFolds;
%         cc = cvpartition(nTrials,'kFold',nFolds);
        FoldTrainTestIndex = ClassEvenPartitionFun(UsedFreqArray,nFolds);
        FoldCoefs = cell(nFolds,1);
        FoldDev = zeros(nFolds,2); % the first column is real dev, the second is null dev
        FoldTestPred = cell(nFolds,2);
        for cf = 1 : nFolds
%             TrainInds = find(cc.training(cf));
            TrainInds = FoldTrainTestIndex{1,cf};
            BlankInds = false(nTrials*2,1);
            BlankInds(TrainInds) = true;
            BlankInds(TrainInds+nTrials) = true;
            %
            TrainFreqParas = FreqMtxOnOffMtx(BlankInds,:);
            TrainRespVec = TotalRespMtx(BlankInds);
            TrainRespVecNorm = TrainRespVec / mean(TrainRespVec); % normalize the mean value to 1 
            TestFreqParas = FreqMtxOnOffMtx(~BlankInds,:);
            TestRespVec = TotalRespMtx(~BlankInds);
            TestRespVecNorm = TestRespVec/mean(TestRespVec);
            
%             TrainRespVec = TrainRespVec / max(1e-5, std(TrainRespVec));
            mdfit = glmnet(TrainFreqParas,TrainRespVecNorm,'poisson',options);
            
            PredTestData = glmnetPredict(mdfit,TestFreqParas,[],'response'); %,[],log(mean(TestRespVec))
            
            cvmdfit = cvglmnet(TrainFreqParas,TrainRespVecNorm,'poisson',options);
            CoefUseds = cvglmnetCoef(cvmdfit,'lambda_1se');
            %%
            PredTestData = PredTestData + 1e-10;
            TestRespVecNorm = TestRespVecNorm + 1e-10;
            Dev_model = 2*sum(TestRespVecNorm.*log(TestRespVecNorm ./ PredTestData) - (TestRespVecNorm - PredTestData));
            Dev_null = 2*sum(TestRespVecNorm.*log(TestRespVecNorm) - (TestRespVecNorm - 1)); %
            DV_explain = 1 - Dev_model/Dev_null;
            [MaxExplainV,Maxexplaininds] = max(DV_explain);
            
           %%
           NshufRepeat = 500;
           optionsshuf = options;
           optionsshuf.lambda = mdfit.lambda;
           shuf_maxinds_explain = zeros(NshufRepeat,1);
           for cshuf = 1 : NshufRepeat
               RespShuf = Vshuffle(TrainRespVecNorm);
               mdfitshuf = glmnet(TrainFreqParas,RespShuf,'poisson',optionsshuf);
               PredTestData = glmnetPredict(mdfitshuf,TestFreqParas,[],'response'); %,[],log(mean(TestRespVec))
               PredTestData = PredTestData + 1e-10;
               TestRespVecNorm = TestRespVecNorm + 1e-10;
               Dev_model = 2*sum(TestRespVecNorm.*log(TestRespVecNorm ./ PredTestData) - (TestRespVecNorm - PredTestData));
               Dev_null = 2*sum(TestRespVecNorm.*log(TestRespVecNorm) - (TestRespVecNorm - 1)); %
               DV_explain = 1 - Dev_model/Dev_null;
               shuf_maxinds_explain(cshuf) = DV_explain(Maxexplaininds);
           end
           
           
           %%
            
            TestRespMtx = repmat(TestRespVec, 1, size(PredTestData, 2));
            SquareErrors = sum((TestRespMtx - PredTestData).^2);
%             figure;plot(SquareErrors)
            [~,minInds] = min(SquareErrors);
            CoefUseds = glmnetCoef(mdfit, mdfit.lambda(Maxexplaininds));
            PredDatas = PredTestData(:, minInds);
            FoldDev(cf, 1) = mdfit.dev(minInds);
            FoldDev(cf, 2) = mdfit.nulldev;
%             if minInds == numel(SquareErrors)
%                 CoefUseds = zeros(size(CoefUseds));
%                 PredDatas = zeros(size(PredDatas));
%             end
            
%             cvmdfit = cvglmnet(TrainFreqParas,TrainRespVec,'poisson',options,[],size(TrainFreqParas,1));
%             CoefUseds = cvglmnetCoef(cvmdfit,'lambda_1se');
            FoldCoefs{cf} = (CoefUseds(2:end))';
            
%             PredTestData = cvglmnetPredict(cvmdfit,TestFreqParas,'lambda_1se','response');
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
    %
    ROICoefData{cROI} = AllRepeatData;
    AllCoefs = cell2mat(AllRepeatData(:,1));
    %%
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
    crCoefAboveThres = double(mean(abs(crCoefMtx) > 0.3) >= 0.3);
    crCoefAboveThres(cROIResp < ROIStds(cr)) = 0;
    
    AvgCoefInds = mean(crCoefMtx);
    NegRespInds = AvgCoefInds < 0; % exclude negtive response value, which may just caused by negtive response
    crCoefAboveThres(NegRespInds) = 0;
    %
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
end

%% New coefficient evaluation method
% Extract Coef Data
ROIAboveThresSummary = cell(nROIs,3);
PassBFInds = zeros(nROIs,1); % zeros indicates no significant tuning
for cr = 1 : nROIs
    %
    crCoef = ROICoefData{cr};
    crCoefMtx = cell2mat(crCoef(:,1));
    cROIResp = ROIOnOffFResp(cr,:);
    
    AvgCoefData = mean(abs(crCoefMtx));
    crCoefAboveThres = double(mean(crCoefMtx > 1e-6) >= 0.85);
    
    crCoefAboveThres(cROIResp < ROIStds(cr)) = 0;
    
    AvgCoefInds = mean(crCoefMtx);
    NegRespInds = AvgCoefInds < 0; % exclude negtive response value, which may just caused by negtive response
    crCoefAboveThres(NegRespInds) = 0;
    %
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
    ROIAboveThresSummary{cr,3} = mean(crCoefMtx > 1e-6); 
    %
end

%%
if ~isdir('./SP_RespField_ana/')
    mkdir('./SP_RespField_ana/');
end
cd('./SP_RespField_ana/');
save ROIglmCoefSave_New.mat ROIAboveThresSummary FreqTypes PassBFInds ROICoefData ROIOnOffFResp -v7.3
cd ..;

%% following code used for test code prediction effects
% ########################################################

% 
% options = glmnetSet;
% options.alpha = 0.9;
% options.nlambda = 110;
% % options.offset = log(mean(TrainRespVec));
% mdfit = glmnet(TrainFreqParas,TrainRespVec,'poisson',options);
% 
% %%
% 
% PredTestData = glmnetPredict(mdfit,TestFreqParas,[],'response'); %,[],log(mean(TestRespVec))
% 
% TestRespMtx = repmat(TestRespVec, 1, size(PredTestData, 2));
% SquareErrors = sum((TestRespMtx - PredTestData).^2);
% figure;plot(SquareErrors)
% [~,minInds] = min(SquareErrors);
% 
% %%
% 
% usedCoef = glmnetCoef(mdfit, mdfit.lambda(minInds));
% PredDatas = PredTestData(:, minInds);
% figure;
% plot(TestRespVec,'k');
% % yyaxis right
% hold on
% plot(PredDatas,'r')
% 
% %%
% 
% PredFitData = glmnetPredict(mdfit,TrainFreqParas,[],'response'); %,[],log(mean(TestRespVec))
% 
% TrainedRespMtx = repmat(TrainRespVec, 1, size(PredFitData, 2));
% TrainedSquareErrors = sum((TrainedRespMtx - PredFitData).^2);
% figure;plot(TrainedSquareErrors)
% [~,minInds] = min(TrainedSquareErrors);
% 
% 
% %%
% figure;hold on
% plot(TrainRespVec,'k')
% plot(PredFitData(:, minInds),'r');
% 
% %%
% cROI = 61;
% %%
% 
% AllCoefs = cell2mat(AllRepeatData(:,1));
% 
% %%
% 
% figure;
% plot(TestRespVec,'k');
% % yyaxis right
% hold on
% plot(PredTestData(:, minInds),'r')
% 
%%
StepROICoefData = cell(nROIs,1);
ROIStds = zeros(nROIs,1);
for cROI = 1 : nROIs
    %%
    cROI = 10;
    ROISPData = squeeze(nnspike(cSessPassTrInds,cROI,:));
    ROISPTrace = reshape(ROISPData',[],1);
%     ROISPNoiseThres = std(ROISPTrace(ROISPTrace>1e-6));
%     ROISPData(ROISPData < ROISPNoiseThres) = 0;
%     ROISPData = ROISPData * frame_rate;
    cROIRaw = squeeze(UsedSelectDatas(:,cROI,:));
    ROIStds(cROI) = mad(cROIRaw(:),1)*1.4826;
    cROIRaw2Trace = reshape(cROIRaw',[],1);
%     cROIRaw2TraceSM = smooth(cROIRaw2Trace,5,'sgolay',3);
    cROIRaw2TraceSM = smooth(cROIRaw2Trace,5);
    cROISMMtxData = (reshape(cROIRaw2TraceSM,size(cROIRaw,2),[]))';
    cROIRawData = cROISMMtxData;
    
    OnsetTrResp = mean(ROISPData(:,OnsetFrame+1:OnsetFrame+FrameWin),2);
    OnsetTrFReap = max(cROIRawData(:,OnsetFrame+1:OnsetFrame+FrameWin),[],2) - ...
        max(min(cROIRawData(:,OnsetFrame+1:OnsetFrame+FrameWin),[],2),0);
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
        OffFTrResp = max(cROIRawData(:,OffsetFrame+1:OffsetFrame+FrameWin),[],2) - ...
            max(min(cROIRawData(:,OnsetFrame+1:OffsetFrame+FrameWin),[],2),0);
    end
    RespMtx = [OnsetTrResp,OffTrResp];
    %
    
    for cFreqs = 1 : nFreqs
        cFreqsInds = UsedFreqArray == FreqTypes(cFreqs);
        ROIOnOffFResp(cROI,cFreqs) = mean(OnsetTrFReap(cFreqsInds));
        ROIOnOffFResp(cROI,cFreqs+nFreqs) = mean(OffFTrResp(cFreqsInds));
    end
        
%
    TotalRespMtx = RespMtx(:);
%     TotalRespMtx = TotalRespMtx/max(TotalRespMtx);
    
    nRepeats = 2;
    StepRepeatData = cell(nRepeats,3);
    for cRepeat = 1 : nRepeats

        nFolds = UsedFolds;
%         cc = cvpartition(nTrials,'kFold',nFolds);
        FoldTrainTestIndex = ClassEvenPartitionFun(UsedFreqArray,nFolds);
        FoldCoefs = cell(nFolds,1);
        FoldDev = zeros(nFolds,2); % the first column is real dev, the second is null dev
        FoldTestPred = cell(nFolds,3);
        for cf = 1 : nFolds
%             TrainInds = find(cc.training(cf));
            TrainInds = FoldTrainTestIndex{1,cf};
            BlankInds = false(nTrials*2,1);
            BlankInds(TrainInds) = true;
            BlankInds(TrainInds+nTrials) = true;

            TrainFreqParas = FreqMtxOnOffMtx(BlankInds,:);
            TrainRespVec = TotalRespMtx(BlankInds);
            TestFreqParas = FreqMtxOnOffMtx(~BlankInds,:);
            TestRespVec = TotalRespMtx(~BlankInds);
            
%             TrainRespVec = TrainRespVec / max(1e-5, std(TrainRespVec));
            
            mddl = stepwiseglm(TrainFreqParas,TrainRespVec,'linear','Distribution','poisson','CategoricalVars',true(size(TrainFreqParas,2),1));
            ypred= predict(mddl, TestFreqParas);

%             PredTestData = cvglmnetPredict(cvmdfit,TestFreqParas,'lambda_1se','response');
            FoldTestPred{cf,1} = ypred;
            FoldTestPred{cf,2} = TestRespVec;
            FoldTestPred{cf,3} = mddl;
        end

%         StepRepeatData{cRepeat,1} = mddl;
%         StepRepeatData{cRepeat,2} = FoldDev;
        StepRepeatData{cRepeat,1} = FoldTestPred;

    %     FoldCoefMtx = cell2mat(FoldCoefs);
    %     figure;
    %     imagesc(abs(FoldCoefMtx))
    end
    %
    StepROICoefData{cROI} = StepRepeatData;
%     StepAllCoefs = cell2mat(StepRepeatData(:,1));
    %%
end
%% #####################################################################
Dsquare = (mdfit.nulldev - mdfit.dev) / mdfit.nulldev;
n = length(TrainRespVec);
p = mdfit.df;
DsquareAdjust = 1 - ((n - 1)./(n - p)).*(1 - Dsquare);
figure;plot(DsquareAdjust)
hold on
plot(Dsquare,'r')

%%
TrainRespVecNorm = TrainRespVec/mean(TrainRespVec);

% mdfit = glmnet(TrainFreqParas,TrainRespVec,'poisson',options);
mdfit = glmnet(TrainFreqParas,TrainRespVecNorm,'poisson',options);

PredTestData = glmnetPredict(mdfit,TestFreqParas,[],'response'); %,[],log(mean(TestRespVec))

TestRespMtx = repmat(TestRespVec, 1, size(PredTestData, 2));
SquareErrors = sum((TestRespMtx - PredTestData).^2);

%%

TestRespVecNorm = TestRespVec/mean(TestRespVec);

%% calculate device from test data set

Dev_model = 2*sum(TestRespVecNorm.*log(TestRespVecNorm ./ PredTestData) - (TestRespVecNorm - PredTestData));

Dev_null = 2*sum(TestRespVecNorm.*log(TestRespVecNorm) - (TestRespVecNorm - 1)); %


