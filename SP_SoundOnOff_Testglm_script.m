
ROI = 93;
ROIData = squeeze(nnspike(:,ROI,:));
SoundOnsetFrame = 29;
SoundDur = round(sound_array(:,3)/1000*29);

TrialNum = size(ROIData,1);
TrialFrame = size(ROIData,2);
TrBaseline = cumsum([0;ones(TrialNum-1,1)*TrialFrame]);
TrFrameOn = TrBaseline + SoundOnsetFrame;
TrFrameOff = TrBaseline + SoundOnsetFrame + SoundDur;
RawROITrace = reshape(ROIData',[],1);

figure;
plot(RawROITrace);
hold on
yscales = get(gca,'ylim');

OnsetFrame_x = repmat(TrFrameOn',2,1);
OnsetFrame_yy = repmat(yscales(:),1,TrialNum);
OnsetFrame_xAll = [OnsetFrame_x;nan(1,TrialNum)];
OnsetFrame_yyAll = [OnsetFrame_yy;nan(1,TrialNum)];

OffSetFrame_x = repmat(TrFrameOff',2,1);
OffSetFrame_yy = OnsetFrame_yy;
OffSetFrame_xAll = [OffSetFrame_x;nan(1,TrialNum)];
OffSetFrame_yyAll = [OffSetFrame_yy;nan(1,TrialNum)];

plot(reshape(OnsetFrame_xAll,[],1),reshape(OnsetFrame_yyAll,[],1),'b','linewidth',1);
plot(reshape(OffSetFrame_xAll,[],1),reshape(OffSetFrame_yyAll,[],1),'m','linewidth',1);

StdThres = std(RawROITrace(RawROITrace~=0));
line([1,numel(RawROITrace)],[StdThres StdThres],'Color',[0.1 0.8 0.1],'linewidth',1.4);

%%
% sucstract off-threshold spike values
ThresFactor = 1; % times of std for each ROI
ThresSubData = zeros(size(nnspike));
ThresSubSMData = zeros(size(nnspike));

GaussianWin = gausswin(5);
GaussianWin = GaussianWin/sum(GaussianWin);

[NumTrials,NumROIs,NumFrames] = size(nnspike);

for cR = 1 : NumROIs
    cRData = squeeze(nnspike(:,cR,:));
    cRDataStd = std(cRData(cRData > 1e-6));
    cR_ThresSubData = cRData;
    cR_ThresSubData(cR_ThresSubData <= cRDataStd*ThresFactor) = 0;
    
    cR_ThresSubData = cR_ThresSubData/max(cR_ThresSubData(:)); % normalize to [0 1]
    ThresSubData(:,cR,:) = cR_ThresSubData;
    
    % generate smoothed data
    cR_ThresSubTrace = reshape(cR_ThresSubData',[],1);
    cR_ThresSubTraceStd = std(cR_ThresSubTrace(cR_ThresSubTrace > 1e-8));
    cRSMTrace = conv(cR_ThresSubTrace,GaussianWin,'same')+...
        (rand(numel(cR_ThresSubTrace),1)-0.5)*cR_ThresSubTraceStd*0.02;
    cRSM_Data = (reshape(cRSMTrace,NumFrames,NumTrials))';
    ThresSubSMData(:,cR,:) = cRSM_Data;
end

% ThresSubData = ThresSubData * 28;

ThresSubDataCell = cell(1,NumTrials);
SounOnOffLabelsCell = cell(1,NumTrials);
SounOffframeLabelsCell = cell(1,NumTrials);
% sound_array
% 
FreqTypes = unique(sound_array(:,1));
FreqTypeNum = length(FreqTypes);
SoundOnOffFrames = zeros(FreqTypeNum,NumFrames);
for cTr = 1 : NumTrials
    cTrFreqsInds = sound_array(cTr,1) == FreqTypes;
    cTrOnOff_frame = frame_rate + [1,round(sound_array(cTr,3)*frame_rate/1000)];
    cTrLabel = SoundOnOffFrames;
    cTrLabel(cTrFreqsInds,cTrOnOff_frame(1):cTrOnOff_frame(2)) = 1;
    
    SounOnOffLabelsCell{cTr} = cTrLabel;
    
    cxTrLabel = SoundOnOffFrames;
    cxTrLabel(cTrFreqsInds,(cTrOnOff_frame(2)+1):(cTrOnOff_frame(2)+frame_rate/2)) = 1;
    SounOffframeLabelsCell{cTr} = cxTrLabel;
    
    ThresSubDataCell{cTr} = squeeze(ThresSubData(cTr,:,:));
    
end
SounOnOffLabelsAll = cat(3,SounOnOffLabelsCell{:});
SounOffframeLabelsAll = cat(3,SounOffframeLabelsCell{:});
%%
ThresSubDataCellNew = cell(1,NumFrames);
SounOnOffLabelsCellNew = cell(1,NumFrames);

% sound_array
% 
% SoundOnOffFrames = zeros(FreqTypeNum,NumFrames);
for cFr = 1 : NumFrames
    
    SounOnOffLabelsCellNew{cFr} = squeeze(SounOnOffLabelsAll(:,cFr,:));
    
    ThresSubDataCellNew{cFr} = (squeeze(ThresSubData(:,:,cFr)))';
    
end
%%
cR = 93;
cROIData = squeeze(ThresSubData(:,cR,:));
cR_InputMtx = SounOnOffLabelsAll;
cR_OffFrameMtx = SounOffframeLabelsAll;

TrainInds = 1:60;
TestInds = 61:90;
TrainROIData = cROIData(TrainInds,:);
TrainDataCol = reshape(TrainROIData',[],1);
TrainDataColSM = conv(TrainDataCol,GaussianWin,'same');
TestROIData = cROIData(TestInds,:);
TestDataCol = reshape(TestROIData',[],1);
TestDataColSM = conv(TestDataCol,GaussianWin,'same');
% onset time
TrainSoundLabel = cR_InputMtx(:,:,TrainInds);
TrainSoundCol = (reshape(TrainSoundLabel,10,[]))';
TestSoundLabel = cR_InputMtx(:,:,TestInds);
TestSoundCol = (reshape(TestSoundLabel,10,[]))';

%% offset time
TrainSOffLable = cR_OffFrameMtx(:,:,TrainInds);
TrainSOffLableCol = (reshape(TrainSOffLable,10,[]))';
TestSOffLabel = cR_OffFrameMtx(:,:,TestInds);
TestSOffLabelCol = (reshape(TestSOffLabel,10,[]))';
TestXDatas = [TrainSoundCol,TrainSOffLableCol];

TrainXDatas = [TrainSoundCol,TrainSOffLableCol];
mdd = stepwiseglm(TrainXDatas,TrainDataColSM,'linear',...
    'Distribution','poisson');
% mddCont = stepwiseglm(TrainXDatas,TrainDataColSM,'constant',...
%     'Distribution','poisson','CategoricalVars',true(size(TrainXDatas,2),1));

% ZerosYDatasInds = TrainDataColSM > 1e-8;
% mdd = stepwiseglm(TrainXDatas(ZerosYDatasInds,:),TrainDataColSM(ZerosYDatasInds),'linear',...
%     'Distribution','poisson','Criterion','aic');
%%
isVariableUsed = mdd.VariableInfo.InModel(1:end-1);
UsedVarTrainDatas = TrainXDatas(:,isVariableUsed);
TestXDatas = [TestSoundCol,TestSOffLabelCol];
UsedTestXDatas = TestXDatas(:,isVariableUsed);

% partition data into 10 folds
K = 10;
cv = cvpartition(numel(TrainDataColSM), 'kfold',K);

mse = zeros(K,1);
CrossMds = cell(K,1);
for k=1:K
    % training/testing indices for this fold
    trainIdx = cv.training(k);
    testIdx = cv.test(k);

    % train GLM model
    mdl = fitglm(UsedVarTrainDatas(trainIdx,:), TrainDataColSM(trainIdx), ...
        'linear', 'distribution','poisson');
    CrossMds{k} = mdl.Coefficients;
    % predict regression output using test dataset
    Y_hat = predict(mdl, UsedTestXDatas);

    % compute mean squared error
    mse(k) = mean((TestDataCol - Y_hat).^2);
end

% average RMSE across k-folds
avrg_rmse = mean(sqrt(mse))
% another way of calculating mse
% % % prediction function given training/testing instances
% % fcn = @(Xtr, Ytr, Xte) predict(...
% %     fitglm(Xtr,Ytr,'linear','distribution','poisson'), ...
% %     Xte);
% % % perform cross-validation, and return average MSE across folds
% % mse = crossval('mse', UsedVarTrainDatas, TrainDataColSM, 'Predfun',fcn, 'kfold',10);
% % % compute root mean squared error
% % avrg_rmse = sqrt(mse)

% fit_ReNewAll = FitPsycheCurveWH_nx(OctavesAll, TrChoice, ParaBoundLim);
%%

[TestPred,PredCC] = predict(mdd,[TestSoundCol,TestSOffLabelCol]);

figure;
yyaxis left
plot(TestDataCol,'k')

yyaxis right
plot(TestPred,'r')

%% try with naive bayesian multiclass classifier
BinLen = round(0.3*frame_rate);
BinOverlap = round(0.2*frame_rate);
OnsetTimeBin = frame_rate + [1,BinLen];
TrainInds = 1:60;
TestInds = 61:90;

OnsetBinData = squeeze(sum(ThresSubSMData(TrainInds,:,OnsetTimeBin(1):OnsetTimeBin(2)),3));

Mdl = fitcnb(OnsetBinData,sound_array(TrainInds,1));
CVMdl = crossval(Mdl);
Loss = kfoldLoss(CVMdl,'mode','individual');
%
TestDataBin = squeeze(sum(ThresSubSMData(TestInds,:,OnsetTimeBin(1):OnsetTimeBin(2)),3));
ShufCorr = zeros(500,1);
for cshuf = 1 : 500
    ShuInds = Vshuffle(1:size(OnsetBinData,1));
    shMdl = fitcnb(OnsetBinData,sound_array(ShuInds,1));
    TestTrPred = predict(shMdl,TestDataBin);
    ShufCorr(cshuf) = mean(sound_array(TestInds,1) == TestTrPred);
    
end
    %%

NumFrame = NumFrames;
NonOverlapStep = BinLen - BinOverlap;
% NumberBin = floor(NumFrames/NonOverlapStep)-1;
BS_StartBinInds = 1:NonOverlapStep:(NumFrames-BinLen);
NumberBin = numel(StartBinInds) - 1;
BinCorrRate = zeros(NumberBin,1);
BinCenters = zeros(NumberBin,1);
for cR = 1 : NumberBin
    BinStartEndInds = (cR-1)*NonOverlapStep + [1,BinLen];
    cBinData = squeeze(sum(ThresSubSMData(TestInds,:,BinStartEndInds(1):BinStartEndInds(2)),3));
    cBinDataPred = predict(Mdl,cBinData);
    cBinCorrRate = mean(sound_array(TestInds,1) == cBinDataPred);
    BinCorrRate(cR) = cBinCorrRate;
    BinCenters(cR) = mean(BinStartEndInds);
end

%%
ShufCorrThres = prctile(ShufCorr,95);

figure;
plot(BinCenters/frame_rate,BinCorrRate)
yscales = get(gca,'ylim');
line([0 NumFrames/frame_rate],[ShufCorrThres ShufCorrThres],'Color','r',...
    'linewidth',1.5,'linestyle','--');
line([1 1],yscales,'Color','c','linewidth',1.2,'linestyle','--')

set(gca,'ylim',yscales);

%%
SoundOffFrames = frame_rate + SoundDur;
MinOffFrame = min(SoundOffFrames);
OffFrameAlign_Diff = SoundOffFrames - MinOffFrame;
AfterFrameLength = NumFrames - max(SoundOffFrames);
SoundOffAlignLength = MinOffFrame + AfterFrameLength;
SoundOffAlignData = zeros(NumTrials,NumROIs,SoundOffAlignLength);

for cTr = 1 : NumTrials
    SoundOffAlignData(cTr,:,:) = ThresSubSMData(cTr,:,OffFrameAlign_Diff(cTr)+1:...
        (OffFrameAlign_Diff(cTr) + SoundOffAlignLength));
end
SoundOffAlignFrame = MinOffFrame;
%% sound off align test
TrainInds = 1:60;
TestInds = 61:90;

NonOverlapStep = BinLen - BinOverlap;
% NumberBin = floor(NumFrames/NonOverlapStep)-1;
OffAlignFrames = size(SoundOffAlignData,3);
OffA_StartBinInds = 1:NonOverlapStep:(OffAlignFrames-BinLen);
NumberBin = numel(OffA_StartBinInds) - 1;
SoundOn_md_BinCorrRate = zeros(NumberBin,1);
BinCenters = zeros(NumberBin,1);
for cR = 1 : NumberBin
    BinStartEndInds = (cR-1)*NonOverlapStep + [1,BinLen];
    cBinData = squeeze(sum(SoundOffAlignData(TrainInds,:,BinStartEndInds(1):BinStartEndInds(2)),3));
    cBinDataPred = predict(Mdl,cBinData);
    cBinCorrRate = mean(sound_array(TrainInds,1) == cBinDataPred);
    SoundOn_md_BinCorrRate(cR) = cBinCorrRate;
    BinCenters(cR) = mean(BinStartEndInds);
end

ShufCorrThres = prctile(ShufCorr,95);

figure;
plot((BinCenters - SoundOffAlignFrame)/frame_rate,SoundOn_md_BinCorrRate)
yscales = get(gca,'ylim');
xscales = get(gca,'xlim');
line(xscales,[ShufCorrThres ShufCorrThres],'Color','r',...
    'linewidth',1.5,'linestyle','--');
line([0 0],yscales,'Color','c','linewidth',1.2,'linestyle','--')

set(gca,'ylim',yscales);

%% training sound off classifier
BinLen = round(0.3*frame_rate);
BinOverlap = round(0.2*frame_rate);
OffsetTimeBin = SoundOffAlignFrame + [1,BinLen];
OffsetBinData = squeeze(sum(SoundOffAlignData(TrainInds,:,OffsetTimeBin(1):OffsetTimeBin(2)),3));
OffsetBinData_Test = squeeze(sum(SoundOffAlignData(TestInds,:,OffsetTimeBin(1):OffsetTimeBin(2)),3));

SOff_Mdl = fitcnb(OffsetBinData,sound_array(TrainInds,1));
SOff_CVMdl = crossval(SOff_Mdl);
SOff_Loss = kfoldLoss(SOff_CVMdl,'mode','individual');

SOff_ShufCorr = zeros(500,1);
for cshuf = 1 : 500
    ShuInds = Vshuffle(1:size(OffsetBinData,1));
    shMdl = fitcnb(OffsetBinData,sound_array(ShuInds,1));
    TestTr_Pred = predict(shMdl,OffsetBinData_Test);
%     shCVMdl = crossval(shMdl);
%     SOff_ShufCorr(cshuf) = kfoldLoss(shCVMdl);
    SOff_ShufCorr(cshuf) = mean(sound_array(TestInds,1) == TestTr_Pred);
end

%%

SoundOff_md_BinCorrRate = zeros(NumberBin,1);
BinCenters = zeros(NumberBin,1);
for cR = 1 : NumberBin
    BinStartEndInds = (cR-1)*NonOverlapStep + [1,BinLen];
    cBinData = squeeze(sum(SoundOffAlignData(TestInds,:,BinStartEndInds(1):BinStartEndInds(2)),3));
    cBinDataPred = predict(SOff_Mdl,cBinData);
    cBinCorrRate = mean(sound_array(TestInds,1) == cBinDataPred);
    SoundOff_md_BinCorrRate(cR) = cBinCorrRate;
    BinCenters(cR) = mean(BinStartEndInds);
end

ShufCorrThres = prctile(ShufCorr,95);

figure;
plot((BinCenters - SoundOffAlignFrame)/frame_rate,SoundOff_md_BinCorrRate);
yscales = get(gca,'ylim');
xscales = get(gca,'xlim');
line(xscales,[ShufCorrThres ShufCorrThres],'Color','r',...
    'linewidth',1.5,'linestyle','--');
line([0 0],yscales,'Color','c','linewidth',1.2,'linestyle','--')

set(gca,'ylim',yscales);

