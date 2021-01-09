% scripts for align behavior parameters into single frame times
% same as script "AlignBehavToFrame_script_new", but for continued
% acquisition session data
% H:\data\batch\batch27_PV\20160427\anm01\test02\channel1\im_data_reg_cpu\result_save\NO_Correction

% FrameTimeBin = 0:FrameTime:TrTime;
TrChoice = double(behavResults.Action_choice);
NMInds = TrChoice ~= 2;
if exist('ExcludedTrInds','var')
% if IsExcludeInds
    BehavExcludesInds = NMInds(:) | ExcludedTrInds(:);
    DataExcludeInds = NMInds(~ExcludedTrInds(:));
else
    BehavExcludesInds = NMInds;
    DataExcludeInds = NMInds;
end

TrStimTime = double(behavResults.Time_stimOnset(BehavExcludesInds));
TrRewardTi = double(behavResults.Time_reward(BehavExcludesInds));
TrAnswerTime = double(behavResults.Time_answer(BehavExcludesInds));
TrTrialTypes = double(behavResults.Trial_Type(BehavExcludesInds));
TrFreqs = double(behavResults.Stim_toneFreq(BehavExcludesInds));

TrIsProbTrs = double(behavResults.Trial_isProbeTrial(BehavExcludesInds));

FrameTime = SavedCaTrials.FrameTime;
FrameNumAll = cellfun(@(x) size(x,2),SavedCaTrials.f_raw(BehavExcludesInds));
FrameNum = min(FrameNumAll);
TrTime = FrameTime*FrameNumAll;  %in ms
ProbStimStr = squeeze(behavSettings.probe_stimType);
% [lick_time_struct,Lick_bias_side]=beha_lickTime_data(behavResults,max(TrTime)); %this function is used for converting lick time strings into arrays and save in a struct
ProbtypeStr = ProbStimStr(1,:);
StimusType = unique(TrFreqs);
nFreqs = length(StimusType);

nTrs = length(TrTime);
TrTimeBinCell = cell(nTrs,1);
DefStimFIndexCell = cell(nTrs,1);
for ctr = 1 : nTrs
    TrTimeBinCell{ctr} = (0:FrameNumAll(ctr))*FrameTime;
    DefStimFIndexCell{ctr} = zeros(FrameNumAll(ctr),nFreqs);
end

% DefStimFIndex = zeros(FrameNum,nFreqs);  % default index values
%%
 StimSTrs = cellstr(num2str(StimusType(:),'f%.fOn'));
 StimoffSTrs = cellstr(num2str(StimusType(:),'%.fOff'));
 StimSTrs = StimSTrs';
 StimoffSTrs = StimoffSTrs';
%  TaskParaStrs = {'LLick','RLick','LAns','RAns',StimSTrs{:},StimoffSTrs{:},'Reward','LTypeOn','LTypeOff',...
%  'RTypeOn','RTypeOff','EstimateSpike'};
 TaskParaStrs = {'LAns','RAns',StimSTrs{:},'Reward'};  %'LTypeOn','RTypeOn'
%
w = gausswin(5,1);
ExtrawindowLen = ceil(length(w)/2);
TrTaskParaAll = cell(nTrs,1);
ExtraShiftNum = round(300/FrameTime);
BaseFunIndex = 1:2:ExtraShiftNum;
ExtraBaseFunNum = length(BaseFunIndex);
AllTrMaxUseF = zeros(nTrs,1);
%%
for cTrs = 1 : nTrs
    %
%     cTrs = 3;
    cTrFrame = FrameNumAll(cTrs);
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
    AnsFrameIndex = zeros(cTrFrame,1);
    LeftAnsFIndex = AnsFrameIndex;  %% task parameter 
    RightAnsFIndex = AnsFrameIndex;  %% task parameter
    if (TrAnswerTime(cTrs) > 0)
        AnsFrameInds = floor(TrAnswerTime(cTrs)/FrameTime);
        
        if (AnsFrameInds < cTrFrame)
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
    StimFIndex = DefStimFIndexCell{cTrs};   %% task parameter
    StimOffIndex = DefStimFIndexCell{cTrs};   %% task parameter
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
    RewardIndex = zeros(cTrFrame,1);   %% task parameter
    if TrRewardTi(cTrs) > 0
        RewardF = floor(TrRewardTi(cTrs)/FrameTime);
        if (RewardF < cTrFrame)
            RewardIndex(RewardF) = 1;
        end
    end
%     % trial type parameter
%     LeftTypeOnIndex = zeros(cTrFrame,1);   %% task parameter
%     LeftTypeOffIndex = zeros(cTrFrame,1);   %% task parameter
%     RightTypeOnIndex = zeros(cTrFrame,1);   %% task parameter
%     RightTypeOffIndex = zeros(cTrFrame,1);   %% task parameter
%     
%     cStimOnsetF = floor(TrStimTime(cTrs)/FrameTime);
%     cStimOffsetF = floor((TrStimTime(cTrs)+300)/FrameTime);
%     if TrTrialTypes(cTrs)
%         RightTypeOnIndex(cStimOnsetF) = 1;
%         RightTypeOffIndex(cStimOffsetF) = 1;
%     else
%         LeftTypeOnIndex(cStimOnsetF) = 1;
%         LeftTypeOffIndex(cStimOffsetF) = 1;
%     end
    
    % create the base function for stimulus and reward
    StimBaseFunc = zeros(nFreqs,ExtraBaseFunNum,cTrFrame);
    StimStrCell = cell(nFreqs,ExtraBaseFunNum);
    RewardBaseFun = zeros(ExtraBaseFunNum,cTrFrame);
    AnsBaseFun = zeros(2,ExtraBaseFunNum,cTrFrame);
    if TrRewardTi(cTrs) > 0
        MaxUsefulF = RewardF + BaseFunIndex(end) + ExtrawindowLen;
    else
        MaxUsefulF = AnsFrameInds + BaseFunIndex(end) + ExtrawindowLen;
    end
    AllTrMaxUseF(cTrs) = MaxUsefulF + ExtrawindowLen;
    
    for cInds = 1 : ExtraBaseFunNum
        cBaseInds = BaseFunIndex(cInds);
        StimBaseFunc(TrFreqs(cTrs) == StimusType,cInds,cBaseInds+cStimOnsetF) = 1;
        if cTrs == 1
            StimBasecStr = cellstr(num2str(StimusType(:),['f%.fB',num2str(cInds)]));
            StimStrCell(:,cInds) = StimBasecStr;  % stimulus base function strs
        end
        if TrRewardTi(cTrs) > 0
            if RewardF+cBaseInds <= cTrFrame
                RewardBaseFun(cInds,RewardF+cBaseInds) = 1;
            end
        end
        if (TrAnswerTime(cTrs) > 0)
            if (AnsFrameInds + cBaseInds < cTrFrame)
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
        StimFIndex,RewardIndex,...   %LeftTypeOnIndex,RightTypeOnIndex,
        RewardBaseFun',AnsBaseFunAll',StimBaseFunAll'];
    for nCol = 1:size(cTrTaskParameters,2)
        cTrTaskParameters(:,nCol) = conv(cTrTaskParameters(:,nCol),w,'same');
    end
    TrTaskParaAll{cTrs} = cTrTaskParameters;
%     figure;
%     imagesc(cTrTaskParameters);
%     line([0.5 size(cTrTaskParameters,2)+0.5],[MaxUsefulF MaxUsefulF],'Color','m','linewidth',2.2)
    %
end
glmnetCoefStrs = {'ConstantV',TaskParaStrs{:},ReBaseStrs{:},AnsBaseStrs{:},StimBaseStrs{:}};
BehavParaTicks = [1,2,3,3+length(StimSTrs)];
BehavParaStrs = {'LAns','RAns','On','Reward','LeftAns','RAns'};
BehavParaTicks = [BehavParaTicks,BehavParaTicks(end)+ExtraBaseFunNum+1,1+BehavParaTicks(end)+ExtraBaseFunNum*2];
for cStimType = 1 : length(StimusType)
     BehavParaTicks = [BehavParaTicks,BehavParaTicks(end)+ExtraBaseFunNum];
     BehavParaStrs = [BehavParaStrs,{num2str(StimusType(cStimType))}];
end
TaskParaStrs = {TaskParaStrs{:},ReBaseStrs{:},AnsBaseStrs{:},StimBaseStrs{:},'EstimateSp'};

%% load spike data

nfolds = 10;
nIters = nfolds;
TrainPerc = 0.75;
nROIs = size(nnspike{1},1);
ROImdCoef = cell(nROIs,nIters);
UsedSpikeData = nnspike(DataExcludeInds);

nTrs = size(UsedSpikeData,1);
PredCoef = zeros(nROIs,nIters);
PredCoefp = zeros(nROIs,nIters);
CVindsAll = cell(nROIs,1);
CVPredData = cell(nROIs,nIters);

UsedSpikeData = nnspike(NMInds);
MaxUsefullcellData = num2cell(AllTrMaxUseF);
MaxUsefulSPData = cellfun(@(x,y) x(:,1:y),UsedSpikeData,MaxUsefullcellData,'UniformOutput',false);
MaxUsefulFitpara = cellfun(@(x,y) x(1:y,:),TrTaskParaAll,MaxUsefullcellData,'UniformOutput',false);
%%
tt=tic;
for croi = 1 : nROIs
    %%
    cRdatacell = cellfun(@(x) (x(croi,:))',MaxUsefulSPData,'UniformOutput',false);
%     squeeze(nnspike(:,croi,:));
%     cRdata = cRdata';
    cc = cvpartition(nTrs,'kFold',10);
    CVindsAll{croi} = cc;
    options = glmnetSet;
    options.alpha = 0.9;
    options.nlambda = 110;
    options.offset = true;
    %%
    for citer = 1 : nfolds
        %%
        TrainIndsLogi = cc.training(citer);
        
        TrainData = cell2mat(cRdatacell(TrainIndsLogi));
        TrainParaData = cell2mat(MaxUsefulFitpara(TrainIndsLogi));
        TestParaData = cell2mat(MaxUsefulFitpara(~TrainIndsLogi));
        TestData = cell2mat(cRdatacell(~TrainIndsLogi));
        UsedDataInds = TrainData > 1e-3;
        %
%         mdl = fitglm(TrainParaData,TrainData, 'Distribution','poisson','VarNames',TaskParaStrs);
        cvmdfit = cvglmnet(TrainParaData,TrainData,'poisson',options);
        cvmdCoef  = cvglmnetCoef(cvmdfit,'lambda_1se');
        ROImdCoef{croi,citer} = cvmdCoef;
        PredTestData = cvglmnetPredict(cvmdfit,TestParaData,[],'response',false);
%         glmnetCoefTabel = array2table(cvmdCoef','VariableNames',glmnetCoefStrs');
        %%
        CVPredData{croi,citer} = PredTestData;  % cvPredDataRe = reshape(cvPredData,500,[]);
        % figure;imagesc(cvPredDataRe');
        
        [coef,cop] = corrcoef(PredTestData,TestData);
        PredCoef(croi,citer) = coef(1,2);
        PredCoefp(croi,citer) = cop(1,2);
    end
    %
end
 toc(tt);
save FitDataSave.mat CVPredData ROImdCoef PredCoef PredCoefp -v7.3

%%
for cR = 1 : nROIs
    %%
    cRCoefCell = ROImdCoef(cR,:);
    cRCoefData = cell2mat(cRCoefCell);
    PosCoefInds = cRCoefData(2:end,:);
    PosCoefSigIndex = double(PosCoefInds > 1e-3);
    SigCoefParaIndex = mean(PosCoefSigIndex,2) >= 0.4;
%     figure;
%     imagesc(PosCoefInds)
    %
    hf = figure;
    plot(SigCoefParaIndex,'.')
    set(gca,'ylim',[-0.1 1.1])
    set(gca,'ylim',[-0.1 1.1],'box','off')
    set(gca,'xtick',BehavParaTicks,'xticklabel',BehavParaStrs(:));
    title(sprintf('ROI%d',cR));
    %%
    saveas(hf,sprintf('ROI%d plot save',cR));
    saveas(hf,sprintf('ROI%d plot save',cR),'png');
    close(hf);
%
end
