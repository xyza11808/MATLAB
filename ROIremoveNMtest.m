function ROIremoveNMtest(InputData,TrialFreq,AlignFrame,FrameRate,varargin)
%this function will be used for remove top selective ROIs from All ROI
%population and see the change of the NeuroMetric curve change
if nargin>4
    TimeWin = varargin{1};
end
if ~exist('TimeWin','var') || isempty(TimeWin)
    TimeWin = 1.5;
end
% FrameWin = floor(TimeWin*FrameRate);

[filename,filepath,findex]=uigetfile('RandROCsave.mat','Select the data file contains ROI selectivity ROC result.');
if ~findex
    disp('No file being selected, quit function.\n');
    return;
end
yy=load(fullfile(filepath,filename));
xx=yy.ResultStrc.AUCPrefer;
ThresSelectivity = mean(yy.ResultStrc.AUCPShuffle);
AboveSratio = sum(xx > ThresSelectivity)/length(xx);
Thres = prctile(xx,80);
ROIinds=xx>Thres;
InputDataBU = InputData;
InputData(:,ROIinds,:)=[];

if ~isdir('./ROI_remove/')
    mkdir('./ROI_remove/');
end
cd('./ROI_remove/');
BehavScore=RandNeuroMTestCrossV(InputData,TrialFreq,ones(length(TrialFreq),1),AlignFrame,FrameRate,TimeWin);

CorrStimType=unique(TrialFreq);
OctaveX=log2(double(CorrStimType)/min(double(CorrStimType)));
Top20ROINum = sum(ROIinds);
AllfitData = zeros(Top20ROINum,length(unique(TrialFreq)));
ErrorRatio = zeros(Top20ROINum,1);
InputData = InputDataBU;
ColorData = jet;
ColorInds = 1:(size(ColorData,1)/Top20ROINum):size(ColorData,1);
RealInds = round(ColorInds);
hAll=figure('position',[400 150 1400 950],'PaperPositionMode','auto');
hold on;
hSpoints=figure('position',[400 150 1400 950],'PaperPositionMode','auto');
hold on;
for nIter = 1:Top20ROINum
    [~,I]=max(xx);
    LowerROIs = true(size(xx));
    LowerROIs(I) = false;
    DInputData = InputData(:,LowerROIs,:);
    
    CColorData = ColorData(RealInds(nIter),:);
    [fitresult,ErrorRatio]=ROIDecreaseNM(DInputData,TrialFreq,ones(length(TrialFreq),1),AlignFrame,FrameRate,TimeWin,BehavScore,hAll,CColorData,hSpoints);
    AllfitData(nIter,:) = fitresult;
    ErrorRatio(nIter) = ErrorRatio;
    
    xx(I)=[];
    InputData=DInputData;
end
saveas(hAll,'ROI remove plot.png');
saveas(hAll,'ROI remove plot.fig');
close(hAll);

save ROIremoveResult.mat AllfitData ErrorRatio ROIinds OctaveX -v7.3
save AboveThresValue.mat AboveSratio ThresSelectivity -v7.3
cd ..;

function [fityAll,ErrorRate]=ROIDecreaseNM(RawDataAll,StimAll,TrialResult,AlignFrame,FrameRate,TimeLength,BehavScore,hf,colorC,hs)
DataSize=size(RawDataAll);
% CorrectInds=TrialResult==1;
CorrectInds=true(1,length(TrialResult));
CorrTrialStim=StimAll(CorrectInds);
CorrTrialData=RawDataAll(CorrectInds,:,:);
CorrStimType=unique(CorrTrialStim);
ALLROIMeanData=zeros(length(CorrStimType),DataSize(2));
ALLROIMeanTrial=zeros(length(CorrStimType),DataSize(2));
ALLROIMeanTestData=zeros(length(CorrStimType),DataSize(2));
CVScoreType1=zeros(3,3*100);
CVScoreType2=zeros(3,3*100);

%%
for n=1:length(CorrStimType)
        TempStim=CorrStimType(n);
        SingleStimInds=CorrTrialStim==TempStim;
        SingleStimDataAll=CorrTrialData(SingleStimInds,:,:);
%         TrialNum=size(SingleStimDataAll,1);
%         SampleTrial=randsample(TrialNum,floor(TrialNum/2));
%         RawTrialInds=zeros(1,TrialNum);
%         RawTrialInds(SampleTrial)=1;
%         RawSampleInds=logical(RawTrialInds);
%         RawTestInds=~RawSampleInds;

        SingleStimData=SingleStimDataAll(:,:,AlignFrame:floor(AlignFrame+FrameRate*TimeLength));
        TrialMeanData=squeeze(mean(SingleStimData));
        ROIMeanData=max(TrialMeanData,[],2);
        ALLROIMeanTrial(n,:)=ROIMeanData';
end
[~,scoreT,~,~,~,~]=pca(ALLROIMeanTrial);
%#######################
for CVNumber=1:100
    for n=1:length(CorrStimType)
        TempStim=CorrStimType(n);
        SingleStimInds=CorrTrialStim==TempStim;
        SingleStimDataAll=CorrTrialData(SingleStimInds,:,:);
        TrialNum=size(SingleStimDataAll,1);
        SampleTrial=randsample(TrialNum,floor(TrialNum*0.8));
        RawTrialInds=zeros(1,TrialNum);
        RawTrialInds(SampleTrial)=1;
        RawSampleInds=logical(RawTrialInds);
        RawTestInds=~RawSampleInds;

        SingleStimData=SingleStimDataAll(RawSampleInds,:,AlignFrame:floor(AlignFrame+FrameRate*TimeLength));
        TrialMeanData=squeeze(mean(SingleStimData));
        ROIMeanData=max(TrialMeanData,[],2);
        ALLROIMeanData(n,:)=ROIMeanData';

        SingleTestData=SingleStimDataAll(RawTestInds,:,AlignFrame:floor(AlignFrame+FrameRate*TimeLength));
        TrialTestData=squeeze(mean(SingleTestData));
        TestMeanData=max(TrialTestData,[],2);
        ALLROIMeanTestData(n,:)=TestMeanData';
    end
    [~,score,latent,~,explained,~]=pca(ALLROIMeanData);
    if sum(explained(1:3))<80
        warning('The first three component explains less than 80 percents, the pca result may not acurate.');
    end

%     LeftStims=CorrStimType(1:length(CorrStimType)/2);
%     RightStims=CorrStimType((length(CorrStimType)/2+1):end);
%     LeftStimsStr=cellstr(num2str(LeftStims(:)));
%     RightStimsStr=cellstr(num2str(RightStims(:)));
    CVScoreType1(:,(1+(CVNumber-1)*3):(CVNumber*3))=score(1:3,1:3)';
    CVScoreType2(:,(1+(CVNumber-1)*3):(CVNumber*3))=score(4:6,1:3)';
    
end
Octavex=log2(double(CorrStimType)/min(double(CorrStimType)));
Octavexfit=Octavex;
Curve_x=linspace(min(Octavex),max(Octavex),500);
rescaleB=max(BehavScore);
rescaleA=min(BehavScore);

labelType=[zeros(1,300) ones(1,300)]';
TrainingData=[CVScoreType1';CVScoreType2'];
CVsvmmodel=fitcsvm(TrainingData,labelType);
CVSVMModel = crossval(CVsvmmodel);  %performing cross-validation
ErrorRate=kfoldLoss(CVSVMModel);  %disp kfold loss of validation
fprintf('Error Rate = %.4f.\n',ErrorRate);
[~,classscoresT]=predict(CVsvmmodel,scoreT(:,1:3));
difscore=classscoresT(:,2)-classscoresT(:,1);
%using sampled SVM classification result to predict all Trials score
fityAll=(rescaleB-rescaleA)*((difscore-min(difscore))./(max(difscore)-min(difscore)))+rescaleA;  %rescale to [0 1]
figure(hf);
scatter(Octavexfit,fityAll,30,colorC);
[~,bfit]=fit_logistic(Octavexfit,(fityAll(:))');
modelfun = @(p1,t)(p1(2)./(1 + exp(-p1(3).*(t-p1(1)))));
curve_fity=modelfun(bfit,Curve_x);
plot(Curve_x,curve_fity,'color',colorC,'LineWidth',1.2);

figure(hs);
scatter(Octavexfit,fityAll,30,colorC);
colorbar;

