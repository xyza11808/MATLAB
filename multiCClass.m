function multiCClass(RawDataAll,StimAll,TrialResult,AlignFrame,FrameRate,varargin)
% this function is trying to performing a multiclass classification of
% different sounds and seeing whether there is any pattern exists for
% stimulus belongs to different octave diff and categories

%Time scale selection, default is 1.5 after aligned frame
if ~isempty(varargin{1})
    TimeLength=varargin{1};
else
    TimeLength=1.5;
end

% label shuffling option
isShuffle=0;
if nargin>6
    if ~isempty(varargin{2})
        isShuffle=varargin{2};
    end
end

% ROI fraction option
ROIindsSelect = true(size(RawDataAll,2),1);
isPartialROI = 0;
if nargin > 7
    if ~isempty(varargin{3})
        ROIindsSelect = varargin{3};
        isPartialROI = 1;
        ROIFraction = sum(ROIindsSelect)/length(ROIindsSelect)*100;
    end
end

% Trial outcome option
TrOutcomeOp = 1; % 0 for non-miss trials, 1 for correct trials, 2 for all trials
if nargin > 8
    if ~isempty(varargin{4})
        TrOutcomeOp = varargin{4};
    end
end

% figure plot option 
isPlot = 1;
if nargin > 9
    if ~isempty(varargin{6})
        isPlot = varargin{6};
    end
end

StimAll = double(StimAll);
if isShuffle
    StimAll = Vshuffle(StimAll);
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

DataSelect = RawDataAll(TrialInds,ROIindsSelect,FrameScale(1):FrameScale(2));
DataUsing = max(DataSelect,[],3);
StimTrUsing = StimAll(TrialInds);
AllStimTypes = unique(StimTrUsing);

if isPlot
    if ~isShuffle
        if ~isdir('./NeuroM_MC_TbyT/')
            mkdir('./NeuroM_MC_TbyT/');
        end
        cd('./NeuroM_MC_TbyT/');
    else
        if ~isdir('./NeuroM_MC_TbyT_shuf/')
            mkdir('./NeuroM_MC_TbyT_shuf/');
        end
        cd('./NeuroM_MC_TbyT_shuf/');
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

% performing multiclass classification
option = statset('UseParallel',1,'Display','final');
t = templateSVM('Solver','SMO','SaveSupportVectors',true,'KernelFunction','linear');
tbl = fitcecoc(DataUsing,StimTrUsing,'Coding','onevsone','Learners',t,'Prior','uniform','options',option);
cvtbl = crossval(tbl);
Lfun = kfoldLoss(cvtbl,'mode','individual');
fprintf('Mean Cross validation error is %.4f.\n',mean(Lfun));

%%
% using half-half random sample for partion, and repeat for multiple times
TrLen = length(StimTrUsing);
PredictAll = cell(1000,1);
IsAllStimExist = false(1000,1);  % reversed logical for calculation convenience
parfor nnn = 1:1000
    TrainInds = false(TrLen,1);
    TrainIndex = randsample(TrLen,round(TrLen*0.8));
    TrainInds(TrainIndex) = true;
    TestInds = ~TrainInds;
    tblPar = fitcecoc(DataUsing(TrainInds,:),StimTrUsing(TrainInds),'Coding','onevsone','Learners',t,'Prior','uniform');
    TestResult = predict(tblPar,DataUsing(TestInds,:));
    TestRealStim = StimTrUsing(TestInds);
    PredResult = [TestResult,TestRealStim(:)];
    PredictAll{nnn} = PredResult;
    if length(unique(TestRealStim)) ~= length(AllStimTypes)
        IsAllStimExist(nnn) = true;
    end
end
PredictAll(IsAllStimExist) = [];
[MeanErroAllC,stimErroAllC,classErroAllC] = cellfun(@(x) PredErrorCal(x),PredictAll,'UniformOutput',false); % the first mean is total error, the second mean is trial type error
MeanErroAll = cell2mat(MeanErroAllC);
stimErroAll = cell2mat(stimErroAllC);
classErroAll = cell2mat(classErroAllC);
save StimPredResult.mat MeanErroAll stimErroAll classErroAll Lfun -v7.3
h_ecoc = figure;
scatter(MeanErroAll(:,1),MeanErroAll(:,2),40,'ro');
xlabel('Between Stimlus error');
ylabel('Between class error');
title('Class error scatter plot');
xlims = get(gca,'xlim');
set(gca,'ylim',xlims,'FontSize',20);
line(xlims,xlims,'Color',[.8 .8 .8],'LineWidth',1.8,'Linestyle','--');
saveas(h_ecoc,'BetStim error vs BetTrType error scatter plot');
saveas(h_ecoc,'BetStim error vs BetTrType error scatter plot','png');
close(h_ecoc);

%%
% separated one vs one binary classification
StimTypesAll = unique(StimTrUsing);
ClassNum = length(StimTypesAll)*(length(StimTypesAll) - 1)/2;
DataAllCVerro = zeros(ClassNum,10);
Class82CVErro = zeros(ClassNum,100);
m = 1;
for nStimtype = 1 : length(StimTypesAll)
    for npairType = (nStimtype+1) : length(StimTypesAll)
        cPositive = StimTrUsing == StimTypesAll(nStimtype);
        cNegtive = StimTrUsing == StimTypesAll(npairType);
        DataSetAll = [DataUsing(cPositive,:);DataUsing(cNegtive,:)];
        StimSetAll = StimTrUsing(logical(cPositive+cNegtive));
        mdl = fitcsvm(DataSetAll,StimSetAll(:));
        CVerror = kfoldLoss(crossval(mdl),'mode','individual');
        DataAllCVerro(m,:) = CVerror;
        parfor nIters = 1 : 100
            TrainInds = false(length(StimSetAll),1);
            RandInds = randsample(length(StimSetAll),round(0.8*length(StimSetAll)));
            TrainInds(RandInds) = true;
            TestInds = ~TrainInds;
            ItMdl = fitcsvm(DataSetAll(TrainInds,:),StimSetAll(TrainInds));
            PredictStims = predict(ItMdl,DataSetAll(TestInds,:));
            RealPredStim = StimSetAll(TestInds);
            Errorate = mean(double(~(PredictStims == RealPredStim(:))));
            Class82CVErro(m,nIters) = Errorate;
        end
        m = m + 1;
    end
end
%%
TypeErro = mean(Class82CVErro,2);
matrixData = squareform(TypeErro);
h_mt = figure;
imagesc(matrixData)
xlabel('Stim Types');
ylabel('Stim Types');
title('Type by type classification error rate');
colorbar;
%%
if isPlot
    saveas(h_mt,'Multi class classification error rate');
    saveas(h_mt,'Multi class classification error rate','png');
    close(h_mt);
    cd ..;
    cd ..;
    if isPartialROI
        cd ..;
    end
end

