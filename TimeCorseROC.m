function varargout = TimeCorseROC(AlignedData,Trial_Type,alignpoint,FrameRate,varargin)
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
isplot = 1;
if nargin > 6
    isplot = varargin{3};
end
PlotDespStr = {'CU','SP'};
PlotDesp = PlotDespStr{CUplot+1};

FrameBin=round((TimeBins/1000)*FrameRate);
TimeBins = (FrameBin / FrameRate)*1000;
fprintf('Real Timebin value is %.4fms.\n',TimeBins);
DatSize=size(AlignedData);
if isplot
    if ~isdir('./TimeFunROC_Plot/')
        mkdir('./TimeFunROC_Plot/');
    end
    cd('./TimeFunROC_Plot/');
end

LeftTrialInds=Trial_Type==0;
RIghtTrialInds=Trial_Type==1;
% BeforeBinNum = floor(alignpoint/FrameBin);
BeforeBinInds = alignpoint:-FrameBin:1;
if BeforeBinInds(end) ~= 1
    BeforeBinInds(end) = 1; % including the last few frames into the same frame bin, but not one single bin along
end
BeforeBinInds = fliplr(BeforeBinInds);
BeforeBinNum = length(BeforeBinInds)-1; % bin inds number minus 1
AfterBinInds = (alignpoint+1):FrameBin:DatSize(3);
if AfterBinInds(end) ~= DatSize(3)
    AfterBinInds(end) = DatSize(3); % set the remain frames into the last framebin, do not given extra bin number
end
AfterBinNum = length(AfterBinInds)-1;
BinLength = BeforeBinNum + AfterBinNum;
BinIndsAll = [BeforeBinInds,AfterBinInds(2:end)]; % at the alignpoint the after bin inds should started with alignpoint+1

% BinLength=floor((DatSize(3))/FrameBin);  %bin length
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
            cEndInds = BinIndsAll(BINNum);
            LeftPoints=TempROIData(LeftTrialInds,1:cEndInds);
            RightPoints=TempROIData(RIghtTrialInds,1:cEndInds);
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
            cEndInds = BinIndsAll(BINNum+1);
            if BINNum == (BeforeBinNum+1)
                cStartInds = BinIndsAll(BINNum)+1;
            else
                cStartInds = BinIndsAll(BINNum);
            end
            LeftPoints=TempROIData(LeftTrialInds,cStartInds:cEndInds);
            RightPoints=TempROIData(RIghtTrialInds,cStartInds:cEndInds);
             LeftPointsMax = max(LeftPoints,[],2);
            RightPointsMax = max(RightPoints,[],2);
            if length(unique(LeftPointsMax)) < 20 || length(unique(RightPointsMax)) < 20
                fprintf('Too few data points for calculation, set to chance level.\n');
                dataBIN = 0.5;
            else
                LeftDataFORroc=[LeftPointsMax(:),zeros(numel(LeftPointsMax),1)];
                RightDataFORroc=[RightPointsMax(:),ones(numel(RightPointsMax),1)];
                try
                    [dataBIN,LMMean]=rocOnlineFoff([LeftDataFORroc;RightDataFORroc]);
                catch
                    fprintf('Current ROI is %d, BinNum is %d. error occurs.\n',ROInum,BINNum);
                    waitforbuttonpress;
                end
                if LMMean
                    dataBIN = 1 - dataBIN;
                end
            end
            BINNEDROCResultLR(ROInum,BINNum)=dataBIN;
        end
    end
    clearvars TempROIData LeftPoints RightPoints LeftDataFORroc RightDataFORroc
end
PXtick = ((BinIndsAll(1:end-1)+BinIndsAll(2:end))/2);
% PXtick = FrameBin:FrameBin:(DatSize(3));
AlignTime = alignpoint/FrameRate;
% AlignBin = alignpoint/FrameBin;
AlignBin = BeforeBinNum+0.5;
% PXtick(1)=[];
PXtickTime=PXtick/FrameRate;
PXtickAfter = PXtick;
%%
if isplot
    FolderName = sprintf('./LR_ROC_timeFun%s/',PlotDesp);
    if ~isdir(FolderName)
        mkdir(FolderName);
    end
    cd(FolderName);
%
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
end
%%
PopuMean=mean(BINNEDROCResultLR);
PopuSEM=std(BINNEDROCResultLR)/sqrt(size(BINNEDROCResultLR,1));
PopuHi=PopuMean+PopuSEM;
PopuLu=PopuMean-PopuSEM;
patchXdata=[PXtickTime (flipud(PXtickTime'))'];
patchYdata=[PopuHi (flipud(PopuLu'))'];

if isplot
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
end

% PXtick=1:FrameBin:DatSize(3);
% PXtick(1)=[];
% PXtickTime=PXtick/FrameRate;

% save timeBinROCResult.mat BINNEDROCResultLR BINNEDROCResultLB BINNEDROCResultRB PXtickAfter PXtick ...
%     alignpoint FrameBin DatSize -v7.3
save timeBinROCResult.mat BINNEDROCResultLR PXtickAfter PXtick PXtickTime ...
    alignpoint FrameBin DatSize -v7.3
if isplot
    cd ..
end
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
LRRand=max(BINNEDROCResultLR,[],2);
if isplot

%3d plot in 2d space
FolderName2 = sprintf('./LR_ROC_timeFun%s/',PlotDesp);
if ~isdir(FolderName2)
    mkdir(FolderName2);
end
cd(FolderName2);
% LBRank=max(BINNEDROCResultLB,[],2);
% RBRank=max(BINNEDROCResultRB,[],2);

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
% xlimvalue=get(gca,'xlim');
xlimvT=(BinLength*TimeBins/1000);
xtickTime=0:(1/(TimeBins/1000)):BinLength;
xticklabelT=0:xlimvT;
set(gca,'xtick',xtickTime,'xticklabel',xticklabelT);
% set(gca,'xticklabel',cellstr(num2str(PXtickTime(:),'%.1f')),'FontSize',12);
% xlim([0 DatSize(3)]);
title('Popu plot of LR AUC');
saveas(hLR,'Popu 3dplot AUC LR.png');
saveas(hLR,'Popu 3dplot AUC LR.fig');
close(hLR);
end
%%
if isplot
    
    DataForPlot = BINNEDROCResultLR';
    [~,Inds] = sort(LRRand);
    SmoothData = zeros(size(DataForPlot));
    for nnn = 1 : length(Inds)
        SmoothData(:,nnn) = smooth(DataForPlot(:,nnn));
    end
    %%
    [xx,zz] = meshgrid(0:3:size(SmoothData,2),0.3:0.1:0.7);
    yy = AlignBin*ones(size(xx));
    c(:,:,1) = 0.6*ones(size(xx));
    c(:,:,2) = 0.6*ones(size(xx));
    c(:,:,3) = 0.6*ones(size(xx));
    
    h_surf = figure;
    hold on;
    surf(SmoothData(:,Inds),'LineStyle','none','Facecolor','interp');
    colormap jet
    surf(xx,yy,zz,c,'facealpha',0.6,'FaceColor','interp','LineStyle','none');
    set(gca,'clim',[0.5 1]);
    set(gca,'xdir','reverse','xtick',1:floor(DatSize(2)/3):DatSize(2));
    ylim([-10 BinLength+10]);
    xlabel('ROIs');
    ylabel('Time (s)');
    zlabel('Fraction correct');
    set(gca,'FontSize',20)
    set(gca,'ytick',xtickTime,'yticklabel',xticklabelT);
    set(gca,'ztick',[0.3 0.7 1]);
    grid off; box off;
    view(113.7,63.6);
%     hax = gca;
%     axisPos = get(hax,'position');
    hBar = colorbar('southoutside');
    CBpos = get(hBar,'position');
    set(hBar,'position',[CBpos(1) 0.85 CBpos(3) 0.03]);
%     set(hax,'position',axisPos);
    set(hBar,'Ticks',[0.5,0.8,1]);
    %
    saveas(h_surf,'Popu 3dplot AUC surf.png');
    saveas(h_surf,'Popu 3dplot AUC surf.fig');
    saveas(h_surf,'Popu 3dplot AUC surf','pdf');
    close(h_surf);

    [~,MaxIndsSmooth] = max(SmoothData);
    BinTimeValue = MaxIndsSmooth*TimeBins/1000;
    [nCount,nCenters] = hist(BinTimeValue);
    h_PeakDis = figure;
    plot(nCenters,nCount,'k','LineWidth',2);
    xlabel('Time (s)','FontSize',20)
    ylabel('ROI count','FontSize',20)
    title('ROC peak time distribution')
    set(gca,'FontSize',20);
    
    %%
    saveas(h_PeakDis,'ROC peak time distribution');
    saveas(h_PeakDis,'ROC peak time distribution','png');
    close(h_PeakDis);
    cd ..;
    % %3d plot in 2d space
    % FolderName3 = sprintf('./Selection_index%s/',PlotDesp);
    % if ~isdir(FolderName3)
    %     mkdir(FolderName3);
    % end
    % cd(FolderName3);
    % 
    % 
    % cd ..;

    %function cd
    cd ..;
end

if nargout > 0
    TimeCourseAUC.tickTime = PXtickTime;
    TimeCourseAUC.ROIBinAUC = BINNEDROCResultLR;
    varargout(1) = {TimeCourseAUC};
end
