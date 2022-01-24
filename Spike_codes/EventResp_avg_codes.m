
ProbNPSess.CurrentSessInds = strcmpi('Task',ProbNPSess.SessTypeStrs);
% TimeWin = [-1.5,8]; % time window used to calculate the psth, usually includes before and after trigger time, in seconds
% Smoothbin = [50,10]; %
% ProbNPSess = ProbNPSess.TrigPSTH(TimeWin, Smoothbin, double(behavResults.Time_stimOnset(:)));
% save(fullfile(pwd,'ks2_5','NPClassHandleSaved.mat'),'ProbNPSess', 'PassSoundDatas', 'behavResults', '-v7.3');

SMBinDataMtx = permute(cat(3,ProbNPSess.TrigData_Bin{ProbNPSess.CurrentSessInds}{:,1}),[1,3,2]); % transfromed into trial-by-units-by-bin matrix
ExcludedInds = (behavResults.Action_choice(:) == 2);
SMBinDataMtxRaw = SMBinDataMtx;
if ~isempty(ProbNPSess.SurviveInds)
    SMBinDataMtx = SMBinDataMtx(:,ProbNPSess.SurviveInds,:);
end
SMBinDataMtx = SMBinDataMtx(~ExcludedInds,:,:);
[TrNum, unitNum, BinNum] = size(SMBinDataMtx);

OnsetTime = double(behavResults.Time_stimOnset(~ExcludedInds));
OnsetTime = OnsetTime(:);
ReTimes = double(behavResults.Time_reward(~ExcludedInds));
ReTimes = ReTimes(:);
ChoiceTimes = double(behavResults.Time_answer(~ExcludedInds));
ChoiceTimes = ChoiceTimes(:);
Trial_freqs = double(behavResults.Stim_toneFreq(~ExcludedInds));
Trial_freqs = Trial_freqs(:);
Trial_Choices = double(behavResults.Action_choice(~ExcludedInds));
Trial_Choices = Trial_Choices(:);
TrialBlockTypes = double(behavResults.BlockType(~ExcludedInds));
TrialBlockTypes = TrialBlockTypes(:);

StimFreqTypes = unique(Trial_freqs);
NumFreqTypes = length(StimFreqTypes);
FreqParas_mtx = double(repmat(Trial_freqs,1,NumFreqTypes) == repmat(StimFreqTypes',TrNum,1));
ChoiceParas_mtx = [1-Trial_Choices,Trial_Choices];
ReParas_mtx = double(ReTimes > 0);

%%

TriggerAlignBin = ProbNPSess.TriggerStartBin{ProbNPSess.CurrentSessInds};
Stimwinbin = round([0,150;151,300]/1000/ProbNPSess.USedbin(2));
AnsRe_winbin = round([0,1000]/1000/ProbNPSess.USedbin(2));
if strcmpi(ProbNPSess.TrigAlignType{ProbNPSess.CurrentSessInds},'trigger') % events aligend to trigger time 
    
    
    
elseif strcmpi(ProbNPSess.TrigAlignType{ProbNPSess.CurrentSessInds},'stim') 
    AlignedChoiceTime = ChoiceTimes - OnsetTime;
    AlignedChoiceBin = round(max(AlignedChoiceTime,0)/1000/ProbNPSess.USedbin(2) + TriggerAlignBin);
    AlignedRewardTime = ReTimes - OnsetTime;
    AlignedReBin = round(max(AlignedRewardTime,0)/1000/ProbNPSess.USedbin(2) + TriggerAlignBin);
    BaselineResp = mean(SMBinDataMtx(:,:,1:TriggerAlignBin-1),3);
    StimResp1 = mean(SMBinDataMtx(:,:,(TriggerAlignBin+Stimwinbin(1,1)+1):(TriggerAlignBin+Stimwinbin(1,2))),3) - BaselineResp;
    StimResp2 = mean(SMBinDataMtx(:,:,(TriggerAlignBin+Stimwinbin(2,1)+1):(TriggerAlignBin+Stimwinbin(2,2))),3) - BaselineResp;
    ChoiceResp = zeros(TrNum, unitNum);
    ReResp = zeros(TrNum, unitNum);
    for cTr = 1 : TrNum
        ChoiceResp(cTr,:) = squeeze(mean(SMBinDataMtx(cTr,:,(TriggerAlignBin+AlignedChoiceBin(cTr)+AnsRe_winbin(1)+1):...
            (TriggerAlignBin+AlignedChoiceBin(cTr)+AnsRe_winbin(2))),3));
        ReResp(cTr,:) = squeeze(mean(SMBinDataMtx(cTr,:,(TriggerAlignBin+AlignedReBin(cTr)+AnsRe_winbin(1)+1):...
            (TriggerAlignBin+AlignedReBin(cTr)+AnsRe_winbin(2))),3));
    end
    NoRewardInds = AlignedReBin == TriggerAlignBin;
    ReResp(NoRewardInds,:) = ChoiceResp(NoRewardInds,:); % using choice response data as non-reward response data
    ChoiceResp = ChoiceResp - BaselineResp;
    ReResp = ReResp - BaselineResp;
   
%     NullRepeat = 200;
%     NullDataSet = cell(NullRepeat,4);
%     for cRepeat = 1 : NullRepeat
%         % generate random sampled response for each target type
%         StimResp_Null_Inds = randsample(BinNum,Stimwinbin(1,2) - Stimwinbin(1,1));
%         StimResp_Null = mean(SMBinDataMtx(:,:,StimResp_Null_Inds),3) -  - BaselineResp;
% 
%         StimResp2_Null_Inds = randsample(BinNum,Stimwinbin(2,2) - Stimwinbin(2,1));
%         StimResp2_Null = mean(SMBinDataMtx(:,:,StimResp2_Null_Inds),3) -  - BaselineResp;
% 
%         ChoiceResp_Null_Inds = randsample(BinNum,AnsRe_winbin(2) - Stimwinbin(1));
%         ChoiceResp_Null = mean(SMBinDataMtx(:,:,StimResp2_Null_Inds),3) -  - BaselineResp;
% 
%         ReResp_Null_Inds = randsample(BinNum,AnsRe_winbin(2) - Stimwinbin(1));
%         ReResp_Null = mean(SMBinDataMtx(:,:,ReResp_Null_Inds),3) -  - BaselineResp;
%         
%         NullDataSet(cRepeat,:) = {StimResp_Null, StimResp2_Null, ChoiceResp_Null, ReResp_Null};
%     end
end

% 


AllParas_mtx = zeros(TrNum*3,NumFreqTypes+2+1+2);
AllParas_mtx(1:TrNum,1:NumFreqTypes) = FreqParas_mtx;
AllParas_mtx((1+TrNum):(TrNum*2),(1+NumFreqTypes):(2+NumFreqTypes)) = ChoiceParas_mtx;
AllParas_mtx((1+TrNum*2):(TrNum*3),(3+NumFreqTypes)) = ReParas_mtx;
BlockType_mtx = [1-TrialBlockTypes,TrialBlockTypes];
AllParas_mtx(1:end,(4+NumFreqTypes):(5+NumFreqTypes)) = [BlockType_mtx;BlockType_mtx;BlockType_mtx];

% %% test glmfitting for each unit
% cUnit = 105;
% cUnitRespVec = [StimResp1(:,cUnit);ChoiceResp(:,cUnit);ReResp(:,cUnit)];
% % cUnitRespVec = cUnitRespVec/mean(cUnitRespVec);
% 
% SampleInds = randsample(numel(cUnitRespVec),round(numel(cUnitRespVec)*0.7));
% trainInds = false(numel(cUnitRespVec),1);
% trainInds(SampleInds) = true;
% 
% TestInds = ~trainInds;
% 
% mdd = stepwiseglm(AllParas_mtx(trainInds,:),cUnitRespVec(trainInds,:),'linear','CategoricalVars',...
%     true(NumFreqTypes+5,1),'PRemove',0.01,'Criterion','rsquared');
% 
% %
% TestDataVec = cUnitRespVec(~trainInds,:);
% TestDataPred = predict(mdd,AllParas_mtx(~trainInds,:));
% 
% NullDEvience = sum((TestDataVec - mean(TestDataVec)).^2);
% predDev = sum((TestDataVec - TestDataPred).^2);
% Explain = (NullDEvience - predDev)/NullDEvience;
% fprintf('Current cluster %d: \n   devience explain = %.6f.\n',ProbNPSess.UsedClus_IDs(cUnit),Explain);
% 
% disp(mdd);
% %% calculate each type response
% 
% StimRespsAllfreq = zeros(NumFreqTypes,2);
% 
% for cf = 1 : NumFreqTypes
%     cfInds = Trial_freqs == StimFreqTypes(cf);
%     StimRespsAllfreq(cf, 1) = mean(StimResp1(cfInds,cUnit));
%     StimRespsAllfreq(cf, 2) = mean(StimResp2(cfInds,cUnit));
% end
% 
% ChoiceRespAvg = zeros(2, 1);
% ChoiceRespAvg(1) = mean(ChoiceResp(Trial_Choices == 0,cUnit));
% ChoiceRespAvg(2) = mean(ChoiceResp(Trial_Choices == 1,cUnit));
% 
% RewardResp = zeros(2, 1);
% RewardResp(1) = mean(ReResp(ReTimes == 0,cUnit)); % no reward 
% RewardResp(1) = mean(ReResp(ReTimes > 1,cUnit)); % reward 
% 
% figure;
% hold on
% plot(1:NumFreqTypes,StimRespsAllfreq(:, 1),'ro','linewidth',0.8);
% plot(1:NumFreqTypes,StimRespsAllfreq(:, 2),'k*','linewidth',0.8);
% plot(NumFreqTypes+[1,2],ChoiceRespAvg,'bd','linewidth',0.8);
% plot(NumFreqTypes+[3,4],RewardResp,'gd','linewidth',0.8);
% set(gca,'xtick',1:(NumFreqTypes+4),'xticklabel',[cellstr(num2str((1:NumFreqTypes)'));{'L';'R';'NoRe';'Re'}]);
% 
% disp(mdd)

%% term matrix

ParasNum = size(AllParas_mtx,2);

% single term inclusion matrix
single_term_mtx = diag(ones(ParasNum,1));

% paired freq with other items matrix
NulldiagVec = zeros(NumFreqTypes,ParasNum - NumFreqTypes);
FreqItermVec = diag(ones(NumFreqTypes,1));
OnepairedIterms = zeros(NumFreqTypes*(ParasNum - NumFreqTypes), ParasNum);
k = 1;
for cPairedInds = 1 : (ParasNum - NumFreqTypes)
    RestMtx = NulldiagVec;
    RestMtx(:,cPairedInds) = 1;
    OnepairedIterms(k:NumFreqTypes*cPairedInds,:) = [FreqItermVec,RestMtx];
    k = k + NumFreqTypes;
end


% paired stimfreq and choice and block types, three-paired
ThreePairedTerms = zeros(NumFreqTypes*(ParasNum - NumFreqTypes-2)*2, ParasNum);
ExcludeBlockTermMtx = OnepairedIterms(1:(NumFreqTypes*(ParasNum - NumFreqTypes - 2)),1:(ParasNum-2));
ThreePairedTerms(:,1:(ParasNum-2)) = [ExcludeBlockTermMtx;ExcludeBlockTermMtx];
ThreePairedTerms(1 : size(ExcludeBlockTermMtx,1),(ParasNum-1):end) = [ones(size(ExcludeBlockTermMtx,1),1),zeros(size(ExcludeBlockTermMtx,1),1)];
ThreePairedTerms((size(ExcludeBlockTermMtx,1)+1):end,(ParasNum-1):end) = [zeros(size(ExcludeBlockTermMtx,1),1),ones(size(ExcludeBlockTermMtx,1),1)];

overAllTerms_mtx = [zeros(1,ParasNum);single_term_mtx;OnepairedIterms;ThreePairedTerms];

%% including term matrix

% cUnit = 180;
% if cUnit > unitNum
%     return;
% end

AllParas_mtx = zeros(TrNum*3,NumFreqTypes+2+1+2);
AllParas_mtx(1:TrNum,1:NumFreqTypes) = FreqParas_mtx;
AllParas_mtx((1+TrNum):(TrNum*2),(1+NumFreqTypes):(2+NumFreqTypes)) = ChoiceParas_mtx;
AllParas_mtx((1+TrNum*2):(TrNum*3),(3+NumFreqTypes)) = ReParas_mtx;
BlockType_mtx = [1-TrialBlockTypes,TrialBlockTypes];
AllParas_mtx(1:end,(4+NumFreqTypes):(5+NumFreqTypes)) = [BlockType_mtx;BlockType_mtx;BlockType_mtx];

NumRepeats = 100;
UnitFitmds_All = cell(unitNum,2);
parfor cUnit = 1 : unitNum
    warning off
    cUnitRespVec = [StimResp1(:,cUnit);ChoiceResp(:,cUnit);ReResp(:,cUnit)];
%     IsNegResp = mean(cUnitRespVec) < 0;
%     cUnitRespVec = cUnitRespVec/mean(cUnitRespVec);
    cUnitRespVec = zscore(cUnitRespVec);
    
    cUnitRepeatDevExplain = zeros(NumRepeats,1);
    cUnitRepeatMD = cell(NumRepeats,1);
    for cRepeat = 1 : NumRepeats
        SampleInds = randsample(numel(cUnitRespVec),round(numel(cUnitRespVec)*0.7));
        trainInds = false(numel(cUnitRespVec),1);
        trainInds(SampleInds) = true;

        TestInds = ~trainInds;

        md2 = fitglm(AllParas_mtx(trainInds,:),cUnitRespVec(trainInds,:),overAllTerms_mtx,'CategoricalVars',...
            true(NumFreqTypes+5,1));

        %
        TestDataVec = cUnitRespVec(~trainInds,:);
        TestDataPred = predict(md2,AllParas_mtx(~trainInds,:));

        NullDEvience = sum((TestDataVec - mean(TestDataVec)).^2);
        predDev = sum((TestDataVec - TestDataPred).^2);
        Explain = (NullDEvience - predDev)/NullDEvience;
        
        cUnitRepeatDevExplain(cRepeat) = Explain;
        cUnitRepeatMD{cRepeat} = md2.Coefficients;
        
    end
%     disp(md2)

%     fprintf('Current cluster %d: \n   devience explain = %.6f.\n',ProbNPSess.UsedClus_IDs(cUnit),Explain);
    UnitFitmds_All(cUnit,:) = {cUnitRepeatMD, cUnitRepeatDevExplain};

end
warning on
%%
cUnit = 31;
if cUnit > unitNum
    return;
end

AllParas_mtx = zeros(TrNum*3,NumFreqTypes+2+1+2);
AllParas_mtx(1:TrNum,1:NumFreqTypes) = FreqParas_mtx;
AllParas_mtx((1+TrNum):(TrNum*2),(1+NumFreqTypes):(2+NumFreqTypes)) = ChoiceParas_mtx;
AllParas_mtx((1+TrNum*2):(TrNum*3),(3+NumFreqTypes)) = ReParas_mtx;
BlockType_mtx = [1-TrialBlockTypes,TrialBlockTypes];
AllParas_mtx(1:end,(4+NumFreqTypes):(5+NumFreqTypes)) = [BlockType_mtx;BlockType_mtx;BlockType_mtx];

% NumRepeats = 100;
% UnitFitmds_All = cell(unitNum,2);
% parfor cUnit = 1 : unitNum
    warning off
    cUnitRespVec = [StimResp1(:,cUnit);ChoiceResp(:,cUnit);ReResp(:,cUnit)];
    cUnitRespVec = zscore(cUnitRespVec);
%     IsNegResp = mean(cUnitRespVec) < 0;
%     cUnitRespVec = cUnitRespVec/mean(cUnitRespVec);
    
%     cUnitRepeatDevExplain = zeros(NumRepeats,1);
%     cUnitRepeatMD = cell(NumRepeats,1);
%     for cRepeat = 1 : NumRepeats
        SampleInds = randsample(numel(cUnitRespVec),round(numel(cUnitRespVec)*0.7));
        trainInds = false(numel(cUnitRespVec),1);
        trainInds(SampleInds) = true;

        TestInds = ~trainInds;

        md2 = fitglm(AllParas_mtx(trainInds,:),cUnitRespVec(trainInds,:),overAllTerms_mtx,'CategoricalVars',...
            true(NumFreqTypes+5,1));

        %
        TestDataVec = cUnitRespVec(~trainInds,:);
        TestDataPred = predict(md2,AllParas_mtx(~trainInds,:));

        NullDEvience = sum((TestDataVec - mean(TestDataVec)).^2);
        predDev = sum((TestDataVec - TestDataPred).^2);
        Explain = (NullDEvience - predDev)/NullDEvience;
        
%         cUnitRepeatDevExplain(cRepeat) = Explain;
%         cUnitRepeatMD{cRepeat} = md2.Coefficients;
        
        disp(md2)

        fprintf('Current cluster %d: \n   devience explain = %.6f.\n',ProbNPSess.UsedClus_IDs(cUnit),Explain);
% end
warning on





%%
% warning off
% % nRepeat = 100;
% NullDevExplain = zeros(NullRepeat,1);
% for cRe = 1 : NullRepeat
% %     AllshufRespVec = Vshuffle(cUnitRespVec);
% %     TrainParas_Mtx = AllParas_mtx(trainInds,:);
% %     SelectInds = 1:size(TrainParas_Mtx,1);
% %     md2sf = fitglm(TrainParas_Mtx(Vshuffle(SelectInds),:),AllshufRespVec(trainInds,:),overAllTerms_mtx,'CategoricalVars',...
% %     true(size(TrainParas_Mtx,2),1));
% % 
% %     TestDataVecShuf = cUnitRespVec(~trainInds,:);
% %     TestDataPred = predict(md2sf,AllParas_mtx(~trainInds,:));
%     cUnitRespVecShuf = [NullDataSet{cRe,1}(:,cUnit);NullDataSet{cRe,2}(:,cUnit);NullDataSet{cRe,3}(:,cUnit)];
%     cUnitRespVecShuf = cUnitRespVecShuf/mean(cUnitRespVecShuf); % incase of zeros mean
%     
%     SampleInds = randsample(numel(cUnitRespVecShuf),round(numel(cUnitRespVecShuf)*0.7));
%     trainInds = false(numel(cUnitRespVecShuf),1);
%     trainInds(SampleInds) = true;
% 
%     TestInds = ~trainInds;
%     
%     md2sf = fitglm(AllParas_mtx(trainInds,:),cUnitRespVecShuf(trainInds,:),overAllTerms_mtx,'CategoricalVars',...
%         true(size(AllParas_mtx,2),1));
%     
%     TestDataVecShuf = cUnitRespVecShuf(~trainInds,:);
%     NullDEvienceShuf = sum((TestDataVecShuf - mean(TestDataVecShuf)).^2);
%     TestDataPred_shuf = predict(md2sf,AllParas_mtx(~trainInds,:));
%     
%     predDevShuf = sum((TestDataVecShuf - TestDataPred_shuf).^2);
%     NullDevExplain(cRe) = (NullDEvienceShuf - predDevShuf)/NullDEvienceShuf;
% end
% disp(prctile(NullDevExplain,95));
% warning on

