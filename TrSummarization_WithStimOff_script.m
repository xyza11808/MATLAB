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
% 
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
if ~iscell(DataRaw)
    nROIs = size(DataRaw,2);
else
    nROIs = size(DataRaw{1},1);
end
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
if iscell(nnspike)
    NMSpikeData = nnspike(NMInds);
else
    NMSpikeData = nnspike(NMInds,:,:);
end
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
    for cAnsDelayNum = 1 : length(AnsDelayFrame)
        cAnsDelayResp = cTrSPData(:,(TrAnsFTimeNM(ctr)+1+AnsDelayFrame(cAnsDelayNum)):(TrAnsFTimeNM(ctr)+1+FrameWin+AnsDelayFrame(cAnsDelayNum)));
        TrEventsRespData(ctr,:,5+cAnsDelayNum) = mean(cAnsDelayResp,2);
    end
end

% substract baseline activity for all response types
BaseSubMtx = repmat(TrEventsRespData(:,:,5),1,1,4);
BaseSubTrEventsResp = max(TrEventsRespData(:,:,1:4) - BaseSubMtx,0);

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
for cROI = 1 : nROIs
    %
%     cROI = 27;
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


    %
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
        DataFitMtx(NMTrNum+1:NMTrNum*2,nFreqs+1) = AnsLMtx;
        DataFitMtx(NMTrNum+1:NMTrNum*2,nFreqs+2) = AnsRMtx;
        DataFitMtx(NMTrNum*2+1:NMTrNum*3,nFreqs+3) = ReLMtx;
        DataFitMtx(NMTrNum*2+1:NMTrNum*3,nFreqs+4) = ReRMtx;
        DataFitMtx(3*NMTrNum+1:end,1:nFreqs+5:end) = FreqMetrix;
        for cDelayNum = 1 : NumAnsDelayFun
            cRowStartInds = NMTrNum*3 + 1 + (cDelayNum - 1) * NMTrNum;
            cColStartInds = 2*nFreqs + 2 + (cDelayNum - 1) * 2;
            
            DataFitMtx(cRowStartInds:cRowStartInds+NMTrNum,cColStartInds + 1) = AnsLMtx;
            DataFitMtx(cRowStartInds:cRowStartInds+NMTrNum,cColStartInds + 2) = AnsRMtx;
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
            BehavParaInds(TrainInds+NMTrNum*2) = true;
            
            for cDelayN = 1 : NumAnsDelayFun
                BehavParaInds(TrainInds+NMTrNum*(2+cDelayN)) = true;
            end
            BehavParaMtx = DataFitMtx(BehavParaInds,:);
            TestBehavParaMtx = DataFitMtx(~BehavParaInds,:);
            %
%             if ~sum(TrainRespDataMtx)
                cvmdfit = cvglmnet(BehavParaMtx,TrainRespDataMtx,'poisson',options,[],20);
                CoefUseds = cvglmnetCoef(cvmdfit,'lambda_1se');

                FoldCoefs{cf,1} = CoefUseds(2:end);
                FoldDev(cf) = max(cvmdfit.glmnet_fit.dev);

                %
            %     figure
            %     hist(TrainRespDataMtx,20)

                PredTestData = cvglmnetPredict(cvmdfit,TestBehavParaMtx,'lambda_1se','response');
                
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
CoefValueThres = 0.4;
RepeatFracThres = 0.5;
ROIAboveThresInds = cell(nROIs,4);
for cROI = 1 : nROIs
    %
    cROIdata = AllROIData{cROI};
    cROICoefdata = cellfun(@(x) (cell2mat((x(:,1))'))',cROIdata(:,1),'uniformOutput',false);
    cROICoef_AllRepeats = cell2mat(cROICoefdata);
    
    cROIDev = (cell2mat((cROIdata(:,2))'))';
    cROICoef_meanV = mean(cROICoef_AllRepeats);
    PosCoefIndex = cROICoef_meanV > 0;
    
    CoefAboveThresMeanFrac = mean(double(abs(cROICoef_AllRepeats) > CoefValueThres));
    CoefAboveThresInds = CoefAboveThresMeanFrac >= RepeatFracThres & PosCoefIndex;
    %
    ROIAboveThresInds{cROI,1} = CoefAboveThresInds;
    ROIAboveThresInds{cROI,2} = [mean(cROIDev(:)),std(cROIDev(:)),numel(cROIDev)];
    ROIAboveThresInds{cROI,3} = CoefAboveThresMeanFrac;
    ROIAboveThresInds{cROI,4} = mean(cROICoef_AllRepeats);
end
%%
save SPDataBehavCoefSaveOff.mat ROIAboveThresInds AllROIData -v7.3
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
