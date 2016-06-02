%%
%this section is used for 2P data analysis
SessionTime=600;
FrameTime=600/188;
MegOnT=floor(300/FrameTime);
MegOffT=floor(420/FrameTime);
BaseOnT=floor(200/FrameTime);
ExpCondition=0;   %for control experiments, this value set to 0; for experimental group(e.g. adding drug) this value set to 1

%if there are any former analysis data, skip ROI drawing step
reloadChoice=input('Do you want to load former analysis result for plot?\n','s');
if strcmpi(reloadChoice,'y')
    [filename,filepath,index]=uigetfile('MatrixData.mat','Select your former ROI drawing data');
    if index
        x=load(fullfile(filepath,filename));
        FchangeDataAll=x.FchangeDataAll;
    else
        return;
    end
else
    %if this a new session data, draw the ROIs for the very first time
    %or you want to redraw ROIs from old session
    [RawDataAll,FchangeDataAll]=ROI_extraction_Meg_2p(FinalImage,NumberImages,h2,MegOnT,BaseOnT);
end

h_fig = plot_CaTraces_ROIs(FchangeDataAll, 1:size(FchangeDataAll,2), 1:size(FchangeDataAll,1));
set(gca,'ycolor','k');
MeanTrace=mean(FchangeDataAll);
SemTrace=std(FchangeDataAll)./sqrt(size(FchangeDataAll,1));
h_popuMean=figure;
StimPara.t_eventOn=300;
StimPara.eventDur=120;
Time=(1:size(FchangeDataAll,2))*FrameTime;
h_save=plot_meanCaTrace(MeanTrace,SemTrace,Time,h_popuMean,StimPara);
hold on;
yscale=axis;
line([BaseOnT,BaseOnT],[yscale(3),yscale(4)],'color','b','LineWidth',2);
ylabel('\DeltaF/F_0 (%)');
xlabel('Time (s)');
set(h_fig,'InvertHardcopy','off');
save_path=uigetdir(pwd,'Select current figure save path');
saveas(h_fig,sprintf('%s/Single_ROI_Trace.png',save_path));
saveas(h_fig,sprintf('%s/Single_ROI_Trace.fig',save_path));
saveas(h_popuMean,sprintf('%s/Popu_ROI_Trace.png',save_path));
saveas(h_popuMean,sprintf('%s/Popu_ROI_Trace.fig',save_path));

close(h_fig);
close(h_popuMean);

h_colorPlot=figure;
imagesc(FchangeDataAll,[0 250]);
colorbar;
%add stim info on color plot figure
y=axis;
line([MegOnT MegOnT],[y(3) y(4)],'color',[1 0 1],'LineWidth',2);
text(MegOnT,y(4)+1,'MegOn');
line([MegOffT MegOffT],[y(3) y(4)],'color',[.8 .8 .8],'LineWidth',2);
Text(MegOffT,y(4)+1,'MegOff','HorizontalAlignment','right');

XTick=0:25:size(FchangeDataAll,2);
XTickLabel=floor((XTick/NumberImages)*SessionTime);
set(gca,'xtick',XTick,'xticklabel',XTickLabel);
title('Color plot');
xlabel('Time (s)');
ylabel('\DeltaF/F_0 (%)');
saveas(h_colorPlot,'Popu_color_plot.png');
saveas(h_colorPlot,'Popu_color_plot.fig');
close(h_colorPlot);

save PopuDatSave.mat MeanTrace BaseOnT MegOnT FrameTime ExpCondition -v7.3
%%
ImageMaskSize=size(ROI_Struct(1).ROImask);
ROImaskSum=double(ROI_Struct(1).ROImask);
ROImaskSumValue=ROImaskSum*ROIbaseValue(1);

for n=2:length(ROIbaseValue)
    NewROIMask=double(ROI_Struct(n).ROImask);
    TestSumMask=ROImaskSum+NewROIMask;
    OverLapInds=find(TestSumMask==2);
    if ~isempty(OverLapInds)
        NewROIMask(OverLapInds)=false;
    end
    ROImaskSum=ROImaskSum+double(NewROIMask);
    ROImaskSumValue=NewROIMask*ROIbaseValue(n)+ROImaskSumValue;
end

%%
%plot deltaf/f live image
RawImagedata=double(FinalImage);
PlotImageData=zeros(size(RawImagedata));
ROImaskSumBaseValue=ROImaskSumValue;
ROImaskSumBaseValue(ROImaskSumBaseValue==0)=1;
mov(1:NumberImages)=struct('cdata', [],'colormap', []);
figure;
for n=1:NumberImages
    SingleFrameData=squeeze(RawImagedata(:,:,n));
    MaskData=ROImaskSum.*SingleFrameData;
    MaskData=medfilt2(MaskData,[5 5]);  %denoise, remove salt and pepper noise 
    PlotImageData(:,:,n)=((MaskData-ROImaskSumValue)./ROImaskSumBaseValue)*100;
    imshow(PlotImageData(:,:,n),[0 400],'Border','tight');
    colormap jet;
    if n>=MegOnT && n<MegOffT
        text(400,80,'MegOn','color','r','FontSize',20);
    end
    mov(n)=getframe(gcf);
    
end
AVISaveName=sprintf('Fchange_Movie%dXspeed.avi',floor(10*FrameTime));
disp('writing files into AVI files...\n');
movie2avi(mov,AVISaveName,'compression','none','fps',10);
disp('GVI files exported successfully!\n');
close(gcf);


%%
%this section is used to summarize data from different experiments and do a
%t-test

add_char='y';
ExpType=[];
DiffData=[];
m=1;
while ~strcmp(add_char,'n')
    [filename,filepath,~]=uigetfile('PopuDatSave.mat','Select your Mean Trace storage data');
    x=load(fullfile(filepath,filename));
    MeanTrace=x.MeanTrace;
    MegOnTFrame=x.MegOnT;
    BaseTFrame=x.BaseOnT;
    if ~BaseTFrame
        BaseTFrame=1;
    end
    BaseMeanV=mean(MeanTrace(BaseTFrame:MegOnTFrame));
    RespMaxValue=max(MeanTrace(MegOnTFrame:end));
    if x.ExpCondition
        %experimental group
        ExpType(m)=0;
    else
        %control group
        ExpType(m)=1;
    end
    DiffData(m)=RespMaxValue-BaseMeanV;
    m=m+1;
    add_char=input('Do you want to add another session data?\n','s');
end

ConTrolData=DiffData(ExpType==1);
ExpData=DiffData(ExpType==0);
ConTrolDataMean=mean(ConTrolData);
ExpDataMean=mean(ExpData);
ConTrolDataSEM=std(ConTrolData)/sqrt(length(ConTrolData));
ExpDataSEM=std(ExpData)/sqrt(length(ExpData));
[h,p]=ttest2(ConTrolData,ExpData);
hSummary=figure;
hold on;
scatter(ExpType,DiffData,30,[.8 .8 .8],'o','LineWidth',2);
bar([0,1],[ExpDataMean,ConTrolDataMean],'c','facealpha',0.25);
errorbar([0,1],[ExpDataMean,ConTrolDataMean],[ExpDataSEM,ConTrolDataSEM],'ko','Linewidth',2);
xlim([-0.5 1.5]);
set(gca,'xtick',[0,1],'xticklabel',{'Exp','Ctl'});
ylabel('Max2Base Diff (\DeltaF/F_0 %)');
title(sprintf('P=%.2e',p));

saveas(hSummary,'Summary plot ttest.png');
saveas(hSummary,'Summary plot ttest.fig');
save StatisticResult.mat DiffData ExpType p -v7.3
