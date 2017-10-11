% scripts for align behavior parameters into single frame times
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
DefStimFIndex = zeros(FrameNum,length(StimusType));  % default index values
%%
 StimSTrs = cellstr(num2str(StimusType(:),'%.fOn'));
 StimoffSTrs = cellstr(num2str(StimusType(:),'%.fOff'));
 StimSTrs = StimSTrs';
 StimoffSTrs = StimoffSTrs';
%  TaskParaStrs = {'LLick','RLick','LAns','RAns',StimSTrs{:},StimoffSTrs{:},'Reward','LTypeOn','LTypeOff',...
%  'RTypeOn','RTypeOff','EstimateSpike'};
 TaskParaStrs = {'LAns','RAns',StimSTrs{:},StimoffSTrs{:},'Reward','LTypeOn','LTypeOff',...
 'RTypeOn','RTypeOff','EstimateSpike'};
%%
w = gausswin(3);
TrTaskParaAll = cell(nTrs,1);
ExtraShiftNum = round(500/FrameTime);
BaseFunIndex = 1:2:ExtraShiftNum;
ExtraBaseFunNum = length(BaseFunIndex);
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
   %
%     cTrTaskParameters = [LeftLickFrames,RightLickFrames,LeftAnsFIndex,RightAnsFIndex,...
%         StimFIndex,StimOffIndex,RewardIndex,LeftTypeOnIndex,LeftTypeOffIndex,RightTypeOnIndex,...
%         RightTypeOffIndex];
    cTrTaskParameters = [LeftAnsFIndex,RightAnsFIndex,...
        StimFIndex,StimOffIndex,RewardIndex,LeftTypeOnIndex,LeftTypeOffIndex,RightTypeOnIndex,...
        RightTypeOffIndex];
    TrTaskParaAll{cTrs} = cTrTaskParameters;
    %
end
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
nnspike = DataFluo2Spike(DeltaF_F,V,P); % estimated spike
nnspike(nnspike < 0.001) = 0; 
nnspike = nnspike + 0.001;
%%
ROImd = cell(size(nnspike,2),1);
for cROI = 1 : size(nnspike,2)
    cROIdata = squeeze(nnspike(1:nTrs,cROI,:));
    cROIVectorData = max(0,reshape(cROIdata',[],1));
    TrTaskParaMtx = cell2mat(TrTaskParaAll);

    %
%     figure;hist(cROIVectorData,100);
    mdl = fitglm(TrTaskParaMtx,cROIVectorData, 'Distribution','poisson','VarNames',TaskParaStrs);
    ROImd{cROI} = mdl;
end