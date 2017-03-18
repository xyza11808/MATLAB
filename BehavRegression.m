function BehavRegression(behavResult,Parameters,FreqBoundary,varargin)
% This function is trying to using input data to performing linear logistic
% regression, so that the weight for each paraeter can reveal the
% possibility of which parameter affects the animal behavior choice most
% The variable parameters can include following parameters for linear
% regerssion calculation, a cell array of strings
%       % 'FreqDiff': calculated as log2(FreqTr/FreqBoundary), the octave
%                     form
%       % 'Bias': Trial bias, calculated by animal licking before stimulus
%                 onset
%       % 'RewardHist': reward history, calculated by former reward bias
%       % 'LastTrEffect': effects of last trials, especially when last
%                  trial is an error trial
%       % 'Modu': optional input, whether there is modulation within
%                  current session
% if any other parameters are needed, will added into analysis in the
% future
% Yu XIN, 30th, Dec., 2016
p = inputParser;
defaultFolds = 10;
addRequired(p,'behavResult',@isstruct);
addRequired(p,'Parameters',@iscell);
addRequired(p,'FreqBoundary',@isnumeric);
% addRequired(p,'ImagingTimeLen',@isnumeric);
addParameter(p,'kfolds',defaultFolds);
p.KeepUnmatched = true;
parse(p,behavResult,Parameters,FreqBoundary,varargin{:});
kFolds = p.Results.kfolds;

DefaultParaStr = {'FreqDiff','Bias','RewardHist','LastTrEffect','Modu'};
DataParaStrc = struct('FreqDiff',0,'Bias',0,'RewardHist',0,'LastTrEffect',0,'Modu',0);
for nInputPara = 1 : length(Parameters)
    InputParaInds = strcmpi(DefaultParaStr,Parameters{nInputPara});
    if sum(InputParaInds)
        ParaName = DefaultParaStr(InputParaInds);
        DataParaStrc.(ParaName{:}) = 1;
    end
end
BehavChoice = behavResult.Action_choice; % miss trials will excluded from anaysis
DataForAll = [];
DataParaStrs = {};
if DataParaStrc.FreqDiff
    AllTrFreq = double(behavResult.Stim_toneFreq);
    AllTrOct = log2(AllTrFreq/FreqBoundary);
    DataForAll = [DataForAll,AllTrOct(:)];
    DataParaStrs = {DataParaStrs{:},'FreqDiff'};
end
if DataParaStrc.Bias
    LickBias = behavResult.BiasSide;
    LickBias(behavResult.BiasSide == 2) = 0;
    LickBias(behavResult.BiasSide == 0) = -1;
    DataForAll = [DataForAll,LickBias(:)];
    DataParaStrs = {DataParaStrs{:},'Bias'};
end
if DataParaStrc.RewardHist
    TrialReward = double(behavResult.Time_reward > 0);
    TrTypes = double(behavResult.Trial_Type);
    cLeftInds = TrTypes == 0;
    cRightInds = TrTypes == 1;
    LeftReward = 0;
    RightReward = 0;
    RewawrdHist = zeros(length(TrTypes),2);
    for nmnm = 1 : length(TrTypes)
        cRewardsum = TrialReward(1:nmnm);
        LeftReward = mean(cRewardsum(cLeftInds(1:nmnm)));
        RightReward = mean(cRewardsum(cRightInds(1:nmnm)));
        cRewardHis = [LeftReward,RightReward];
        cRewardHis(isnan(cRewardHis)) = 0;
        RewawrdHist(nmnm,:) = cRewardHis;
    end
    RewawrdDiff = RewawrdHist(:,1) - RewawrdHist(:,2);
    DataForAll = [DataForAll,RewawrdDiff];
    DataParaStrs = {DataParaStrs{:},'LR_rewardDiff'};
end
if DataParaStrc.LastTrEffect
    TrialChoice = behavResult.Action_choice;
%     TrialChoice(TrialChoice == 2) = [];
    TrialReward = double(behavResult.Time_reward > 0);
    TrialReward(behavResult.Action_choice == 2) = 2;
%     TrialEffect = TrialReward;
    TrialChoice(TrialReward == 0) = 1 - TrialChoice(TrialReward == 0);
    TrialLastEffect = TrialChoice;
    TrialLastEffect(TrialChoice == 0) = -1;
    TrialLastEffect(TrialChoice == 2) = 0;
    DataForAll = [DataForAll,TrialLastEffect(:)];
    DataParaStrs = {DataParaStrs{:},'LastTrEffect'};
end
if DataParaStrc.Modu
    TrialModulation = behavResult.isModu;
    DataForAll = [DataForAll,TrialModulation(:)];
    DataParaStrs = {DataParaStrs{:},'ModuLation'};
end
fprintf('Parameters used for regression:\n');
disp(DataParaStrs);

% third part data set for extra training
TestDataNum = 20;
TestIndex = randsample(length(BehavChoice),TestDataNum);
TestData = DataForAll(TestIndex,:);
TestChoice = BehavChoice(TestIndex);

% All model training and cross-validation
TrainingInds = true(length(BehavChoice),1);
TrainingInds(TestIndex) = false;
TrainingData = DataForAll(TrainingInds,:);
TrainingChoice = BehavChoice(TrainingInds);
% Model training
[BTrainAll,~,statsTrainAll,isOUTITernAll] = mnrfit(TrainingData,categorical(TrainingChoice(:)));
% MatrixWeight = BTrain(2:end);
% MatrixScore = TrainingDataSet * MatrixWeight + BTrain(1);
% pValue = 1./(1+exp(-1.*MatrixScore));
% CVresult = kfoldLoss(crossval)  % have to performing manually
% cross-validation
cp = cvpartition(categorical(TrainingChoice(:)),'k',kFolds);
cvError = zeros(kFolds,1);
% isOUTITern = 0;
% isOUTITernAll = 0;
for nn = 1 : kFolds
    TrIdx = cp.training(nn);
    TeIdx = cp.test(nn);
    [BTrain,~,statsTrain,isOUTITern] = mnrfit(TrainingData(TrIdx,:),categorical(TrainingChoice(TrIdx)));
%     TestChoice = BehavChoice(TeIdx);
    if isOUTITern
        fprintf('Bad regression partion for partition dataset %d.\n',nn);
    else
        [pihat,~,~] = mnrval(BTrain,TrainingData(TeIdx,:),statsTrain);
        PredChoice = double(pihat(:,2));
        ErrorNum = sum(PredChoice ~= double(TrainingChoice(TeIdx)))/length(PredChoice);
        cvError(nn) = ErrorNum;
    end
end
if ~isOUTITernAll
    [pihatAll,~,~] = mnrval(BTrainAll,TestData,statsTrainAll);
    ThirdTestPred = double(pihatAll(:,2));
%     ThirdTestChoice = BehavChoice(~TrainingInds);
    ThirdTestErro = sum(ThirdTestPred ~= TestChoice(:))/length(ThirdTestPred);  % third part choice prediction
    save RegressionResult.mat BTrainAll statsTrainAll isOUTITernAll cvError ThirdTestErro DataForAll BehavChoice -v7.3
else
    fprintf('Model can not find a good regression result, quit analysis.\n');
    return;
end