function varargout = multiCClass(RawDataAll,BehavStrc,TrialResult,AlignFrame,FrameRate,varargin)
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
        ROIFraction = sum(ROIindsSelect)/length(ROIindsSelect);
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
    if ~isempty(varargin{5})
        isPlot = varargin{5};
    end
end
if isstruct(BehavStrc)
    StimAll = double(BehavStrc.Stim_toneFreq(:));
    StimAll = double(StimAll);
else
    StimAll = BehavStrc;
end
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
DataUsing = mean(DataSelect,3);
StimTrUsing = StimAll(TrialInds);
AllStimTypes = unique(StimTrUsing);
% if mod(length(AllStimTypes),2)
%     fprintf('Input trial stimlus should have even number of frequency types.');
%     return;
% end
%%
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
        if ~isdir(sprintf('./Partial_%.0fROI/',ROIFraction*100))
            mkdir(sprintf('./Partial_%.0fROI/',ROIFraction*100));
        end
        cd(sprintf('./Partial_%.0fROI/',ROIFraction*100));
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
% % using half-half random sample for partion, and repeat for multiple times
% TrLen = length(StimTrUsing);
% PredictAll = cell(1000,1);
% IsAllStimExist = false(1000,1);  % reversed logical for calculation convenience
% parfor nnn = 1:1000
%     TrainInds = false(TrLen,1);
%     TrainIndex = randsample(TrLen,round(TrLen*0.8));
%     TrainInds(TrainIndex) = true;
%     TestInds = ~TrainInds;
%     tblPar = fitcecoc(DataUsing(TrainInds,:),StimTrUsing(TrainInds),'Coding','onevsone','Learners',t,'Prior','uniform');
%     TestResult = predict(tblPar,DataUsing(TestInds,:));
%     TestRealStim = StimTrUsing(TestInds);
%     PredResult = [TestResult,TestRealStim(:)];
%     PredictAll{nnn} = PredResult;
%     if length(unique(TestRealStim)) ~= length(AllStimTypes)
%         IsAllStimExist(nnn) = true;
%     end
% end
% PredictAll(IsAllStimExist) = [];
% [MeanErroAllC,stimErroAllC,classErroAllC] = cellfun(@(x) PredErrorCal(x),PredictAll,'UniformOutput',false); % the first mean is total error, the second mean is trial type error
% MeanErroAll = cell2mat(MeanErroAllC);
% stimErroAll = cell2mat(stimErroAllC);
% classErroAll = cell2mat(classErroAllC);
% save StimPredResult.mat MeanErroAll stimErroAll classErroAll Lfun -v7.3
% h_ecoc = figure;
% scatter(MeanErroAll(:,1),MeanErroAll(:,2),40,'ro');
% xlabel('Between Stimlus error');
% ylabel('Between class error');
% title('Class error scatter plot');
% xlims = get(gca,'xlim');
% set(gca,'ylim',xlims,'FontSize',20);
% line(xlims,xlims,'Color',[.8 .8 .8],'LineWidth',1.8,'Linestyle','--');
% saveas(h_ecoc,'BetStim error vs BetTrType error scatter plot');
% saveas(h_ecoc,'BetStim error vs BetTrType error scatter plot','png');
% close(h_ecoc);

%%
% separated one vs one binary classification
StimTypesAll = unique(StimTrUsing);
ClassNum = length(StimTypesAll)*(length(StimTypesAll) - 1)/2;
% DataAllCVerro = zeros(ClassNum,10);
Class82CVErro = zeros(ClassNum,100);
% PairedROCAll = zeros(ClassNum,size(DataUsing,2));
m = 1;
for nStimtype = 1 : length(StimTypesAll)
    for npairType = (nStimtype+1) : length(StimTypesAll)
        cPositive = StimTrUsing == StimTypesAll(nStimtype);
        cNegtive = StimTrUsing == StimTypesAll(npairType);
        StimTrUsing = StimTrUsing(:);
        DataSetAll = [DataUsing(cPositive,:);DataUsing(cNegtive,:)];
        StimSetAll = [StimTrUsing(cPositive);StimTrUsing(cNegtive)];
%         ROIabs = PairedStimROC(DataSetAll,StimSetAll);
%         PairedROCAll(m,:) = ROIabs;
%         mdl = fitcsvm(DataSetAll,StimSetAll(:));
%         CVerror = kfoldLoss(crossval(mdl),'mode','individual');
%         DataAllCVerro(m,:) = CVerror;
        parfor nIters = 1 : 100
            TrainInds = false(length(StimSetAll),1);
            RandInds = CusRandSample(StimSetAll,round(0.8*length(StimSetAll)));
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
% StimIndex = 1 : length(StimTypesAll);
% save pairROCresult.mat PairedROCAll StimTypesAll -v7.3
%%
StimIndex = 1 : length(StimTypesAll);
StimForStr = double(StimTypesAll)/1000;
TypeErro = mean(Class82CVErro,2);
matrixData = 1 - squareform(TypeErro);
BoundaryData = diag(0.5*ones(length(StimIndex),1));
matrixData = matrixData - BoundaryData;  % set boundary values to 0.5
if isPlot
    h_mt = figure('position',[720 240 500 340]);
    imagesc(StimIndex,StimIndex,matrixData,[0.5 1])
    set(gca,'xtick',StimIndex,'xticklabel',cellstr(num2str(StimForStr(:),'%.2f')),...
        'ytick',StimIndex,'yticklabel',cellstr(num2str(StimForStr(:),'%.2f')));
    xlabel('Stim Types (kHz)');
    ylabel('Stim Types (kHz)');
    title('Type by type classification correct rate');
    set(gca,'FontSize',20)
    colorbar;
    saveas(h_mt,'Multi class classification correct rate');
    saveas(h_mt,'Multi class classification correct rate','png');
    close(h_mt);
end
if isPlot ~= 2
    save PairedClassResult.mat matrixData StimTypesAll Class82CVErro -v7.3
end
%%
% calculate the classification error compared with stimlus distance.
TempMatrixData = matrixData;
% SimTypesBack = StimTypesAll;
if mod(length(StimTypesAll),2)
    BoundFreqInds = ceil(length(StimTypesAll)/2);
    StimTypesAll(BoundFreqInds) = [];
    TempMatrixData(BoundFreqInds,:) = [];
    TempMatrixData(:,BoundFreqInds) = [];
    BackMtxData = TempMatrixData;
else
    BackMtxData = matrixData;
end
ClassNum = length(StimTypesAll)/2;
OvatveStep = log2(double(StimTypesAll(2))/double(StimTypesAll(1)));
TempMatrixData(1:ClassNum,(ClassNum+1):end) =  BackMtxData((ClassNum+1):end,(ClassNum+1):end);
TempMatrixData((ClassNum+1):end,(ClassNum+1):end) = BackMtxData(1:ClassNum,(ClassNum+1):end);  % upper class are all within class error, bottom data are all between class data
WinClassDis = WithinCmask(ClassNum);
BetClassDis = BetCmask(ClassNum);
WithinClassMask = WinClassDis > 0;
LeftWinClassDis = WinClassDis(WithinClassMask);
leftMatrixData = TempMatrixData(1:ClassNum,1:ClassNum);
LeftWinClassError = leftMatrixData(WithinClassMask);

RightWinClassDis = LeftWinClassDis;
rightMatrixData = TempMatrixData(1:ClassNum,(ClassNum+1):end);
RightWinClassError = rightMatrixData(WithinClassMask);

BetClassWinDis = BetClassDis;
BetClassWinError = TempMatrixData((ClassNum+1):end,1:ClassNum);
[BetweenClassCorrData,BetweenClassCorrDataM] = DistanceBasedError(BetClassWinDis,BetClassWinError);

[LeftClassCorrData,LeftClassCorrDataM] = DistanceBasedError(LeftWinClassDis,LeftWinClassError);
[RightClassCorrData,RightClassCorrDataM] = DistanceBasedError(RightWinClassDis,RightWinClassError);
if isPlot~= 2
    save DisErrorDataAllSave.mat BetweenClassCorrData LeftClassCorrData RightClassCorrData OvatveStep StimTypesAll ...
       BetweenClassCorrDataM LeftClassCorrDataM RightClassCorrDataM -v7.3
end
%%
if isPlot
    h_sum = figure('position',[100 200 500 400]);
    hold on
    h1 = plot(BetweenClassCorrDataM(:,2)*OvatveStep,BetweenClassCorrDataM(:,1),'k-o','LineWidth',1.6);% between class distance vs error
    h2 = plot(LeftClassCorrDataM(:,2)*OvatveStep,LeftClassCorrDataM(:,1),'b-o','LineWidth',1.6); % left winthin group error
    h3 = plot(RightClassCorrDataM(:,2)*OvatveStep,RightClassCorrDataM(:,1),'r-o','LineWidth',1.6); %right within group error
    xlim([0 2.4]);
    set(gca,'xtick',BetweenClassCorrDataM(:,2)*OvatveStep);
    xlabel('Octave Difference');
    ylabel('Mean Error rate');
    title('Distance vs mean error rate plot');
    set(gca,'Fontsize',20);
    legend([h1,h2,h3],{'BetweenClass','WithinLeftClass','WithinRightClass'},'FontSize',14);
    saveas(h_sum,'Distance vs error plot save');
    saveas(h_sum,'Distance vs error plot save','png');
    close(h_sum);

    cd ..;
    cd ..;
    if isPartialROI
        cd ..;
    end
end
if nargout > 0
    OutData.ClfMtx = matrixData;
    OutData.StimsAll = StimTypesAll;
    OutData.ClfError = Class82CVErro;
    OutData.BCCD = BetweenClassCorrData;
    OutData.LCCD = LeftClassCorrData;
    OutData.RCCD = RightClassCorrData;
    OutData.OvatveStep = OvatveStep;
    OutData.BCCDM = BetweenClassCorrDataM;
    OutData.LCCDM = LeftClassCorrDataM;
    OutData.RCCDM = RightClassCorrDataM;
    varargout{1} = OutData;
end


function WithinClass = WithinCmask(ClassSize)
% input the number of components within any class, return within class mask
% for distance based error rate calculation
k = (ClassSize - 1) .* (ClassSize/2);
MaskValue = zeros(k,1);
Count = 1;
for n = 1 : ClassSize
    for m = (n+1) : ClassSize
        MaskValue(Count) = m - n;
        Count = Count + 1;
    end
end
WithinClassMask = squareform(MaskValue);
WithinClass = triu(WithinClassMask);

function BetweenClass = BetCmask(ClassSize)
% input the number of components between two class, return between class mask
% for distance based error rate calculation
% k = ClassSize^2;
BetweenClass = zeros(ClassSize);
BaseVector = (1:ClassSize)';
for nx = ClassSize : (-1) : 1
    BetweenClass(:,nx) = BaseVector + ClassSize - nx;
end

