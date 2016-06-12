function TimeCorseROC(AlignedData,Trial_Type,alignpoint,FrameRate,varargin)
%this function will calculate ROC change as a function of time, and using
%each time bin ROC calculation result to do the final plot

if isempty(varargin) || isempty(varargin{1})
    TimeBins=100;  %ms
else
    TimeBins=varargin{1};
end
if nargin > 5 && ~isempty(varargin{2})
    CUplot = sign(varargin{2});   %positive value for Seperate bin plot
    %     PlotDesp = 'CU';
else
    CUplot = 0;
end
PlotDespStr = {'CU','SP'};
PlotDesp = PlotDespStr{CUplot+1};

FrameBin=floor((TimeBins/1000)*FrameRate);
DatSize=size(AlignedData);

if ~isdir('./TimeFunROC_Plot/')
    mkdir('./TimeFunROC_Plot/');
end
cd('./TimeFunROC_Plot/');

LeftTrialInds=Trial_Type==0;
RIghtTrialInds=Trial_Type==1;
%considering 2s time after stim onset
BinLength=floor((DatSize(3))/FrameBin);  %bin length
% BaseBInLength=floor(alignpoint/FrameBin);
BINNEDROCResultLR=zeros(DatSize(2),BinLength);
% % BINNEDROCResultLB=zeros(DatSize(2),BinLength+BaseBInLength);
% % BINNEDROCResultRB=zeros(DatSize(2),BinLength+BaseBInLength);

% BINNEDROCResultLBP2=zeros(DatSize(2),BaseBInLength);
% BINNEDROCResultLBP1=zeros(DatSize(2),BinLength);
% BINNEDROCResultRBP2=zeros(DatSize(2),BaseBInLength);
% BINNEDROCResultRBP1=zeros(DatSize(2),BinLength);

if ~CUplot
    %##################
    % cumulate time bin ROC calculation
    parfor ROInum=1:DatSize(2)
        TempROIData=squeeze(AlignedData(:,ROInum,:));
        %     BasePoints=TempROIData(:,1:alignpoint);
        %     BaseDataFORroc=[BasePoints(:),2*ones(numel(BasePoints),1)];
        for BINNum=1:BinLength
            LeftPoints=TempROIData(LeftTrialInds,1:(alignpoint+BINNum*FrameBin));
            RightPoints=TempROIData(RIghtTrialInds,1:(alignpoint+BINNum*FrameBin));
            LeftPointsMax = max(LeftPoints,[],2);
            RightPointsMax = max(RightPoints,[],2);
            % LeftPoints=TempROIData(LeftTrialInds,1:(BINNum*FrameBin);
            % RightPoints=TempROIData(RIghtTrialInds,1:(BINNum*FrameBin));
            
            LeftDataFORroc=[LeftPointsMax(:),zeros(numel(LeftPointsMax),1)];
            RightDataFORroc=[RightPointsMax(:),ones(numel(RightPointsMax),1)];
            % BaseDataFORroc=[BasePoints(:),2*ones(numel(BasePoints),1)];
            [dataBIN,LMMean]=rocOnlineFoff([LeftDataFORroc;RightDataFORroc]);
            if LMMean
                dataBIN = 1 - dataBIN;
            end
            BINNEDROCResultLR(ROInum,BINNum)=dataBIN;
            
            %         [dataBINLB,~]=rocOnlineFoff([LeftDataFORroc;BaseDataFORroc]);
            %         BINNEDROCResultLBP1(ROInum,BINNum)=dataBINLB;
            %
            %         [dataBINRB,~]=rocOnlineFoff([RightDataFORroc;BaseDataFORroc]);
            %         BINNEDROCResultRBP1(ROInum,BINNum)=dataBINRB;
        end
        %     for BaseBinNum=1:BaseBInLength
        %         LeftBaseBINPoints=TempROIData(LeftTrialInds,1:(BaseBinNum*FrameBin));
        %         LeftBaseFORroc=[LeftBaseBINPoints(:),zeros(numel(LeftBaseBINPoints),1)];
        %
        %         RightBaseBINPoints=TempROIData(RIghtTrialInds,1:(BaseBinNum*FrameBin));
        %         RightBaseFORroc=[RightBaseBINPoints(:),ones(numel(RightBaseBINPoints),1)];
        %
        %         [dataBINLBB,~]=rocOnlineFoff([LeftBaseFORroc;BaseDataFORroc]);
        %         BINNEDROCResultLBP2(ROInum,BaseBinNum)=dataBINLBB;
        %
        %         [dataBINRBB,~]=rocOnlineFoff([RightBaseFORroc;BaseDataFORroc]);
        %         BINNEDROCResultRBP2(ROInum,BaseBinNum)=dataBINRBB;
        %     end
        
    end
    clearvars TempROIData LeftPoints RightPoints LeftDataFORroc RightDataFORroc
    % BINNEDROCResultLB=[BINNEDROCResultLBP2,BINNEDROCResultLBP1];
    % BINNEDROCResultRB=[BINNEDROCResultRBP2,BINNEDROCResultRBP1];
else
    % %##################
    % % Seperate time bin ROC calculation
%     BINNEDROCResultLRSP=zeros(DatSize(2),BinLength);
    parfor ROInum=1:DatSize(2)
        TempROIData=squeeze(AlignedData(:,ROInum,:));
        for BINNum=1:BinLength
            LeftPoints=TempROIData(LeftTrialInds,(((BINNum-1)*FrameBin)+1):(alignpoint+BINNum*FrameBin));
            RightPoints=TempROIData(RIghtTrialInds,(((BINNum-1)*FrameBin)+1):(alignpoint+BINNum*FrameBin));
             LeftPointsMax = max(LeftPoints,[],2);
            RightPointsMax = max(RightPoints,[],2);
            
            LeftDataFORroc=[LeftPointsMax(:),zeros(numel(LeftPointsMax),1)];
            RightDataFORroc=[RightPointsMax(:),ones(numel(RightPointsMax),1)];
            [dataBIN,LMMean]=rocOnlineFoff([LeftDataFORroc;RightDataFORroc]);
            if LMMean
                dataBIN = 1 - dataBIN;
            end
            BINNEDROCResultLR(ROInum,BINNum)=dataBIN;
        end
    end
    clearvars TempROIData LeftPoints RightPoints LeftDataFORroc RightDataFORroc
end

PXtick=alignpoint:FrameBin:(DatSize(3));
AlignTime=alignpoint/FrameRate;
PXtick(1)=[];
PXtickTime=PXtick/FrameRate;
PXtickAfter = PXtick;

FolderName = sprintf('./LR_ROC_timeFun%s/',PlotDesp);
if ~isdir(FolderName)
    mkdir(FolderName);
end
cd(FolderName);

for ROInum=1:DatSize(2)
    hROI=figure;
    plot(PXtickTime,BINNEDROCResultLR(ROInum,:),'r-o','LineWidth',2);
    line([AlignTime AlignTime],[0 1],'color',[.8 .8 .8],'LineWidth',1.8);
    %     set(gca,'xticklabel',cellstr(num2str(PXtickTime(:),'%.1f')),'FontSize',12);
    x=get(gca,'xlim');
    xlim([0 x(2)]);
    line([0 x(2)],[0.5 0.5],'color','g','LineWidth',1.8,'LineStyle','--');
    xlabel('Time (s)');
    ylabel('ROC value');
    title(sprintf('ROI%d plot',ROInum),'FontSize',14);
    saveas(hROI,sprintf('ROI%d time binROC plot.png',ROInum));
    saveas(hROI,sprintf('ROI%d time binROC plot.fig',ROInum));
    close(hROI);
end

PopuMean=mean(BINNEDROCResultLR);
PopuSEM=std(BINNEDROCResultLR)/sqrt(size(BINNEDROCResultLR,1));
PopuHi=PopuMean+PopuSEM;
PopuLu=PopuMean-PopuSEM;
patchXdata=[PXtickTime (flipud(PXtickTime'))'];
patchYdata=[PopuHi (flipud(PopuLu'))'];

hPopu=figure;
hold on
plot(PXtickTime,PopuMean,'color','r','LineWidth',1.8);
% errorbar(PXtickTime,PopuMean,PopuSEM,'ro','LineWidth',1.5);
patch(patchXdata,patchYdata,[.8 .8 .8],'facealpha',0.4);
line([AlignTime AlignTime],[0 1],'color',[.8 .8 .8],'LineWidth',1.8);
% set(gca,'xticklabel',cellstr(num2str(PXtickTime(:),'%.1f')),'FontSize',12);
x=get(gca,'xlim');
xlim([0 x(2)]);
line([0 x(2)],[0.5 0.5],'color','g','LineWidth',1.8,'LineStyle','--');
xlabel('Time (s)');
ylabel('ROC value');
title('Popu timeBINroc','FontSize',14);
saveas(hPopu,'Popu timeBINroc plot.png');
saveas(hPopu,'Popu timeBINroc plot.fig');
close(hPopu);
cd ..



% PXtick=1:FrameBin:DatSize(3);
% PXtick(1)=[];
% PXtickTime=PXtick/FrameRate;

% save timeBinROCResult.mat BINNEDROCResultLR BINNEDROCResultLB BINNEDROCResultRB PXtickAfter PXtick ...
%     alignpoint FrameBin DatSize -v7.3
save timeBinROCResult.mat BINNEDROCResultLR PXtickAfter PXtick ...
    alignpoint FrameBin DatSize -v7.3
%%
%plot of left sound response to baseline response
% if ~isdir('./LB_ROC_timeFun/')
%     mkdir('./LB_ROC_timeFun/');
% end
% cd('./LB_ROC_timeFun/');
% for ROInum=1:DatSize(2)
%     hROI=figure;
%     plot(PXtickTime,BINNEDROCResultLB(ROInum,:),'r-o','LineWidth',2);
%     line([AlignTime AlignTime],[0 1],'color',[.8 .8 .8],'LineWidth',1.8);
% %     set(gca,'xticklabel',cellstr(num2str(PXtickTime(:),'%.1f')),'FontSize',12);
%     x=get(gca,'xlim');
%     xlim([0 x(2)]);
%     line([0 x(2)],[0.5 0.5],'color','g','LineWidth',1.8,'LineStyle','--');
%     xlabel('Time (s)');
%     ylabel('ROC value');
%     title(sprintf('ROI%d plot',ROInum),'FontSize',14);
%     saveas(hROI,sprintf('ROI%d time binROC LB plot.png',ROInum));
%     saveas(hROI,sprintf('ROI%d time binROC LB plot.fig',ROInum));
%     close(hROI);
% end
%
% PopuMean=mean(BINNEDROCResultLB);
% PopuSEM=std(BINNEDROCResultLB)/sqrt(size(BINNEDROCResultLB,1));
% PopuHi=PopuMean+PopuSEM;
% PopuLu=PopuMean-PopuSEM;
% patchXdata=[PXtickTime (flipud(PXtickTime'))'];
% patchYdata=[PopuHi (flipud(PopuLu'))'];
%
%
% hPopu=figure;
% hold on
% plot(PXtickTime,PopuMean,'color','r','LineWidth',1.8);
% patch(patchXdata,patchYdata,[.8 .8 .8],'facealpha',0.4);
% line([AlignTime AlignTime],[0 1],'color',[.8 .8 .8],'LineWidth',1.8);
% % set(gca,'xticklabel',cellstr(num2str(PXtickTime(:),'%.1f')),'FontSize',12);
% x=get(gca,'xlim');
% xlim([0 x(2)]);
% line([0 x(2)],[0.5 0.5],'color','g','LineWidth',1.8,'LineStyle','--');
% xlabel('Time (s)');
% ylabel('ROC value');
% title('Popu timeBINroc LB','FontSize',14);
% saveas(hPopu,'Popu timeBINroc LB plot.png');
% saveas(hPopu,'Popu timeBINroc LB plot.fig');
% close(hPopu);
% cd ..
%
% %%
% %plot of right sound response to baseline response
% if ~isdir('./RB_ROC_timeFun/')
%     mkdir('./RB_ROC_timeFun/');
% end
% cd('./RB_ROC_timeFun/');
% for ROInum=1:DatSize(2)
%     hROI=figure;
%     plot(PXtickTime,BINNEDROCResultRB(ROInum,:),'r-o','LineWidth',2);
%     line([AlignTime AlignTime],[0 1],'color',[.8 .8 .8],'LineWidth',1.8);
% %     set(gca,'xticklabel',cellstr(num2str(PXtickTime(:),'%.1f')),'FontSize',12);
%     x=get(gca,'xlim');
%     xlim([0 x(2)]);
%     line([0 x(2)],[0.5 0.5],'color','g','LineWidth',1.8,'LineStyle','--');
%     xlabel('Time (s)');
%     ylabel('ROC value');
%     title(sprintf('ROI%d plot',ROInum),'FontSize',14);
%     saveas(hROI,sprintf('ROI%d time binROC RB plot.png',ROInum));
%     saveas(hROI,sprintf('ROI%d time binROC RB plot.fig',ROInum));
%     close(hROI);
% end
%
% PopuMean=mean(BINNEDROCResultRB);
% PopuSEM=std(BINNEDROCResultRB)/sqrt(size(BINNEDROCResultRB,1));
% PopuHi=PopuMean+PopuSEM;
% PopuLu=PopuMean-PopuSEM;
% patchXdata=[PXtickTime (flipud(PXtickTime'))'];
% patchYdata=[PopuHi (flipud(PopuLu'))'];
%
% hPopu=figure;
% hold on
% plot(PXtickTime,PopuMean,'color','r','LineWidth',1.8);
% % errorbar(PXtickTime,PopuMean,PopuSEM,'ro','LineWidth',1.5);
% patch(patchXdata,patchYdata,[.8 .8 .8],'facealpha',0.4);
% line([AlignTime AlignTime],[0 1],'color',[.8 .8 .8],'LineWidth',1.8);
% % set(gca,'xticklabel',cellstr(num2str(PXtickTime(:),'%.1f')),'FontSize',12);
% x=get(gca,'xlim');
% xlim([0 x(2)]);
% line([0 x(2)],[0.5 0.5],'color','g','LineWidth',1.8,'LineStyle','--');
% xlabel('Time (s)');
% ylabel('ROC value');
% title('Popu timeBINroc RB','FontSize',14);
% saveas(hPopu,'Popu timeBINroc RB plot.png');
% saveas(hPopu,'Popu timeBINroc RB plot.fig');
% close(hPopu);
% cd ..

%%
%3d plot in 2d space
FolderName2 = sprintf('./LR_ROC_timeFun%s/',PlotDesp);
if ~isdir(FolderName2)
    mkdir(FolderName2);
end
cd(FolderName2);
% LBRank=max(BINNEDROCResultLB,[],2);
% RBRank=max(BINNEDROCResultRB,[],2);
LRRand=max(BINNEDROCResultLR,[],2);

% hLB=Popu_3d_Plot(BINNEDROCResultLB,LBRank);
% figure(hLB);
% xlimvalue=get(gca,'xlim');
% xlimvT=(xlimvalue(2)*TimeBins/1000);
% xtickTime=0:(1/(TimeBins/1000)):xlimvalue(2);
% xticklabelT=0:xlimvT;
% set(gca,'xtick',xtickTime,'xticklabel',xticklabelT);
% % set(gca,'xticklabel',cellstr(num2str(PXtickTime(:),'%.1f')),'FontSize',12);
% % xlim([0 DatSize(3)]);
% title('Popu plot of LB AUC');
% saveas(hLB,'Popu 3dplot AUC LB.png');
% saveas(hLB,'Popu 3dplot AUC LB.fig');
% close(hLB);

% hRB=Popu_3d_Plot(BINNEDROCResultRB,RBRank);
% figure(hRB);
% xlimvalue=get(gca,'xlim');
% xlimvT=(xlimvalue(2)*TimeBins/1000);
% xtickTime=0:(1/(TimeBins/1000)):xlimvalue(2);
% xticklabelT=0:xlimvT;
% set(gca,'xtick',xtickTime,'xticklabel',xticklabelT);
% % set(gca,'xticklabel',cellstr(num2str(PXtickTime(:),'%.1f')),'FontSize',12);
% % xlim([0 DatSize(3)]);
% title('Popu plot of RB AUC');
% saveas(hRB,'Popu 3dplot AUC RB.png');
% saveas(hRB,'Popu 3dplot AUC RB.fig');
% close(hRB);

hLR=Popu_3d_Plot(BINNEDROCResultLR,LRRand);
figure(hLR);
xlimvalue=get(gca,'xlim');
xlimvT=(xlimvalue(2)*TimeBins/1000);
xtickTime=0:(1/(TimeBins/1000)):xlimvalue(2);
xticklabelT=0:xlimvT;
set(gca,'xtick',xtickTime,'xticklabel',xticklabelT);
% set(gca,'xticklabel',cellstr(num2str(PXtickTime(:),'%.1f')),'FontSize',12);
% xlim([0 DatSize(3)]);
title('Popu plot of LR AUC');
saveas(hLR,'Popu 3dplot AUC LR.png');
saveas(hLR,'Popu 3dplot AUC LR.fig');
close(hLR);

cd ..;

%3d plot in 2d space
FolderName3 = sprintf('./Selection_index%s/',PlotDesp);
if ~isdir(FolderName3)
    mkdir(FolderName3);
end
cd(FolderName3);


cd ..;

%function cd
cd ..;
