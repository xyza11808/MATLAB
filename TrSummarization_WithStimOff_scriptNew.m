% clear
% clc
if ~exist('DataRaw','var')
    load('CSessionData.mat','DataRaw');
end
% DataRaw = data;
% try
%     load('EstimateSPsaveNew.mat');
% catch
%     load('EstimateSPsave.mat');
% end
% clearvars nnspike SpikeAligned 
% 
% nnspike = Fluo2SpikeConstrainOOpsi(DataRaw,[],[],frame_rate,2);
if ~iscell(DataRaw)
    nROIs = size(DataRaw,2);
else
    nROIs = size(DataRaw{1},1);
end

if iscell(DataRaw)
    DataTrace = cell2mat(DataRaw');
else
    DataTrace = reshape(permute(DataRaw,[2,3,1]),nROIs,[]);  
end
%%
ROIstdThres = zeros(nROIs,1);
for cR = 1 : nROIs
    cRTrace = DataTrace(cR,:);
    StdUpperLowBound = prctile(cRTrace,[10 90]);
    StdCalRange = std(cRTrace(cRTrace >= StdUpperLowBound(1) & ...
        cRTrace <= StdUpperLowBound(2)));
    ROIstdThres(cR) = StdCalRange;
end

% save EstimateSPsaveNewAR2.mat DataRaw behavResults frame_rate nnspike -v7.3
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

TrOctsNM = log2(TrFreqsNM/min(TrFreqsNM)) - 1;
TrAnsFTimeNM = round((TrAnsTimeNM/1000)*frame_rate);
TrFTimeReNM = round((TrTimeReNM/1000)*frame_rate);
TrStimOnFTimeNM = round((TrStimOnTimeNM/1000)*frame_rate);
TimeWin = 0.3;%s, time window used for response calculation
FrameWin = round(TimeWin*frame_rate);
AnsDelayFun = [0.5,1];
AnsDelayFrame = round(AnsDelayFun*frame_rate);
NumAnsDelayFun = length(AnsDelayFrame);
[~,FreqSortInds] = sort(TrOctsNM);
%%
% NewNNData = ThresSubData(nnspike);
if iscell(nnspike)
    NMSpikeData = nnspike(NMInds);
%     NMSpikeData = NewNNData(NMInds);
else
    NMSpikeData = nnspike(NMInds,:,:);
%     NMSpikeData = NewNNData(NMInds,:,:);
end
%%
TrEventsRespData = zeros(NMTrNum,nROIs,5+NumAnsDelayFun); % freq, answer, reward corresponded to three columns
for ctr = 1 : NMTrNum
    if iscell(nnspike)
        cTrSPData = NMSpikeData{ctr};
    else
        cTrSPData = squeeze(NMSpikeData(ctr,:,:));
    end
    BeforeSPBaselineMtx = cTrSPData(:,(TrStimOnFTimeNM(ctr)-FrameWin+1):TrStimOnFTimeNM(ctr));
    BeforeSPBaselineTrace = mean(BeforeSPBaselineMtx,2);
    TrEventsRespData(ctr,:,5) = BeforeSPBaselineTrace;
    cStimOnResp = cTrSPData(:,(TrStimOnFTimeNM(ctr)+1):(TrStimOnFTimeNM(ctr)+1+FrameWin));
    TrEventsRespData(ctr,:,1) = mean(cStimOnResp,2);
    cStimOffResp = cTrSPData(:,(TrStimOnFTimeNM(ctr)+1+FrameWin):(TrStimOnFTimeNM(ctr)+1+2*FrameWin));
    TrEventsRespData(ctr,:,4) = mean(cStimOffResp,2);
    
    cAnsResp = cTrSPData(:,(TrAnsFTimeNM(ctr)+1):(TrAnsFTimeNM(ctr)+1+FrameWin));
    TrEventsRespData(ctr,:,2) = mean(cAnsResp,2);
    
    if TrFTimeReNM(ctr)
        cReResp = cTrSPData(:,(TrFTimeReNM(ctr)+1):(TrFTimeReNM(ctr)+1+FrameWin));
        TrEventsRespData(ctr,:,3) = mean(cReResp,2);
    end
    nMaxFrame = size(cTrSPData,3);
    for cAnsDelayNum = 1 : length(AnsDelayFrame)
        cAnsDelayResp = cTrSPData(:,...
            min(TrAnsFTimeNM(ctr)+1+AnsDelayFrame(cAnsDelayNum),nMaxFrame):min(TrAnsFTimeNM(ctr)+1+FrameWin+AnsDelayFrame(cAnsDelayNum),nMaxFrame));
        TrEventsRespData(ctr,:,5+cAnsDelayNum) = mean(cAnsDelayResp,2);
    end
end

% substract baseline activity for all response types
BaseSubMtx = repmat(TrEventsRespData(:,:,5),1,1,4);
% BaseSubTrEventsResp = mean(TrEventsRespData(:,:,1:4) - BaseSubMtx,0);
BaseSubTrEventsResp = mean(TrEventsRespData(:,:,1:4));
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
NumParas = size(TrEventsRespData,3);

AllROIData = cell(nROIs,1);

options = glmnetSet;
    options.alpha = 0.9;
    options.nlambda = 110;
%% using glmnet analysis, unable to use parpool while using this function

for cROI = 1 : nROIs
    %
%     cROI = 48;
%     close
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
    FreqMetrix = double(repmat(FreqTypes',NMTrNum,1) == repmat(TrOctsNM,1,nFreqs)); 
    AnsLMtx = 1 - TrChoiceNM;
    AnsRMtx = TrChoiceNM;
    ReLMtx = TrTrTypesNM == 0 & TrTrTypesNM == TrChoiceNM;
    ReRMtx = TrTrTypesNM == 1 & TrTrTypesNM == TrChoiceNM;
    IsReConsidered = 0;
    %
    if IsReConsidered
        DataFitMtx = zeros(numel(cROIData),2*nFreqs+2+2+NumAnsDelayFun*2);
        DataFitMtx(1:NMTrNum,1:nFreqs) = FreqMetrix;
        DataFitMtx((NMTrNum+1):NMTrNum*2,nFreqs+1) = AnsLMtx;
        DataFitMtx((NMTrNum+1):NMTrNum*2,nFreqs+2) = AnsRMtx;
        DataFitMtx((NMTrNum*2+1):NMTrNum*3,nFreqs+3) = ReLMtx;
        DataFitMtx((NMTrNum*2+1):NMTrNum*3,nFreqs+4) = ReRMtx;
        DataFitMtx((3*NMTrNum+1):NMTrNum*4,(nFreqs+5):(2*nFreqs+4)) = FreqMetrix;
        for cDelayNum = 1 : NumAnsDelayFun
            cRowStartInds = NMTrNum*4 + (cDelayNum - 1) * NMTrNum;
            cColStartInds = 2*nFreqs + 4 + (cDelayNum - 1) * 2;
            
            DataFitMtx((cRowStartInds+1):(cRowStartInds+NMTrNum),cColStartInds + 1) = AnsLMtx;
            DataFitMtx((cRowStartInds+1):(cRowStartInds+NMTrNum),cColStartInds + 2) = AnsRMtx;
        end
        
        RespData = cROIData;
    else
        DataFitMtx = zeros(numel(cROIData(:,[1,2,4,6:NumParas])),2*nFreqs+2+NumAnsDelayFun*2);
        DataFitMtx(1:NMTrNum,1:nFreqs) = FreqMetrix;
        DataFitMtx(NMTrNum+1:NMTrNum*2,nFreqs+1) = AnsLMtx;
        DataFitMtx(NMTrNum+1:NMTrNum*2,nFreqs+2) = AnsRMtx;
        DataFitMtx(NMTrNum*2+1:NMTrNum*3,nFreqs+3:2*nFreqs+2) = FreqMetrix;
        for cDelayNum = 1 : NumAnsDelayFun
            cRowStartInds = NMTrNum*3 + (cDelayNum - 1) * NMTrNum;
            cColStartInds = 2*nFreqs + 2 + (cDelayNum - 1) * 2;
            
            DataFitMtx(cRowStartInds+1:cRowStartInds+NMTrNum,cColStartInds + 1) = AnsLMtx;
            DataFitMtx(cRowStartInds+1:cRowStartInds+NMTrNum,cColStartInds + 2) = AnsRMtx;
        end
        
        RespData = cROIData(:,[1,2,4,6:NumParas]);
    end
%     figure;
%     imagesc(RespData)
%     
    %
    
    nRepeats = 2;
    RepeatData = cell(nRepeats,3);
% %     StepRepeatFitCells = cell(nRepeats,1);
    %
    for cRepeat = 1 : nRepeats
        %
        nFolds = 10;
        IsRandPartition = 0;
        try
            FoldTrainTestIndex = ClassEvenPartitionFun(TrOctsNM,nFolds);
        catch ME
%             fprintf('Error partition.\n');
            cc = cvpartition(NMTrNum,'kFold',nFolds);
            IsRandPartition = 1;
        end
        FoldCoefs = cell(nFolds,3);
        FoldDev = zeros(nFolds,1);
        FoldTestPred = cell(nFolds,2);
        StepFitCell = cell(nFolds,3);
        for cf = 1 : nFolds
            %
            if IsRandPartition
                TrainInds = find(cc.training(cf));
            else
                TrainInds = FoldTrainTestIndex{1,cf};
            end
            BlankInds = false(NMTrNum,1);
            % TrainInds = randsample(NMTrNum,round(NMTrNum*0.7));
            BlankInds(TrainInds) = true;

            TrainRespDataMtx = reshape(RespData(BlankInds,:),[],1);
            TestRespData = reshape(RespData(~BlankInds,:),[],1);

            BehavParaInds = false(size(DataFitMtx,1),1);
            BehavParaInds(TrainInds) = true;
            BehavParaInds(TrainInds+NMTrNum) = true;
            BehavParaInds(TrainInds+NMTrNum*2) = true;
            
            for cDelayN = 1 : NumAnsDelayFun
                BehavParaInds(TrainInds+NMTrNum*(2+cDelayN)) = true;
            end
            BehavParaMtx = DataFitMtx(BehavParaInds,:);
            TestBehavParaMtx = DataFitMtx(~BehavParaInds,:);
            %
%             if ~sum(TrainRespDataMtx)
%                 cvmdfit = cvglmnet(BehavParaMtx,TrainRespDataMtx,'poisson',options,[],20);
%                 CoefUseds = cvglmnetCoef(cvmdfit,'lambda_1se');
               %
                mdfit = glmnet(BehavParaMtx,TrainRespDataMtx,'poisson',options);
                PredTestData = glmnetPredict(mdfit,TestBehavParaMtx,[],'response'); %,[],log(mean(TestRespVec))
                TestRespMtx = repmat(TestRespData, 1, size(PredTestData, 2));
                SquareErrors = sum((TestRespMtx - PredTestData).^2);
                
% %                 mddl = stepwiseglm(BehavParaMtx,TrainRespDataMtx,'linear','Distribution','poisson','CategoricalVars',true(size(BehavParaMtx,2),1));
% %                 ypred= predict(mddl, TestBehavParaMtx);
                
                %
    %             figure;plot(SquareErrors)
                [~,minInds] = min(SquareErrors);
                minInds = min(minInds, 10);
                CoefUseds = glmnetCoef(mdfit, mdfit.lambda(minInds));
                PredDatas = PredTestData(:, minInds);
            
                FoldCoefs{cf,1} = (CoefUseds(2:end))';
                FoldDev(cf,1) = mdfit.dev(minInds);
                FoldDev(cf,2) = mdfit.nulldev;

                CoefAbsAll = abs(CoefUseds(2:end));
                [CoefSort,SortInds] = sort(CoefAbsAll,'descend');
                DevExplained = 100*CoefSort/sum(CoefSort);
                FoldCoefs{cf,2} = SortInds;
                CoefExplainBlank = zeros(numel(CoefAbsAll),1);
                CoefExplainBlank(SortInds) = DevExplained;
                FoldCoefs{cf,3} = CoefExplainBlank;
%             else
%                 CoefUseds = zeros(size(BehavParaMtx,2)+1,1);
%                 FoldCoefs{cf,1} = CoefUseds(2:end);
%                 FoldDev(cf) = 0;
%                 PredTestData = zeros(size(TestRespData));
%                 FoldCoefs{cf,2} = CoefUseds;
%                 FoldCoefs{cf,3} = CoefUseds;
%             end
            FoldTestPred{cf,1} = PredTestData;
            FoldTestPred{cf,2} = TestRespData;
            
% %             StepFitCell{cf,1} = mddl;
% %             StepFitCell{cf,2} = ypred;
% %             StepFitCell{cf,3} = TestRespData;
            
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
        
% %         StepRepeatFitCells{cRepeat} = StepFitCell;
        
    end
    AllCoefsCell = RepeatData{:,1};
    AllCoefsMtx = cell2mat(AllCoefsCell(:,1));
    AllROIData{cROI} = RepeatData;
end

%%
AllROI_StepwiseCoefData = cell(nROIs,2);

%%  using stepwiseglm function, using parpool for speed
parfor cROI = 1 : nROIs
    %%
    cROI = 9;
%     close
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
    FreqMetrix = double(repmat(FreqTypes',NMTrNum,1) == repmat(TrOctsNM,1,nFreqs)); 
    AnsLMtx = 1 - TrChoiceNM;
    AnsRMtx = TrChoiceNM;
    ReLMtx = TrTrTypesNM == 0 & TrTrTypesNM == TrChoiceNM;
    ReRMtx = TrTrTypesNM == 1 & TrTrTypesNM == TrChoiceNM;
    IsReConsidered = 0;
    %
    if IsReConsidered
        DataFitMtx = zeros(numel(cROIData),2*nFreqs+2+2+NumAnsDelayFun*2);
        DataFitMtx(1:NMTrNum,1:nFreqs) = FreqMetrix;
        DataFitMtx((NMTrNum+1):NMTrNum*2,nFreqs+1) = AnsLMtx;
        DataFitMtx((NMTrNum+1):NMTrNum*2,nFreqs+2) = AnsRMtx;
        DataFitMtx((NMTrNum*2+1):NMTrNum*3,nFreqs+3) = ReLMtx;
        DataFitMtx((NMTrNum*2+1):NMTrNum*3,nFreqs+4) = ReRMtx;
        DataFitMtx((3*NMTrNum+1):NMTrNum*4,(nFreqs+5):(2*nFreqs+4)) = FreqMetrix;
        for cDelayNum = 1 : NumAnsDelayFun
            cRowStartInds = NMTrNum*4 + (cDelayNum - 1) * NMTrNum;
            cColStartInds = 2*nFreqs + 4 + (cDelayNum - 1) * 2;
            
            DataFitMtx((cRowStartInds+1):(cRowStartInds+NMTrNum),cColStartInds + 1) = AnsLMtx;
            DataFitMtx((cRowStartInds+1):(cRowStartInds+NMTrNum),cColStartInds + 2) = AnsRMtx;
        end
        
        RespData = cROIData;
    else
        DataFitMtx = zeros(numel(cROIData(:,[1,2,4,6:NumParas])),2*nFreqs+2+NumAnsDelayFun*2);
        DataFitMtx(1:NMTrNum,1:nFreqs) = FreqMetrix;
        DataFitMtx(NMTrNum+1:NMTrNum*2,nFreqs+1) = AnsLMtx;
        DataFitMtx(NMTrNum+1:NMTrNum*2,nFreqs+2) = AnsRMtx;
        DataFitMtx(NMTrNum*2+1:NMTrNum*3,nFreqs+3:2*nFreqs+2) = FreqMetrix;
        for cDelayNum = 1 : NumAnsDelayFun
            cRowStartInds = NMTrNum*3 + (cDelayNum - 1) * NMTrNum;
            cColStartInds = 2*nFreqs + 2 + (cDelayNum - 1) * 2;
            
            DataFitMtx(cRowStartInds+1:cRowStartInds+NMTrNum,cColStartInds + 1) = AnsLMtx;
            DataFitMtx(cRowStartInds+1:cRowStartInds+NMTrNum,cColStartInds + 2) = AnsRMtx;
        end
        
        RespData = cROIData(:,[1,2,4,6:NumParas]);
    end
    figure;
    hist(RespData(RespData > 1e-8),50)
    RespData(RespData < 1e-9) = 1e-9;
%     
    %%
    
    nRepeats = 2;
    StepRepeatFitCells = cell(nRepeats,1);
    %
    for cRepeat = 1 : nRepeats
        %
        nFolds = 10;
        IsRandPartition = 0;
        try
            FoldTrainTestIndex = ClassEvenPartitionFun(TrOctsNM,nFolds);
        catch ME
%             fprintf('Error partition.\n');
            cc = cvpartition(NMTrNum,'kFold',nFolds);
            IsRandPartition = 1;
        end
        FoldCoefs = cell(nFolds,3);
        FoldDev = zeros(nFolds,1);
        FoldTestPred = cell(nFolds,2);
        StepFitCell = cell(nFolds,3);
        for cf = 1 : nFolds
            %
            if IsRandPartition
                TrainInds = find(cc.training(cf));
            else
                TrainInds = FoldTrainTestIndex{1,cf};
            end
            BlankInds = false(NMTrNum,1);
            % TrainInds = randsample(NMTrNum,round(NMTrNum*0.7));
            BlankInds(TrainInds) = true;

            TrainRespDataMtx = reshape(RespData(BlankInds,:),[],1);
            TestRespData = reshape(RespData(~BlankInds,:),[],1);

            BehavParaInds = false(size(DataFitMtx,1),1);
            BehavParaInds(TrainInds) = true;
            BehavParaInds(TrainInds+NMTrNum) = true;
            BehavParaInds(TrainInds+NMTrNum*2) = true;
            
            for cDelayN = 1 : NumAnsDelayFun
                BehavParaInds(TrainInds+NMTrNum*(2+cDelayN)) = true;
            end
            BehavParaMtx = DataFitMtx(BehavParaInds,:);
            TestBehavParaMtx = DataFitMtx(~BehavParaInds,:);
                
                mddl = stepwiseglm(BehavParaMtx,TrainRespDataMtx,'linear','Distribution','gamma','CategoricalVars',true(size(BehavParaMtx,2),1));
                ypred= predict(mddl, TestBehavParaMtx);
                
                %

            StepFitCell{cf,1} = mddl;
            StepFitCell{cf,2} = ypred;
            StepFitCell{cf,3} = TestRespData;

        end

        StepRepeatFitCells{cRepeat} = StepFitCell;
        
    end

    StepFitCoefsCell = StepRepeatFitCells{:};
    StepFitCoefs = cellfun(@(x) x.Formula.InModel,StepFitCoefsCell(:,1),'Uniformoutput',false);
%%
    AllROI_StepwiseCoefData(cROI, :) = {StepFitCoefsCell, StepFitCoefs};
    
end


%% analysis ROI coef Data 
nROIs = length(AllROIData);
CoefValueThres = 0;
RepeatFracThres = 0.75;
ROIAboveThresInds = cell(nROIs,4);
for cROI = 1 : nROIs
    %
    cROIdata = AllROIData{cROI};
    cROICoefdata = cellfun(@(x) (cell2mat((x(:,1))'))',cROIdata(:,1),'uniformOutput',false);
    cROICoef_AllRepeats = cell2mat(cROICoefdata);
    %
    cROIDev = (cell2mat((cROIdata(:,2))'))';
    cROICoef_meanV = mean(cROICoef_AllRepeats);
    PosCoefIndex = cROICoef_meanV > 0;
    %
    CoefAboveThresMeanFrac = mean(double(abs(cROICoef_AllRepeats) > CoefValueThres));
    CoefAboveThresInds = CoefAboveThresMeanFrac >= RepeatFracThres & PosCoefIndex;
    %
    ROIAboveThresInds{cROI,1} = CoefAboveThresInds;
    ROIAboveThresInds{cROI,2} = [mean(cROIDev(:)),std(cROIDev(:)),numel(cROIDev)];
    ROIAboveThresInds{cROI,3} = CoefAboveThresMeanFrac;
    ROIAboveThresInds{cROI,4} = mean(cROICoef_AllRepeats);
end
%%
if ~isdir('./SP_RespField_ana/')
    mkdir('./SP_RespField_ana/');
end
cd('./SP_RespField_ana/');
save SPDataBehavCoefSaveOff_191228.mat ROIAboveThresInds AllROIData ROIstdThres -v7.3
cd ..;
%%
% cROI = 28;
% cROISPData = cellfun(@(x) x(cROI,:),NMSpikeData,'uniformOutput',false);
% cROISPDataMtx = cell2mat(cROISPData');
% %
% cROIData = cellfun(@(x) x(cROI,:),DataRaw,'uniformOutput',false);
% cROIDataMtx = cell2mat(cROIData');
% %%
% figure;
% plot(cROISPDataMtx)
% yyaxis right
% plot(cROIDataMtx)
% %%
% ccROIData = squeeze(TrEventsRespData(:,103,:));
% figure;
% imagesc(ccROIData(FreqSortInds,:))
% %%
% close;
% cROI = 103;
% figure
% plot(ROIAboveThresInds{cROI,1},'ko','linewidth',1.8);
% ylim([-0.05 1.05]);
