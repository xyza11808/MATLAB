function varargout=RandNMTChoiceDecoding(RawDataAll,StimAll,TrialResult,AlignFrame,FrameRate,varargin)
%this function will be used to process the random data profile and try to
%create a neurometric function to compare with psychometric function
%RawDataAll should be aligned data

TimeLength=1.5;
if ~isempty(varargin)
    if ~isempty(varargin{1})
        TimeLength=varargin{1};
    end
end

isShuffle=0;
if nargin>6
    if ~isempty(varargin{2})
        isShuffle=varargin{2};
    end
end

ispcaDR = 0;
if nargin>7
    if ~isempty(varargin{3})
        ispcaDR = varargin{3};
    end
end

ROIindsSelect = true(size(RawDataAll,2),1);
isPartialROI = 0;
if nargin > 8
    if ~isempty(varargin{4})
        ROIindsSelect = varargin{4};
        isPartialROI = 1;
        ROIFraction = sum(ROIindsSelect)/length(ROIindsSelect);
    end
end

isModelLoad = 0;
if nargin > 9
    if ~isempty(varargin{5})
        isModelLoad = varargin{5};
    end
end

TrialUseTypeOp = 0;
if nargin > 10
    if ~isempty(varargin{6})
        TrialUseTypeOp = varargin{6};
    end
end

ifErrorChoiceCorrect = 0;
switch TrialUseTypeOp
    case 0
        CorrectInds=TrialResult ~= 2;
        ifErrorChoiceCorrect = 1;
    case 1
        CorrectInds=TrialResult == 1;
    case 2
        CorrectInds=true(1,length(TrialResult));
        ifErrorChoiceCorrect = 1;
    otherwise
        error('Error trial outcomme type selection choice.');
end

if isModelLoad
    [fn,fp,fi] = uigetfile('Clfsave.mat','Please select your former classification model');
    if fi
        xx = load(fullfile(fp,fn));
        Exmodel = xx.mdl;
        if isfield(xx,'coeffT')
            CoeffT = load(xx.coeffT);
            ispcaDR = 1;
        end
    else
        fprintf('Skip file selection, using customized classification model.\n');
        isModelLoad = 0;
    end
end
    
%%
RawDataAll = RawDataAll(:,ROIindsSelect,:);
DataSize=size(RawDataAll);

CorrTrialStim=StimAll(CorrectInds);
CorrTrialData=RawDataAll(CorrectInds,:,:);
CorrStimType=unique(CorrTrialStim);
CorrTrialTypes = CorrTrialStim > CorrStimType(length(CorrStimType)/2);
% GivenTrialType = CorrTrialTypes;
CorrTrialResults = TrialResult(CorrectInds);
AnmTrChoice = double(CorrTrialTypes);
if ifErrorChoiceCorrect
    ErrorInds = CorrTrialResults == 0;
    AnmTrChoice(ErrorInds) = 1 - AnmTrChoice(ErrorInds);   % real animal choice used for training tag
end
%
if length(TimeLength) == 1
    FrameScale = sort([AlignFrame,AlignFrame+floor(TimeLength*FrameRate)]);
elseif length(TimeLength) == 2
    FrameScale = sort([AlignFrame+floor(TimeLength(1)*FrameRate),AlignFrame+floor(TimeLength(2)*FrameRate)]);
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
if FrameScale(2) > DataSize(3)
    warning('Time Selection excceed matrix index, correct to %d',DataSize(3));
    FrameScale(2) = DataSize(3);
    if FrameScale(2) > DataSize(3)
        error('ErrorTimeScaleInput');
    end
end

ConsideringData=max(CorrTrialData(:,:,FrameScale(1):FrameScale(2)),[],3);
nROI = size(ConsideringData,2);
% T8TData = max(ConsideringData,[],3);  % trial by ROI matrix, will be project by one projection vector

%%
if ispcaDR
    if ~isdir('./NeuroM_test_pca/')
        mkdir('./NeuroM_test_pca/');
    end
    cd('./NeuroM_test_pca/');
else
    if ~isdir('./NeuroM_test/')
        mkdir('./NeuroM_test/');
    end
    cd('./NeuroM_test/');
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

%%  
if isShuffle
    %shuffled trial types
    ShuffleType=CorrTrialStim;
    %#######################################
    %stimtype shuffle section
    TrialLength=numel(ShuffleType);
    for n=1:TrialLength
        w = ceil(rand*n);
        t = ShuffleType(w);
        ShuffleType(w) = ShuffleType(n);
        ShuffleType(n) = t;
    end
    CorrTrialStimBU=CorrTrialStim;
    CorrTrialStim=ShuffleType;
end

%%
% generate training dataset
nIters = 300;
nTrials = 20;
MeanChoiceData = zeros(nIters*2,nROI);  % Training dataset
Choicelabel = zeros(nIters*2,1);  % Training data label
for ntimes = 1 : nIters
    DataInds = CusRandSample(AnmTrChoice,nTrials);
    cChoosingData = ConsideringData(DataInds,:);
    cChooseChoice = AnmTrChoice(DataInds);
    
    Choices = unique(cChooseChoice);
    for nnx = 1 : length(Choices)
        choiceInds = cChooseChoice == Choices(nnx);
        cChoiceData = mean(cChoosingData(choiceInds,:));
        MeanChoiceData(((ntimes - 1)*length(Choices) + nnx),:) = cChoiceData;
        Choicelabel(((ntimes - 1)*length(Choices) + nnx)) = Choices(nnx);
    end
end

%%
% data dimensionality reduction based on frequency types
% data dimensionality reduction is optional for analysis
Freqtypes = CorrStimType;
AllFreqData = zeros(length(Freqtypes),nROI);
for nfreqs = 1 : length(Freqtypes)
    cFreq = Freqtypes(nfreqs);
    cFreqInds = CorrTrialStim == cFreq;
    cFreqData = ConsideringData(cFreqInds,:);
    AllFreqData(nfreqs,:) = mean(cFreqData);
end

if ~isModelLoad
    if ispcaDR
        [coeffT,scoreT,~,~,explainedT,~]=pca(AllFreqData);
        save PCAsave.mat coeffT scoreT explainedT -v7.3
        fprintf('First three components explains %.2f of total variance.\n',sum(explainedT(1:3)));
        StimSumScore = scoreT(:,1:3);

        MeanChoiceDataMeanSub = MeanChoiceData - repmat(mean(MeanChoiceData),size(MeanChoiceData,1),1);
        TrainingScoreAll = MeanChoiceDataMeanSub * coeffT;
        TrainingScore = TrainingScoreAll(:,1:3);
    else
        TrainingScore = MeanChoiceData;
        StimSumScore = AllFreqData;
    end
else
    if exist('CoeffT','vars')
        AllFreqDataMeanSub = AllFreqData - repmat(mean(AllFreqData),size(AllFreqData,1),1);
        scoreT = AllFreqDataMeanSub * CoeffT;
        StimSumScore = scoreT(:,1:3);
        
        MeanChoiceDataMeanSub = MeanChoiceData - repmat(mean(MeanChoiceData),size(MeanChoiceData,1),1);
        TrainingScoreAll = MeanChoiceDataMeanSub * CoeffT;
        TrainingScore = TrainingScoreAll(:,1:3);
    else    % using all information for classification
        TrainingScore = MeanChoiceData;
        StimSumScore = AllFreqData;
    end
end
        
%%
% loading behavior data
[filename,filepath,~]=uigetfile('boundary_result.mat','Select your random plot fit result');
load(fullfile(filepath,filename));
Octavex=log2(double(CorrStimType)/min(double(CorrStimType)));
% Octavefit=Octavex;
Octavexfit=Octavex;
% OctaveTest=Octavex;
realy=boundary_result.StimCorr;
realy(1:3)=1-realy(1:3);
Curve_x=linspace(min(Octavex),max(Octavex),500);
rescaleB=max(realy);
rescaleA=min(realy);

%%
% training the classifier
if isModelLoad
    mdl = Exmodel;
    CTrainingPred = predict(mdl,TrainingScore);
    OverCorrRate = mean(CTrainingPred(:) == Choicelabel(:));
    fprintf('the correct rate for current training session is %.2f.\n',OverCorrRate*100);
    save ExternalModelCorr.mat OverCorrRate -v7.3
else
    mdl = fitcsvm(TrainingScore,Choicelabel);
    CVmodel = crossval(mdl,'k',20);
    TrainErro = kfoldLoss(CVmodel,'mode','individual');
    fprintf('Model Crossval error lost is %.4f.\n',mean(TrainErro));
end
[~,TestPredScore] = predict(mdl,StimSumScore);
difscore = TestPredScore(:,2) - TestPredScore(:,1);
%
if max(difscore) > 2*abs(min(difscore))
    fityAll=(rescaleB-rescaleA)*((difscore-min(difscore))./(abs(min(difscore))-min(difscore)))+rescaleA; 
    fityAll(fityAll>rescaleB) = rescaleB;
    NorScaleValue = [min(difscore),abs(min(difscore))];
elseif abs(min(difscore)) > 2 * max(difscore) && max(difscore) > 0
    fityAll=(rescaleB-rescaleA)*((difscore+max(difscore))./(abs(max(difscore)*2)))+rescaleA; 
    fityAll(fityAll<rescaleA) = rescaleA;
    NorScaleValue = [(-1)*abs(max(difscore)),max(difscore)];
else
    fityAll=(rescaleB-rescaleA)*((difscore-min(difscore))./(max(difscore)-min(difscore)))+rescaleA;  %rescale to [0 1]
    NorScaleValue = [min(difscore),max(difscore)];
end

if ispcaDR
    save Clfsave.mat TrainingScore Choicelabel StimSumScore NorScaleValue fityAll TestPredScore mdl NorScaleValue coeffT -v7.3
else
    save Clfsave.mat TrainingScore Choicelabel StimSumScore NorScaleValue fityAll TestPredScore mdl NorScaleValue -v7.3
end
%%
% plot current results
modelfun = @(p1,t)(p1(2)./(1 + exp(-p1(3).*(t-p1(1)))));
[~,breal] = fit_logistic(Octavexfit,realy);
[~,bfit] = fit_logistic(Octavexfit,fityAll);
Curve_realy = modelfun(breal,Curve_x);
Curve_Fity = modelfun(bfit,Curve_x);

h_compPlot = figure('position',[200 200 1000 800]);
hold on;
plot(Curve_x,Curve_realy,'k','LineWidth',2);
plot(Curve_x,Curve_Fity,'r','LineWidth',2);
scatter(Octavexfit,realy,80,'k','o','LineWidth',2);
scatter(Octavexfit,fityAll,80,'r','o','LineWidth',2);
text(Octavexfit(2),0.8,sprintf('nROI = %d',nROI),'FontSize',15);
legend('behav\_curve','Neuro\_curve','Behav\_data','Neuro\_data','location','southeast');
legend('boxoff');
xlabel('Tone Frequency (kHz)');
ylabel('Fraction choice (R)');
ylim([0 1]);
CorrStimTypeTick = Freqtypes/1000;
set(gca,'xtick',Octavex,'xticklabel',cellstr(num2str(CorrStimTypeTick(:),'%.2f')),'FontSize',20);
set(gca,'FontSize',18);
if length(TimeLength) == 1
    saveas(h_compPlot,sprintf('Neuro_psycho_%dms_comp_plot.png',TimeLength*1000));
    saveas(h_compPlot,sprintf('Neuro_psycho_%dms_comp_plot.fig',TimeLength*1000));
else
%     StartTime = min(TimeLength);
%     TimeScale = max(TimeLength) - min(TimeLength);
    saveas(h_compPlot,sprintf('Neuro_psycho_%dms%dmsDur_comp_plot.png',StartTime*1000,TimeScale*1000));
    saveas(h_compPlot,sprintf('Neuro_psycho_%dms%dmsDur_comp_plot.fig',StartTime*1000,TimeScale*1000));
end
close(h_compPlot);

save NMDataSummry.mat Octavexfit realy fityAll -v7.3
%%
cd ..;
cd ..;
if isPartialROI
    cd ..;
end
if nargout >0
    varargout{1} = realy;
end