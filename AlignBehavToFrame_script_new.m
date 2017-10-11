% scripts for align behavior parameters into single frame times
% H:\data\batch\batch27_PV\20160427\anm01\test02\channel1\im_data_reg_cpu\result_save\NO_Correction
FrameTime = SavedCaTrials.FrameTime;
FrameNum = SavedCaTrials.nFrames;
TrTime = FrameTime*FrameNum;  %in ms
FrameTimeBin = 0:FrameTime:TrTime;
TrStimTime = double(behavResults.Time_stimOnset);
TrRewardTi = double(behavResults.Time_reward);
TrAnswerTime = double(behavResults.Time_answer);
TrTrialTypes = double(behavResults.Trial_Type);
TrFreqs = double(behavResults.Stim_toneFreq);
TrChoice = double(behavResults.Action_choice);
TrIsProbTrs = double(behavResults.Trial_isProbeTrial);

nTrs = length(TrStimTime);
ProbStimStr = squeeze(behavSettings.probe_stimType);
[lick_time_struct,Lick_bias_side]=beha_lickTime_data(behavResults,ceil(TrTime)); %this function is used for converting lick time strings into arrays and save in a struct
ProbtypeStr = ProbStimStr(1,:);
StimusType = unique(TrFreqs);
nFreqs = length(StimusType);
DefStimFIndex = zeros(FrameNum,nFreqs);  % default index values
%%
 StimSTrs = cellstr(num2str(StimusType(:),'f%.fOn'));
 StimoffSTrs = cellstr(num2str(StimusType(:),'%.fOff'));
 StimSTrs = StimSTrs';
 StimoffSTrs = StimoffSTrs';
%  TaskParaStrs = {'LLick','RLick','LAns','RAns',StimSTrs{:},StimoffSTrs{:},'Reward','LTypeOn','LTypeOff',...
%  'RTypeOn','RTypeOff','EstimateSpike'};
 TaskParaStrs = {'LAns','RAns',StimSTrs{:},'LTypeOn','RTypeOn','Reward'};
%
w = gausswin(5,1);
TrTaskParaAll = cell(nTrs,1);
ExtraShiftNum = round(300/FrameTime);
BaseFunIndex = 1:2:ExtraShiftNum;
ExtraBaseFunNum = length(BaseFunIndex);
%%
for cTrs = 1 : nTrs
    %
%     LeftLickFrames = zeros(FrameNum,1); %% task parameter
%     RightLickFrames = zeros(FrameNum,1); %% task parameter
%     cTrlickStrc = lick_time_struct(cTrs);
%     % Left Lick To index
%     if ~isempty(cTrlickStrc.LickTimeLeft)
%         LickT2FrameInds = floor(cTrlickStrc.LickTimeLeft/FrameTime);
%         if length(unique(LickT2FrameInds)) == length(LickT2FrameInds)
%             LickT2FrameInds(LickT2FrameInds > FrameNum) = [];
%             LeftLickFrames(LickT2FrameInds) = LeftLickFrames(LickT2FrameInds) + 1;
%         else
%              LickT2FrameInds(LickT2FrameInds > FrameNum) = [];
%             for click = 1 : cTrlickStrc.LickNumLeft
%                 LeftLickFrames(LickT2FrameInds(click)) = LeftLickFrames(LickT2FrameInds(click)) + 1;
%             end
%         end
%     end
%     % Right Lick To index
%     if ~isempty(cTrlickStrc.LickTimeRight)
%         LickT2FrameInds = floor(cTrlickStrc.LickTimeRight/FrameTime);
%         if length(unique(LickT2FrameInds)) == length(LickT2FrameInds)
%             LickT2FrameInds(LickT2FrameInds > FrameNum) = [];
%             RightLickFrames(LickT2FrameInds) = RightLickFrames(LickT2FrameInds) + 1;
%         else
%             LickT2FrameInds(LickT2FrameInds > FrameNum) = [];
%             for click = 1 : cTrlickStrc.LickNumRight
%                 RightLickFrames(LickT2FrameInds(click)) = RightLickFrames(LickT2FrameInds(click)) + 1;
%             end
%         end
%     end
    % answer frame time index
    AnsFrameIndex = zeros(FrameNum,1);
    if (TrAnswerTime(cTrs) > 0)
        AnsFrameInds = floor(TrAnswerTime(cTrs)/FrameTime);
        LeftAnsFIndex = AnsFrameIndex;  %% task parameter 
        RightAnsFIndex = AnsFrameIndex;  %% task parameter
        if (AnsFrameInds < FrameNum)
            if TrChoice % right choice lick
%                 RightLickFrames(AnsFrameInds) = 0;
                RightAnsFIndex(AnsFrameInds) = 1;
            else  % left choice lick
%                 LeftLickFrames(AnsFrameInds) = 0;
                LeftAnsFIndex(AnsFrameInds) = 1;
            end
        end
    end
    % stimulus frame index
    StimFIndex = DefStimFIndex;   %% task parameter
    StimOffIndex = DefStimFIndex;   %% task parameter
    if TrIsProbTrs(cTrs)
        if strcmpi(ProbtypeStr,'ActiveReward') % no stimulus sound was given
%             continue;
        else
            cStim = TrFreqs(cTrs);
            cStimOnsetF = floor(TrStimTime(cTrs)/FrameTime);
            cStimOffsetF = floor((TrStimTime(cTrs)+300)/FrameTime);
            StimFIndex(cStimOnsetF,cStim == StimusType) = 1;
            StimOffIndex(cStimOffsetF,cStim == StimusType) = 1;
        end
    else
        cStim = TrFreqs(cTrs);
        cStimOnsetF = floor(TrStimTime(cTrs)/FrameTime);
        cStimOffsetF = floor((TrStimTime(cTrs)+300)/FrameTime);
        StimFIndex(cStimOnsetF,cStim == StimusType) = 1;
        StimOffIndex(cStimOffsetF,cStim == StimusType) = 1;
    end
    % reward index
    RewardIndex = zeros(FrameNum,1);   %% task parameter
    if TrRewardTi(cTrs) > 0
        RewardF = floor(TrRewardTi(cTrs)/FrameTime);
        if (RewardF < FrameNum)
            RewardIndex(RewardF) = 1;
        end
    end
    % trial type parameter
    LeftTypeOnIndex = zeros(FrameNum,1);   %% task parameter
    LeftTypeOffIndex = zeros(FrameNum,1);   %% task parameter
    RightTypeOnIndex = zeros(FrameNum,1);   %% task parameter
    RightTypeOffIndex = zeros(FrameNum,1);   %% task parameter
    
    cStimOnsetF = floor(TrStimTime(cTrs)/FrameTime);
    cStimOffsetF = floor((TrStimTime(cTrs)+300)/FrameTime);
    if TrTrialTypes(cTrs)
        RightTypeOnIndex(cStimOnsetF) = 1;
        RightTypeOffIndex(cStimOffsetF) = 1;
    else
        LeftTypeOnIndex(cStimOnsetF) = 1;
        LeftTypeOffIndex(cStimOffsetF) = 1;
    end
    
    % create the base function for stimulus and reward
    StimBaseFunc = zeros(nFreqs,ExtraBaseFunNum,FrameNum);
    StimStrCell = cell(nFreqs,ExtraBaseFunNum);
    RewardBaseFun = zeros(ExtraBaseFunNum,FrameNum);
    AnsBaseFun = zeros(2,ExtraBaseFunNum,FrameNum);
    for cInds = 1 : ExtraBaseFunNum
        cBaseInds = BaseFunIndex(cInds);
        StimBaseFunc(TrFreqs(cTrs) == StimusType,cInds,cBaseInds+cStimOnsetF) = 1;
        if cTrs == 1
            StimBasecStr = cellstr(num2str(StimusType(:),['f%.fB',num2str(cInds)]));
            StimStrCell(:,cInds) = StimBasecStr;  % stimulus base function strs
        end
        RewardBaseFun(cInds,RewardF+cBaseInds) = 1;
        if (TrAnswerTime(cTrs) > 0)
            if (AnsFrameInds + cBaseInds < FrameNum)
                if TrChoice % right choice lick
    %                 RightLickFrames(AnsFrameInds) = 0;
                    AnsBaseFun(2,cInds,AnsFrameInds + cBaseInds) = 1;
                else  % left choice lick
    %                 LeftLickFrames(AnsFrameInds) = 0;
                    AnsBaseFun(1,cInds,AnsFrameInds + cBaseInds) = 1;
                end
            end
        end
    end
    StimBaseFunAll = reshape(permute(StimBaseFunc,[2,1,3]),nFreqs*ExtraBaseFunNum,[]);
    AnsBaseFunAll = [squeeze(AnsBaseFun(1,:,:));squeeze(AnsBaseFun(2,:,:))];
    if cTrs == 1
        StimBaseStrs = (reshape(StimStrCell',[],1))';  % stimstrs for stimulus base function
        ReBaseStrs = (cellstr(num2str((1:ExtraBaseFunNum)','ReBase%.f')))';
        AnsBaseStrs = ([cellstr(num2str((1:ExtraBaseFunNum)','LeftAns%.f'));cellstr(num2str((1:ExtraBaseFunNum)','RightAns%.f'))])';
    end
   %
%     cTrTaskParameters = [LeftLickFrames,RightLickFrames,LeftAnsFIndex,RightAnsFIndex,...
%         StimFIndex,StimOffIndex,RewardIndex,LeftTypeOnIndex,LeftTypeOffIndex,RightTypeOnIndex,...
%         RightTypeOffIndex];
    cTrTaskParameters = [LeftAnsFIndex,RightAnsFIndex,...
        StimFIndex,LeftTypeOnIndex,RightTypeOnIndex,RewardIndex,...
        RewardBaseFun',AnsBaseFunAll',StimBaseFunAll'];
    for nCol = 1:size(cTrTaskParameters,2)
        cTrTaskParameters(:,nCol) = conv(cTrTaskParameters(:,nCol),w,'same');
    end
    TrTaskParaAll{cTrs} = cTrTaskParameters;
    %
end
TaskParaStrs = {TaskParaStrs{:},ReBaseStrs{:},AnsBaseStrs{:},StimBaseStrs{:},'EstimateSp'};
%% data preprocessing
RawData = SavedCaTrials.f_raw;
[~,DeltaF_F,exclude_inds]=FluoChangeCa2NPl(SavedCaTrials,behavResults,behavSettings,5,'2afc',ROIinfoBU,[]);
%% spike convertion
%parameter struc
V.Ncells = 1;
V.T = FrameNum;
V.Npixels = 1;
V.dt = FrameTime/1000;
P.lam = 10;
P.gam = 1 - V.dt/5; % tau = 5s, peak decay time
ROIstd = std(baselineDataAll,[],2);
nnspike = DataFluo2Spike(DeltaF_F,V,P,[],ROIstd); % estimated spike
nnspike(nnspike < 0.001) = 0; 
nnspike = nnspike + 0.001;
save newSpikeSave.mat nnspike DeltaF_F TrTaskParaAll -v7.3
% %%
% ROImd = cell(size(nnspike,2),1);
% for cROI = 1 : size(nnspike,2)
%     %
%     cROIdata = squeeze(nnspike(1:nTrs,cROI,:));
%     cROIVectorData = max(0,reshape(cROIdata',[],1));
%     TrTaskParaMtx = cell2mat(TrTaskParaAll);
% 
%     %
% %     figure;hist(cROIVectorData,100);
%     mdl = fitglm(TrTaskParaMtx,cROIVectorData, 'Distribution','poisson','VarNames',TaskParaStrs);
%     ROImd{cROI} = mdl;
%     %
% end
% %%
% cROI = 1;
% OldSpikeData = squeeze(cSPspike(:,cROI,:));
% OldSpikeVec = reshape(OldSpikeData',[],1);
% % NewSpikeData = squeeze(NewSpike(:,cROI,:));
% % NewSpikeVec = reshape(NewSpikeData,[],1);
% New2SPData = squeeze(nnspike(:,cROI,:));
% New2SPVec = reshape(New2SPData',[],1);
% TrialInds = 1:size(OldSpikeData,2):length(OldSpikeVec);
% PlotTrInds = reshape([TrialInds;TrialInds;nan(1,length(TrialInds))],[],1);
% PlotTrYinds = reshape([zeros(1,length(TrialInds));500*ones(1,length(TrialInds));nan(1,length(TrialInds))],[],1);
% 
% hf = figure;
% yyaxis left
% hold on
% plot(OldSpikeVec,'k');
% % plot(NewSpikeVec,'m');
% plot(New2SPVec,'r');
% 
% cRawData = squeeze(DeltaF_F(:,cROI,:));
% cRawVec = reshape(cRawData',[],1);
% yyaxis right
% hold on
% plot(cRawVec,'b');
% plot(PlotTrInds,PlotTrYinds,'linestyle','--','Color',[.7 .7 .7]);
% save TestDataSet.mat nnspike TrTaskParaAll -v7.3
%%

nfolds = 10;
nIters = nfolds;
TrainPerc = 0.75;
nROIs = size(nnspike,2);
ROImdCoef = cell(nROIs,nIters);
nTrs = size(nnspike,1);
PredCoef = zeros(nROIs,nIters);
PredCoefp = zeros(nROIs,nIters);
CVindsAll = cell(nROIs,1);
CVPredData = cell(nROIs,nIters);
%%
parfor croi = 1 : nROIs
    %
    cRdata = squeeze(nnspike(:,croi,:));
    cRdata = cRdata';
    cc = cvpartition(nTrs,'kFold',10);
    CVindsAll{croi} = cc;
    options = glmnetSet;
    options.alpha = 0.9;
    options.nlambda = 110;
    %
    for citer = 1 : nfolds
        %%
        TrainIndsLogi = cc.training(citer);
        
        TrainData = reshape((cRdata(:,TrainIndsLogi)),[],1);
        TrainParaData = cell2mat(TrTaskParaAll(TrainIndsLogi));
        TestParaData = cell2mat(TrTaskParaAll(~TrainIndsLogi));
        TestData = reshape((cRdata(:,~TrainIndsLogi)),[],1);
        %%
%         mdl = fitglm(TrainParaData,TrainData, 'Distribution','poisson','VarNames',TaskParaStrs);
        cvmdfit = cvglmnet(TrainParaData,TrainData,'poisson',options);
        cvmdCoef  = cvglmnetCoef(cvmdfit,'lambda_1se');
        ROImdCoef{croi,citer} = cvmdCoef;
        PredTestData = cvglmnetPredict(cvmdfit,TestParaData,[],'poisson');
        CVPredData{croi,citer} = PredTestData;  % cvPredDataRe = reshape(cvPredData,500,[]);
        %% figure;imagesc(cvPredDataRe');
        
        [coef,cop] = corrcoef(PredTestData,TestData);
        PredCoef(croi,citer) = coef(1,2);
        PredCoefp(croi,citer) = cop(1,2);
    end
    %
end
%%
if ~isdir('./TestPred_compPlot/')
    mkdir('./TestPred_compPlot/');
end
cd('./TestPred_compPlot/');
save modelData.mat ROImdCoef PredCoef PredCoefp CVindsAll CVPredData -v7.3
%%
for cROI=1:nROIs
    %
    cROIData = squeeze(nnspike(:,cROI,:));
    ROImaxColor = 1;%prctile(cROIData(:),80);
    cROICVinds = CVindsAll{cROI};
    for cfold = 1 : nfolds
        Halffold = nfolds/2;
        if mod(cfold,Halffold) == 1
            hf = figure('position',[50 120 1800 950]);
        end
        if cfold <= Halffold
            subplot(2,Halffold,cfold);
            cTestData = cROIData(cROICVinds.test(cfold),:); % test dataset
            imagesc(cTestData,[0 ROImaxColor]);
            title(sprintf('Partition%d',cfold));
            if cfold == 1
                ylabel('Behav. Trials');
            end
            set(gca,'FontSize',15);
            
            subplot(2,Halffold,cfold+Halffold);
            cPredData = (reshape(CVPredData{cROI,cfold},FrameNum,[]))'; % prediction of test dataset
            imagesc(cPredData,[0 ROImaxColor]);
            title({sprintf('Coef = %.3f',PredCoef(cROI,cfold));sprintf('p = %.3e',PredCoefp(cROI,cfold))});
            if cfold == 1
                ylabel('Pred. Trials');
            end
            set(gca,'FontSize',15);
        else
            subplot(2,Halffold,(cfold-Halffold));
            cTestData = cROIData(cROICVinds.test(cfold),:); % test dataset
            imagesc(cTestData,[0 ROImaxColor]);
            title(sprintf('Partition%d',cfold));
            if cfold == 1
                ylabel('Behav. Trials');
            end
            set(gca,'FontSize',15);
            
            subplot(2,Halffold,cfold);
            cPredData = (reshape(CVPredData{cROI,cfold},FrameNum,[]))'; % prediction of test dataset
            imagesc(cPredData,[0 ROImaxColor]);
            title({sprintf('Coef = %.3f',PredCoef(cROI,cfold));sprintf('p = %.3e',PredCoefp(cROI,cfold))});
            if cfold == 1
                ylabel('Pred. Trials');
            end
            set(gca,'FontSize',15);
        end
        if cfold == Halffold
            saveas(hf,sprintf('ROI%d testVSpred data compare part1',cROI));
            saveas(hf,sprintf('ROI%d testVSpred data compare part1',cROI),'png');
            close(hf);
        elseif cfold == nfolds
            saveas(hf,sprintf('ROI%d testVSpred data compare part2',cROI));
            saveas(hf,sprintf('ROI%d testVSpred data compare part2',cROI),'png');
            close(hf);
        end
    end
    %
end
cd ..;