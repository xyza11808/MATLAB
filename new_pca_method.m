
% calculate the diff matrix between mean left and mean right data 
MeanDiffData = (MeanLeftData - MeanRightData)';
figure;imagesc(MeanDiffData');
MeanLeftData = MeanLeftData';
MeanRightData = MeanRightData';

%%
[coeffT,scoreT,~,~,explainedT,~] = pca(MeanDiffData);
fprintf('The first three PCs explains %.2f%% of total varience.\n',sum(explainedT(1:3)));

%%
LeftMeanSub = MeanLeftData - repmat(mean(MeanLeftData),size(MeanLeftData,1),1);
RightMeanSub = MeanRightData - repmat(mean(MeanRightData),size(MeanRightData,1),1);
LeftScore = LeftMeanSub * coeffT(:,1:3);
RightScore = RightMeanSub * coeffT(:,1:3);
figure;
hold on
plot3(LeftScore(:,1),LeftScore(:,2),LeftScore(:,3),'b','LineWidth',2.2);
plot3(RightScore(:,1),RightScore(:,2),RightScore(:,3),'r','LineWidth',2.2);
scatter3([LeftScore(1,1),RightScore(1,1)],[LeftScore(1,2),RightScore(1,2)],[LeftScore(1,3),RightScore(1,3)],50,'ko','LineWidth',2.2)

%%
figure;
hold on
plot(LeftScore(:,1),LeftScore(:,2),'b','LineWidth',2.2);
plot(RightScore(:,1),RightScore(:,2),'r','LineWidth',2.2);
scatter([LeftScore(1,1),RightScore(1,1)],[LeftScore(1,2),RightScore(1,2)],50,'ko','LineWidth',2.2)

%%
LRDistance = sqrt((LeftScore(:,1) - RightScore(:,1)).^2 + (LeftScore(:,2) - RightScore(:,2)).^2 + ...
    (LeftScore(:,3) - RightScore(:,3)).^2);
NorLRDistance = LRDistance / max(LRDistance);
figure;
plot(NorLRDistance);


%%
figure;
imagesc(MeanDiffData(1:37,:)');

%%
CutOffData=ThresCutoff(smooth_data,1);
PCA_2AFC_classification(CutOffData,behavResults,session_name,frame_rate,start_frame);

%%
LeftTrace = score_data_left;
RightTrace = score_data_right;
FrameNum = size(RightTrace,1);
x_trigger=[score_data_left(start_frame,1),score_data_right(start_frame,1)];
y_trigger=[score_data_left(start_frame,2),score_data_right(start_frame,2)];
z_trigger=[score_data_left(start_frame,3),score_data_right(start_frame,3)];

for nframe = 1 : FrameNum
    h_pca = figure('color','w');
    hold on;
    plot3(score_data_left(1:nframe,1),score_data_left(1:nframe,2),score_data_left(1:nframe,3),'color','b','LineWidth',2.5);
    plot3(score_data_right(1:nframe,1),score_data_right(1:nframe,2),score_data_right(1:nframe,3),'color','r','LineWidth',2.5);
    if nframe >= start_frame
        scatter3(x_trigger,y_trigger,z_trigger,'MarkerEdgeColor','k','MarkerFaceColor','c','LineWidth',2);
    end
    xlim([-100 200]);
    ylim([-80 80]);
    zlim([-40 50]);
    view([-36 40]);
    frame=getframe(h_pca);
    im=frame2im(frame);
    [I,map]=rgb2ind(im,512);
     if nframe==1
        imwrite(I,map,'Test_pca_animation.gif','Loopcount',1,'DelayTime',0.036);
    else
        imwrite(I,map,'Test_pca_animation.gif','WriteMode','append','DelayTime',0.036);
     end
     close(h_pca);
end

