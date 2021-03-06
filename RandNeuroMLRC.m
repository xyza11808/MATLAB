function varargout=RandNeuroMLRC(RawDataAll,StimAll,TrialResult,AlignFrame,FrameRate,TrialType,varargin)
%this function will be used to process the random data profile and try to
%create a neurometric function to compare with psychometric function
%RawDataAll should be aligned data
%using logistic regression classifier to to the classification
% using function mnrfit for regression specifically


if ~isempty(varargin{1})
    TimeLength=varargin{1};
else
    TimeLength=1.5;
end
isShuffle=0;
if nargin>7
    if ~isempty(varargin{2})
        isShuffle=varargin{2};
    else
        isShuffle=0;
    end
end
%%
DataSize=size(RawDataAll);
% CorrectInds=TrialResult==1;
% CorrectInds=true(1,length(TrialResult));
CorrectInds=TrialResult~=2;  %exclude all miss trials
CorrTrialStim=StimAll(CorrectInds);
CorrTrialData=RawDataAll(CorrectInds,:,:);
CorrStimType=unique(CorrTrialStim);
ALLROIMeanData=zeros(length(CorrStimType),DataSize(2));
ALLROIMeanTrial=zeros(length(CorrStimType),DataSize(2));
ALLROIMeanTestData=zeros(length(CorrStimType),DataSize(2));

if length(TimeLength) == 1
    FrameScale = sort([AlignFrame,AlignFrame+floor(TimeLength*FrameRate)]);
elseif length(TimeLength) == 2
    StartTime = min(TimeLength);
    TimeScale = max(TimeLength) - min(TimeLength);
    FrameScale = sort([AlignFrame+floor(TimeLength(1)*FrameRate),AlignFrame+floor(TimeLength(2)*FrameRate)]);
else
    warning('Input TimeLength variable have a length of %d, but it have to be 1 or 2',length(TimeLength));
    return;
end
if FrameScale(1) < 1
    warning('Time Selection excceed matrix index, correct to 1');
    FrameScale(1) = 1;
end
if FrameScale(2) > DataSize(3)
    warning('Time Selection excceed matrix index, correct to %d',DataSize(3));
    FrameScale(2) = DataSize(3);
end


ConsideringData=CorrTrialData(:,:,FrameScale(1):FrameScale(2));
T8TData = max(ConsideringData,[],3);  % trial by ROI matrix, will be project by one projection vector
[TrialNum,nROI,nTrace] = size(ConsideringData);
TrialType = double(TrialType);
 UniqueFreqTypes = double(unique(CorrTrialStim));
 Octa = log2(UniqueFreqTypes/UniqueFreqTypes(1));
 CorrStimTypeTick = double(CorrStimType)/1000;
 %%
 % loading real behavior data
 [filename,filepath,~]=uigetfile('boundary_result.mat','Select your random plot fit result');
load(fullfile(filepath,filename));
Octavex=log2(double(CorrStimType)/min(double(CorrStimType)));
% Octavefit=Octavex;
% Octavexfit=Octavex;
% OctaveTest=Octavex;
realy=boundary_result.StimCorr;
realy(1:3)=1-realy(1:3);
Curve_x=linspace(min(Octavex),max(Octavex),500);
% rescaleB=max(realy);
% rescaleA=min(realy);


%%
% iteration start
% using half of the data for training, and another half for testing
try
    NumIter = 100;
    FreqScoreAll = zeros(length(CorrStimType),2,NumIter); %within second dimension, the first column indicates frequency score ...
    %, the second column indicates frequency SEM
    ClassificationData = cell(NumIter,3);
    isBadRegression = zeros(NumIter,1);
    ROISigpInds = zeros(NumIter,nROI);
    ROIWeight = zeros(NumIter,nROI);
    for niter = 1 : NumIter
        TrainingNum = ceil(TrialNum*0.5);
        TestingNum = TrialNum - TrainingNum;
        SampleInds = randsample(TrialNum,TrainingNum);

        AllTInds = false(TrialNum,1);
        AllTInds(SampleInds) = true;

        TrainingDataSet = T8TData(AllTInds,:);
        TrainingTType = TrialType(AllTInds);
        TrainingFreq = CorrTrialStim(AllTInds);

        TestingDataSet = T8TData(~AllTInds,:);
        TestingTType = TrialType(~AllTInds);
        TestingFreq = CorrTrialStim(~AllTInds);

        % using training data set to train a logistic regression classifier
        
        [BTrain,~,statsTrain,isOUTITern] = mnrfit(TrainingDataSet,categorical(TrainingTType(:)));
        MatrixWeight = BTrain(2:end);
        %  ROIbias = (statsTrain.beta(2:end))';
        MatrixScore = TrainingDataSet * MatrixWeight + BTrain(1);
        pValue = 1./(1+exp(-1.*MatrixScore));
        
         ROIpvalue = zeros(size(TrainingDataSet,2),2);
         WeightROI = zeros(size(TrainingDataSet,2),2);
         isOutROI = zeros(size(TrainingDataSet,2),1);
         for nROI = 1 : size(TrainingDataSet,2)
             CurrentROID = TrainingDataSet(:,nROI);
             [BTrain2,~,statsTrain2,isOUTITern2] = mnrfit(CurrentROID,categorical(TrainingTType(:)));
             ROIpvalue(nROI,:) = statsTrain2.p;
             WeightROI(nROI,:) =  BTrain2;
             isOutROI(nROI) = isOUTITern2;
         end
         Sigp = ROIpvalue < 0.05;
         ROISigpInds(niter,:) = (double(Sigp(:,2)))';
        ROIWeight(niter,:) = WeightROI(:,2);
        
        %testing test data set score
        %  TestMatrixScore = TestingDataSet * MatrixWeight + BTrain(1);
        [pihat,~,~] = mnrval(BTrain,TestingDataSet,statsTrain);
        PredTrialType=double(pihat(:,2));
        ErrorNum = abs(double(pihat(:,2)) - double(TestingTType)');

         UniqueFreqTypes = unique(TestingFreq);
         FreqScores = zeros(length(UniqueFreqTypes),2);
    %      FreqCI = zeros(length(UniqueFreqTypes),2);
         for nfreq = 1 : length(UniqueFreqTypes)
             cFreq = UniqueFreqTypes(nfreq);
             cFreqTrials =  TestingFreq == cFreq;
             cFreqScore = PredTrialType(cFreqTrials);
             FreqScores(nfreq,:) = [mean(cFreqScore) (std(cFreqScore)/sqrt(length(cFreqScore)))];
    %          FreqCI(nfreq,1) = mean(dlow(cFreqTrials,1));
    %          FreqCI(nfreq,2) = mean(dhi(cFreqTrials,1));
         end
         FreqScoreAll(:,:,niter) = FreqScores;
         ClassificationData(niter,:) = {{pValue},{statsTrain},{[PredTrialType;TestingTType']}};
         if isOUTITern
             isBadRegression (niter) = 1;
         end
    end
    %end of iteration
    isBadRegression = logical(isBadRegression);
    FreqScoreAll(:,:,isBadRegression) = [];
catch
%     warning('More than 30% of trials show bad classifications, quit function.\n');
     if length(TimeLength) == 1
        if ~isdir(sprintf('./LRC_classification_%dms/',TimeLength*1000))
            mkdir(sprintf('./LRC_classification_%dms/',TimeLength*1000));
        end
        cd(sprintf('./LRC_classification_%dms/',TimeLength*1000));
     else
         if ~isdir(sprintf('./LRC_classification_%dms%dmsDur/',StartTime*1000,TimeScale*1000))
            mkdir(sprintf('./LRC_classification_%dms%dmsDur/',StartTime*1000,TimeScale*1000));
        end
        cd(sprintf('./LRC_classification_%dms%dmsDur/',StartTime*1000,TimeScale*1000));
     end
         
    fileID = fopen('BAD PERFORMANCE EXIST.txt','w+');
    fprintf(fileID,'%s\n','Matrix is close to singular or badly scaled,Logistic regression cannot performed.');
    fclose(fileID);
    cd ..;
    return;
end
%%

MeanSigInds = mean(ROISigpInds);
RelatedROIs = find(MeanSigInds > 0.4);
MeanWeight = mean(ROIWeight);

h_ROISigMean = figure('position',[150 350 1500 750]);
[haxO,hline1O,hline2O] = plotyy(1:nROI,MeanSigInds,1:nROI,abs(MeanWeight));
text(RelatedROIs,MeanSigInds(RelatedROIs),cellstr(num2str(RelatedROIs(:),'%d')),'color','b','FontSize',12);
set(hline1O,'color','r','Marker','o','LineWidth',1.2);
set(hline2O,'color','b','Marker','*','LineWidth',1,'LineStyle','--');
ylabel(haxO(1),'ROI significant rate');
ylabel(haxO(2),'Abs Weight');
title('ROI weight');
xlabel('ROIs');
set(haxO(1),'FontSize',20);
set(haxO(2),'FontSize',20);

AllFreqScore = squeeze(FreqScoreAll(:,1,:));  % 6 by 100 matrix
MeanFreqScore = mean(AllFreqScore,2);
SEMfreq = std(AllFreqScore,[],2)/sqrt(NumIter-sum(isBadRegression));
[~,bLRCfit]=fit_logistic(Octa,MeanFreqScore);
% Curve_x=linspace(min(Octa),max(Octa),500);
modelfun = @(p1,t)(p1(2)./(1 + exp(-p1(3).*(t-p1(1)))));
curve_fity=modelfun(bLRCfit,Curve_x);

[~,breal]=fit_logistic(Octa,realy);
curve_realy=modelfun(breal,Curve_x);

if length(TimeLength) == 1
        if ~isdir(sprintf('./LRC_classification_%dms/',TimeLength*1000))
            mkdir(sprintf('./LRC_classification_%dms/',TimeLength*1000));
        end
        cd(sprintf('./LRC_classification_%dms/',TimeLength*1000));
else
         if ~isdir(sprintf('./LRC_classification_%dms%dmsDur/',StartTime*1000,TimeScale*1000))
            mkdir(sprintf('./LRC_classification_%dms%dmsDur/',StartTime*1000,TimeScale*1000));
        end
        cd(sprintf('./LRC_classification_%dms%dmsDur/',StartTime*1000,TimeScale*1000));
end

save ROIweight.mat MeanWeight MeanSigInds RelatedROIs -v7.3
if length(TimeLength) == 1
    saveas(h_ROISigMean,sprintf('LRC_ROI_weight_%dms',TimeLength*1000),'png');
    saveas(h_ROISigMean,sprintf('LRC_ROI_weight_%dms',TimeLength*1000),'fig');
    % saveas(h_ROISigMean,'LRC_ROI_weight','epsc');
else
    saveas(h_ROISigMean,sprintf('LRC_ROI_weight_%dms%dmsDur',StartTime*1000,TimeScale*1000),'png');
    saveas(h_ROISigMean,sprintf('LRC_ROI_weight_%dms%dmsDur',StartTime*1000,TimeScale*1000),'fig');
end

h_LRC = figure('position',[300,120,1050,1000],'PaperPositionMode','auto');
% h_PopuSEM = figure('position',[300 150 1100 900],'PaperpositionMode','auto');
hold on
[hax,hline1,hline2] = plotyy(Curve_x,curve_realy,Curve_x,curve_fity);
set(hline1,'color','k','LineWidth',2);  % behavior 
set(hline2,'color','r','LineWidth',2);  % model result
set(hax(1),'xtick',Octa,'xticklabel',cellstr(num2str(CorrStimTypeTick(:),'%.2f')),'ycolor','k','ytick',[0 0.2 0.4 0.6 0.8 1]);
set(hax(2),'ycolor','r','ytick',[0 0.2 0.4 0.6 0.8 1]);
set(hax,'FontSize',20);
ylabel(hax(1),'Fraction choice (R)');
ylabel(hax(2),'Model performance');
xlabel('Tone Frequency (kHz)');
ylim(hax(1),[-0.1 1.1]);
ylim(hax(2),[-0.1 1.1]);
xlim(hax(1),[Octa(1)-0.1 Octa(end)+0.1]);
xlim(hax(2),[Octa(1)-0.1 Octa(end)+0.1]);
title('Real and fit data comparation');
errorbar(Octa,MeanFreqScore,SEMfreq,'ro','LineWidth',1.5,'MarkerSize',10);
scatter(Octa,realy,40,'k','o','LineWidth',2);
if length(TimeLength) == 1
    saveas(h_LRC,sprintf('Neuro_psycho_%dms_Psem_plot.png',TimeLength*1000));
    saveas(h_LRC,sprintf('Neuro_psycho_%dms_Psem_plot.fig',TimeLength*1000));
else
    saveas(h_LRC,sprintf('Neuro_psycho_%dms%dmsDur_Psem_plot.png',StartTime*1000,TimeScale*1000));
    saveas(h_LRC,sprintf('Neuro_psycho_%dms%dmsDur_Psem_plot.fig',StartTime*1000,TimeScale*1000));
end
% close(h_LRC);
save ModelPlotData.mat Octa realy MeanFreqScore CorrStimTypeTick TimeLength -v7.3
%saving result
save LRCsampling.mat FreqScoreAll ClassificationData isBadRegression -v7.3
cd ..;

if nargout>0
    varargout(1) = {FreqScoreAll};
end