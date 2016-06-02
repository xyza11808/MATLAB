
for n=1:100
    h=figure;
    imagesc(rand(200,200));
    saveas(h,'test_plot.png');
    close(h);
end
drawnow



%%
DataSize=size(RawDataAll);
RespData=RawDataAll(:,:,AlignFrame:floor(AlignFrame+FrameRate*1.5));
scoreData=zeros(DataSize(1),DataSize(3),3);
h_score=figure;
hold on
for n=1:DataSize(1)
    TempData=squeeze(RawDataAll(n,:,:));
    y=zscore(TempData');
    [~,score,~,~,explained,~]=pca(y);
    plot3(smooth(score(:,1)),smooth(score(:,2)),smooth(score(:,3)));
    scoreData(n,:,:)=score(:,1:3);
end

%%
h=figure;
hold on
for n=1:length(CorrStimType)
    SingleTypeInds=CorrTrialStim==CorrStimType(n);
    SingleTypeData=squeeze(mean(scoreData(SingleTypeInds,:,:)));
    plot3(smooth(SingleTypeData(:,1)),smooth(SingleTypeData(:,2)),smooth(SingleTypeData(:,3)));
    scatter3(SingleTypeData(1,1),SingleTypeData(1,2),SingleTypeData(1,3),60,'o','MarkerEdgeColor','r');
end
