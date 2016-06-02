
%%
% Old Code
close all;
[filename,filepath,~]=uigetfile('*.tif','Select yoru image file');
FileTif=fullfile(filepath,filename);
cd(filepath);
InfoImage=imfinfo(FileTif);
mImage=InfoImage(1).Width;
nImage=InfoImage(1).Height;
NumberImages=length(InfoImage);
FinalImage=zeros(nImage,mImage,NumberImages,'uint16');
BSwithdrawFim=zeros(nImage,mImage,NumberImages,'uint16');
MeanData=zeros(NumberImages,1);
for i=1:NumberImages
   RGBdata=imread(FileTif,'Index',i,'Info',InfoImage);
   if size(RGBdata,3)>1
        FinalImage(:,:,i)=uint16(squeeze(RGBdata(:,:,2)));
   else
       FinalImage(:,:,i)=(RGBdata);
   end
   tempData=(double(FinalImage(:,:,i)));
   MeanData(i)=mean(tempData(:));
   TempAdjustim=tempData-repmat(MeanData(i),nImage,mImage);
   BSwithdrawFim(:,:,i)=uint16(TempAdjustim);
end

%%
SessionTime=900;
FrameTime=900/851;
MegOnT=floor(300/FrameTime);
BaseOnT=floor(100/FrameTime);  %time


%%
%test imfilter to raw image
FilterImage=zeros(nImage,mImage,NumberImages,'uint16');
for n=1:NumberImages
    FilterImage(:,:,n)=wiener2(squeeze(FinalImage(:,:,n)),[5 5]);
end
FinalImageBU=FinalImage;
FinalImage=FilterImage;

%%
figure;
for n=1:NumberImages
    imagesc(squeeze(FinalImage(:,:,n)),[0 500]);
    title(sprintf('frame%d',n));
    colorbar;
    colormap gray;
    pause(1/50);
end


%%
%processing data using data matrix from above code
if BaseOnT==0
    BaseOnT=1;
end
im_mean=uint16(mean(FinalImage(:,:,BaseOnT:end),3));
im=im_mov_avg(FinalImage(:,:,BaseOnT:end),3);
im_Max=max(im(:,:,BaseOnT:end),[],3);
max_delta=im_Max-im_mean;


%%
%plot the delta F/F0 value
[counts,centers]=hist(double(FinalImage(:)),50);
f0=centers(counts==max(counts));
deltaF=((double(im_Max)-f0)/f0)*100;
h_Deltaf=figure;
imagesc(deltaF,[20 200]);
h_bar=colorbar;
set(get(h_bar,'Title'),'string','\DeltaF/F_0');
colormap(jet);
saveas(h_Deltaf,'Delta_fluo_plot.png');
saveas(h_Deltaf,'Delta_fluo_plot.fig');


%%
h1=figure('Name','Mean image','NumberTitle','off');
A1=imagesc(im_mean,[0 200]);
colormap gray
colorbar;

h2=figure('Name','Max_delta image','NumberTitle','off'); %this map can be used for ROI drawing
A2=imagesc(uint16((double(max_delta)/f0)*100),[0 400]);
h_bar=colorbar;
set(get(h_bar,'Title'),'string','MaxDeltaNor.');
colormap gray
saveas(h2,'Fluo_change_f.png');
saveas(h2,'Fluo_change_f.fig');

% h3=figure;
% test03=(max_delta./im_mean)*100;
% imagesc(test03);
% colorbar



%%
%this section is used for 2P data analysis
SessionTime=9;   %session time 
sessionFrames=280;
FrameTime=SessionTime/sessionFrames;
MegOnT=floor(1/FrameTime);
MegOffT=floor(2/FrameTime);
BaseOnT=floor(0/FrameTime);
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

h_colorPlot=figure('position',[220 40 1120 900],'PaperPositionMode','auto');;
colorScale=[0 300];
imagesc(FchangeDataAll,colorScale);
colorbar;
%add stim info on color plot figure
y=axis;
line([MegOnT MegOnT],[y(3) y(4)],'color',[1 0 1],'LineWidth',2);
text(MegOnT,y(3)+0.5,'MegOn','color',[1 0 1],'FontSize',8);
line([MegOffT MegOffT],[y(3) y(4)],'color',[.8 .8 .8],'LineWidth',2);
text(MegOffT,y(3)+0.5,'MegOff','HorizontalAlignment','right','color',[1 0 1],'FontSize',8);

XTick=0:50:size(FchangeDataAll,2);
XTickLabel=floor((XTick/NumberImages)*SessionTime);
set(gca,'xtick',XTick,'xticklabel',XTickLabel);
title('Color plot');
xlabel('Time (s)');
ylabel('\DeltaF/F_0 (%)');
saveas(h_colorPlot,'Popu_color_plot.png');
saveas(h_colorPlot,'Popu_color_plot.fig');
close(h_colorPlot);

save PopuDatSave.mat MeanTrace BaseOnT MegOnT FrameTime ExpCondition -v7.3

%export Mean trace data into xls file for further analysis
xlsdata1=table(MeanTrace','VariableNames',{'PopuMean'});
xlsdata2=table(BaseOnT,MegOnT,ExpCondition,'VariableNames',{'BaseOnTime','MegOnTime','Expmodu'});
xlsfilename='MeanTraceResult.xls';
writetable(xlsdata1,xlsfilename,'Sheet',1);
writetable(xlsdata2,xlsfilename,'Sheet',1,'Range','B1:D2');

%%
%for moive generation
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
FPS=10;
MegOffT=floor(420/FrameTime);
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
AVISaveName=sprintf('Fchange_Movie%dXspeed.avi',floor(FPS*FrameTime));
disp('writing files into AVI files...\n');
movie2avi(mov,AVISaveName,'compression','none','fps',FPS);
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
    h_trace=figure;
    plot(MeanTrace,'color','k','LineWidth',1.8);
    hold on;
    yscale=axis;
    line([MegOnTFrame,MegOnTFrame],[yscale(3),yscale(4)],'color','b','LineWidth',2);
    text(MegOnTFrame,0.9*yscale(4),'MegOn','color',[1 0 1]);
    ylabel('\DeltaF/F_0 (%)');
%     xlabel('Time (s)');
    [xInds,yInds]=ginput(2);  %select the maxium response range for calculation
    XIndsScale=[floor(xInds(1)),ceil(xInds(2))];
    RespMaxValue=mean(MeanTrace(XIndsScale(1):XIndsScale(2)));
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

%%
%1p data analysis

ROIData=ROI_extraction_Meg(BSwithdrawFim,NumberImages,h2);
AllROIdata=ROIData.ROIChange;
AllROIdata(ROIData.BSROI,:)=[];
h_fig = plot_CaTraces_ROIs(AllROIdata, 1:size(AllROIdata,2), 1:size(AllROIdata,1));
set(gca,'ycolor','k')
MeanTrace=mean(AllROIdata);
SemTrace=std(AllROIdata)./sqrt(size(AllROIdata,1));
h_popuMean=figure;
StimPara.t_eventOn=20;  %this place should be modified according to real condition
% StimPara.eventDur=352;  %time length of given stimuli
h_save=plot_meanCaTrace(MeanTrace,SemTrace,1:size(AllROIdata,2),h_popuMean,StimPara);
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


%%
%cumulation plot of responsive ROIs
%only maxium response time appears after stim onset time will be included
%in the plot
[MaxVa,MaxiumInds]=max(AllROIdata,[],2);
% ExcludeInds = MaxiumInds<StimPara.t_eventOn | MaxVa<10;  %Max Value less than 10% will be excluded from responsive ROIs
ExcludeInds = MaxVa<10;
RespROIMaxT=MaxiumInds;
RespROIMaxT(ExcludeInds)=[];
RespFraction=length(RespROIMaxT)/length(MaxiumInds);
h_cumuPlot=figure;
cdfplot(RespROIMaxT);
grid off;
title(sprintf('Cumulation Plot (Resp Frac.=%.2f)',RespFraction));
xlabel('Time (s)');
ylabel('Cumu Fraction');
saveas(h_cumuPlot,'Cumulation_plot.png');
saveas(h_cumuPlot,'Cumulation_plot.fig');
% close(h_cumuPlot);

%%
%this section will be used for plots of different types of modulations
TotalNum_char=input('Please input the total session number for comparation:\n','s');
TotalNum=str2num(TotalNum_char);
csize=size(jet);
cstep=csize(1)/TotalNum;
cvalue=floor(1:cstep:csize);
h_compare=figure;
hold on;
for n=1:TotalNum
    [ffnamePopu,ffpathPopu,~]=uigetfile('*.mat','choose your tif file analysis result started with FChange_Meg*');
    x=load(fullfile(ffpathPopu,ffnamePopu));
    AllROIdata=x.ROIData.ROIChange;
    AllROIdata(x.ROIData.BSROI,:)=[];
    MeanTrace=mean(AllROIdata);
    SemTrace=std(AllROIdata)./sqrt(size(AllROIdata,1));
    StimPara.t_eventOn=20;  %this place should be modified according to real condition
    h_save=plot_meanCaTrace(MeanTrace,SemTrace,1:size(AllROIdata,2),h_compare,StimPara);
    set(h_save.meanPlot,'color',jet(cvalue(n),:));
end
title('Different modulations');
save(h_compare,'Comparation_plot.png');
save(h_compare,'Comparation_plot.fig');
% close(h_compare);


%%
%sum all Meg data together in to array
% SumAllData=struct('MegValue',[],'MegData',{});
SumMegValue=[];
SumRespROIvalue={};
add_char='y';
m=1;
while ~strcmpi(add_char,'n')
    [fname,fpath,findex]=uigetfile('*.mat','Please select your previous ROI analysis result');
    if ~findex
        add_char='n';
        continue;
    end
    load(fullfile(fpath,fname));
    AddMegValue=SaveResult.MegValue;
    AddRespROIvalue=SaveResult.ROIvalueMax;
    if m==1
        SumMegValue=AddMegValue;
        SumRespROIvalue(m)={AddRespROIvalue};
    else
        if any(SumMegValue==AddMegValue)
            sameInds=find(SumMegValue==AddMegValue);
            oldsamedata=SumRespROIvalue{sameInds};
            SumRespROIvalue(sameInds)={[oldsamedata;AddRespROIvalue]};
            m=m-1;
        else
            SumMegValue=[SumMegValue AddMegValue];
            SumRespROIvalue(m)={AddRespROIvalue};
        end
    end
    m=m+1;
    add_char=input('Do you want to add another session data?\n','s');
end

[SumMegValueSort,I]=sort(SumMegValue);
SumRespROIvalueSort=SumRespROIvalue(I);

%%
%final plot
%this section will be used for analysis of population response to different
%stimulus condition
% add_char='y';
% m=1;
h_all=figure;
hold on
TickDespCell={};
MegSEMAll=[];
MegMean=[];
TickValue=[];
MegValue=[];
MegMeanAll=[];
% while ~strcmpi(add_char,'n')
%     [fname,fpath,findex]=uigetfile('*.mat','Please select your previous ROI analysis result');
%     if ~findex
%         add_char='n';
%         continue;
%     end
%     cd(fpath);
%     load(fname);
for n=1:length(SumMegValue)
    SaveResult.MegValue=SumMegValueSort(n);
    SaveResult.ROIvalueMax=SumRespROIvalueSort{n};
    if SaveResult.MegValue == -1
        disp('Meg Off test exists, put at the left side.\n');
        MegOffInds=n;
        XTICKDESP='OFF';
        TickDespCell=[{XTICKDESP} TickDespCell,];
        TickValue=[-1 TickValue];
    else
        TickDespCell=[TickDespCell,{num2str(SaveResult.MegValue)}];
        TickValue=[TickValue n];
    end
    MegValue=[MegValue SaveResult.MegValue];
%     TickValue=[TickValue m];
    MegSEM=std(SaveResult.ROIvalueMax)/sqrt(length(SaveResult.ROIvalueMax));
    MegSEMAll=[MegSEMAll MegSEM];
    MegMean=mean(SaveResult.ROIvalueMax);
    MegMeanAll=[MegMeanAll MegMean];
%     bar(SaveResult.MegValue,MegMean,0.3,'c','facealpha',0.4);
%     bar(m,MegMean,0.3,'c','facealpha',0.4);
%     scatter(ones(1,length(SaveResult.ROIvalueMax))*m,(SaveResult.ROIvalueMax)',30,[.8 .8 .8],'o','LineWidth',1.4);
%     errorbar(SaveResult.MegValue,MegMean,MegSEM,'LineWidth',2);
    if SaveResult.MegValue == -1
         bar(SaveResult.MegValue,MegMean,0.3,'c','facealpha',0.4);
         scatter(ones(1,length(SaveResult.ROIvalueMax))*(-1),(SaveResult.ROIvalueMax)',30,[.8 .8 .8],'o','LineWidth',1.4);
         errorbar(SaveResult.MegValue,MegMean,MegSEM,'LineWidth',2);
    else
        bar(n,MegMean,0.3,'c','facealpha',0.4);
        scatter(ones(1,length(SaveResult.ROIvalueMax))*n,(SaveResult.ROIvalueMax)',30,[.8 .8 .8],'o','LineWidth',1.4);
        errorbar(n,MegMean,MegSEM,'LineWidth',2);
    end
    
%     add_char=input('Do you want to add another session data?\n','s');
%     m=m+1;
end
% [CTick,CI]=sort(TickValue);
xlim([-2 length(SumMegValue)+1]);
set(gca,'xtick',TickValue,'xticklabel',TickDespCell);
xlabel('Meg, Intensity (mT)');
ylabel('Fluo change(%)');
title('Population response to different Meg stimulus');
SavePath=uigetdir(pwd,'Choose a fig save path');
saveas(h_all,sprintf('%s/Popilation_resp_plot.png',SavePath));
saveas(h_all,sprintf('%s/Popilation_resp_plot.fig',SavePath));
save(sprintf('%s/Popu_Meg_result.mat',SavePath),'MegValue','MegSEMAll','MegMeanAll','-v7.3');

%%
% Old or redount code section
% %%
% %ROI drawing
% figure(h2);
% hold on
% nROI=0;
% ROIDraw=1;
% ROI_Struct=struct('ROImask',[],'ROIposi',[],'ROIvalue',[],'ROIPixel',[]);
% while ROIDraw
%     nROI=nROI+1;
%     h_ROI=imfreehand;
%     h_mask=createMask(h_ROI);
%     h_position=getPosition(h_ROI);
%     choice = questdlg('confirm ROI drawing?','confirm ROI', 'Yes&C','Yes&E', 'Re-draw','Yes&C');
%     switch choice
%         case 'Yes&C'
%             ROI_Struct(nROI).ROImask=h_mask;
%             ROI_Struct(nROI).ROIposi=h_position;
%             delete(h_ROI);
%             ROI_pos_label(h_position,nROI,h2);
%         case 'Yes&E'
%             ROI_Struct(nROI).ROImask=h_mask;
%             ROI_Struct(nROI).ROIposi=h_position;
%             delete(h_ROI);
%             ROIDraw=0;
%             ROI_pos_label(h_position,nROI,h2);
%         case 'Re-draw'
%             nROI=nROI-1;
%             delete(h_ROI);
%         otherwise
%             disp('Quit ROI drawing.\n');
%             close all;
%     end
% end
% 
% if nROI
%     for n=1:nROI
%         ROI_Struct(n).ROIvalue=zeros(1,NumberImages);
%         ROI_Struct(n).ROIPixel=cell(1,NumberImages);
%     end
%     for m=1:NumberImages
%         TempImage=squeeze(FinalImage(:,:,m));
%         for n=1:nROI
%             nROIPixel=TempImage(ROI_Struct(n).ROImask);
%             nROIvalue=mean(nROIPixel);
%             ROI_Struct(n).ROIvalue(m)=nROIvalue;
%             ROI_Struct(n).ROIPixel(m)={nROIPixel};
%         end
%     end
% end
% clearvars nROIPixel nROIvalue
% save ROI_result_save.mat ROI_Struct -v7.3
% 
% 
% %%
% BS_ROI_char=input('Please input the BS ROI number:\n','s');
% BS_ROI=str2num(BS_ROI_char);
% BS_trace=ROI_Struct(BS_ROI).ROIvalue;
% BS_trace_diff=BS_trace-BS_trace(1);
% ROIAdjust=zeros(nROI,NumberImages);
% ROIchange=zeros(nROI,NumberImages);
% BSvalue=zeros(nROI,1);
% MaxROIValue=zeros(nROI,1);
% for n=1:nROI
%     ROIAdjust(n,:)=ROI_Struct(n).ROIvalue-BS_trace_diff;
%     [x,Value]=hist(ROIAdjust(n,:));
%     maxinds=find(double(x==max(x)),1,'first');
%     BSvalue(n)=Value(maxinds);
%     if BSvalue(n)==0
%         f0=1;
%     else
%         f0=BSvalue(n);
%     end
%     ROIchange(n,:)=(ROIAdjust(n,:)-BSvalue(n))/f0*100;
%     MaxROIValue(n)=max(ROIchange(n,:));
% end
% 
% ActiveROIMax=MaxROIValue;
% ActiveROIMax(BS_ROI)=[];
% ROI_Meg_str=input('Please input the megnatic field value:\n','s');
% ROI_Meg_value=str2num(ROI_Meg_str);
% SaveResult=struct('MegValue',ROI_Meg_value,'ROIvalueMax',ActiveROIMax,'ROIChange',ROIchange,'BSROI',BS_ROI);
% save(sprintf('FChange_Meg%dmT.mat',ROI_Meg_value),'SaveResult','-v7.3');

%%



% %%
% modebase=mode(FinalImage(:));
% f_change=double((im-modebase))/double(modebase);
% f_max=max(f_change,[],3);
% h4=figure;
% imagesc(f_max);
% colorbar;
% 
% %%
% f_change=zeros(nImage,mImage,NumberImages,'uint16'); 
% f_base=uint16(mean(FinalImage(:,:,1:10),3));
% for n=1:NumberImages
%     f_change(:,:,n)=((squeeze(FinalImage(:,:,n))-f_base)./f_base)*100;
% end
% f_max=max(f_change,[],3);
% h4=figure;
% imagesc(f_max);
% colorbar;
% 
% 
% %%
% %loading tif file into matlab matrix data
% % New Code
% FileTif='imageserials_16bit.tif';
% InfoImage=imfinfo(FileTif);
% mImage=InfoImage(1).Width;
% nImage=InfoImage(1).Height;
% NumberImages=length(InfoImage);
% FinalImage=zeros(nImage,mImage,NumberImages,'uint16'); 
%  
% TifLink = Tiff(FileTif, 'r');
% for i=1:NumberImages
%    TifLink.setDirectory(i);
%    FinalImage(:,:,i)=TifLink.read();
% end
% TifLink.close();
% 

%%##########################################################################
% called function

% function ROI_pos_label(h_position,nROI,handle)
% 
% figure(handle)
% center_position=floor(mean(h_position));
% text(center_position(1),center_position(2),num2str(nROI),'HorizontalAlignment','center');
% line(h_position(:,1),h_position(:,2),'LineWidth',1.5,'color','r');
% hold on
%%##########################################################################