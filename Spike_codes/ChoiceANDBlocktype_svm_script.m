% I:\ksOutput_backup\b107a08_ksoutput\A2021226_b107a08_NPSess02_g0_cat\catgt_A2021226_b107a08_NPSess02_g0\Cat_A2021226_b107a08_NPSess02_g0_imec1\ks2_5

ProbNPSess.CurrentSessInds = strcmpi('Task',ProbNPSess.SessTypeStrs);

SMBinDataMtx = permute(cat(3,ProbNPSess.TrigData_Bin{ProbNPSess.CurrentSessInds}{:,1}),[1,3,2]); % transfromed into trial-by-units-by-bin matrix


if ~isempty(ProbNPSess.SurviveInds)
    SMBinDataMtx = SMBinDataMtx(:,ProbNPSess.SurviveInds,:);
end
SMBinDataMtxRaw = SMBinDataMtx;

UsedUnitInds = SessAreaIndexStrc.OL.MatchedUnitInds;

UsedUnitPSTHdata = SMBinDataMtx(:,UsedUnitInds,:);


    
[TrNum, unitNum, BinNum] = size(UsedUnitPSTHdata);

TriggerAlignBin = ProbNPSess.TriggerStartBin{ProbNPSess.CurrentSessInds};

BaselineResp_All = mean(UsedUnitPSTHdata(:,:,1:(TriggerAlignBin-1)),3);
%%
BlockSectionInfo = Bev2blockinfoFun(behavResults);
BlockTypesAll = double(behavResults.BlockType(:));

RevFreqs = BlockSectionInfo.BlockFreqTypes(logical(BlockSectionInfo.IsFreq_asReverse));
TrialFreqsAll = double(behavResults.Stim_toneFreq(:));
TrialAnmChoice = double(behavResults.Action_choice(:));
TrialAnmChoice(TrialAnmChoice == 2) = NaN;
RevFreqInds = find(ismember(TrialFreqsAll,RevFreqs));
RevFreqChoices = TrialAnmChoice(RevFreqInds);

NMRevfreqInds = ~isnan(RevFreqChoices);
NMRevFreqIndedx = RevFreqInds(NMRevfreqInds);
NMRevFreqChoice = RevFreqChoices(NMRevfreqInds);
NMRevFreqAllFreqs = TrialFreqsAll(NMRevFreqIndedx);
NMRevFreqBlockTypes = BlockTypesAll(NMRevFreqIndedx);

NMRevFreqDatas = UsedUnitPSTHdata(NMRevFreqIndedx,:,:); % All datas for revfreqs only
NumberOfUnits = size(NMRevFreqDatas, 2); % number of units will be used for population decoding
NumberOfRevFreqTrs = size(NMRevFreqDatas, 1);

NonRevFreqs = BlockSectionInfo.BlockFreqTypes(~logical(BlockSectionInfo.IsFreq_asReverse));
NonRevFreqInds = find(ismember(TrialFreqsAll,NonRevFreqs));
NonRevFreqChoice = TrialAnmChoice(NonRevFreqInds);
NMNonRevFreqInds = ~isnan(NonRevFreqChoice);
NMNonRevFreqIndex = NonRevFreqInds(NMNonRevFreqInds);
NMNonRevFreqChoice = TrialAnmChoice(NMNonRevFreqIndex);
NMNonRevFreqsAll = TrialFreqsAll(NMNonRevFreqIndex);
NMNonRevFreqBlockType = BlockTypesAll(NMNonRevFreqIndex);

NMNonRevFreqDatas = UsedUnitPSTHdata(NMNonRevFreqIndex,:,:); % All datas for revfreqs only
NumberOfNonRevFreqTrs = size(NMNonRevFreqDatas, 1);

%%
Block0BaselineDatas = mean(squeeze(mean(NMRevFreqDatas(NMRevFreqBlockTypes == 0,:,1:TriggerAlignBin),3)));
Block1BaselineDatas = mean(squeeze(mean(NMRevFreqDatas(NMRevFreqBlockTypes == 1,:,1:TriggerAlignBin),3)));
AvgBlockBaselineDatas = (Block0BaselineDatas+Block1BaselineDatas)/2;

SingleTrBaselines = squeeze(mean(NMRevFreqDatas(:,:,1:TriggerAlignBin),3));
NonRevFreqSingleTrBaselines = squeeze(mean(NMNonRevFreqDatas(:,:,1:TriggerAlignBin),3));

AfterStimResp_winbin = round([0,1000]/1000/ProbNPSess.USedbin(2));

AfterStimResp = mean(NMRevFreqDatas(:,:,...
    (TriggerAlignBin+AfterStimResp_winbin(1,1)+1):(TriggerAlignBin+AfterStimResp_winbin(1,2))),3)...
    - SingleTrBaselines + repmat(AvgBlockBaselineDatas, NumberOfRevFreqTrs, 1);

AfterStimResp_withbaseline = mean(NMRevFreqDatas(:,:,...
    (TriggerAlignBin+AfterStimResp_winbin(1,1)+1):(TriggerAlignBin+AfterStimResp_winbin(1,2))),3);

NonRevfreq_AStimResp = mean(NMNonRevFreqDatas(:,:,...
    (TriggerAlignBin+AfterStimResp_winbin(1,1)+1):(TriggerAlignBin+AfterStimResp_winbin(1,2))),3)...
    - NonRevFreqSingleTrBaselines + repmat(AvgBlockBaselineDatas, NumberOfNonRevFreqTrs, 1); 

NonRevfreq_AStimResp_WB = mean(NMNonRevFreqDatas(:,:,...
    (TriggerAlignBin+AfterStimResp_winbin(1,1)+1):(TriggerAlignBin+AfterStimResp_winbin(1,2))),3);

%%
nRepeats = 100;
mdperforms = zeros(nRepeats,2);
for cR = 1 : nRepeats
    TrainingInds = false(NumberOfRevFreqTrs,1);
    RandIns = CusRandSample(NMRevFreqChoice,round(NumberOfRevFreqTrs*0.7));
    TrainingInds(RandIns) = true;

    mdl = fitcsvm(AfterStimResp(TrainingInds,:),NMRevFreqChoice(TrainingInds));
    CVmodel = crossval(mdl,'k',10);
    TrainErro = kfoldLoss(CVmodel,'mode','individual');

%     fprintf('Model Crossval error lost is %.4f.\n',mean(TrainErro));
    % testTrial score prediction
    [TestPredChoice, TestTrScore] = predict(mdl,AfterStimResp(~TrainingInds,:));
%     TestTrChoice = NMRevFreqChoice(~TrainingInds);
    mdperforms(cR,:) = [mean(TrainErro),mean(TestPredChoice == NMRevFreqChoice(~TrainingInds))];
end

fprintf('MDPerms = %.4f\n',mean(mdperforms(:,2)));
BTmdl = fitcsvm(AfterStimResp, NMRevFreqBlockTypes);
%% Choice prediction with baseline response
WB_mdperforms = zeros(nRepeats,2);
for cR = 1 : nRepeats
    TrainingInds = false(NumberOfRevFreqTrs,1);
    RandIns = CusRandSample(NMRevFreqChoice,round(NumberOfRevFreqTrs*0.7));
    TrainingInds(RandIns) = true;

    WBmdl = fitcsvm(AfterStimResp_withbaseline(TrainingInds,:),NMRevFreqChoice(TrainingInds));
    CVmodel = crossval(WBmdl,'k',10);
    TrainErro = kfoldLoss(CVmodel,'mode','individual');

%     fprintf('Model Crossval error lost is %.4f.\n',mean(TrainErro));
    % testTrial score prediction
    [TestPredChoice, TestTrScore] = predict(WBmdl,AfterStimResp_withbaseline(~TrainingInds,:));
%     TestTrChoice = NMRevFreqChoice(~TrainingInds);
    WB_mdperforms(cR,:) = [mean(TrainErro),mean(TestPredChoice == NMRevFreqChoice(~TrainingInds))];
end
fprintf('MDPerms = %.4f\n',mean(WB_mdperforms(:,2)));
BT_WBmdl = fitcsvm(AfterStimResp_withbaseline, NMRevFreqBlockTypes);
%%
BoxData = [WB_mdperforms(:,2);mdperforms(:,2)];
BoxDataInds = [zeros(nRepeats,1);ones(nRepeats,1)];
huf = figure;
boxplot(BoxData, BoxDataInds, 'Labels',{'WithBaseline','BaselineSub'})
[~,p] = ttest2(WB_mdperforms(:,2),mdperforms(:,2));
disp(p);


%% svm performance compare plot
hhf = figure;
hold on
TestTrChoice = NMRevFreqChoice(~TrainingInds);
Test0ChoiceInds = TestTrChoice == 0;
TestNum0Choice = sum(Test0ChoiceInds);
TestNum1Choice = sum(~Test0ChoiceInds);
% plot(TestTrScore(Test0ChoiceInds,2), 2 + (rand(TestNum0Choice,1)-0.5)*2, 'bo','linewidth',1.4,'MarkerSize',12);
% plot(TestTrScore(~Test0ChoiceInds,2), 2 + (rand(TestNum1Choice,1)-0.5)*2, 'ro','linewidth',1.4,'MarkerSize',12);
% set(gca,'ylim',[0.9 3.1],'ytick',2);
% line([0 0],[0.9 3.1],'Color',[1 0.7 0.2],'linestyle','--','linewidth',1.4);

[WithBasePredChoice,WithBaselineScores]=predict(mdl,AfterStimResp_withbaseline);
ClassRelateScores=WithBaselineScores(:,2);
WithBase0ChoiceInds = NMRevFreqChoice == 0;
WithBaseNum0Choice = sum(WithBase0ChoiceInds);
WithBaseNum1Choice = sum(~WithBase0ChoiceInds);
% plot(ClassRelateScores(WithBase0ChoiceInds), 2 + (rand(WithBaseNum0Choice,1)-0.5)*2, 'bd','linewidth',1,'MarkerSize',8);
% plot(ClassRelateScores(~WithBase0ChoiceInds), 2 + (rand(WithBaseNum1Choice,1)-0.5)*2, 'rd','linewidth',1,'MarkerSize',8);

errorbar(mean(TestTrScore(Test0ChoiceInds,2)), 1.8, std(TestTrScore(Test0ChoiceInds,2))/sqrt(TestNum0Choice),...
    'horizontal','bo','linewidth',1.2);
errorbar(mean(TestTrScore(~Test0ChoiceInds,2)), 2.2, std(TestTrScore(~Test0ChoiceInds,2))/sqrt(TestNum1Choice),...
    'horizontal','ro','linewidth',1.2);

errorbar(mean(ClassRelateScores(WithBase0ChoiceInds)), 3.8, ...
    std(ClassRelateScores(WithBase0ChoiceInds))/sqrt(WithBaseNum0Choice),'horizontal','o','linewidth',1.2,'Color',[0.1 0.5 0.8]);
errorbar(mean(ClassRelateScores(~WithBase0ChoiceInds)), 4.2, ...
    std(ClassRelateScores(~WithBase0ChoiceInds))/sqrt(WithBaseNum1Choice),'horizontal','o','linewidth',1.2,'Color',[0.8 0.5 0.1]);

%%
[~, ChoiceDataOnBlockplane] = predict(mdl, AfterStimResp_withbaseline);

figure;
hold on
Choice0Inds = NMRevFreqChoice == 0;
NumChoice0Datas = sum(Choice0Inds);
NumChoice1Datas = sum(~Choice0Inds);

plot(ChoiceDataOnBlockplane(Choice0Inds),rand(NumChoice0Datas,1),'bo');
plot(ChoiceDataOnBlockplane(~Choice0Inds),rand(NumChoice1Datas,1)+1,'ro');

%% pca use reversed frequency datas

[coeffT,scoreT,~,~,explainedT,~]=pca(AfterStimResp);
WBRespcolmeanSub = AfterStimResp_withbaseline - mean(AfterStimResp_withbaseline,2); % column mean substraction
UsedBSScore = scoreT(:,1:3); % the first three PCs
ScoreWB = WBRespcolmeanSub * coeffT(:,1:3);

NonRevFreqRespcolmeanSub = NonRevfreq_AStimResp - mean(NonRevfreq_AStimResp,2);
NonRevFreqScore = NonRevFreqRespcolmeanSub * coeffT(:,1:3);

NonRevFreqWBRespcolmeanSub = NonRevfreq_AStimResp_WB - mean(NonRevfreq_AStimResp_WB,2);
NonRevFreqScoreWB = NonRevFreqWBRespcolmeanSub * coeffT(:,1:3);

RevfreqBaseResp_meansub = SingleTrBaselines - mean(SingleTrBaselines,2);
RevfreqBaseResp_Score = RevfreqBaseResp_meansub * coeffT(:,1:3);

NonRevfreqBaseResp_meansub = NonRevFreqSingleTrBaselines - mean(NonRevFreqSingleTrBaselines,2);
NonRevfreqBaseResp_Score = NonRevfreqBaseResp_meansub * coeffT(:,1:3);


% TrChoice0Inds = NMRevFreqChoice == 0;
TrChoice0Inds = NMRevFreqBlockTypes == 0;

NonRevfreqTrChoice0Inds = NMNonRevFreqChoice == 0;

figure;
hold on
plot3(UsedBSScore(TrChoice0Inds,1),UsedBSScore(TrChoice0Inds,2),UsedBSScore(TrChoice0Inds,3),'bo','LineWidth',1.2);
plot3(UsedBSScore(~TrChoice0Inds,1),UsedBSScore(~TrChoice0Inds,2),UsedBSScore(~TrChoice0Inds,3),'ro','LineWidth',1.2);

% plot3(ScoreWB(TrChoice0Inds,1),ScoreWB(TrChoice0Inds,2),ScoreWB(TrChoice0Inds,3),'b*','LineWidth',1.2);
% plot3(ScoreWB(~TrChoice0Inds,1),ScoreWB(~TrChoice0Inds,2),ScoreWB(~TrChoice0Inds,3),'r*','LineWidth',1.2);

% plot3(NonRevFreqScore(NonRevfreqTrChoice0Inds,1),NonRevFreqScore(NonRevfreqTrChoice0Inds,2),NonRevFreqScore(NonRevfreqTrChoice0Inds,3),'ks');
% plot3(NonRevFreqScore(~NonRevfreqTrChoice0Inds,1),NonRevFreqScore(~NonRevfreqTrChoice0Inds,2),NonRevFreqScore(~NonRevfreqTrChoice0Inds,3),'ms');
% 
% plot3(NonRevFreqScoreWB(NonRevfreqTrChoice0Inds,1),NonRevFreqScoreWB(NonRevfreqTrChoice0Inds,2),NonRevFreqScoreWB(NonRevfreqTrChoice0Inds,3),'ks');
% plot3(NonRevFreqScoreWB(~NonRevfreqTrChoice0Inds,1),NonRevFreqScoreWB(~NonRevfreqTrChoice0Inds,2),NonRevFreqScoreWB(~NonRevfreqTrChoice0Inds,3),'ms');

% baseline response projection
plot3(RevfreqBaseResp_Score(TrChoice0Inds,1),RevfreqBaseResp_Score(TrChoice0Inds,2),RevfreqBaseResp_Score(TrChoice0Inds,3),'bs','LineWidth',1.2);
plot3(RevfreqBaseResp_Score(~TrChoice0Inds,1),RevfreqBaseResp_Score(~TrChoice0Inds,2),RevfreqBaseResp_Score(~TrChoice0Inds,3),'rs','LineWidth',1.2);

plot3(NonRevfreqBaseResp_Score(NonRevfreqTrChoice0Inds,1),NonRevfreqBaseResp_Score(NonRevfreqTrChoice0Inds,2),...
    NonRevfreqBaseResp_Score(NonRevfreqTrChoice0Inds,3),'b*','LineWidth',1.2);
plot3(NonRevfreqBaseResp_Score(~NonRevfreqTrChoice0Inds,1),NonRevfreqBaseResp_Score(~NonRevfreqTrChoice0Inds,2),...
    NonRevfreqBaseResp_Score(~NonRevfreqTrChoice0Inds,3),'r*','LineWidth',1.2);


xlabel('PC1');
ylabel('PC2');
zlabel('PC3');


%% pca use non-reversed frequency datas

[coeffT,scoreT,~,~,explainedT,~]=pca(NonRevfreq_AStimResp);
NonRevFreqScore = scoreT(:,1:3); % the first three PCs

WBRespcolmeanSub = AfterStimResp_withbaseline - mean(AfterStimResp_withbaseline,2); % column mean substraction
ScoreWB = WBRespcolmeanSub * coeffT(:,1:3);

RevFreqRespcolmeanSub = AfterStimResp - mean(AfterStimResp,2);
UsedBSScore = RevFreqRespcolmeanSub * coeffT(:,1:3);

NonRevFreqWBRespcolmeanSub = NonRevfreq_AStimResp_WB - mean(NonRevfreq_AStimResp_WB,2);
NonRevFreqScoreWB = NonRevFreqWBRespcolmeanSub * coeffT(:,1:3);


TrChoice0Inds = NMRevFreqChoice == 0;
% TrChoice0Inds = NMRevFreqBlockTypes == 0;

NonRevfreqTrChoice0Inds = NMNonRevFreqChoice == 0;

figure;
hold on
% plot3(UsedBSScore(TrChoice0Inds,1),UsedBSScore(TrChoice0Inds,2),UsedBSScore(TrChoice0Inds,3),'bo','LineWidth',1.2);
% plot3(UsedBSScore(~TrChoice0Inds,1),UsedBSScore(~TrChoice0Inds,2),UsedBSScore(~TrChoice0Inds,3),'ro','LineWidth',1.2);
% 
% plot3(ScoreWB(TrChoice0Inds,1),ScoreWB(TrChoice0Inds,2),ScoreWB(TrChoice0Inds,3),'b*','LineWidth',1.2);
% plot3(ScoreWB(~TrChoice0Inds,1),ScoreWB(~TrChoice0Inds,2),ScoreWB(~TrChoice0Inds,3),'r*','LineWidth',1.2);

plot3(NonRevFreqScore(NonRevfreqTrChoice0Inds,1),NonRevFreqScore(NonRevfreqTrChoice0Inds,2),NonRevFreqScore(NonRevfreqTrChoice0Inds,3),'ks');
plot3(NonRevFreqScore(~NonRevfreqTrChoice0Inds,1),NonRevFreqScore(~NonRevfreqTrChoice0Inds,2),NonRevFreqScore(~NonRevfreqTrChoice0Inds,3),'ms');
% 
plot3(NonRevFreqScoreWB(NonRevfreqTrChoice0Inds,1),NonRevFreqScoreWB(NonRevfreqTrChoice0Inds,2),...
    NonRevFreqScoreWB(NonRevfreqTrChoice0Inds,3),'k.','MarkerSize',10);
plot3(NonRevFreqScoreWB(~NonRevfreqTrChoice0Inds,1),NonRevFreqScoreWB(~NonRevfreqTrChoice0Inds,2),...
    NonRevFreqScoreWB(~NonRevfreqTrChoice0Inds,3),'m.','MarkerSize',10);

xlabel('PC1');
ylabel('PC2');
zlabel('PC3');




