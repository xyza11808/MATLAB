function varargout=RandNeuroMTestNew(RawDataAll,StimAll,TrialResult,AlignFrame,FrameRate,varargin)
%this function will be used to process the random data profile and try to
%create a neurometric function to compare with psychometric function
%RawDataAll should be aligned data

if ~isempty(varargin{1})
    TimeLength=varargin{1};
else
    TimeLength=1.5;
end
if nargin>6
    if ~isempty(varargin{2})
        isShuffle=varargin{2};
    else
        isShuffle=0;
    end
else
    isShuffle=0;
end
%%
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
CVScoreTypeTest1=zeros(3,3,100);
CVScoreTypeTest2=zeros(3,3,100);

if length(TimeLength) == 1
    FrameScale = sort([AlignFrame,AlignFrame+floor(TimeLength*FrameRate)]);
elseif length(TimeLength) == 2
    FrameScale = sort([AlignFrame+floor(TimeLength(1)*FrameRate),AlignFrame+floor(TimeLength(2)*FrameRate)]);
else
    warning('Input TimeLength variable have a length of %d, but it have to be 1 or 2',length(TimeLength));
    return;
end
if FrameScale(1) < 1
    warning('Time Selection excceed matrix index, correct to 1');
end
if FrameScale(2) > DataSize(3)
    warning('Time Selection excceed matrix index, correct to %d',DataSize(3));
end

ConsideringData=CorrTrialData(:,:,FrameScale(1):FrameScale(2));


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
if ~isdir('./NeuroM_test/')
    mkdir('./NeuroM_test/');
end
cd('./NeuroM_test/');

if ~isdir(sprintf('./AfterTimeLength-%dms/',TimeLength*1000))
    mkdir(sprintf('./AfterTimeLength-%dms/',TimeLength*1000));
end
cd(sprintf('./AfterTimeLength-%dms/',TimeLength*1000));

%%
for n=1:length(CorrStimType)
        TempStim=CorrStimType(n);
        SingleStimInds=CorrTrialStim==TempStim;
%         SingleStimDataAll=CorrTrialData(SingleStimInds,:,:);
%         TrialNum=size(SingleStimDataAll,1);
%         SampleTrial=randsample(TrialNum,floor(TrialNum/2));
%         RawTrialInds=zeros(1,TrialNum);
%         RawTrialInds(SampleTrial)=1;
%         RawSampleInds=logical(RawTrialInds);
%         RawTestInds=~RawSampleInds;

        SingleStimData=ConsideringData(SingleStimInds,:,:);
        TrialMeanData=squeeze(mean(SingleStimData));
        ROIMeanData=max(TrialMeanData,[],2);
        ALLROIMeanTrial(n,:)=ROIMeanData';
end
[coeff,scoreT,~,~,explainedT,~]=pca(ALLROIMeanTrial);
disp(sum(explainedT(1:3)));
ProjCoff = coeff(:,1:3);
%%
LeftStims=CorrStimType(1:length(CorrStimType)/2);
RightStims=CorrStimType((length(CorrStimType)/2+1):end);
LeftStimsStr=cellstr(num2str(LeftStims(:)));
RightStimsStr=cellstr(num2str(RightStims(:)));
h3d=figure;
hold on;
for CVNumber=1:100
    for n=1:length(CorrStimType)
        TempStim=CorrStimType(n);
        SingleStimInds=CorrTrialStim==TempStim;
        SingleStimDataAll=ConsideringData(SingleStimInds,:,:);
        TrialNum=size(SingleStimDataAll,1);
        SampleTrial=randsample(TrialNum,floor(TrialNum*0.8));
        RawTrialInds=zeros(1,TrialNum);
        RawTrialInds(SampleTrial)=1;
        RawSampleInds=logical(RawTrialInds);
        RawTestInds=~RawSampleInds;

        SingleStimData=SingleStimDataAll(RawSampleInds,:,:);
        TrialMeanData=squeeze(mean(SingleStimData));
        ROIMeanData=max(TrialMeanData,[],2);
%         ProjCoff' * (ROIMeanData - mean(ROIMeanData));
        ALLROIMeanData(n,:)=ROIMeanData';

        SingleTestData=SingleStimDataAll(RawTestInds,:,:);
        TrialTestData=squeeze(mean(SingleTestData));
        TestMeanData=max(TrialTestData,[],2);
        ALLROIMeanTestData(n,:)=TestMeanData';
    end

    % ALLROIMeanNor=zeros(length(CorrStimType),DataSize(2));
    % ROIMaxV=max(ALLROIMeanData);
    % ALLROIMeanNor=(ALLROIMeanData./repmat(ROIMaxV,length(CorrStimType),1)); %each ROI will be normalized to each ROIs max value
    % [coeff,score,latent,~,explained,~]=pca(ALLROIMeanNor);
    %
    % ALLROIMeanZsTrans=zscore(ALLROIMeanData);
    MeanSubMatrix = bsxfun(@minus,ALLROIMeanData,mean(ALLROIMeanData));
    score = MeanSubMatrix * ProjCoff;  %project the new data into same pc space
%     [coeff,score,latent,~,explained,~]=pca(ALLROIMeanData);
%     if sum(explained(1:3)) < 85
%         fprintf('Explained ratio less than 85%.\n');
%         CVNumber=CVNumber-1;
%         continue;
%     end
    MeanTestMatrix = bsxfun(@minus,ALLROIMeanTestData,mean(ALLROIMeanTestData));
    score2 = MeanTestMatrix * ProjCoff;
    CVScoreTypeTest1(:,:,CVNumber) = score2(1:3,:);
    CVScoreTypeTest2(:,:,CVNumber) = score2(4:6,:);
%     [coeff2,score2,latent2,~,explained2,~]=pca(ALLROIMeanTestData);

%     if sum(explained(1:3))<80
%         warning('The first three component explains less than 80 percents, the pca result may not acurate.');
%     end
%     save RandPcaResult.mat ALLROIMeanData coeff score latent explained -v7.3

    % Stimstr=num2str(CorrStimType);
    % StimstrCell=strsplit(Stimstr,' ');
    % h3d=figure;
    % biplot(coeff(:,1:3),'varlabels',StimstrCell);
    % grid off;
    % title('PCA score for given stimulus');
    % saveas(h3d,'Random_pcs_3d_space.png');
    % saveas(h3d,'Random_pcs_3d_space.fig');
    % close(h3d);
    % 
    % h2d=figure;
    % biplot(coeff(:,1:2),'scores',score(:,1:2),'varlabels',StimstrCell);
    % grid off;
    % title('PCA score for given stimulus');
    % saveas(h2d,'Random_pcs_2d_space.png');
    % saveas(h2d,'Random_pcs_2d_space.fig');
    % close(h2d);

    CVScoreType1(:,(1+(CVNumber-1)*3):(CVNumber*3))=score(1:3,1:3)';
    CVScoreType2(:,(1+(CVNumber-1)*3):(CVNumber*3))=score(4:6,1:3)';
%     CVScoreTypeTest1(:,(1+(CVNumber-1)*3):(CVNumber*3))=score2(1:3,1:3)';
%     CVScoreTypeTest2(:,(1+(CVNumber-1)*3):(CVNumber*3))=score2(4:6,1:3)';
%     
    % h3d=figure;
    % hold on;
    scatter3(score(1:3,1),score(1:3,2),score(1:3,3),30,'bo');
    text(score(1:3,1),score(1:3,2),score(1:3,3),LeftStimsStr);
    scatter3(score(4:6,1),score(4:6,2),score(4:6,3),30,'r*');
    text(score(4:6,1),score(4:6,2),score(4:6,3),RightStimsStr);
    
end
legend('LeftScore','RightScore','location','northeastoutside');
xlabel('pc1');
ylabel('pc2');
zlabel('pc3');
saveas(h3d,sprintf('PC_score_distribution_3d_space_%dms.png',TimeLength*1000));
saveas(h3d,sprintf('PC_score_distribution_3d_space_%dms.fig',TimeLength*1000));
close(h3d);

%%
% labelType=[zeros(1,length(CorrStimType)/2) ones(1,length(CorrStimType)/2)]';
% svmmodel=fitcsvm(score(:,1:3),labelType);
% [~,classscores]=predict(svmmodel,score(:,1:3));
% difscore=classscores(:,2)-classscores(:,1);
% fity=((difscore-min(difscore))./(max(difscore)-min(difscore)));  %rescale to [0 1]
[filename,filepath,~]=uigetfile('boundary_result.mat','Select your random plot fit result');
load(fullfile(filepath,filename));
Octavex=log2(double(CorrStimType)/min(double(CorrStimType)));
% Octavefit=Octavex;
Octavexfit=Octavex;
OctaveTest=Octavex;
realy=boundary_result.StimCorr;
realy(1:3)=1-realy(1:3);
Curve_x=linspace(min(Octavex),max(Octavex),500);
rescaleB=max(realy);
rescaleA=min(realy);

%% 
hALLL3d=figure;
hold on
scatter3(CVScoreType1(1,:),CVScoreType1(2,:),CVScoreType1(3,:),30,'bo');
scatter3(CVScoreType2(1,:),CVScoreType2(2,:),CVScoreType2(3,:),30,'r*');

labelType=[zeros(1,300) ones(1,300)]';
TrainingData=[CVScoreType1';CVScoreType2'];
CVsvmmodel=fitcsvm(TrainingData,labelType);
CVSVMModel = crossval(CVsvmmodel);  %performing cross-validation
ErrorRate=kfoldLoss(CVSVMModel);  %disp kfold loss of validation
fprintf('Error Rate = %.4f.\n',ErrorRate);

%%
% test data set performance test
LeftTypeClass = zeros(3,100);
RightTypeClass = zeros(3,100);
for nStype = 1 : (length(CorrStimType)/2)
    cLeftTestData = (squeeze(CVScoreTypeTest1(nStype,:,:)))';
    cRightTestData = (squeeze(CVScoreTypeTest2(nStype,:,:)))';
    LeftTypeClass(nStype,:) = predict(CVsvmmodel,cLeftTestData);
    RightTypeClass(nStype,:) = predict(CVsvmmodel,cRightTestData);
end
LeftErrorRate = mean(LeftTypeClass,2);
RightCorrRate = mean(RightTypeClass,2);
FitAllPoints = [LeftErrorRate',RightCorrRate'];
fityAll = (rescaleB-rescaleA)*((FitAllPoints-min(FitAllPoints))./(max(FitAllPoints)-min(FitAllPoints)))+rescaleA;
%%
% [~,classscoresT]=predict(CVsvmmodel,scoreT(:,1:3));
% difscore=classscoresT(:,2)-classscoresT(:,1);
% LogDif = log(abs(difscore));
% LogDif(1:3) = -LogDif(1:3);
% %using sampled SVM classification result to predict all Trials score
% fityAll=(rescaleB-rescaleA)*((LogDif-min(LogDif))./(max(LogDif)-min(LogDif)))+rescaleA;  %rescale to [0 1]

% %Test data set for error rate calculation
% LeftData=CVScoreTypeTest1';
% RightData = CVScoreTypeTest2';
% PredictL=predict(CVsvmmodel,LeftData);
% PredictR=predict(CVsvmmodel,RightData);
% ErrorRateTest=(sum(PredictL)+sum(1-PredictR))/(length(PredictL)+length(PredictR));  %Test data errorrate
ErrorRateTest = mean(FitAllPoints) - 0.5;

SV=CVsvmmodel.SupportVectors;
plot3(SV(:,1),SV(:,2),SV(:,3),'kp','MarkerSize',15);
legend('LeftScore','RightScore','Support Vectors','location','northeastoutside');
title(sprintf('Error rate = %.2f(CV), %.3f(Test)',ErrorRate,ErrorRateTest));
xlabel('pc1');
ylabel('pc2');
zlabel('pc3');
saveas(hALLL3d,sprintf('PC_SampleAll_distribution_3d_space_%dms.png',TimeLength*1000));
saveas(hALLL3d,sprintf('PC_SampleAll_distribution_3d_space_%dms.fig',TimeLength*1000));
close(hALLL3d);

save FinalClassificationScore.mat CVScoreType1 CVScoreType2 CVsvmmodel ErrorRate fityAll -v7.3
save TestDataSet.mat CVScoreTypeTest1 CVScoreTypeTest2 ErrorRateTest -v7.3
%%
% [~,breal]=fit_logistic(Octavex,realy);
%excludes some bad points from fit
h3=figure;
scatter(Octavex,realy,30,'MarkerEdgeColor','r','MarkerFaceColor','y');
hold on;
inds_exclude=input('please select the trial inds that should be excluded from analysis.\n','s');
if ~isempty(inds_exclude)
    inds_exclude=str2num(inds_exclude);
    octave_dist_exclude=Octavex(inds_exclude);
    reward_type_exclude=realy(inds_exclude);
    Octavex(inds_exclude)=[];
    realy(inds_exclude)=[];
    scatter(octave_dist_exclude,reward_type_exclude,100,'x','MarkerEdgeColor','b');
end

[~,breal]=fit_logistic(Octavex,realy);
close(h3);

%####################
h3=figure;

scatter(Octavexfit,fityAll,30,'MarkerEdgeColor','r','MarkerFaceColor','y');
hold on;
inds_excludefit=input('please select the trial inds that should be excluded from analysis.\n','s');
if ~isempty(inds_excludefit)
    inds_excludefit=str2num(inds_excludefit);
    octave_dist_excludefit=Octavexfit(inds_excludefit);
    reward_type_excludefit=fityAll(inds_excludefit);
    Octavexfit(inds_excludefit)=[];
    fityAll(inds_excludefit)=[];
    scatter(octave_dist_excludefit,reward_type_excludefit,100,'x','MarkerEdgeColor','b');
end

[~,bfit]=fit_logistic(Octavexfit,fityAll);
close(h3);


%##############################
% [~,bfit]=fit_logistic(Octavefit,fity');
modelfun = @(p1,t)(p1(2)./(1 + exp(-p1(3).*(t-p1(1)))));
curve_realy=modelfun(breal,Curve_x);
curve_fity=modelfun(bfit,Curve_x);
syms x
Realboundary=solve(modelfun(breal,x)==0.5,x);
Fitboundary=solve(modelfun(bfit,x)==0.5,x);

h2CompPlot=figure;
hold on;
plot(Curve_x,curve_fity,'r','LineWidth',2);
plot(Curve_x,curve_realy,'k','LineWidth',2);
scatter(Octavex,realy,40,'k','p','LineWidth',2);
scatter(Octavexfit,fityAll,40,'r','o','LineWidth',2);
text(0.1,0.9,sprintf('B=%.3f',double(Realboundary)),'Color','k','FontSize',14);
text(0.1,0.8,sprintf('B=%.3f',double(Fitboundary)),'Color','r','FontSize',14);

if ~isempty(inds_exclude)
    scatter(octave_dist_exclude,reward_type_exclude,100,'x','MarkerEdgeColor','r');
    scatter(octave_dist_exclude,reward_type_exclude,50,'p','MarkerEdgeColor','r');
end
if ~isempty(inds_excludefit)
    scatter(octave_dist_excludefit,reward_type_excludefit,100,'x','MarkerEdgeColor','m');
    scatter(octave_dist_excludefit,reward_type_excludefit,50,'o','MarkerEdgeColor','m');
end
legend('logi\_fitc','logi\_realc','Real\_data','Fit\_data','location','northeastoutside');
title('Real and fit data comparation');
xlabel('Octave');
ylabel('Rightward Choice');
ylim([0 1]);
%%
saveas(h2CompPlot,sprintf('Neuro_psycho_%dms_comp_plot.png',TimeLength*1000));
saveas(h2CompPlot,sprintf('Neuro_psycho_%dms_comp_plot.fig',TimeLength*1000));
close(h2CompPlot);
save randCurveFit.mat CVsvmmodel Octavex realy fityAll breal bfit -v7.3

% %Test test data with sample data result
% [~,Testscores]=predict(svmmodel,score2(:,1:3));
% difscoreTest=Testscores(:,2)-Testscores(:,1);
% fityTest=((difscoreTest-min(difscoreTest))./(max(difscoreTest)-min(difscoreTest)));  %rescale to [0 1]
% 
% htest=figure;
% hold on;
% scatter(OctaveTest,fityTest,30,'MarkerEdgeColor','m','MarkerFaceColor','g');
% [~,bTest]=fit_logistic(OctaveTest,fityTest');
% curve_Testy=modelfun(bTest,Curve_x);
% syms x
% Testboundary=solve(modelfun(bTest,x)==0.5,x);
% plot(Curve_x,curve_Testy,'m','LineWidth',2);
% plot(Curve_x,curve_fity,'r','LineWidth',2);
% plot(Curve_x,curve_realy,'k','LineWidth',2);
% scatter(Octavexfit,fity,40,'o','MarkerEdgeColor','r','MarkerFaceColor','g','LineWidth',2);
% scatter(Octavex,realy,40,'k','*','LineWidth',1.2);
% text(0.1,0.9,sprintf('B=%.3f',double(Testboundary)),'Color','m','FontSize',14);
% legend('TestFit\_point','logi\_Testc','Fit\_data','Real\_data','SampleFit\_point','RealData\_point','location','northeastoutside');
% title('Test Data classification');
% xlabel('Octave');
% ylabel('Rightward Choice');
% ylim([0 1]);
% saveas(htest,sprintf('Neuro_psycho_%dms_TestData_plot.png',TimeLength*1000));
% saveas(htest,sprintf('Neuro_psycho_%dms_TestData_plot.fig',TimeLength*1000));
% close(htest);

cd ..;
cd ..;
if nargout >0
    varargout{1} = realy;
end