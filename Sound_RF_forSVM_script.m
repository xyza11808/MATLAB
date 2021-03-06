%%
%loading all analysis result
clear;
clc;
ResultPath=uigetdir(pwd,'Please Select your tif file analysis result save path');
cd(ResultPath);
files=dir('*.mat');
for n=1:length(files)
    if ~isempty(strcmpi(files(n).name,'CaTrials')) || ~isempty(strfind(files(n).name,'ROIinfo'))
        load(files(n).name);
    end
end
if ~exist('CaTrials','var')
    CaTrials=SavedCaTrials;
    TrialNum=CaTrials.TrialNum;
    AllDataRaw=CaTrials.f_raw;
else
    TrialNum=length(CaTrials);
    SingleTrialSize=size(CaTrials(1).f_raw);
    AllDataRaw=uint16(zeros(TrialNum,SingleTrialSize(1),SingleTrialSize(2)));
    % if isfield(CaTrials,'RingF')
    %     for n=1:TrialNum
    %         AllDataRaw(n,:,:)=uint16(CaTrials(n).f_raw-CaTrials(n).RingF);
    %     end
    % else
    for n=1:TrialNum
        AllDataRaw(n,:,:)=uint16(CaTrials(n).f_raw);
    end
end

FrameNum=CaTrials(1).nFrames;
FrameTime=FrameNum*(CaTrials(1).FrameTime)/1000;
nROIs=CaTrials(1).nROIs;
FrameRate=floor(1000/CaTrials(1).FrameTime);
TimeTicklabel=0:5:(FrameNum/FrameRate);
TimeTick=TimeTicklabel*FrameRate;
TimeTrace=((1:FrameNum)/FrameRate);
SessionTickLable=0:50:(FrameNum/FrameRate)*TrialNum;
SessionTick=SessionTickLable*FrameRate;

if ~exist('ROIinfo','var')
    ROIinfo=ROIinfoBU;
end
[f_raw_trials,f_percent_change,exclude_inds]=FluoChangeCa2NPl(CaTrials,[],[],2,'rf',ROIinfo,[]);

[Sfname,Sfpath,~]=uigetfile('*.txt','Please Select your Sound stimuli text file');
SArray = textread(fullfile(Sfpath,Sfname));
FreqVector = SArray(:,1);
DBVector = SArray(:,2);

%%
% DBtype = unique(DBVector);
DBexludeInds = DBVector < 70;
FreqVector (DBexludeInds) = [];
f_change_consid = f_percent_change;
f_change_consid(DBexludeInds,:,:) = []; 

FreqType = unique(FreqVector);
FreqVSLabel = zeros(length(FreqType),2);
FreqVSLabel(:,1) = FreqType;

%%
BehavBoundary = 16000;
OctChange = log2((FreqType / BehavBoundary));
NoneClassiInds = abs(OctChange) > 0.1;
LeftFreqInds = OctChange <= -0.1;  %left side freq number
RightFreqInds = OctChange >= 0.1;  %Right side freq number
FreqVSLabel(RightFreqInds,2) = 1;
FreqVSLabel(~NoneClassiInds,:) = [];
ConsiderFreqLen = size(FreqVSLabel,1);
ConsiderFreq = FreqVSLabel(:,1);
OctConsider = log2(ConsiderFreq / BehavBoundary);
RFpesudoType = FreqVector > BehavBoundary;

AllDataSize = size(f_change_consid);
SVMdata = zeros(ConsiderFreqLen,AllDataSize(2),AllDataSize(3));
AllROIData = zeros(ConsiderFreqLen,AllDataSize(2));
for nType = 1 : ConsiderFreqLen
    CFreq = ConsiderFreq(nType);
    CFinds = FreqVector == CFreq;
    CRespMatrix = squeeze(mean(f_change_consid(CFinds,:,:)));
    cFreqVector = max(CRespMatrix,[],2);
    AllROIData(nType,:) = cFreqVector';
end
[coeff,scoreAll,~,~,Explain,~] = pca(AllROIData);
disp(sum(Explain(1:3)));

%%
% multi class classification analysis
% multiCClass(f_change_consid,FreqVector,ones(length(FreqVector),1),FrameRate,FrameRate,1.5)

%%
% Passive ROC analysis, and compare plot with task data
AllFreqvector = FreqVector;
DataAll = max(f_change_consid(:,:,(FrameRate+1):(FrameRate*2)),[],3);
RFTypeInds = double(AllFreqvector > BehavBoundary);

ROCvalueAll = zeros(size(DataAll,2),1);
ROCisreverse = zeros(size(DataAll,2),1);
for nnROI = 1 : size(DataAll,2)
    DataForROC = [DataAll(:,nnROI),RFTypeInds(:)];
    [ROCountROC,isreverse] = rocOnlineFoff(DataForROC);
    ROCvalueAll(nnROI) = ROCountROC;
    ROCisreverse(nnROI) = isreverse;
end
ROCvalueAllABS = ROCvalueAll;
ROCvalueAllABS(logical(ROCisreverse)) = 1 - ROCvalueAllABS(logical(ROCisreverse));
[ROCvalueSort,ROCvalueInds] = sort(ROCvalueAllABS,'descend');

h_roc = figure;
plot(ROCvalueSort,'o','LineWidth',1.8,'MarkerSize',12,'MarkerEdgeColor','k');
xlims = get(gca,'xlim');
line(xlims,[0.5 0.5],'Color',[.8 .8 .8],'LineWidth',1.8,'LineStyle','--');
xlabel('ROI rank');
ylabel('ROC value');
title('Sorted ROC rank');
%%
saveas(h_roc,'RF Ranked auc plot');
saveas(h_roc,'RF Ranked auc plot','png');
close(h_roc);

%%
% auc compare plot
[fn,fp,fi] = uigetfile('SumReaultSave.mat','Please selct your summarized data save file');
xxx = load(fullfile(fp,fn));
ROCdata2afc = xxx.SessionData.ROIauc(:);
if length(ROCdata2afc) ~= length(ROCvalueAllABS)
    ROIindex = 1 : length(ROCdata2afc);
    ROCdataRF = ROCvalueAllABS(ROIindex);
else
    ROCdataRF = ROCvalueAllABS;
end
%
h_comp = figure;
scatter(ROCdata2afc,ROCdataRF,40,'ko');
line([0 1],[0.5 0.5],'color',[.8 .8 .8],'LineWidth',1.8,'LineStyle','--');
line([0.5 0.5],[0 1],'color',[.8 .8 .8],'LineWidth',1.8,'LineStyle','--');
line([0 1],[0 1],'color',[.8 .8 .8],'LineWidth',1.8,'LineStyle','--');
xlim([0 1]);ylim([0 1]);
xlabel('2afc data auc');
ylabel('rf data auc');
[~,p] = ttest2(ROCdata2afc,ROCdataRF);
title(sprintf('P = %.2e',p));
set(gca,'FontSize',20);

save ROIrocsave.mat ROCdata2afc ROCdataRF ROCvalueAll ROCisreverse -v7.3
%%
saveas(gcf,'Task and rf auc plot');
saveas(gcf,'Task and rf auc plot','png');
close

%%
nIter = 1000;
TbyTErrorSum = zeros(nIter,1);
TbyTScoreProb = cell(nIter,1);
TbyTScoreregSum = zeros(nIter,1);
% TbyTScoreSum = zeros(nIter,2);
parfor nmnm = 1 : nIter
    TrainInds = false(length(AllFreqvector),1);
    TrainIndex = randsample(length(AllFreqvector),round(length(AllFreqvector)*0.8));
    TrainInds(TrainIndex) = true;
    TestInds = ~TrainInds;
    
    %training current classifier
    mdl = fitcsvm(DataAll(TrainInds,:),RFTypeInds(TrainInds));
    [TestResult,~] = predict(mdl,DataAll(TestInds,:));
    ErrVector = sum(abs(TestResult - RFTypeInds(TestInds)))/length(TestResult);
    TbyTErrorSum(nmnm) = ErrVector;
    
    SVMWeights = mdl.Beta;
    SVMbias = mdl.Bias;
    TrainData = DataAll(TrainInds,:);
    TrainScore = TrainData*SVMWeights + SVMbias;
    TestingDataSet = DataAll(TestInds,:);
    TestScore = TestingDataSet*SVMWeights + SVMbias;
    sp = categorical(RFTypeInds(TrainInds));
    Testsp = categorical(RFTypeInds(TestInds));
    %
    [BTrain2,~,statsTrain2,isOUTITern2] = mnrfit(TrainScore,sp);
    [pihat,~,~] = mnrval(BTrain2,TestScore,statsTrain2);
    PredTrialType=double(pihat(:,2));  % probability for current score being class one
    
    TbyTScoreProb{nmnm} = [PredTrialType,RFTypeInds(TestInds)];
    TbyTScoreregSum(nmnm) = sum(abs(PredTrialType-RFTypeInds(TestInds)))/length(PredTrialType);
%     TbyTScoreSum(nmnm,:) = TestScore;
end

h_rfError = figure('position',[230 230 1410 740]);
subplot(1,2,1);
hist(TbyTErrorSum,20);
title('Test Error rate distribution');
xlabel('Error rate');
ylabel('nIters');
set(gca,'Fontsize',20);

subplot(1,2,2)
hist(TbyTScoreregSum,20);
title('Prob error hist')
xlabel('Error rate');
ylabel('nIters');
set(gca,'Fontsize',20);

saveas(h_rfError,'RF trial by trial classification error rate');
saveas(h_rfError,'RF trial by trial classification error rate','png');
close(h_rfError);
save ErrorRateResult.mat TbyTErrorSum TbyTScoreregSum -v7.3

%%
% load behavior result
[filename,filepath,~]=uigetfile('boundary_result.mat','Select your random plot fit result');
xx=load(fullfile(filepath,filename));
BehavFreq = xx.boundary_result.StimType;
Realy = xx.boundary_result.StimCorr;
Corry = Realy;
Realy(1:3) = 1 - Realy(1:3);
BehavOctave = log2(double(BehavFreq)/BehavBoundary);
[~,breal] = fit_logistic(BehavOctave(:),Realy(:));
rescaleB = max(Realy);
rescaleA = min(Realy);

%%
% Generate SVM training dataset
RepeatNum = 100;
LeftTrainingSet = zeros(RepeatNum * sum(LeftFreqInds),3);
RightTrainingSet = zeros(RepeatNum * sum(RightFreqInds),3);
LeftTestSet = LeftTrainingSet;
RightTestSet = RightTrainingSet;
ProjCoeff = coeff(:,1:3)';
for nRepeat = 1 : RepeatNum
    for nfreq = 1 : ConsiderFreqLen
        CFreq = ConsiderFreq(nfreq);
        CFinds = FreqVector == CFreq;
        cData = f_change_consid(CFinds,:,:);
        CTnum = size(cData,1);
        SampleTrial=randsample(CTnum,floor(CTnum*0.5));
        AllTrialInds = false(CTnum,1);
        TrainInds = AllTrialInds;
        TrainInds(SampleTrial) = true;

        TrainingSet = squeeze(mean(cData(TrainInds,:,:)));
        TrainingDataSet = (max(TrainingSet,[],2));
        
        TestSet = squeeze(mean(cData(~TrainInds,:,:)));
        TestDataSet = (max(TestSet, [], 2));
        if ~FreqVSLabel(nfreq,2)
            ProjScore = ProjCoeff * (TrainingDataSet - mean(TrainingDataSet));
            LeftTrainingSet((sum(LeftFreqInds)*(nRepeat - 1)+nfreq),:) = ProjScore;
            
            ProjTestScore = ProjCoeff * (TestDataSet - mean(TestDataSet));
            LeftTestSet((sum(LeftFreqInds)*(nRepeat - 1)+nfreq),:) = ProjTestScore;
        else
            ProjScore = ProjCoeff * (TrainingDataSet - mean(TrainingDataSet));
            RightTrainingSet((sum(LeftFreqInds)*(nRepeat - 1)+nfreq),:) = ProjScore;
            
            ProjTestScore = ProjCoeff * (TestDataSet - mean(TestDataSet));
            RightTestSet((sum(LeftFreqInds)*(nRepeat - 1)+nfreq),:) = ProjTestScore;
        end
    end
end

%%
hDataset=figure('position',[250 200 1200 800]);

subplot(1,2,1)
hold on
plot3(LeftTrainingSet(:,1),LeftTrainingSet(:,2),LeftTrainingSet(:,3),'bo','MarkerSize',10,'LineWidth',1.2);
plot3(RightTrainingSet(:,1),RightTrainingSet(:,2),RightTrainingSet(:,3),'ro','MarkerSize',10,'LineWidth',1.2);
xlabel('PC1');ylabel('PC2');zlabel('PC3');
title('Traning data distribution in PCA space');

subplot(1,2,2)
hold on
plot3(LeftTestSet(:,1),LeftTestSet(:,2),LeftTestSet(:,3),'bo','MarkerSize',10,'LineWidth',0.8);
plot3(RightTestSet(:,1),RightTestSet(:,2),RightTestSet(:,3),'ro','MarkerSize',10,'LineWidth',0.8);
xlabel('PC1');ylabel('PC2');zlabel('PC3');
title('Test data distribution in PCA space');

%%
CSVNmodel = fitcsvm([LeftTrainingSet;RightTrainingSet],[zeros(size(LeftTrainingSet,1),1);ones(size(RightTrainingSet,1),1)]);
ModelLoss = kfoldLoss(crossval(CSVNmodel));
TestScore = predict(CSVNmodel,[LeftTestSet;RightTestSet]);
RealScore = [zeros(size(LeftTrainingSet,1),1);ones(size(RightTrainingSet,1),1)];
ErrorRate = sum(abs(RealScore-TestScore))/length(RealScore);
fprintf('Error Rate = %.4f.\n',ErrorRate);
suptitle(sprintf('Error Rate = %.3f',ErrorRate));
saveas(hDataset,'DataSet example plot.png');
saveas(hDataset,'DataSet example plot.fig');
close(hDataset);
%%
[~,classscoresT]=predict(CSVNmodel,scoreAll(:,1:3));
difscore=classscoresT(:,2)-classscoresT(:,1);
fityAll=(rescaleB-rescaleA)*(difscore-min(difscore))./(max(difscore)-min(difscore)) + rescaleA; 
% check whether this bad normalization is caused by one significantly large
% value on one side of the boundary


save RFpcaResult.mat fityAll OctConsider BehavFreq Corry BehavOctave -v7.3
save rfCLFmodelsave.mat LeftTestSet LeftTrainingSet RightTestSet RightTrainingSet CSVNmodel ErrorRate scoreAll -v7.3

hclass = figure;
hold on;
plot(OctConsider,fityAll,'ro', 'MarkerSize',10,'LineWidth',0.8);
plot(BehavOctave,Realy,'ko','MarkerSize',10,'LineWidth',0.8);
xlabel('Oct.Diff from boundary');
ylabel('Rightward choice');
set(gca,'fontSize',20);
title('RF data classification');
modelfun = @(p1,t)(p1(2)./(1 + exp(-p1(3).*(t-p1(1)))));
[~,bfit]=fit_logistic(OctConsider,fityAll);
Curve_x = linspace(min(OctConsider),max(OctConsider),500);
Curve_y = modelfun(bfit,Curve_x);
CurveBehavy = modelfun(breal,Curve_x);
plot(Curve_x,Curve_y,'r','LineWidth',1.6);
plot(Curve_x,CurveBehavy,'k','LineWidth',1.6)

saveas(hclass,'ScattterPlot for ROI.png');
saveas(hclass,'ScattterPlot for ROI.fig');
close(hclass);

%%
% another method to Generate SVM training dataset
RepeatNum = 100;
LeftTrainingSet = zeros(RepeatNum * sum(LeftFreqInds),3);
RightTrainingSet = zeros(RepeatNum * sum(RightFreqInds),3);
LeftTestSet = LeftTrainingSet;
RightTestSet = RightTrainingSet;
trainingRawData = zeros(ConsiderFreqLen,nROIs);
testRawData = zeros(ConsiderFreqLen,nROIs);
FreqLabel = FreqVSLabel(:,2);
RightLabelNum = sum(FreqLabel);
LeftLabelNum = length(FreqLabel) - RightLabelNum;
ProjCoeff = coeff(:,1:3)';
for nRepeat = 1 : RepeatNum
    for nfreq = 1 : ConsiderFreqLen
        CFreq = ConsiderFreq(nfreq);
        CFinds = FreqVector == CFreq;
        cData = f_change_consid(CFinds,:,:);
        CTnum = size(cData,1);
        SampleTrial=randsample(CTnum,floor(CTnum*0.8));
        AllTrialInds = false(CTnum,1);
        TrainInds = AllTrialInds;
        TrainInds(SampleTrial) = true;

        TrainingSet = squeeze(mean(cData(TrainInds,:,:)));
        TrainingDataSet = (max(TrainingSet,[],2));
        trainingRawData(nfreq,:) = TrainingDataSet;
        
        TestSet = squeeze(mean(cData(~TrainInds,:,:)));
        TestDataSet = (max(TestSet, [], 2));
        testRawData(nfreq,:) = TestDataSet;
    end
        [~,scooreTrain,~] = pca(trainingRawData);
        [~,scoreTest,~] = pca(testRawData);
        LeftTrainingSet((LeftLabelNum*(nRepeat-1)+1):(LeftLabelNum*nRepeat),:) = scooreTrain(~FreqLabel,1:3);
        RightTrainingSet((RightLabelNum*(nRepeat-1)+1):(RightLabelNum*nRepeat),:) = scooreTrain(logical(FreqLabel),1:3);
        
        LeftTestSet((LeftLabelNum*(nRepeat-1)+1):(LeftLabelNum*nRepeat),:) = scoreTest(~FreqLabel,1:3);
        RightTestSet((RightLabelNum*(nRepeat-1)+1):(RightLabelNum*nRepeat),:) = scoreTest(logical(FreqLabel),1:3);
end

hDatasetNew=figure;

subplot(1,2,1)
hold on
plot3(LeftTrainingSet(:,1),LeftTrainingSet(:,2),LeftTrainingSet(:,3),'bo','MarkerSize',10,'LineWidth',1.2);
plot3(RightTrainingSet(:,1),RightTrainingSet(:,2),RightTrainingSet(:,3),'ro','MarkerSize',10,'LineWidth',1.2);
xlabel('PC1');ylabel('PC2');zlabel('PC3');
title('Traning data distribution in PCA space');

subplot(1,2,2)
hold on
plot3(LeftTestSet(:,1),LeftTestSet(:,2),LeftTestSet(:,3),'bo','MarkerSize',10,'LineWidth',0.8);
plot3(RightTestSet(:,1),RightTestSet(:,2),RightTestSet(:,3),'ro','MarkerSize',10,'LineWidth',0.8);
xlabel('PC1');ylabel('PC2');zlabel('PC3');
title('Test data distribution in PCA space');


%%
CSVNmodel = fitcsvm([LeftTrainingSet;RightTrainingSet],[zeros(size(LeftTrainingSet,1),1);ones(size(RightTrainingSet,1),1)]);
TestScore = predict(CSVNmodel,[LeftTestSet;RightTestSet]);
RealScore = [zeros(size(LeftTrainingSet,1),1);ones(size(RightTrainingSet,1),1)];
ErrorRate = sum(abs(RealScore-TestScore))/length(RealScore);
fprintf('Error Rate = %.4f.\n',ErrorRate);

suptitle(sprintf('Erro rate = %.3f',ErrorRate));
saveas(hDatasetNew,'DataSet example plot_M2.png');
saveas(hDatasetNew,'DataSet example plot_M2.fig');

[~,classscoresT]=predict(CSVNmodel,scoreAll(:,1:3));
difscore=classscoresT(:,2)-classscoresT(:,1);
fityAll=(difscore-min(difscore))./(max(difscore)-min(difscore));
[~,bfit]=fit_logistic(OctConsider(:),fityAll(:));
modelfun = @(p1,t)(p1(2)./(1 + exp(-p1(3).*(t-p1(1)))));
octaveX = linspace(min(OctConsider),max(OctConsider),500);
FitY = modelfun(bfit,octaveX);
RealY = modelfun(breal,octaveX);
ConsiderOct = ConsiderFreq/1000;

save RFpcaResult.mat LeftTestSet LeftTrainingSet RightTestSet RightTrainingSet CSVNmodel ErrorRate scoreAll fityAll -v7.3

hclass = figure;
hold on;
plot(OctConsider,fityAll,'ro','LineWidth',2);
plot(octaveX,FitY,'r','LineWidth',2);
plot(BehavOctave,Realy,'ko','LineWidth',2);
plot(octaveX,RealY,'k','LineWidth',2);
legend('RF points','RF fit','Behav points','Behav fit','location','southeast');
legend('boxoff');
xlabel('Tone Frequency (kHz)');
ylabel('Fraction choice (R)');
ylim([0 1.1])
title('RF data fitting')
set(gca,'xtick',OctConsider,'xticklabel',cellstr(num2str(ConsiderOct(:),'%.2f')),'FontSize',20);
saveas(hclass,'ScattterPlot for ROI_M2.png');
saveas(hclass,'ScattterPlot for ROI_M2.fig');
% close(hclass);
