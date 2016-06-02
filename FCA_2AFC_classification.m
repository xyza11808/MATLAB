function FCA_2AFC_classification(InputData,TrialType,TrialOutcome,varargin)
%this function is attemptting to classify 2AFC choices according to gived
%data based on factor analysis analysis 
%the number of factors will be considered in this function is 8, while the
%first 2 or three factors can already explained above 90% of total variance
% so the first three factor score may already be able to show whether
% there are any spcial difference between different trial tractories.
% Inputdata should be smoothed before doing factor analysis
%XIN Yu, 10th, May, 2015

if nargin>3
    session_name=(varargin{1});
    if size(session_name,1)~=1
        session_name=session_name';
    end
    frameRate=varargin{2};
    start_frame=varargin{3};
elseif nargin<4
    session_name=datestr(now,30); 
    frameRate=55; %default value
    start_frame=29; %default value
end
if nargin>6
    ROIstd=varargin{4};
    for n=1:length(ROIstd)
        InputData(:,n,:)=InputData(:,n,:)/ROIstd(n);  %normalized by correcponded populational std
    end
end
    
if nargin>7
    ROInds_selection=1;
    ROInds_left=varargin{5};
    ROInds_right=varargin{6};
else
    ROInds_selection=0;
end

if ROInds_selection
    ROInds=unique([ROInds_left(:)',ROInds_right(:)']);
    final_data=InputData(:,ROInds,:);
else
    final_data=InputData;
end

% data preparation
LeftCorrInds = ((TrialType == 0) & (TrialOutcome == 1));
RightCorrInds = ((TrialType == 1) & (TrialOutcome == 1));
LeftErroInds = ((TrialType == 0) & (TrialOutcome == 0));
RightErroInds = ((TrialType == 1) & (TrialOutcome == 0));

LeftCorrData = final_data(LeftCorrInds ,:,:);
RightCorrData = final_data(RightCorrInds ,:,:);
LeftErroData = final_data(LeftErroInds,:,:);
RightErroData = final_data(RightErroInds,:,:);
nROI = size(final_data,2);
nTimePoints = size(final_data,3);
TimePoints = (1:nTimePoints)/frameRate;

LeftCorrNum = size(LeftCorrData,1);
RightCorrNum = size(RightCorrData,1);
LeftErroNum = size(LeftErroData,1);
RightErroNum = size(RightErroData,1);
AllFactorScore = zeros((LeftCorrNum+RightCorrNum+LeftErroNum+RightErroNum),nTimePoints,3);
AllFactorScoreNR = zeros((LeftCorrNum+RightCorrNum+LeftErroNum+RightErroNum),nTimePoints,3);  % non rotated factor score

% Correct left trials and its mean trace calculation
TrialExplainLC = zeros(LeftCorrNum,1);
BaseInds = 0;
for nTrial = 1 : LeftCorrNum
    cTdata = (squeeze(LeftCorrData(nTrial,:,:)))';   % nTimePoints by nROIs
    [lamda,~,T,~,F]=factoran(cTdata,8,'rotate','none');
    SSAll = sum(lamda.^2);
    SSfraction = SSAll/sum(SSAll);
    F3explain = sum(SSfraction(1:3));  %fraction of variance explained by first three factors
    TrialExplainLC(nTrial) = F3explain;
    AllFactorScore(BaseInds+nTrial,:,:) = F(:,1:3);
    NonrotateF = F * T';
    AllFactorScoreNR(BaseInds+nTrial,:,:) = NonrotateF(:,1:3);
end
BaseInds = BaseInds + LeftCorrNum;
MeanLCorrData = (squeeze(mean(LeftCorrData)))';
[lamda,~,T,~,F]=factoran(MeanLCorrData,8,'rotate','none');
SSAll = sum(lamda.^2);
SSfraction = SSAll/sum(SSAll);
F3explain = sum(SSfraction(1:3));
fprintf('Variance explained by first three factors is %.4f.\n',F3explain);
NonrotateF = F * T';
MeanLCorrFscore = F(:,1:3);
MeanLCorrFscoreNR = NonrotateF(:,1:3);

% correct Right trials and mean trace score
TrialExplainRC = zeros(RightCorrNum,1);
for nTrial = 1 : RightCorrNum
    cTdata = (squeeze(RightCorrData(nTrial,:,:)))';   % nTimePoints by nROIs
    [lamda,~,T,~,F]=factoran(cTdata,8,'rotate','none');
    SSAll = sum(lamda.^2);
    SSfraction = SSAll/sum(SSAll);
    F3explain = sum(SSfraction(1:3));  %fraction of variance explained by first three factors
    TrialExplainRC(nTrial) = F3explain;
    AllFactorScore(BaseInds+nTrial,:,:) = F(:,1:3);
    NonrotateF = F * T';
    AllFactorScoreNR(BaseInds+nTrial,:,:) = NonrotateF(:,1:3);
end
BaseInds = BaseInds + RightCorrNum;
MeanRCorrData = (squeeze(mean(RightCorrData)))';
[lamda,~,T,~,F]=factoran(MeanRCorrData,8,'rotate','none');
SSAll = sum(lamda.^2);
SSfraction = SSAll/sum(SSAll);
F3explain = sum(SSfraction(1:3));
fprintf('Variance explained by first three factors is %.4f.\n',F3explain);
NonrotateF = F * T';
MeanRCorrFscore = F(:,1:3);
MeanRCorrFscoreNR = NonrotateF(:,1:3);

if LeftErroNum
    % left error trials and mean trace factro analysis score
    TrialExplainLE = zeros(LeftErroNum,1);
    for nTrial = 1 : LeftErroNum
        cTdata = (squeeze(LeftErroData(nTrial,:,:)))';   % nTimePoints by nROIs
        [lamda,~,T,~,F]=factoran(cTdata,8,'rotate','none');
        SSAll = sum(lamda.^2);
        SSfraction = SSAll/sum(SSAll);
        F3explain = sum(SSfraction(1:3));  %fraction of variance explained by first three factors
        TrialExplainLE(nTrial) = F3explain;
        AllFactorScore(BaseInds+nTrial,:,:) = F(:,1:3);
        NonrotateF = F * T';
        AllFactorScoreNR(BaseInds+nTrial,:,:) = NonrotateF(:,1:3);
    end
    BaseInds = BaseInds + LeftErroNum;
    if LeftErroNum == 1
        MeanLEorrData = (squeeze(LeftErroData))';
    else
        MeanLEorrData = (squeeze(mean(LeftErroData)))';
    end
    [lamda,~,T,~,F]=factoran(MeanLEorrData,8,'rotate','none');
    SSAll = sum(lamda.^2);
    SSfraction = SSAll/sum(SSAll);
    F3explain = sum(SSfraction(1:3));
    fprintf('Variance explained by first three factors is %.4f.\n',F3explain);
    NonrotateF = F * T';
    MeanLEorrFscore = F(:,1:3);
    MeanLEorrFscoreNR = NonrotateF(:,1:3);
end

if RightErroNum
    % Right error trials and mean trace factor score
    TrialExplainLE = zeros(RightErroNum,1);
    for nTrial = 1 : RightErroNum
        cTdata = (squeeze(RightErroData(nTrial,:,:)))';   % nTimePoints by nROIs
        [lamda,~,T,~,F]=factoran(cTdata,8,'rotate','none');
        SSAll = sum(lamda.^2);
        SSfraction = SSAll/sum(SSAll);
        F3explain = sum(SSfraction(1:3));  %fraction of variance explained by first three factors
        TrialExplainLE(nTrial) = F3explain;
        AllFactorScore(BaseInds+nTrial,:,:) = F(:,1:3);
        NonrotateF = F * T';
        AllFactorScoreNR(BaseInds+nTrial,:,:) = NonrotateF(:,1:3);
    end
    BaseInds = BaseInds + RightErroNum;
    if RightErroNum == 1
        MeanREorrData = (squeeze(RightErroData))';
    else
        MeanREorrData = (squeeze(mean(RightErroData)))';
    end
    [lamda,~,T,~,F]=factoran(MeanREorrData,8,'rotate','none');
    SSAll = sum(lamda.^2);
    SSfraction = SSAll/sum(SSAll);
    F3explain = sum(SSfraction(1:3));
    fprintf('Variance explained by first three factors is %.4f.\n',F3explain);
    NonrotateF = F * T';
    MeanREorrFscore = F(:,1:3);
    MeanREorrFscoreNR = NonrotateF(:,1:3);
end

if ~isdir('./factor analysis trajectory/')
    mkdir('./factor analysis trajectory/');
end
cd('./factor analysis trajectory/');

save FactorScore.mat MeanLCorrFscore MeanLCorrFscoreNR MeanRCorrFscore MeanRCorrFscoreNR ...
    MeanREorrFscore MeanREorrFscoreNR -v7.3 
save F3V_explained.mat TrialExplainLC TrialExplainRC TrialExplainLE TrialExplainLE -v7.3 
%%
% start plotting of all trace
h_tracePlot = figure('position',[110,70,1700,1000],'PaperPositionMode','auto');  % only correct left and left trials will be plotted
% plot of the mean trace, in 3d
subplot(1,3,[1,2]);
hold on
plot3(MeanLCorrFscore(:,1),MeanLCorrFscore(:,2),MeanLCorrFscore(:,3),'b','LineWidth',1.2);  %specific color for meanleft trace
plot3(MeanRCorrFscore(:,1),MeanRCorrFscore(:,2),MeanRCorrFscore(:,3),'r','LineWidth',1.2);  %specific color for meanright trace
plot3(MeanLCorrFscore(1,1),MeanLCorrFscore(1,2),MeanLCorrFscore(1,3),'g*','LineWidth',1.2,'MarkerSize',10);  % left Trial start time score
plot3(MeanLCorrFscore(start_frame,1),MeanLCorrFscore(start_frame,2),MeanLCorrFscore(start_frame,3),'co','LineWidth',1.2,'MarkerSize',10);  % left Stim start time score
plot3(MeanRCorrFscore(1,1),MeanRCorrFscore(1,2),MeanRCorrFscore(1,3),'g*','LineWidth',1.2,'MarkerSize',10);  % right Trial start time score
plot3(MeanRCorrFscore(start_frame,1),MeanRCorrFscore(start_frame,2),MeanRCorrFscore(start_frame,3),'co','LineWidth',1.2,'MarkerSize',10);  % right Stim start time score
legend('Left Corr Data','Right Corr Data','Location','northwest');
legend('boxoff');
xlabel('x_1');ylabel('x_2');zlabel('x_3');
title('mean Trial score of first three factor');

subplot(1,3,3);
% Euclidean distances
Type1Dis = MeanLCorrFscore;
Type2Dis = MeanRCorrFscore;
EDis = sqrt(sum((Type2Dis - Type1Dis).^2,2));
plot(TimePoints,EDis,'k');
yaxis = axis;
line([start_frame start_frame]/frameRate,[yaxis(3) yaxis(4)],'color',[.8 .8 .8],'LineWidth',1.2);
text(((start_frame/frameRate)+0.1), 0.8*yaxis(4), 'StimOnset', 'color','r');
xlabel('Time(s)');
ylabel('L2R distance');
title('Trial Type distance')
saveas(h_tracePlot,'Mean trace plot and trace distance.png');
saveas(h_tracePlot,'Mean trace plot and trace distance.fig');
% close(h_tracePlot);

%%
% plot of all traces corresponded to four different trial types, in
% individual 
TrialTypeNum=[LeftCorrNum, RightCorrNum, LeftErroNum, RightErroNum];
TypeColorsST=[0 0 1 0.2;...    %color blue for single left trial plot
            1 0 0 0.2;...    %color red for single right trial plot
            0 0 0.7 0.2;...  %color dark-red for single trial plot
            0.2 0.2 0.2 0.2];%color shadow-black for single trial plot
TypeColor={'b','r',[0.7 0 0],[0.7 0.7 0.7]};
TypeDesp={'LeftCorr','RightCorr','LeftErro','RightErro'};
for nplot=1:4
    if nplot==1
        AddIndsExtra=0;
    else
        AddIndsExtra=sum(TrialTypeNum(1:(nplot-1)));
    end
    h_n = figure('position',[500,200,1200,900],'PaperPositionMode','auto');  % only correct left and left trials will be plotted
    hold on;
    for CurrentTNum=1:TrialTypeNum(nplot)
        CurrentPlot=squeeze(AllFactorScore(AddIndsExtra+CurrentTNum,:,:));
        plot3(CurrentPlot(:,1),CurrentPlot(:,2),CurrentPlot(:,3),'color',TypeColorsST(nplot,:),'LineWidth',0.6);
    end
    CurentMean=squeeze(mean(AllFactorScore((AddIndsExtra+1):(AddIndsExtra+TrialTypeNum(nplot)),:,:)));
    if size(CurentMean,2) == 1
        CurentMean = CurentMean';
    end
    plot3(CurentMean(:,1),CurentMean(:,2),CurentMean(:,3),'color',TypeColor{nplot},'LineWidth',2.5);
    xlabel('PC1');ylabel('PC2');zlabel('PC3');
    title(sprintf('%s All plot',TypeDesp{nplot}));
    saveas(h_n,sprintf('SingleTrial pca plot %s.png',TypeDesp{nplot}));
    saveas(h_n,sprintf('SingleTrial pca plot %s.fig',TypeDesp{nplot}));
    close(h_n);
end

%%
% plot the left and right correct trials trace all together
h_n = figure('position',[250,200,1200,900],'PaperPositionMode','auto');  % all left and Right trials will be plotted
hold on;
TrialTypeNum=[LeftCorrNum, RightCorrNum, LeftErroNum, RightErroNum];
TypeColorsST=[0 0 1 0.2;...    %color blue for single left trial plot
            1 0 0 0.2;...    %color red for single right trial plot
            0 0 0.7 0.2;...  %color dark-red for single trial plot
            0.2 0.2 0.2 0.2];%color shadow-black for single trial plot
TypeColor={'b','r',[0.7 0 0],[0.7 0.7 0.7]};
TypeDesp={'LeftCorr','RightCorr','LeftErro','RightErro'};
for nplot=1:2
    if nplot==1
        AddIndsExtra=0;
    else
        AddIndsExtra=sum(TrialTypeNum(1:(nplot-1)));
    end
    for CurrentTNum=1:TrialTypeNum(nplot)
        CurrentPlot=squeeze(AllFactorScore(AddIndsExtra+CurrentTNum,:,:));
        plot3(CurrentPlot(:,1),CurrentPlot(:,2),CurrentPlot(:,3),'color',TypeColorsST(nplot,:),'LineWidth',0.6);
    end
    CurentMean=squeeze(mean(AllFactorScore((AddIndsExtra+1):(AddIndsExtra+TrialTypeNum(nplot)),:,:)));
    if size(CurentMean,2) == 1
        CurentMean = CurentMean';
    end
    plot3(CurentMean(:,1),CurentMean(:,2),CurentMean(:,3),'color',TypeColor{nplot},'LineWidth',2.5);
    xlabel('PC1');ylabel('PC2');zlabel('PC3');
    
end
 title('LRcorr All plot');
saveas(h_n,'SingleTrial pca plot LRcorr.png');
saveas(h_n,'SingleTrial pca plot LRcorr.fig');
% close(h_n);

%%
cd ..;