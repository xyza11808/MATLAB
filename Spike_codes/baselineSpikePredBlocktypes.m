cclr
load('NPClassHandleSaved.mat')
load('Chnlocation.mat');
load('SessAreaIndexData.mat');
if isempty(ProbNPSess.ChannelAreaStrs)
    ProbNPSess.ChannelAreaStrs = {ChnArea_indexes,ChnArea_Strings(:,3)};
end
%%
ProbNPSess.CurrentSessInds = strcmpi('Task',ProbNPSess.SessTypeStrs);
% TimeWin = [-1.5,8]; % time window used to calculate the psth, usually includes before and after trigger time, in seconds
% Smoothbin = [50,10]; %
% ProbNPSess = ProbNPSess.TrigPSTH(TimeWin, Smoothbin, double(behavResults.Time_stimOnset(:)));
% save(fullfile(pwd,'ks2_5','NPClassHandleSaved.mat'),'ProbNPSess', 'PassSoundDatas', 'behavResults', '-v7.3');

SMBinDataMtx = permute(cat(3,ProbNPSess.TrigData_Bin{ProbNPSess.CurrentSessInds}{:,1}),[1,3,2]); % transfromed into trial-by-units-by-bin matrix

SMBinDataMtxRaw = SMBinDataMtx;
if ~isempty(ProbNPSess.SurviveInds)
    SMBinDataMtx = SMBinDataMtx(:,ProbNPSess.SurviveInds,:);
end
% SMBinDataMtx = SMBinDataMtx(:,:,:);
SMBinDataMtx = SMBinDataMtx(:,SessAreaIndexStrc.CA3.MatchedUnitInds,:);

%%
[TrNum, unitNum, BinNum] = size(SMBinDataMtx);

TriggerAlignBin = ProbNPSess.TriggerStartBin{ProbNPSess.CurrentSessInds};
halfBaselineWinInds = round((TriggerAlignBin-1)/2);
BaselineResp_First = mean(SMBinDataMtx(:,:,1:halfBaselineWinInds),3);
BaselineResp_Last = mean(SMBinDataMtx(:,:,(halfBaselineWinInds+1):(TriggerAlignBin-1)),3);

% RespTimeWin = round(1/ProbNPSess.USedbin(2));
% BaselineResp_First = mean(SMBinDataMtx(:,:,(TriggerAlignBin+1):(TriggerAlignBin+RespTimeWin)),3);

BlockSectionInfo = Bev2blockinfoFun(behavResults);
%%
zsbaselineData = zscore(BaselineResp_First);

BlockTypesAll = double(behavResults.BlockType(:));
sampleInds = randsample(TrNum,round(TrNum*0.7));
IsTrainingSet = false(TrNum,1);
IsTrainingSet(sampleInds) = true;
trainSet_resps = BaselineResp_First(IsTrainingSet,:);
TrainSet_labels = BlockTypesAll(IsTrainingSet);
TestSet_resps = BaselineResp_First(~IsTrainingSet,:);
TestSet_labels = BlockTypesAll(~IsTrainingSet);

mdl = fitcsvm(trainSet_resps,TrainSet_labels);
CVmodel = crossval(mdl,'k',10);
TrainErro = kfoldLoss(CVmodel,'mode','individual');

fprintf('Model Crossval error lost is %.4f.\n',mean(TrainErro));
predTestLabels = predict(mdl,TestSet_resps);
mean(TestSet_labels == predTestLabels)

%%

RepeatNum = 100;
IsTrainingSet = false(TrNum,1);
shufPredCorr = zeros(RepeatNum,1);
for cR = 1 : RepeatNum
    shufBlocks = Vshuffle(BlockTypesAll);
    sampleInds = randsample(TrNum,round(TrNum*0.7));
    TrainInds = IsTrainingSet;
    TrainInds(sampleInds) = true;
    
    shuftrainSet_resps = BaselineResp_First(TrainInds,:);
    shufTrainSet_labels = shufBlocks(TrainInds);
    shufTestSet_resps = BaselineResp_First(~TrainInds,:);
    shufTestSet_labels = shufBlocks(~TrainInds);

    mdl_shuf = fitcsvm(shuftrainSet_resps,shufTrainSet_labels);
    
    predTestLabels = predict(mdl_shuf,shufTestSet_resps);
    shufPredCorr(cR) = mean(predTestLabels == shufTestSet_labels);
    
    
end

%% ROC test for each unit
AUCValuesAll = zeros(unitNum,3);
smoothed_baseline_resp = zeros(size(BaselineResp_First));
for cUnit = 1 : unitNum
    cUnitDatas = BaselineResp_First(:,cUnit);
    [AUC, IsMeanRev] = AUC_fast_utest(cUnitDatas, BlockTypesAll);
    
    [~,~,SigValues] = ROCSiglevelGeneNew([cUnitDatas, BlockTypesAll],200,1,0.01);
    AUCValuesAll(cUnit,:) = [AUC, IsMeanRev, SigValues];
    
    smoothed_baseline_resp(:,cUnit) = smooth(cUnitDatas,7);
end

% RevInds = AUCValuesAll(:,2) == 1;
% AUCValuesAll(RevInds,1) = 1 - AUCValuesAll(RevInds,1);

%%
cUnit = 38;
if cUnit > unitNum
    fprintf('Out of index range.\n');
    return;
end
close;
lhf = figure;
hold on
plot(smoothed_baseline_resp(:,cUnit),'b');
cChnStrs = ProbNPSess.ChannelAreaStrs{2}{ProbNPSess.ChannelUseds_id(cUnit)};
title(sprintf('(%s) AUC = %.4f', cChnStrs, AUCValuesAll(cUnit)));
yaxiss = get(gca,'ylim');
if size(BlockSectionInfo.BlockTrScales,1) == 1
    BlockEndInds = BlockSectionInfo.BlockTrScales(2);
else
    BlockEndInds = BlockSectionInfo.BlockTrScales(1:end-1,2);
end
for cB = 1 : length(BlockEndInds)
    line([BlockEndInds(cB) BlockEndInds(cB)],yaxiss,...
        'Color','k','linewidth',1.2); 
end

%% logistic regression classifier to predict block type 

% MiddleTrainInds = round(mean(BlockSectionInfo.BlockTrScales,2))+(-80:80); %[120+(-60:60); 380+(-60:60)];
% BlockInds = [BlockTypesAll(MiddleTrainInds(1,:)),BlockTypesAll(MiddleTrainInds(2,:))];
% MiddleTrainInds = MiddleTrainInds';
% MiddleRespData = BaselineResp_First(MiddleTrainInds(:),:);
% MiddleBlockInds = BlockInds(:);
% [BTrain,dev,statsTrain] = mnrfit(MiddleRespData,categorical(MiddleBlockInds));
[BTrain,dev,statsTrain] = mnrfit(BaselineResp_First,categorical(BlockTypesAll(:)));
[pihat,dlow,dhi] = mnrval(BTrain,BaselineResp_First,statsTrain);
PredProb = pihat(:,1);

%%
MatrixWeight = BTrain(2:end);
%  ROIbias = (statsTrain.beta(2:end))';
MatrixScore = BaselineResp_Last * MatrixWeight + BTrain(1);
pValue = 1./(1+exp(-1.*MatrixScore));


%% pred new half dataset
[pihatNew,dlowNew,dhiNew] = mnrval(BTrain,BaselineResp_Last,statsTrain);
PredProbNew = pihatNew(:,1);

%% predict block type using SVM classifier
PredProbNew = 1 - predict(mdl,BaselineResp_Last); % the result was minused by 1 to adapted for choice direction

%% plot the behavior result on top
RevFreqs = BlockSectionInfo.BlockFreqTypes(logical(BlockSectionInfo.IsFreq_asReverse));
TrialFreqsAll = double(behavResults.Stim_toneFreq(:));
TrialAnmChoice = double(behavResults.Action_choice(:));
TrialAnmChoice(TrialAnmChoice == 2) = NaN;
RevFreqInds = find(ismember(TrialFreqsAll,RevFreqs));
RevFreqChoices = TrialAnmChoice(RevFreqInds);

NMRevfreqInds = ~isnan(RevFreqChoices);
NMRevFreqIndedx = RevFreqInds(NMRevfreqInds);
NMRevFreqChoice = RevFreqChoices(NMRevfreqInds);

lhf2 = figure;
hold on
hl1 = plot(smooth(PredProbNew,5),'b','linewidth',1);
hl2 = plot(NMRevFreqIndedx,smooth(NMRevFreqChoice,9),'Color',[0.9 0.6 0.2],'linewidth',1);
yaxiss = get(gca,'ylim');
if size(BlockSectionInfo.BlockTrScales,1) == 1
    BlockEndInds = BlockSectionInfo.BlockTrScales(2);
else
    BlockEndInds = BlockSectionInfo.BlockTrScales(1:end-1,2);
end
for cB = 1 : length(BlockEndInds)
    line([BlockEndInds(cB) BlockEndInds(cB)],yaxiss,...
        'Color','k','linewidth',1.2); 
end
legend([hl1, hl2],{'PredProb','RevfreqChoice'},'location','northwest','box','off');

%% time-lagged correlation plot
predProb4Revfreqs = PredProbNew(NMRevFreqIndedx);
% [xcf,lags,bounds] = crosscorr(predProb4Revfreqs,NMRevFreqChoice,'NumLags',20,'NumSTD',3);
figure; 
crosscorr(predProb4Revfreqs,NMRevFreqChoice,'NumLags',40,'NumSTD',3);



