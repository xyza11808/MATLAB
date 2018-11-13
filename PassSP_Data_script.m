
close
cROI = 6;
ROI1Data = squeeze(f_percent_change(:,cROI,:));
ROI1Trace = reshape(ROI1Data',[],1);
figure;plot(ROI1Trace)
% f_percent_change = f_percent_change;
%%

nnspike = Fluo2SpikeConstrainOOpsi(f_percent_change,[],[],frame_rate,2);



%%
close
cROI = 40;
ROI1Data = squeeze(f_percent_change(:,cROI,:));
ROI1Trace = reshape(ROI1Data',[],1);

ROISPData = squeeze(nnspike(:,cROI,:));
ROISPTrace = reshape(ROISPData',[],1);
figure;
% hold on
plot(ROI1Trace,'k');
yyaxis right
plot(ROISPTrace,'r')

%%
[~,SortInds] = sort(SelectSArray);
figure;imagesc(ROISPData(SortInds,:))

%%
Time_Win = 0.3;
FrameWin = round(Time_Win * frame_rate);
OnsetFrame = frame_rate;
OffsetFrame = frame_rate+FrameWin;

OnsetTrResp = mean(ROISPData(:,OnsetFrame+1:OnsetFrame+FrameWin),2);
OffTrResp = mean(ROISPData(:,OffsetFrame+1:OffsetFrame+FrameWin),2);
RespMtx = [OnsetTrResp,OffTrResp];

figure;
imagesc(RespMtx(SortInds,:))

%%
nTrials = length(SelectSArray);
FreqTypes = unique(SelectSArray);
nFreqs = length(FreqTypes);
FreqMtxInds = double(repmat(SelectSArray,1,nFreqs) == repmat(FreqTypes',nTrials,1));
FreqMtxOnOffMtx = zeros(nTrials*2,nFreqs*2);
FreqMtxOnOffMtx(1:nTrials,1:nFreqs) = FreqMtxInds;
FreqMtxOnOffMtx((1:nTrials)+nTrials,(1:nFreqs)+nFreqs) = FreqMtxInds;

%%
%     close
%     figure;
%     plot(CoefUseds(2:end),'ko','linewidth',1.6)
options = glmnetSet;
options.alpha = 0.9;
options.nlambda = 110;
TotalRespMtx = RespMtx(:);


nFolds = 5;
cc = cvpartition(NMTrNum,'kFold',nFolds);
FoldCoefs = cell(nFolds,3);
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
    FoldCoefs{cf} = CoefUseds(2:end);
    FoldDev(cf) = max(cvmdfit.glmnet_fit.dev);
    
    PredTestData = cvglmnetPredict(cvmdfit,TestFreqParas,'lambda_1se','response');
    FoldTestPred{cf,1} = PredTestData;
    FoldTestPred{cf,2} = TestRespVec;
end

