function varargout = TbyTAllROIclassInputParse(RawDataAll,StimAll,TrialResult,AlignFrame,FrameRate,varargin)
% This function will be used for trial by trial classiifcation of trial
% type, and will try to predict the animal's final choice result
% RawDataAll can be any kind of aligned data set, and the AlignFrame should
% be the correponded aligned frame position
% optional input parameters: 
%       %TimeLen: Time window used for calculation neuron response
%       %isShuffle: 0 or 1, whether performing data shuffling
%       %isLoadModel: whether loading external classification model for
%                     calculation
%       %PartialROIInds: ROI inds used for analysis, logical vector
%       %TrOutcomeOp: Trial oucomes used for analysis, 0 as non-missing
%                      trials, 1 for correct trials, and 2 for all trials
%       %isDataOutput: whether output current function result
%       % Yu XIN, 30th, Dec., 2016


p = inputParser;
defaultTimeLen = 1.5;
defaultIsshuffle = 0;
defaultIsmodelload = 0;
defaultIspartialROI = true(size(RawDataAll,2),1);
defaultTroutcome = 1;
defaultisDataOutput = 0;
defaultisErrorCal = 0;
defaultisDisLogiFit = 0;
defaultisWeightsave = 0;
% defaultisTrModulate = [];
addRequired(p,'RawDataAll',@isnumeric);
addRequired(p,'StimAll',@isnumeric);
addRequired(p,'TrialResult',@isnumeric);
addRequired(p,'AlignFrame',@isnumeric);
addRequired(p,'FrameRate',@isnumeric);
addParameter(p,'TimeLen',defaultTimeLen);
addParameter(p,'isShuffle',defaultIsshuffle);
addParameter(p,'isLoadModel',defaultIsmodelload);
addParameter(p,'PartialROIInds',defaultIspartialROI);
addParameter(p,'TrOutcomeOp',defaultTroutcome);
addParameter(p,'isDataOutput',defaultisDataOutput);
addParameter(p,'isErCal',defaultisErrorCal);
addParameter(p,'isDisLogisFit',defaultisDisLogiFit);
addParameter(p,'isWeightsave',defaultisWeightsave);
% addParameter(p,'isModulate',defaultisTrModulate);
p.KeepUnmatched = true;
parse(p,RawDataAll,StimAll,TrialResult,AlignFrame,FrameRate,varargin{:});

TimeLength = p.Results.TimeLen;
isShuffle = p.Results.isShuffle;
isLoadModel = p.Results.isLoadModel;
ROIindsSelect = p.Results.PartialROIInds;
TrOutcomeOp = p.Results.TrOutcomeOp;
isDataOutput = p.Results.isDataOutput;
isErrorCal = p.Results.isErCal;
isDisLogFit = p.Results.isDisLogisFit;
isWeightDisp = p.Results.isWeightsave;


isPartialROI = 0;
if ~sum(strcmpi(p.UsingDefaults,'isPartialROI'))
    isPartialROI = 1;
    ROIFraction = sum(ROIindsSelect)/length(ROIindsSelect);
end

if nargout > 0
    isDataOutput = 1;
end
% %Time scale selection, default is 1.5 after aligned frame
% if ~isempty(varargin{1})
%     TimeLength=varargin{1};
% else
%     TimeLength=1.5;
% end
% 
% % label shuffling option
% isShuffle=0;
% if nargin>6
%     if ~isempty(varargin{2})
%         isShuffle=varargin{2};
%     end
% end
% % external model load option
% isLoadModel = 0;
% if nargin>7
%     if ~isempty(varargin{3})
%         isLoadModel = varargin{3};
%     end
% end
% 
% % ROI fraction option
% ROIindsSelect = true(size(RawDataAll,2),1);
% isPartialROI = 0;
% if nargin > 8
%     if ~isempty(varargin{4})
%         ROIindsSelect = varargin{4};
%         isPartialROI = 1;
%         ROIFraction = sum(ROIindsSelect)/length(ROIindsSelect);
%     end
% end
% 
% % Trial outcome option
% TrOutcomeOp = 1; % 0 for non-miss trials, 1 for correct trials, 2 for all trials
% if nargin > 9
%     if ~isempty(varargin{5})
%         TrOutcomeOp = varargin{5};
%     end
% end
% 
% % Output option, used when only function is just called by other functions
% isDataOutput = 0;
% if nargin > 10
%     if ~isempty(varargin{6})
%         isDataOutput = varargin{6};
%     end
% end

% Time scale to frame scale
%
if length(TimeLength) == 1
    FrameScale = sort([AlignFrame,AlignFrame+round(TimeLength*FrameRate)]);
elseif length(TimeLength) == 2
    FrameScale = sort([AlignFrame+round(TimeLength(1)*FrameRate),AlignFrame+round(TimeLength(2)*FrameRate)]);
    StartTime = min(TimeLength);
    TimeScale = max(TimeLength) - min(TimeLength);
else
    warning('Input TimeLength variable have a length of %d, but it have to be 1 or 2',length(TimeLength));
    return;
end
if FrameScale(1) < 1
    warning('Time Selection excceed matrix index, correct to 1');
    FrameScale(1) = 1;
    if FrameScale(2) < 1
        error('ErrorTimeScaleInput');
    end
end
if FrameScale(2) > size(RawDataAll,3)
    warning('Time Selection excceed matrix index, correct to %d',DataSize(3));
    FrameScale(2) = size(RawDataAll,3);
    if FrameScale(2) > size(RawDataAll,3)
        error('ErrorTimeScaleInput');
    end
end

% trial outcome selection
% using only correct trials for analysis, but using non-missing trials is
% also an option
switch TrOutcomeOp
    case 0  % non-miss trials option
        TrialInds = TrialResult ~= 2;
        fprintf('Using all non-missing trials for classification.\n');
    case 1 % only correct trial selection
        TrialInds = TrialResult == 1;
        fprintf('Using only correct trials for classification.\n');
    case 2 % all trials option
        TrialInds = true(length(TrialResult),1);
        fprintf('Using all trials for classification training.\n')
    otherwise
        error('Error trial outcome option, which can only be either 0,1 or 2');
end

% shuffling option
% % #######################################
% % this section will be skipped, shuffled data as threshold option
% if isShuffle
% %     ShuffleType = StimAll;
% %     TrialLength = length(StimAll);
% %     for n=1:TrialLength
% %         w = ceil(rand*n);
% %         t = ShuffleType(w);
% %         ShuffleType(w) = ShuffleType(n);
% %         ShuffleType(n) = t;
% %     end
%     OrderTrialStim=StimAll;
%     StimAll=Vshuffle(StimAll);
% end
% % #######################################

% Data considered 
UsingData = max(RawDataAll(TrialInds,ROIindsSelect,FrameScale(1):FrameScale(2)),[],3);
UsingStim = StimAll(TrialInds);
UsingStimType = unique(UsingStim);
ThresStim = UsingStimType(length(UsingStimType)/2);
UsingTrialType = double(UsingStim > ThresStim);
UsingTrialType = UsingTrialType (:);
UsingTrialResult = TrialResult(TrialInds);

if TrOutcomeOp == 0
    UsingTrialType(UsingTrialResult == 0) = 1 - UsingTrialType(UsingTrialResult == 0);
elseif TrOutcomeOp == 1
    ErroInds = TrialResult == 0;
    ErrorData = max(RawDataAll(ErroInds,ROIindsSelect,FrameScale(1):FrameScale(2)),[],3);  % all error trials data
    ErrorTypes = StimAll(ErroInds) > ThresStim;
    ErroChoice = 1 - ErrorTypes;
end

%%
if ~isDataOutput
    if ~isLoadModel
        if ~isdir('./NeuroM_TbyT_test/')
            mkdir('./NeuroM_TbyT_test/');
        end
        cd('./NeuroM_TbyT_test/');

    else
        if ~isdir('./NeuroM_LoadSVM_TbyT/')
            mkdir('./NeuroM_LoadSVM_TbyT/');
        end
        cd('./NeuroM_LoadSVM_TbyT/');

    end

    if isPartialROI
        if ~isdir(sprintf('./Partial_%.2fROI/',ROIFraction*100))
            mkdir(sprintf('./Partial_%.2fROI/',ROIFraction*100));
        end
        cd(sprintf('./Partial_%.2fROI/',ROIFraction*100));
    end

    if length(TimeLength) == 1
        if ~isdir(sprintf('./AfterTimeLength-%dms/',TimeLength*1000))
            mkdir(sprintf('./AfterTimeLength-%dms/',TimeLength*1000));
        end
        cd(sprintf('./AfterTimeLength-%dms/',TimeLength*1000));
    else
    %     StartTime = min(TimeLength);
    %     TimeScale = max(TimeLength) - min(TimeLength);

        if ~isdir(sprintf('./AfterTimeLength-%dms%dmsDur/',StartTime*1000,TimeScale*1000))
            mkdir(sprintf('./AfterTimeLength-%dms%dmsDur/',StartTime*1000,TimeScale*1000));
        end
        cd(sprintf('./AfterTimeLength-%dms%dmsDur/',StartTime*1000,TimeScale*1000));
    end
end
% using all given ROIs to do the classification
BaseTraingInds = false(length(UsingStim),1);
% TrainSeeds = randsample(length(UsingStim),0.5*length(UsingStim));
% TrainInds = BaseTraingInds;
% TrainInds(TrainSeeds) = true;
% TestInds = ~TrainInds;

% using given data to train the TbyT model
% Training ten times and save  all options
nIters = 200;
% if ~isDataOutput
% %     TrainModel = cell(1000,1);
%     TrainModelLoss = zeros(nIters,1);
%     if isDisLogFit
%         SUFTrainModelLoss = zeros(nIters,1);
%     end
% end

TestLoss = zeros(nIters,1);
if isDisLogFit
    ProbLoss = zeros(nIters,1);
    ProbLossCell = cell(nIters,1);
    isBadRegression = zeros(nIters,1);
end
if isWeightDisp
    IterWeightAll = zeros(nIters,sum(ROIindsSelect));
end
parfor nTimes = 1 : nIters
    if TrOutcomeOp == 1  %only correct trials used for training
        TrainSeeds = CusRandSample(length(UsingStim),round(0.8*length(UsingStim)));
    elseif TrOutcomeOp == 0
        TrainSeeds = CusRandSample(UsingTrialResult,round(0.8*length(UsingStim)));
    end
    
    TrainInds = BaseTraingInds;
    TrainInds(TrainSeeds) = true;
    TestInds = ~TrainInds;
    TrainData = UsingData(TrainInds,:);
    TestData = UsingData(TestInds,:);
    TrainM = fitcsvm(TrainData,UsingTrialType(TrainInds));
%     if ~isDataOutput
% %         TrainModel{nTimes} = TrainM;
%         if size(TrainData,1) > 40
%             TrainModelLoss(nTimes) = kfoldLoss(crossval(TrainM));
%         end
%     end
    ModelPred = predict(TrainM,TestData);
    TestTypes = UsingTrialType(TestInds);
    TestDataLoss = sum(abs(ModelPred - TestTypes))/length(ModelPred);
    TestLoss(nTimes) = TestDataLoss;
    if isErrorCal
        if TrOutcomeOp == 1 % all error trials will be used as test dataset
            ErrorPred = predict(TrainM,ErrorData);
            ErrorDataLoss = sum(abs(ErroChoice(:) - ErrorPred(:)))/length(ErroChoice);
            ErroLoss(nTimes) = ErrorDataLoss;
        elseif TrOutcomeOp == 0 % all non-missing trials being used for training
            ErrorData = [];
            ErroChoice = [];
%             fprintf('Test ErrorData exists.\n');
%             fprintf('Test ErrorChoice exists.\n');
            TestIndsOutcome = UsingTrialResult(TestInds);
            CorrTestInds = TestIndsOutcome == 1;
            TestCorrDataLoss = sum(abs(ModelPred(CorrTestInds) - TestTypes(CorrTestInds)))/sum(CorrTestInds);
            TestLoss(nTimes) = TestCorrDataLoss; % only calculate correct trials test loss

    %         ErroTestTypes = TestTypes(~CorrTestInds);
            TestErroDataLoss = sum(abs(ModelPred(~CorrTestInds) - TestTypes(~CorrTestInds)))/sum(~CorrTestInds);
            ErroLoss(nTimes) = TestErroDataLoss;
        end
    end
    
    if isWeightDisp
        SVMWeights = TrainM.Beta;
        IterWeightAll(nTimes,:) = SVMWeights;
    end
    
    if isDisLogFit
        SVMWeights = TrainM.Beta;
        SVMbias = TrainM.Bias;
        TrainData = UsingData(TrainInds,:);
        TrainScore = TrainData*SVMWeights + SVMbias;
        TestingDataSet = UsingData(TestInds,:);
        TestScore = TestingDataSet*SVMWeights + SVMbias;
        sp = categorical(UsingTrialType(TrainInds));  % turn current vector's format from double to categorical format
    %     Testsp = categorical(UsingTrialType(TestInds));
        try
            [BTrain2,~,statsTrain2,isOUTITern] = mnrfit(TrainScore,sp); %#ok<*PFTUS>
            ismnrfitErr = 0;
        catch
            ismnrfitErr = 1;
            [BTrain2,~,statsTrain2] = mnrfit(TrainScore,sp);
        end
        [pihat,~,~] = mnrval(BTrain2,TestScore,statsTrain2);
        PredTrialType = double(pihat(:,2));  % probability for current score being class one
        ProbLossCell{nTimes} = [PredTrialType,UsingTrialType(TestInds)];
        ProbLoss(nTimes) = sum(abs(PredTrialType-UsingTrialType(TestInds)))/length(PredTrialType);
        if ~ismnrfitErr
            if isOUTITern
                isBadRegression(nTimes) = 1;
            end
        end
    end
    %     fprintf('Test Data error rate is %.3f.\n',TestDataLoss);
end
% if isBadModelCV
%     clearvars TrainModelLoss
% end
MinTestLoss = mean(TestLoss);
fprintf('Mean Test Data error rate is %.3f.\n',MinTestLoss);

if isShuffle
    % ####################################################
    % shuffle section, for baseline calculation
    shuStimAll = Vshuffle(StimAll);
    UsingStim = shuStimAll(TrialInds);
    UsingTrialType = double(UsingStim>UsingStimType(length(UsingStimType)/2));
    UsingTrialType = UsingTrialType(:);

    SUFTestLoss = zeros(nIters,1);
    SUFProbLoss = zeros(nIters,1);
    SUFProbLossCell = cell(nIters,1);
    SUFisBadRegression = zeros(nIters,1);
    parfor nTimes = 1 : nIters
        TrainSeeds = randsample(length(UsingStim),round(0.8*length(UsingStim)));
        TrainInds = BaseTraingInds;
        TrainInds(TrainSeeds) = true;
        TestInds = ~TrainInds;
        TrainData = UsingData(TrainInds,:);
        TestData = UsingData(TestInds,:);
        TrainM = fitcsvm(TrainData,UsingTrialType(TrainInds));
%         if ~isDataOutput
%     %         TrainModel{nTimes} = TrainM;
%             if size(TrainData,1) > 40
%                 SUFTrainModelLoss(nTimes) = kfoldLoss(crossval(TrainM));
%             end
%         end
        ModelPred = predict(TrainM,TestData);
        TestDataLoss = sum(abs(ModelPred - UsingTrialType(TestInds)))/length(ModelPred);
        SUFTestLoss(nTimes) = TestDataLoss;
        if isDisLogFit
            SVMWeights = TrainM.Beta;
            SVMbias = TrainM.Bias;
            TrainData = UsingData(TrainInds,:);
            TrainScore = TrainData*SVMWeights + SVMbias;
            TestingDataSet = UsingData(TestInds,:);
            TestScore = TestingDataSet*SVMWeights + SVMbias;
            sp = categorical(UsingTrialType(TrainInds));  % turn current vector's format from double to categorical format
        %     Testsp = categorical(UsingTrialType(TestInds));
            try
                [BTrain2,~,statsTrain2,isOUTITern] = mnrfit(TrainScore,sp); %#ok<*PFTIN>
                ismnrfitErr = 0;
            catch
                ismnrfitErr = 1;
                [BTrain2,~,statsTrain2] = mnrfit(TrainScore,sp);
            end
            [pihat,~,~] = mnrval(BTrain2,TestScore,statsTrain2);
            PredTrialType = double(pihat(:,2));  % probability for current score being class one
            SUFProbLossCell{nTimes} = [PredTrialType,UsingTrialType(TestInds)];
            SUFProbLoss(nTimes) = sum(abs(PredTrialType-UsingTrialType(TestInds)))/length(PredTrialType);
            if ~ismnrfitErr
                if isOUTITern
                    SUFisBadRegression(nTimes) = 1;
                end
            end
        end
    %     fprintf('Test Data error rate is %.3f.\n',TestDataLoss);
    end
    % % % end of shuffle section
end

if ~isDataOutput
    if isShuffle
         if isDisLogFit
            save TbyTClass.mat TestLoss ProbLossCell ProbLoss isBadRegression SUFTestLoss SUFProbLoss SUFisBadRegression SUFProbLossCell -v7.3
         else
             save TbyTClass.mat TestLoss isBadRegression SUFTestLoss SUFisBadRegression -v7.3
         end
    else
        if isDisLogFit
            save TbyTClassNoSUF.mat TestLoss ProbLossCell ProbLoss isBadRegression -v7.3
        else
            save TbyTClassNoSUF.mat TestLoss -v7.3
        end
    end
    if isErrorCal
        save ErrorChoicePred.mat ErroLoss -v7.3
    end
    if isWeightDisp
        save CLFWeightsave.mat IterWeightAll -v7.3
    end
    %%
    h = figure('position',[230 230 1450 600]);
    if isDisLogFit
        subplot(1,2,1)
    end
    hist(TestLoss,20);
    xlabel('Error rate');
    ylabel('Rank number');
    title('Error rate distribution of test dataset');
    
    if isDisLogFit
        ProbLossBate = ProbLoss;
        ProbLossBate(logical(isBadRegression)) = [];
        subplot(1,2,2)
        hist(ProbLossBate,20);
        xlabel('Error rate');
        ylabel('Rank number');
        title('Prob error rate distribution of test dataset');
    end
    
    saveas(h,'Error rate distribution plot');
    saveas(h,'Error rate distribution plot','png');
    close(h);
    %%
    cd ..;  
    cd ..;

    if isPartialROI
        cd ..;
    end
else
    
    varargout{1} = TestLoss;
    if isDisLogFit
        ProbLoss(logical(isBadRegression)) = [];
        varargout{2} = ProbLoss;
    else
        varargout{2} = [];
    end
    if isShuffle
        
        varargout{3} = SUFTestLoss;
        if isDisLogFit
            SUFProbLoss(logical(SUFisBadRegression)) = [];
            varargout{4} = SUFProbLoss;
        else
            varargout{4} = [];
        end
    end
    if isErrorCal
        if isShuffle
            varargout{5} = ErroLoss;
        else
            varargout{3} = ErroLoss;
        end
    end
end
