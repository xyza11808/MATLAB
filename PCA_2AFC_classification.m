function PCA_2AFC_classification(InputData,behavResults,varargin)
%this function is attemptting to classify 2AFC choices according to gived
%data based on pca analysis 
%XIN Yu, 10th, May, 2015

if nargin>2
    session_name=(varargin{1});
    if size(session_name,1)~=1
        session_name=session_name';
    end
    frameRate=varargin{2};
    start_frame=varargin{3};
elseif nargin<3
    session_name=datestr(now,30); 
    frameRate=55; %default value
    start_frame=28; %default value
end
if nargin>5
    ROIstd=varargin{4};
    for n=1:length(ROIstd)
        InputData(:,n,:)=InputData(:,n,:)/ROIstd(n);
    end
end
    
if nargin>6
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

if ~isdir('./align_pca_analysis/')
    mkdir('./align_pca_analysis/');
end
cd('./align_pca_analysis/');

% data_size=size(final_data);
left_trials_bingo_inds=(behavResults.Trial_Type==0 & behavResults.Time_reward>0);
right_trials_bingo_inds=(behavResults.Trial_Type==1 & behavResults.Time_reward>0);
left_erro_inds=(behavResults.Trial_Type==0 & behavResults.Action_choice~=0);
right_erro_inds=(behavResults.Trial_Type==1 & behavResults.Action_choice~=1);
left_corr_data=final_data(left_trials_bingo_inds,:,:);
right_corr_data=final_data(right_trials_bingo_inds,:,:);
left_erro_data=final_data(left_erro_inds,:,:);
right_erro_data=final_data(right_erro_inds,:,:);

left_data_size=size(left_corr_data);
right_data_size=size(right_corr_data);
left_erro_size=size(left_erro_data);
right_erro_size=size(right_erro_data);
pca_score_all=zeros((left_data_size(1)+right_data_size(1)+left_erro_size(1)+right_erro_size(1)),left_data_size(3),3);

% score_data_left=zeros(left_data_size(3),3);
for n=1:left_data_size(1)
    trans_data=permute(squeeze(left_corr_data(n,:,:)),[2 1]);%rearrange the matrix according to the order given by [], the elements of the vector indicates different dimensions of the given matrix
%     for m=1:left_data_size(2)
%         trans_data(m,:)=smooth(trans_data(m,:),11);
%     end
%     trans_data=(zscore(trans_data'))';
    [~,score,~]=pca(trans_data);
    pca_score_all(n,:,:)=score(:,1:3);
%     score_data_left=score_data_left+score(:,1:3);
end
% score_data_left=smooth(score_data_left/left_data_size(1));
% score_data_left=zeros(left_data_size(3),3);

MeanLeftData=squeeze(mean(left_corr_data));
% MeanLeftData=(zscore(MeanLeftData'))';
trans_data=permute(MeanLeftData,[2 1]);
[~,score,~]=pca(trans_data);
score_data_left=score(:,1:3);

% score_data_right=zeros(right_data_size(3),3);
for n=1:right_data_size(1)
    trans_data=permute(squeeze(right_corr_data(n,:,:)),[2 1]);
%     for m=1:right_data_size(2)
%         trans_data(m,:)=smooth(trans_data(m,:),11);
%     end
%     trans_data=(zscore(trans_data'))';
    [~,score,~]=pca(trans_data);
    pca_score_all(n+left_data_size(1),:,:)=score(:,1:3);
%     score_data_right=score_data_right+score(:,1:3);
end
% score_data_right=smooth(score_data_right/right_data_size(1));
% score_data_right=zeros(right_data_size(3),3);

MeanRightData=squeeze(mean(right_corr_data));
% MeanRightData=(zscore(MeanRightData'))';
trans_data=permute(MeanRightData,[2 1]);
[~,score,~]=pca(trans_data);
score_data_right=score(:,1:3);

% score_erro_left=zeros(left_erro_size(3),3);
for n=1:left_erro_size(1)
    trans_data=permute(squeeze(left_erro_data(n,:,:)),[2 1]);
%     for m=1:right_data_size(2)
%         trans_data(m,:)=smooth(trans_data(m,:),11);
%     end
%     trans_data=(zscore(trans_data'))';
    [~,score,~]=pca(trans_data);
    pca_score_all((n+left_data_size(1)+right_data_size(1)),:,:)=score(:,1:3);
%     score_erro_left=score_erro_left+score(:,1:3);
end
% score_erro_left=smooth(score_erro_left/left_erro_size(1));
% score_erro_left=zeros(left_erro_size(3),3);

MeanLEData=squeeze(mean(left_erro_data));
% MeanLEData=(zscore(MeanLEData'))';
trans_data=permute(MeanLEData,[2 1]);
if size(trans_data,1) < 3
    score_erro_left=zeros(size(score_data_left));
    fprintf('Left error data is less than three trials, skip pca analysis.\n');
else

    [~,score,~]=pca(trans_data);
    score_erro_left=score(:,1:3);
end

% score_erro_right=zeros(right_erro_size(3),3);
for n=1:right_erro_size(1)
    trans_data=permute(squeeze(right_erro_data(n,:,:)),[2 1]);
%     for m=1:right_data_size(2)
%         trans_data(m,:)=smooth(trans_data(m,:),11);
%     end
%     trans_data=(zscore(trans_data'))';
    [~,score,~]=pca(trans_data);
    pca_score_all((n+left_data_size(1)+right_data_size(1)+left_erro_size(1)),:,:)=score(:,1:3);
%     score_erro_right=score_erro_right+score(:,1:3);
end
% score_erro_right=smooth(score_erro_right/right_erro_size(1));
% score_erro_right=zeros(right_erro_size(3),3);

MeanREData=squeeze(mean(right_erro_data));
% MeanREData=(zscore(MeanREData'))';
trans_data=permute(MeanREData,[2 1]);
if size(trans_data,1) < 3
    score_erro_right=zeros(size(score_data_right));
    fprintf('Right error data is less than three trials, skip pca analysis.\n');
else
    [~,score,~]=pca(trans_data);
    score_erro_right=score(:,1:3);
end

h_pca=figure;
plot3(score_data_left(:,1),score_data_left(:,2),score_data_left(:,3),'color','b','LineWidth',2.5);
hold on;
plot3(score_data_right(:,1),score_data_right(:,2),score_data_right(:,3),'color','r','LineWidth',2.5);
plot3(score_erro_left(:,1),score_erro_left(:,2),score_erro_left(:,3),'color',[.8 .8 .8],'LineWidth',1.5);
plot3(score_erro_right(:,1),score_erro_right(:,2),score_erro_right(:,3),'color',[.1 .1 .1],'LineWidth',1.5);
x_start=[score_data_left(1,1),score_data_right(1,1),score_erro_left(1,1),score_erro_right(1,1)];
x_end=[score_data_left(end,1),score_data_right(end,1),score_erro_left(end,1),score_erro_right(end,1)];
y_start=[score_data_left(1,2),score_data_right(1,2),score_erro_left(1,2),score_erro_right(1,2)];
y_end=[score_data_left(end,2),score_data_right(end,2),score_erro_left(end,2),score_erro_right(end,2)];
z_start=[score_data_left(1,3),score_data_right(1,3),score_erro_left(1,3),score_erro_right(1,3)];
z_end=[score_data_left(end,3),score_data_right(end,3),score_erro_left(end,3),score_erro_right(end,3)];
x_trigger=[score_data_left(start_frame,1),score_data_right(start_frame,1),score_erro_left(start_frame,1),score_erro_right(start_frame,1)];
y_trigger=[score_data_left(start_frame,2),score_data_right(start_frame,2),score_erro_left(start_frame,2),score_erro_right(start_frame,2)];
z_trigger=[score_data_left(start_frame,3),score_data_right(start_frame,3),score_erro_left(start_frame,3),score_erro_right(start_frame,3)];
scatter3(x_start,y_start,z_start,'MarkerEdgeColor','c','MarkerFaceColor','g');
scatter3(x_end,y_end,z_end,'MarkerEdgeColor','c','MarkerFaceColor','y');
scatter3(x_trigger,y_trigger,z_trigger,'MarkerEdgeColor','r','MarkerFaceColor','c','LineWidth',2);
hold off;
legend('corr\_left','corr\_right','erro\_left','erro\_right','start','end');
title('PCA analysis result');
xlabel('PC1');ylabel('PC2');zlabel('PC3');
grid on;
saveas(h_pca,[session_name,'_PCA_3D_result'],'png');
saveas(h_pca,[session_name,'_PCA_3D_result']);
close;

h_pca3_dis=figure;
left_right_corr_dis=sqrt((score_data_left(:,1)-score_data_right(:,1)).^2+(score_data_left(:,2)-score_data_right(:,2)).^2+...
    (score_data_left(:,3)-score_data_right(:,3)).^2);
left_right_corr_disNor=left_right_corr_dis/(max(left_right_corr_dis));
left_corr_erro_dist=sqrt((score_erro_left(:,1)-score_data_left(:,1)).^2+(score_erro_left(:,2)-score_data_left(:,2)).^2+...
    (score_erro_left(:,3)-score_data_left(:,3)).^2);
left_corr_erro_dist=left_corr_erro_dist/(max(left_corr_erro_dist));
right_corr_erro_dist=sqrt((score_erro_right(:,1)-score_data_right(:,1)).^2+(score_erro_right(:,2)-score_data_right(:,2)).^2+...
    (score_erro_right(:,3)-score_data_right(:,3)).^2);
right_corr_erro_dist=right_corr_erro_dist/(max(right_corr_erro_dist));
plot(smooth(left_right_corr_disNor),'color','r');
title('PC distance between correct left and right trials');
x_tick=0:frameRate:length(left_right_corr_disNor);
x_ticklabel=x_tick/frameRate;
set(gca,'xtick',x_tick,'xticklabel',x_ticklabel);
xlabel('time(s)');
ylabel('Normalized distance');
hold on;
plot(smooth(left_corr_erro_dist),'color','g');
plot(smooth(right_corr_erro_dist),'color','c');
legend('LR\_corr\_distance','Left\_CR\_distance','Right\_CR\_distance','location','SouthEastOutside');
hh2=axis;   
triger_position=start_frame;
plot([triger_position,triger_position],[hh2(3),hh2(4)],'color',[.8 .8 .8],'LineWidth',2);
hold off;
saveas(h_pca3_dis,'Dsitance between correct left and right trials','png');
close;

h_pca2=figure;
plot(score_data_left(:,1),score_data_left(:,2),'color','b','LineWidth',2.5);
hold on;
plot(score_data_right(:,1),score_data_right(:,2),'color','r','LineWidth',2.5);
plot(score_erro_left(:,1),score_erro_left(:,2),'color',[.8 .8 .8],'LineWidth',1.5);
plot(score_erro_right(:,1),score_erro_right(:,2),'color',[.1 .1 .1],'LineWidth',1.5);
x_start=[score_data_left(1,1),score_data_right(1,1),score_erro_left(1,1),score_erro_right(1,1)];
x_end=[score_data_left(end,1),score_data_right(end,1),score_erro_left(end,1),score_erro_right(end,1)];
y_start=[score_data_left(1,2),score_data_right(1,2),score_erro_left(1,2),score_erro_right(1,2)];
y_end=[score_data_left(end,2),score_data_right(end,2),score_erro_left(end,2),score_erro_right(end,2)];
x_trigger=[score_data_left(start_frame,1),score_data_right(start_frame,1),score_erro_left(start_frame,1),score_erro_right(start_frame,1)];
y_trigger=[score_data_left(start_frame,2),score_data_right(start_frame,2),score_erro_left(start_frame,2),score_erro_right(start_frame,2)];
% z_start=[score_data_left(1,3),score_data_right(1,3),score_erro_left(1,3),score_erro_right(1,3)];
% z_end=[score_data_left(end,3),score_data_right(end,3),score_erro_left(end,3),score_erro_right(end,3)];
scatter(x_trigger,y_trigger,'MarkerEdgeColor','r','MarkerFaceColor','c','LineWidth',2);
scatter(x_start,y_start,'MarkerEdgeColor','c','MarkerFaceColor','g');
scatter(x_end,y_end,'MarkerEdgeColor','c','MarkerFaceColor','y');

hold off;
legend('corr\_left','corr\_right','erro\_left','erro\_right','start','end');
title('PCA analysis result');
xlabel('PC1');ylabel('PC2');
grid on;
saveas(h_pca2,[session_name,'_PCA_2D_result'],'png');
saveas(h_pca2,[session_name,'_PCA_2D_result']);
close;

%%
%plot of all single trial pca result together
TrialTypeNum=[left_data_size(1),right_data_size(1),left_erro_size(1),right_erro_size(1)];
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
    h_n=figure;
    hold on;
    for CurrentTNum=1:TrialTypeNum(nplot)
        CurrentPlot=squeeze(pca_score_all(AddIndsExtra+CurrentTNum,:,:));
        plot3(CurrentPlot(:,1),CurrentPlot(:,2),CurrentPlot(:,3),'color',TypeColorsST(nplot,:),'LineWidth',0.8);
    end
    CurentMean=squeeze(mean(pca_score_all((AddIndsExtra+1):(AddIndsExtra+TrialTypeNum(nplot)),:,:)));
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

% %##########################################################################################
% %comparing the shuffled data with organized data pca analysis result.
% size_scoreall=size(pca_score_all);
% if size_scoreall(1)>100
%     sample_size=100;
% elseif size_scoreall(1)>80
%     sample_size=60;
% else
%     sample_size=50;
%     disp(['The over trial number is ' num2str(size_scoreall(1)) ', this analysis result maybe not acurate.\n']);
% end
% sample_inds=randsample(1:size_scoreall(1),sample_size);
% AvgScore=squeeze(mean(pca_score_all(sample_inds,:,:)));
% LeftAvgDis=sqrt((score_data_left(:,1)-AvgScore(:,1)).^2+(score_data_left(:,2)-AvgScore(:,2)).^2+...
%     (score_data_left(:,3)-AvgScore(:,3)).^2);
% LeftAvgDis=LeftAvgDis/max(LeftAvgDis);
% RightAvgDis=sqrt((AvgScore(:,1)-score_data_right(:,1)).^2+(AvgScore(:,2)-score_data_right(:,2)).^2+...
%     (AvgScore(:,3)-score_data_right(:,3)).^2);
% RightAvgDis=RightAvgDis/max(RightAvgDis);
% h_AVG_Dis=figure;
% plot(smooth(LeftAvgDis),'color','r');
% title('PC3 distance between correct left and right trials and avg score');
% x_tick=0:frameRate:length(left_right_corr_disNor);
% x_ticklabel=x_tick/frameRate;
% set(gca,'xtick',x_tick,'xticklabel',x_ticklabel);
% xlabel('time(s)');
% ylabel('Normalized distance');
% hold on;
% plot(smooth(RightAvgDis)*(-1),'color','c');
% legend('L\_Avg\_distance','R\_Avg\_distance','location','SouthEastOutside');
% hh2=axis;   
% triger_position=start_frame;
% plot([triger_position,triger_position],[hh2(3),hh2(4)],'color',[.8 .8 .8],'LineWidth',2);
% hold off;
% saveas(h_AVG_Dis,'Dsitance of left and righttrials to Avg trace','png');
% close;
cd ..;