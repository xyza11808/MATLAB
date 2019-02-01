function varargout = TbyTAllROIclass(RawDataAll,StimAll,TrialResult,AlignFrame,FrameRate,varargin)
% this function will be used for trial by trial classiifcation of trial
% type, and will try to predict the animal's final choice result
% RawDataAll can be any kind of aligned data set, and the AlignFrame should
% be the correponded aligned frame position

TimeLength=1.5;
if nargin > 5
    if ~isempty(varargin{1})
        TimeLength=varargin{1};
    end
end

% label shuffling option
isShuffle=0;
if nargin>6
    if ~isempty(varargin{2})
        isShuffle=varargin{2};
    end
end
% external model load option
isLoadModel = 0;
if nargin>7
    if ~isempty(varargin{3})
        isLoadModel = varargin{3};
    end
end

% ROI fraction option
ROIindsSelect = true(size(RawDataAll,2),1);
isPartialROI = 0;
if nargin > 8
    if ~isempty(varargin{4})
        ROIindsSelect = varargin{4};
        isPartialROI = 1;
        ROIFraction = sum(ROIindsSelect)/length(ROIindsSelect);
    end
end

% Trial outcome option
TrOutcomeOp = 1; % 0 for non-miss trials, 1 for correct trials, 2 for all trials
if nargin > 9
    if ~isempty(varargin{5})
        TrOutcomeOp = varargin{5};
    end
end

% Output option, used when only function is just called by other functions
isDataOutput = 0;
if nargin > 10
    if ~isempty(varargin{6})
        isDataOutput = varargin{6};
    end
end
if nargout > 0
    isDataOutput = 1;
end
% ways to define trial types for each stimulus
IsStimTypeDefineVec = 0;
if nargin > 11
    if ~isempty(varargin{7})
        StimTypeDefineVec = varargin{7};
        IsStimTypeDefineVec = 1;
    end
end
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
    case 1 % only correct trial selection
        TrialInds = TrialResult == 1;
    case 2 % all trials option
        TrialInds = true(length(TrialResult),1);
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
UsingData = mean(RawDataAll(TrialInds,ROIindsSelect,FrameScale(1):FrameScale(2)),3);
UsingStim = StimAll(TrialInds);
UsingStimType = unique(UsingStim);
% UsingTrialType = double(UsingStim>UsingStimType(length(UsingStimType)/2));
if IsStimTypeDefineVec
    UsingTrialType = StimTypeDefineVec(TrialInds);
else
    UsingTrialType = double(UsingStim>16000);
end
UsingTrialType = UsingTrialType (:);

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
nIters = 1000;
% if ~isDataOutput
% %     TrainModel = cell(1000,1);
%     TrainModelLoss = zeros(nIters,1);
%     SUFTrainModelLoss = zeros(nIters,1);
% end

TestLoss = zeros(nIters,1);
TestInfoAll = zeros(nIters,1);
% ProbLoss = zeros(nIters,1);
% ProbLossCell = cell(nIters,1);
% isBadRegression = zeros(nIters,1);
parfor nTimes = 1 : nIters
    TrainSeeds = CusRandSample(UsingStim,round(0.8*length(UsingStim)));
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
    TestDataLoss = sum(abs(ModelPred - UsingTrialType(TestInds)))/length(ModelPred);
    TestLoss(nTimes) = TestDataLoss;
    Info = MutInfo(UsingTrialType(TestInds),ModelPred);
    TestInfoAll(nTimes) = Info;
    
    % skip model score estimation
%     SVMWeights = TrainM.Beta;
%     SVMbias = TrainM.Bias;
%     TrainData = UsingData(TrainInds,:);
%     TrainScore = TrainData*SVMWeights + SVMbias;
%     TestingDataSet = UsingData(TestInds,:);
%     TestScore = TestingDataSet*SVMWeights + SVMbias;
%     sp = categorical(UsingTrialType(TrainInds));  % turn current vector's format from double to categorical format
% %     Testsp = categorical(UsingTrialType(TestInds));
%     
%     [BTrain2,~,statsTrain2,isOUTITern] = mnrfit(TrainScore,sp);
%     [pihat,~,~] = mnrval(BTrain2,TestScore,statsTrain2);
%     PredTrialType = double(pihat(:,2));  % probability for current score being class one
%     ProbLossCell{nTimes} = [PredTrialType,UsingTrialType(TestInds)];
%     ProbLoss(nTimes) = sum(abs(PredTrialType-UsingTrialType(TestInds)))/length(PredTrialType);
%     if isOUTITern
%         isBadRegression(nTimes) = 1;
%     end
% %     fprintf('Test Data error rate is %.3f.\n',TestDataLoss);
end
MnTestLoss = mean(TestLoss);
fprintf('Mean Test Data error rate is %.3f.\n',MnTestLoss);

if isShuffle
    % ####################################################
    % shuffle section, for baseline calculation
    shuStimAll = Vshuffle(StimAll);
    UsingStim = shuStimAll(TrialInds);
    UsingTrialType = double(UsingStim>UsingStimType(length(UsingStimType)/2));
    UsingTrialType = UsingTrialType(:);

    SUFTestLoss = zeros(nIters,1);
%     SUFProbLoss = zeros(nIters,1);
%     SUFProbLossCell = cell(nIters,1);
%     SUFisBadRegression = zeros(nIters,1);
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
        
        %skip logistic fitting result
%         SVMWeights = TrainM.Beta;
%         SVMbias = TrainM.Bias;
%         TrainData = UsingData(TrainInds,:);
%         TrainScore = TrainData*SVMWeights + SVMbias;
%         TestingDataSet = UsingData(TestInds,:);
%         TestScore = TestingDataSet*SVMWeights + SVMbias;
%         sp = categorical(UsingTrialType(TrainInds));  % turn current vector's format from double to categorical format
%     %     Testsp = categorical(UsingTrialType(TestInds));
% 
%         [BTrain2,~,statsTrain2,isOUTITern] = mnrfit(TrainScore,sp);
%         [pihat,~,~] = mnrval(BTrain2,TestScore,statsTrain2);
%         PredTrialType = double(pihat(:,2));  % probability for current score being class one
%         SUFProbLossCell{nTimes} = [PredTrialType,UsingTrialType(TestInds)];
%         SUFProbLoss(nTimes) = sum(abs(PredTrialType-UsingTrialType(TestInds)))/length(PredTrialType);
%         if isOUTITern
%             SUFisBadRegression(nTimes) = 1;
%         end
    %     fprintf('Test Data error rate is %.3f.\n',TestDataLoss);
    end
    % % % end of shuffle section
end

if ~isDataOutput
    if isShuffle
%         save TbyTClass.mat TrainModelLoss TestLoss ProbLossCell ProbLoss isBadRegression SUFTestLoss SUFProbLoss SUFisBadRegression SUFProbLossCell -v7.3
        save TbyTClass.mat TestLoss SUFTestLoss -v7.3
    else
%         save TbyTClassNoSUF.mat TrainModelLoss TestLoss ProbLossCell ProbLoss isBadRegression -v7.3
        save TbyTClassNoSUF.mat TestLoss -v7.3
    end
    h = figure;
%     h = figure('position',[230 230 1450 600]);
%     subplot(1,2,1)
    hist(TestLoss,20);
    xlabel('Error rate');
    ylabel('Rank number');
    title('Error rate distribution of test dataset');
    
%     ProbLossBate = ProbLoss;
%     ProbLossBate(logical(isBadRegression)) = [];
%     subplot(1,2,2)
%     hist(ProbLossBate,20);
%     xlabel('Error rate');
%     ylabel('Rank number');
%     title('Prob error rate distribution of test dataset');
    saveas(h,'Error rate distribution plot');
    saveas(h,'Error rate distribution plot','png');
    close(h);
    
    cd ..;  
    cd ..;

    if isPartialROI
        cd ..;
    end
else
    if nargout == 1
        varargout{1} = {TestLoss,TestInfoAll};
    elseif nargout == 2
        varargout{1} = {TestLoss,TestInfoAll};
        if isShuffle
            varargout{2} = SUFTestLoss;
        else
            varargout{2} = [];
        end
    elseif nargout > 2
    %     ProbLoss(logical(isBadRegression)) = [];
        varargout{1} = {TestLoss,TestInfoAll};
        varargout{2} = [];
    %     varargout{2} = ProbLoss;
    %         SUFProbLoss(logical(SUFisBadRegression)) = [];
        if isShuffle
            varargout{3} = SUFTestLoss;
            varargout{4} = [];
        else
            varargout{3} = [];
            varargout{4} = [];
        end
    %         varargout{4} = SUFProbLoss;
    end
end
