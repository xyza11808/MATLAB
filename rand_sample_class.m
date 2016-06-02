function rand_sample_class(AlignedData,StartFrame,EndFrame,TrialType,TrialResult,varargin)
%this function is used for random sample of all behavior trials within a
%session and use the after-stimulus response (mean value as a considering
%value for each ROI within each trial) and PCA analysis to calculate the
%PCA score to see whether two trial types have different PCA score
%distributions in a two or three dimensional PC space
%TrialResult 0 means error trial. 1 means correct trials and 2 means
%missing trials

if nargin<6
    SessionName='Trial_specific_PC_score';
else
    SessionName=varargin{1};
end

if nargin<7 
    ConsideringTrialType='corr';  %valuable input choice: corr, erro, all, miss
else
    ConsideringTrialType=varargin{2};
    if isempty(ConsideringTrialType)
        ConsideringTrialType='corr';
    end
end
TrialResult=TrialResult';
DataSize=size(AlignedData);
if DataSize(1)~=length(TrialType) || DataSize(1)~=length(TrialResult)
    warning('trial data number if different from behavior printed result, quit analysis...');
    return;
end

LeftCorrTrial = TrialType==0 & TrialResult==1;
RightCorrTrial = TrialType==1 & TrialResult==1;
LeftErroTrial = TrialType==0 & TrialResult==0;
RightErroTrial = TrialType==1 & TrialResult==0;
% LeftMissTrial = TrialType==0 && TrialResult==2;  %currently exclude
% missing trials
% RightMissTrial = TrialType==1 && TrialResult==2;

if sum(LeftCorrTrial) < 40 || sum(RightCorrTrial < 40)
    warning('correct trial number is not that much, the final analysis result may not accurate.\n');
end
if ~isdir('./sample_pca_plot/')
    mkdir('./sample_pca_plot/');
end
cd('./sample_pca_plot/');


if strcmpi(ConsideringTrialType,'corr')
    %only correct trials will be considered
    CorrTrials=logical(LeftCorrTrial+RightCorrTrial);
    DataPoor=AlignedData(CorrTrials,:,:);
    TrialTypes=TrialType(CorrTrials);
    SelectLength=size(DataPoor,1);
    if SelectLength < 80
        warning('Trial number is not enough for random sample, quit following analysis.\n');
        return;
    end
    SamplePCAScoreL=zeros(1000,3);
    SamplePCAScoreR=zeros(1000,3);
    explainedL=zeros(1000,1);
    explainedR=zeros(1000,1);
    tic;
    for n=1:1000
        SampleInds = randsample(SelectLength,60);
        PCARawData = squeeze(mean(DataPoor(SampleInds,:,StartFrame:EndFrame),3));
        SampleType = TrialTypes(SampleInds);
        [~,score,latent,~,explained,~]=pca(PCARawData(SampleType == 0,:));
%         pareto(latent);%调用matla画图
        PCAScore=score(:,1:3);
        explainedL(n)=sum(explained(1:3));
        PCAPoint=mean(PCAScore);
        SamplePCAScoreL(n,:)=PCAPoint;
        close;
        
        [~,score,latent,~,explained,~]=pca(PCARawData(SampleType == 1,:));
%         pareto(latent);%调用matla画图
        PCAScore=score(:,1:3);
        explainedR(n)=sum(explained(1:3));
        PCAPoint=mean(PCAScore);
        SamplePCAScoreR(n,:)=PCAPoint;
        close;
    end
    t=toc;
    disp(['random sample complete in ' num2str(t) ' seconds.\n']);
    h3d=figure;
    scatter3(SamplePCAScoreL(:,1),SamplePCAScoreL(:,2),SamplePCAScoreL(:,3),15,'c','*'); %'MarkerEdgeColor','c','MarkerFaceColor','g'
    xlabel('PC1');ylabel('PC2');zlabel('PC3');
    hold on;
    grid on;
    MeanScoreL=mean(SamplePCAScoreL);
    scatter3(MeanScoreL(1),MeanScoreL(2),MeanScoreL(3),50,'r','*');
    
    scatter3(SamplePCAScoreR(:,1),SamplePCAScoreR(:,2),SamplePCAScoreR(:,3),15,'b','+');
    MeanScoreR=mean(SamplePCAScoreR);
    scatter3(MeanScoreR(1),MeanScoreR(2),MeanScoreR(3),50,'g','+');
    title('ThreeD PCA analysis result');
    legend('LeftScore','MeanLeft','RightScore','MeanRight');
    saveas(h3d,[SessionName '_3d_distribution'],'png');
    saveas(h3d,[SessionName '_3d_distribution']);
    close;
    
    h2d=figure;
    scatter(SamplePCAScoreL(:,1),SamplePCAScoreL(:,2),15,'c','*');
    xlabel('PC1');ylabel('PC2');
    hold on;
    meanscoreL=mean(SamplePCAScoreL(:,1:2));
    scatter(meanscoreL(1),meanscoreL(2),50,'r','*');
    
    scatter(SamplePCAScoreR(:,1),SamplePCAScoreR(:,2),15,'b','+');
    meanscoreR=mean(SamplePCAScoreR(:,1:2));
    scatter(meanscoreR(1),meanscoreR(2),50,'g','+');
    title('TwoD PCA analysis result');
    legend('LeftScore','MeanLeft','RightScore','MeanRight');
    saveas(h2d,[SessionName '_2d_distribution'],'png');
    saveas(h2d,[SessionName '_2d_distribution']);
    close;
    save PCA_sample_save.mat SamplePCAScoreL SamplePCAScoreR explainedL explainedR -v7.3

elseif strcmpi(ConsideringTrialType,'all')
    %all trials will result will be considered
%     CorrTrials=logical(LeftCorrTrial+RightCorrTrial);
    DataPoor=AlignedData;
    TrialTypes=TrialType;
    SelectLength=size(DataPoor,1);
    if SelectLength < 80
        warning('Trial number is not enough for random sample, quit following analysis.\n');
        return;
    end
    SamplePCAScoreL=zeros(1000,3);
    SamplePCAScoreR=zeros(1000,3);
    explainedL=zeros(1000,1);
    explainedR=zeros(1000,1);
    for n=1:1000
        SampleInds = randsample(SelectLength,60);
        PCARawData = squeeze(mean(DataPoor(SampleInds,:,StartFrame:EndFrame),3));
        SampleType = TrialTypes(SampleInds);
        [~,score,~,~,explained,~]=pca(PCARawData(SampleType == 0,:));
        PCAScore=score(:,1:3);
        explainedL(n)=sum(explained(1:3));
        PCAPoint=mean(PCAScore);
        SamplePCAScoreL(n,:)=PCAPoint;
        
        [~,score,~,~,explained,~]=pca(PCARawData(SampleType == 1,:));
        PCAScore=score(:,1:3);
        explainedR(n)=sum(explained(1:3));
        PCAPoint=mean(PCAScore);
        SamplePCAScoreR(n,:)=PCAPoint;
    end
    h3d=figure;
    scatter3(SamplePCAScoreL(:,1),SamplePCAScoreL(:,2),SamplePCAScoreL(:,3),15,'c','*'); %'MarkerEdgeColor','c','MarkerFaceColor','g'
    xlabel('PC1');ylabel('PC2');zlabel('PC3');
    hold on;
    grid on;
    MeanScoreL=mean(SamplePCAScoreL);
    scatter3(MeanScoreL(1),MeanScoreL(2),MeanScoreL(3),50,'r','*');
    
    scatter3(SamplePCAScoreR(:,1),SamplePCAScoreR(:,2),SamplePCAScoreR(:,3),15,'b','+');
    MeanScoreR=mean(SamplePCAScoreR);
    scatter3(MeanScoreR(1),MeanScoreR(2),MeanScoreR(3),50,'g','+');
    title('ThreeD PCA analysis result');
    legend('LeftScore','MeanLeft','RightScore','MeanRight');
    saveas(h3d,[SessionName '_3d_distribution'],'png');
    saveas(h3d,[SessionName '_3d_distribution']);
    close;
    
    h2d=figure;
    scatter(SamplePCAScoreL(:,1),SamplePCAScoreL(:,2),15,'c','*');
    xlabel('PC1');ylabel('PC2');
    hold on;
    meanscoreL=mean(SamplePCAScoreL(:,1:2));
    scatter(meanscoreL(1),meanscoreL(2),50,'g','*');
    
    scatter(SamplePCAScoreR(:,1),SamplePCAScoreR(:,2),15,'b','+');
    meanscoreR=mean(SamplePCAScoreR(:,1:2));
    scatter(meanscoreR(1),meanscoreR(2),50,'g','+');
    title('TwoD PCA analysis result');
    legend('LeftScore','MeanLeft','RightScore','MeanRight');
    saveas(h2d,[SessionName '_2d_distribution'],'png');
    saveas(h2d,[SessionName '_2d_distribution']);
    close;
    save PCA_sample_save.mat SamplePCAScoreL SamplePCAScoreR explainedL explainedR -v7.3
    
elseif strcmpi(ConsideringTrialType,'erro')
    %considering correct and error trials
    ConsiderTrials=logical(LeftCorrTrial+RightCorrTrial+LeftErroTrial+RightErroTrial);
    DataPoor=AlignedData(ConsiderTrials,:,:);
    TrialTypes=TrialType(ConsiderTrials);
    SelectLength=size(DataPoor,1);
    if SelectLength < 80
        warning('Trial number is not enough for random sample, quit following analysis.\n');
        return;
    end
    SamplePCAScoreL=zeros(1000,3);
    SamplePCAScoreR=zeros(1000,3);
    explainedL=zeros(1000,1);
    explainedR=zeros(1000,1);
    for n=1:1000
        SampleInds = randsample(SelectLength,60);
        PCARawData = squeeze(mean(DataPoor(SampleInds,:,StartFrame:EndFrame),3));
        SampleType = TrialTypes(SampleInds);
        [~,score,~,~,explained,~]=pca(PCARawData(SampleType == 0,:));
        PCAScore=score(:,1:3);
        explainedL(n)=sum(explained(1:3));
        PCAPoint=mean(PCAScore);
        SamplePCAScoreL(n,:)=PCAPoint;
        
        [~,score,~,~,explained,~]=pca(PCARawData(SampleType == 1,:));
        PCAScore=score(:,1:3);
        explainedR(n)=sum(explained(1:3));
        PCAPoint=mean(PCAScore);
        SamplePCAScoreR(n,:)=PCAPoint;
    end
    h3d=figure;
    scatter3(SamplePCAScoreL(:,1),SamplePCAScoreL(:,2),SamplePCAScoreL(:,3),15,'c','*'); %'MarkerEdgeColor','c','MarkerFaceColor','g'
    xlabel('PC1');ylabel('PC2');zlabel('PC3');
    hold on;
    grid on;
    MeanScoreL=mean(SamplePCAScoreL);
    scatter3(MeanScoreL(1),MeanScoreL(2),MeanScoreL(3),50,'r','*');
    
    scatter3(SamplePCAScoreR(:,1),SamplePCAScoreR(:,2),SamplePCAScoreR(:,3),15,'b','+');
    MeanScoreR=mean(SamplePCAScoreR);
    scatter3(MeanScoreR(1),MeanScoreR(2),MeanScoreR(3),50,'g','+');
    title('ThreeD PCA analysis result');
    legend('LeftScore','MeanLeft','RightScore','MeanRight');
    saveas(h3d,[SessionName '_3d_distribution'],'png');
    saveas(h3d,[SessionName '_3d_distribution']);
    close;
    
    h2d=figure;
    scatter(SamplePCAScoreL(:,1),SamplePCAScoreL(:,2),15,'c','*');
    xlabel('PC1');ylabel('PC2');
    hold on;
    meanscoreL=mean(SamplePCAScoreL(:,1:2));
    scatter(meanscoreL(1),meanscoreL(2),50,'g','*');
    
    scatter(SamplePCAScoreR(:,1),SamplePCAScoreR(:,2),15,'b','+');
    meanscoreR=mean(SamplePCAScoreR(:,1:2));
    scatter(meanscoreR(1),meanscoreR(2),50,'g','+');
    title('TwoD PCA analysis result');
    legend('LeftScore','MeanLeft','RightScore','MeanRight');
    saveas(h2d,[SessionName '_2d_distribution'],'png');
    saveas(h2d,[SessionName '_2d_distribution']);
    close;
    save PCA_sample_save.mat SamplePCAScoreL SamplePCAScoreR explainedL explainedR -v7.3
    
end

cd ..;