% clear
% clc
%%
TrFreqsAll = double(behavResults.Stim_toneFreq(:));
TrChoiceAll = double(behavResults.Action_choice(:));
TrAnsTimeAll = double(behavResults.Time_answer(:));
TrTrTypes = double(behavResults.Trial_Type(:));
TrTimeRe = double(behavResults.Time_reward(:));
TrStimOnTime = double(behavResults.Time_stimOnset(:));
NMInds = TrChoiceAll ~= 2;

TrFreqsNM = TrFreqsAll(NMInds);
TrChoiceNM = TrChoiceAll(NMInds);
TrAnsTimeNM = TrAnsTimeAll(NMInds);
TrTimeReNM = TrTimeRe(NMInds);
TrStimOnTimeNM = TrStimOnTime(NMInds);
TrTrTypesNM = TrTrTypes(NMInds);
NMTrNum = length(TrFreqsNM);

nROIs = size(SpikeAligned,2);

TrOctsNM = log2(TrFreqsNM/min(TrFreqsNM)) - 1;
TrAnsFTimeNM = round((TrAnsTimeNM/1000)*frame_rate);
TrFTimeReNM = round((TrTimeReNM/1000)*frame_rate);
TrStimOnFTimeNM = round((TrStimOnTimeNM/1000)*frame_rate);
TimeWin = 0.3;%s, time window used for response calculation
FrameWin = round(TimeWin*frame_rate);
[~,FreqSortInds] = sort(TrOctsNM);
%%
TrEventsRespData = zeros(NMTrNum,nROIs,3); % freq, answer, reward corresponded to three columns
for ctr = 1 : NMTrNum
    cTrSPData = nnspike{ctr};
    cStimOnResp = cTrSPData(:,(TrStimOnFTimeNM(ctr)+1):(TrStimOnFTimeNM(ctr)+1+FrameWin));
    TrEventsRespData(ctr,:,1) = mean(cStimOnResp,2);
    
    cAnsResp = cTrSPData(:,(TrAnsFTimeNM(ctr)+1):(TrAnsFTimeNM(ctr)+1+FrameWin));
    TrEventsRespData(ctr,:,2) = mean(cAnsResp,2);
    
    if TrFTimeReNM(ctr)
        cReResp = cTrSPData(:,(TrFTimeReNM(ctr)+1):(TrFTimeReNM(ctr)+1+FrameWin));
        TrEventsRespData(ctr,:,3) = mean(cReResp,2);
    end
end

%%
FreqTypes = unique(TrOctsNM);
nFreqs = numel(FreqTypes);
FreqInds = cell(nFreqs,1);
for cf = 1 : nFreqs
%     FreqInds{cf} = TrOctsNM == FreqTypes(cf) & TrTrTypesNM == TrChoiceNM;
    FreqInds{cf} = TrOctsNM == FreqTypes(cf);
end

%%
% close
AllROIData = cell(nROIs,1);
for cROI = 1 : nROIs
    % cROI = 42;
    cROIData = squeeze(TrEventsRespData(:,cROI,:));
    % figure('position',[200 100 800 320])
    % subplot(121)
    % imagesc(cROIData(FreqSortInds,:),[0 min(max(cROIData(:)),0.05)]);  %

    cRData = zeros(nFreqs,2);
    for ccf = 1 : nFreqs
        cRData(ccf,1) = mean(cROIData(FreqInds{ccf},1));
        cRData(ccf,2) = std(cROIData(FreqInds{ccf},1));
    end
    % subplot(122)
    % errorbar((1:nFreqs)',cRData(:,1),cRData(:,2),'k-o','linewidth',2)


    %
    FreqMetrix = double(repmat(FreqTypes',NMTrNum,1) == repmat(TrOctsNM,1,nFreqs)); 
    AnsLMtx = 1 - TrChoiceNM;
    AnsRMtx = TrChoiceNM;
    ReLMtx = TrTrTypesNM == 0 & TrTrTypesNM == TrChoiceNM;
    ReRMtx = TrTrTypesNM == 1 & TrTrTypesNM == TrChoiceNM;
    IsReConsidered = 0;
    if IsReConsidered
        DataFitMtx = zeros(numel(cROIData),nFreqs+2+2);
        DataFitMtx(1:NMTrNum,1:nFreqs) = FreqMetrix;
        DataFitMtx(NMTrNum+1:NMTrNum*2,nFreqs+1) = AnsLMtx;
        DataFitMtx(NMTrNum+1:NMTrNum*2,nFreqs+2) = AnsRMtx;
        DataFitMtx(NMTrNum*2+1:end,nFreqs+3) = ReLMtx;
        DataFitMtx(NMTrNum*2+1:end,nFreqs+4) = ReRMtx;
        RespData = cROIData;
    else
        DataFitMtx = zeros(numel(cROIData(:,1:2)),nFreqs+2);
        DataFitMtx(1:NMTrNum,1:nFreqs) = FreqMetrix;
        DataFitMtx(NMTrNum+1:NMTrNum*2,nFreqs+1) = AnsLMtx;
        DataFitMtx(NMTrNum+1:NMTrNum*2,nFreqs+2) = AnsRMtx;
        RespData = cROIData(:,1:2);
    end

    %
    options = glmnetSet;
    options.alpha = 0.9;
    options.nlambda = 110;
    nRepeats = 10;
    RepeatData = cell(nRepeats,3);
    for cRepeat = 1 : nRepeats
        nFolds = 5;
        cc = cvpartition(NMTrNum,'kFold',nFolds);
        FoldCoefs = cell(nFolds,3);
        FoldDev = zeros(nFolds,1);
        FoldTestPred = cell(nFolds,2);

        for cf = 1 : nFolds
            TrainInds = find(cc.training(cf));
            BlankInds = false(NMTrNum,1);
            % TrainInds = randsample(NMTrNum,round(NMTrNum*0.7));
            BlankInds(TrainInds) = true;

            TrainRespDataMtx = reshape(RespData(BlankInds,:),[],1);
            TestRespData = reshape(RespData(~BlankInds,:),[],1);

            BehavParaInds = false(size(DataFitMtx,1),1);
            BehavParaInds(TrainInds) = true;
            BehavParaInds(TrainInds+NMTrNum) = true;
            BehavParaMtx = DataFitMtx(BehavParaInds,:);
            TestBehavParaMtx = DataFitMtx(~BehavParaInds,:);
            %
            cvmdfit = cvglmnet(BehavParaMtx,TrainRespDataMtx,'poisson',options,[],20);
            CoefUseds = cvglmnetCoef(cvmdfit,'lambda_1se');

            FoldCoefs{cf,1} = CoefUseds(2:end);
            FoldDev(cf) = max(cvmdfit.glmnet_fit.dev);

            %
        %     figure
        %     hist(TrainRespDataMtx,20)

            PredTestData = cvglmnetPredict(cvmdfit,TestBehavParaMtx,'lambda_1se','response');
            FoldTestPred{cf,1} = PredTestData;
            FoldTestPred{cf,2} = TestRespData;

            CoefAbsAll = abs(CoefUseds(2:end));
            [CoefSort,SortInds] = sort(CoefAbsAll,'descend');
            DevExplained = 100*CoefSort/sum(CoefSort);
            FoldCoefs{cf,2} = SortInds;
            CoefExplainBlank = zeros(numel(CoefAbsAll),1);
            CoefExplainBlank(SortInds) = DevExplained;
            FoldCoefs{cf,3} = CoefExplainBlank;
        %     figure('position',[1000 100 800 320]);
        %     subplot(121)
        %     hold on
        %     plot(PredTestData,'k');
        %     plot(TestRespData,'r')
        % 
        %     subplot(122)
        %     plot(1:length(CoefUseds)-1,abs(CoefUseds(2:end)),'ko','linewidth',1.8);

        end
        RepeatData{cRepeat,1} = FoldCoefs;
        RepeatData{cRepeat,2} = FoldDev;
        RepeatData{cRepeat,3} = FoldTestPred;
    end
    AllROIData{cROI} = RepeatData;
end
 
%% analysis ROI coef Data 
nROIs = length(AllROIData);
CoefValueThres = 0.05;
RepeatFracThres = 1;
ROIAboveThresInds = cell(nROIs,2);
for cROI = 1 : nROIs
    cROIdata = AllROIData{cROI};
    cROICoefdata = cellfun(@(x) (cell2mat((x(:,1))'))',cROIdata(:,1),'uniformOutput',false);
    cROICoef_AllRepeats = cell2mat(cROICoefdata);
    
    cROIDev = (cell2mat((cROIdata(:,2))'))';
    
    CoefAboveThresMeanFrac = mean(double(abs(cROICoef_AllRepeats) > 0.05));
    CoefAboveThresInds = CoefAboveThresMeanFrac >= RepeatFracThres;
    
    ROIAboveThresInds{cROI,1} = CoefAboveThresInds;
    ROIAboveThresInds{cROI,2} = [mean(cROIDev(:)),std(cROIDev(:)),numel(cROIDev)];
    ROIAboveThresInds{cROI,3} = CoefAboveThresMeanFrac;
end
save SPDataBehavCoefSave.mat ROIAboveThresInds AllROIData -v7.3
%%
% close
% cROI = 117;
% hf = figure;
% hold on
% 
% plot(ROIAboveThresInds{cROI,1},'ko','linewidth',1.8);
% plot(ROIAboveThresInds{cROI,3},'ro','linewidth',1.8);
% xlim([0 11])
% ylim([-0.05 1.05])
% title(sprintf('ROI %d DE Avg = %.4f, std = %.4f',cROI,ROIAboveThresInds{cROI,2}(1),ROIAboveThresInds{cROI,2}(2)));
% 
% %%
% % evaluating alpha value effects
% UsedAlpha = 0:0.1:1;
% NumAlpha = length(UsedAlpha);
% MinCVM = zeros(NumAlpha,2);
% for cTest = 1 : NumAlpha
%     options.alpha = UsedAlpha(cTest);
%     cvmdfit = cvglmnet(BehavParaMtx,TrainRespDataMtx,'poisson',options);
%     MinCVM(cTest,1) = min(cvmdfit.cvm);
%     
%     PredTestData = cvglmnetPredict(cvmdfit,TestBehavParaMtx,'lambda_min','response');
%     MinCVM(cTest,2) = sqrt(sum((PredTestData(:) - TestRespData(:)).^2)/numel(TestRespData));
% end
% 
% 
% %% test of every single ROI response pattern
% close
% close
% close
%     cROI = 2;
%     cROIData = squeeze(TrEventsRespData(:,cROI,:));
%     figure('position',[200 100 800 320])
%     subplot(121)
%     imagesc(cROIData(FreqSortInds,:),[0 min(max(cROIData(:)),0.05)]);  %
% 
%     cRData = zeros(nFreqs,2);
%     for ccf = 1 : nFreqs
%         cRData(ccf,1) = mean(cROIData(FreqInds{ccf},1));
%         cRData(ccf,2) = std(cROIData(FreqInds{ccf},1));
%     end
%     subplot(122)
%     errorbar((1:nFreqs)',cRData(:,1),cRData(:,2),'k-o','linewidth',2)
% 
% 
%     %
%     FreqMetrix = double(repmat(FreqTypes',NMTrNum,1) == repmat(TrOctsNM,1,nFreqs)); 
%     AnsLMtx = 1 - TrChoiceNM;
%     AnsRMtx = TrChoiceNM;
%     ReLMtx = TrTrTypesNM == 0 & TrTrTypesNM == TrChoiceNM;
%     ReRMtx = TrTrTypesNM == 1 & TrTrTypesNM == TrChoiceNM;
%     IsReConsidered = 0;
%     if IsReConsidered
%         DataFitMtx = zeros(numel(cROIData),nFreqs+2+2);
%         DataFitMtx(1:NMTrNum,1:nFreqs) = FreqMetrix;
%         DataFitMtx(NMTrNum+1:NMTrNum*2,nFreqs+1) = AnsLMtx;
%         DataFitMtx(NMTrNum+1:NMTrNum*2,nFreqs+2) = AnsRMtx;
%         DataFitMtx(NMTrNum*2+1:end,nFreqs+3) = ReLMtx;
%         DataFitMtx(NMTrNum*2+1:end,nFreqs+4) = ReRMtx;
%         RespData = cROIData;
%     else
%         DataFitMtx = zeros(numel(cROIData(:,1:2)),nFreqs+2);
%         DataFitMtx(1:NMTrNum,1:nFreqs) = FreqMetrix;
%         DataFitMtx(NMTrNum+1:NMTrNum*2,nFreqs+1) = AnsLMtx;
%         DataFitMtx(NMTrNum+1:NMTrNum*2,nFreqs+2) = AnsRMtx;
%         RespData = cROIData(:,1:2);
%     end
% 
%     %
%     options = glmnetSet;
%     options.alpha = 0.9;
%     options.nlambda = 110;
%     
%     nFolds = 5;
%     cc = cvpartition(NMTrNum,'kFold',nFolds);
%     cf = 1;
%     
%     TrainInds = find(cc.training(cf));
%     BlankInds = false(NMTrNum,1);
%     % TrainInds = randsample(NMTrNum,round(NMTrNum*0.7));
%     BlankInds(TrainInds) = true;
% 
%     TrainRespDataMtx = reshape(RespData(BlankInds,:),[],1);
%     TestRespData = reshape(RespData(~BlankInds,:),[],1);
% 
%     BehavParaInds = false(size(DataFitMtx,1),1);
%     BehavParaInds(TrainInds) = true;
%     BehavParaInds(TrainInds+NMTrNum) = true;
%     BehavParaMtx = DataFitMtx(BehavParaInds,:);
%     TestBehavParaMtx = DataFitMtx(~BehavParaInds,:);
%     %
%     cvmdfit = cvglmnet(BehavParaMtx,TrainRespDataMtx,'poisson',options,[],20);
%     CoefUseds = cvglmnetCoef(cvmdfit,'lambda_1se');
% 
% 
% %             FoldDev(cf) = max(cvmdfit.glmnet_fit.dev);
% 
%     %
%     figure
%     hist(TrainRespDataMtx,20)
% 
%     PredTestData = cvglmnetPredict(cvmdfit,TestBehavParaMtx,'lambda_min','response');
% 
%     CoefAbsAll = abs(CoefUseds(2:end));
%     [CoefSort,SortInds] = sort(CoefAbsAll,'descend');
%     DevExplained = 100*CoefSort/sum(CoefSort);
% 
%     CoefExplainBlank = zeros(numel(CoefAbsAll),1);
% 
%     figure('position',[1000 100 800 320]);
%     subplot(121)
%     hold on
%     plot(PredTestData,'k');
%     plot(TestRespData,'r')
% 
%     subplot(122)
%     plot(1:length(CoefUseds)-1,abs(CoefUseds(2:end)),'ko','linewidth',1.8);

