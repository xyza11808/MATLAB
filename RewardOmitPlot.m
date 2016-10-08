function varargout = RewardOmitPlot(AllData,OmitInds,TrialResult,TrialType,TimeAnswer,TimeOnset,FrameRate,varargin)
%this function will be used for plots of all reward omit trials compared
%with normal reward trials. only correct trials will be considered here
%XIN Yu, 10, Nov, 2015

DataSize=size(AllData);
TrialNum=DataSize(1);
ROINum=DataSize(2);
FramesNum=DataSize(3);
% RewardFrame=floor((double(RewardTime)/1000)*FrameRate);
AnswerFrame = round((double(TimeAnswer)/1000)*FrameRate);
OnsetFrame = round((double(TimeOnset)/1000)*FrameRate);
XTick=0:FrameRate:FramesNum;
XTickLabel=XTick/FrameRate;

if nargin>7
    Pre_filename=varargin{1};
else
    Pre_filename='RewardOmit plot';
end
if nargin>8
    Allclimss=varargin{2};
else
    Allclimss=[];
end
isplot = 1;
if nargin > 9
    isplot=varargin{3};
end
CorrectInds=(TrialResult==1)';
ErrorInds=(TrialResult==0)';


CorrLNorInds = CorrectInds & TrialType == 0 & ~OmitInds;
CorrLOmtInds = CorrectInds & TrialType == 0 & OmitInds;
CorrRNorInds = CorrectInds & TrialType == 1 & ~OmitInds;
CorrROmtInds = CorrectInds & TrialType == 1 & OmitInds;

ErroLNorInds = ErrorInds & TrialType == 0 & ~OmitInds;
ErroLOmtInds = ErrorInds & TrialType == 0 & OmitInds;
ErroRNorInds = ErrorInds & TrialType == 1 & ~OmitInds;
ErroROmtInds = ErrorInds & TrialType == 1 & OmitInds;

TypeInds.CLNorInds = CorrLNorInds;
TypeInds.CLOmtInds = CorrLOmtInds;
TypeInds.CRNorInds = CorrRNorInds;
TypeInds.CROmtInds = CorrROmtInds;

TypeInds.ELNorInds = ErroLNorInds;
TypeInds.ELOmtInds = ErroLOmtInds;
TypeInds.ERNorInds = ErroRNorInds;
TypeInds.EROmtInds = ErroROmtInds;

if isplot
    %%
    %######################################################
    %corr data mess
    CorrOmitInds=OmitInds(CorrectInds);
    CorrTrailType=TrialType(CorrectInds);
    CorrRewardTime=AnswerFrame(CorrectInds);
    CorrData=AllData(CorrectInds,:,:);
    CorrTrialNum=size(CorrData,1);
    CorrLeftInds=CorrTrailType==0;
    CorrRightInds=CorrTrailType==1;
    CorrLeftOmitInds=CorrOmitInds(CorrLeftInds);
    CorrLeftNorInds=logical(1-CorrLeftOmitInds);
    CorrRightOmitInds=CorrOmitInds(CorrRightInds);
    CorrRightNorInds=logical(1-CorrRightOmitInds);
    
    %###############################################
    %inds for sorting plot
    CorrRewardTimeL = CorrRewardTime(CorrLeftInds);
    CorrRewardTimeR = CorrRewardTime(CorrRightInds);
    
    CorrLeftOmitTime=CorrRewardTimeL(CorrLeftOmitInds);
    CorrLeftNorTime=CorrRewardTimeL(CorrLeftNorInds);
    
    CorrRightOmitTime=CorrRewardTimeR(CorrRightOmitInds);
    CorrRightNorTime=CorrRewardTimeR(CorrRightNorInds);
    
    [CLeftOmitValue,CLeftOmitInds]=sort(CorrLeftOmitTime);
    [CLeftNorValue,CLeftNorInds]=sort(CorrLeftNorTime);
    
    [CRightOmitValue,CRightOmitInds]=sort(CorrRightOmitTime);
    [CRightNorValue,CRightNorInds]=sort(CorrRightNorTime);
    
    %%
    %##########################################################################
    %error data mess
    ErroOmitInds=OmitInds(ErrorInds);
    ErroTrailType=TrialType(ErrorInds);
    ErroRewardTime=AnswerFrame(ErrorInds);
    ErroData=AllData(ErrorInds,:,:);
    ErroTrialNum=size(ErroData,1);
    ErroLeftInds=ErroTrailType==0;
    ErroRightInds=ErroTrailType==1;
    ErroLeftOmitInds=ErroOmitInds(ErroLeftInds);
    ErroLeftNorInds=logical(1-ErroLeftOmitInds);
    ErroRightOmitInds=ErroOmitInds(ErroRightInds);
    ErroRightNorInds=logical(1-ErroRightOmitInds);
    
    %###############################################
    %inds for sorting plot
    ErroRewardTimeL = ErroRewardTime(ErroLeftInds);
    ErroRewardTimeR = ErroRewardTime(ErroRightInds);
    
    ErroLeftOmitTime=ErroRewardTimeL(ErroLeftOmitInds);
    ErroLeftNorTime=ErroRewardTimeL(ErroLeftNorInds);
    
    ErroRightOmitTime=ErroRewardTimeR(ErroRightOmitInds);
    ErroRightNorTime=ErroRewardTimeR(ErroRightNorInds);
    
    [ELeftOmitValue,ELeftOmitInds]=sort(ErroLeftOmitTime);
    [ELeftNorValue,ELeftNorInds]=sort(ErroLeftNorTime);
    [ERightOmitValue,ERightOmitInds]=sort(ErroRightOmitTime);
    [ERightNorValue,ERightNorInds]=sort(ErroRightNorTime);
    
    %%
    %##########################################################
    %ROI plots
    if ~isdir('./Normal_Omit_plot/')
        mkdir('./Normal_Omit_plot/');
    end
    cd('./Normal_Omit_plot/');
    if ~isdir('.\Corr_trials\')
        mkdir('.\Corr_trials\');
    end
    if ~isdir('.\Error_trials\')
        mkdir('.\Error_trials\');
    end
    CorrDirStr='.\Corr_trials\';
    ErroDirStr='.\Error_trials\';
    
    if ~isdir('.\MeanTrace_plot\')
        mkdir('.\MeanTrace_plot\');
    end
    
    
    AllCorrDataSave=struct('LeftCorrData',[],'RightCorrData',[],'LeftDataModu',[],'RightDataModu',[]);
    AllCorrTimeSave=struct('LeftCorrTime',CorrLeftNorTime,'RightCorrTime',CorrRightNorTime,'LeftTimeModu',CorrLeftOmitTime,'RightTimeModu',CorrRightOmitTime);
    AllErrorDataSave=struct('LeftErroData',[],'RightErroData',[],'LeftDataModu',[],'RightDataModu',[]);
    AllErroTimeSave=struct('LeftErroTime',ErroLeftNorTime,'RightErroTime',ErroRightNorTime,'LeftTimeModu',ErroLeftOmitTime,'RightTimeModu',ErroRightOmitTime);
    NewAllClim = [];
    for n=1:ROINum
        SingleROIData=squeeze(CorrData(:,n,:));
        if isempty(Allclimss)
            clims=[];
            clims(1)=max([0 min(SingleROIData(:))]);
            clims(2)=max(SingleROIData(:));
            if clims(2)>(10*median(SingleROIData(:)))
                clims(2) = (clims(2)+median(SingleROIData(:)))/3;
            end
            if clims(2) > 500
                clims(2) = 400;
            end
            NewAllClim(n,:) = clims;
        else
            clims=Allclimss(n,:);
        end
        SingleROIDataL = SingleROIData(CorrLeftInds,:);
        SingleROIDataR = SingleROIData(CorrRightInds,:);
        
        %#########################################################################################################
        %correct trials plot
        SingleLeftData=SingleROIDataL(CorrLeftNorInds,:);
        SingleRightData=SingleROIDataR(CorrRightNorInds,:);
        SingleLeftOmitData=SingleROIDataL(CorrLeftOmitInds,:);
        SingleRightOmitData=SingleROIDataR(CorrRightOmitInds,:);
        AllCorrDataSave(n).LeftCorrData=SingleLeftData;
        AllCorrDataSave(n).RightCorrData=SingleRightData;
        AllCorrDataSave(n).LeftDataModu=SingleLeftOmitData;
        AllCorrDataSave(n).RightDataModu=SingleRightOmitData;
        
        %correct trials plot
        h_AllC=figure('position',[200 100 1300 1000],'paperpositionmode','auto');
        subplot(3,2,[1,3]);
        imagesc(SingleLeftData(CLeftNorInds,:),clims);
        hold on;
        title(['Left Normal Corr Trials for ROI' num2str(n)]);
        set(gca,'xtick',XTick,'xticklabel',XTickLabel,'FontSize',20);
        xlabel('Time(s)');
        ylabel('Trials');
        cOnsetT = OnsetFrame(CorrLNorInds);
        cOnsetTSort = cOnsetT(CLeftNorInds);
        for m=1:length(CLeftNorInds)
            line([CLeftNorValue(m) CLeftNorValue(m)],[m-0.5 m+0.5],'color',[0.6,0,0.6],'LineWidth',1.5);
            line([cOnsetTSort(m) cOnsetTSort(m)],[m-0.5 m+0.5],'color',[0.6,0,0.6],'LineWidth',1.5);
        end
        hold off;
        
        subplot(3,2,5);
        imagesc(SingleLeftOmitData(CLeftOmitInds,:),clims);
        hold on;
        title(['Left Omit Corr Trials for ROI' num2str(n)]);
        set(gca,'xtick',XTick,'xticklabel',XTickLabel,'FontSize',20);
        xlabel('Time(s)');
        ylabel('Trials');
        cOnsetT = OnsetFrame(CorrLOmtInds);
        cOnsetTSort = cOnsetT(CLeftOmitInds);
        for m=1:length(CLeftOmitInds)
            line([CLeftOmitValue(m) CLeftOmitValue(m)],[m-0.5 m+0.5],'color',[0.6,0,0.6],'LineWidth',1.5);
            line([cOnsetTSort(m) cOnsetTSort(m)],[m-0.5 m+0.5],'color',[0.6,0,0.6],'LineWidth',1.5);
        end
        hold off;
        
        subplot(3,2,[2,4]);
        imagesc(SingleRightData(CRightNorInds,:),clims);
        hold on;
        title(['Right Normal Corr Trials for ROI' num2str(n)]);
        set(gca,'xtick',XTick,'xticklabel',XTickLabel,'FontSize',20);
        xlabel('Time(s)');
        ylabel('Trials');
        cOnsetT = OnsetFrame(CorrRNorInds);
        cOnsetTSort = cOnsetT(CRightNorInds);
        for m=1:length(CRightNorInds)
            line([CRightNorValue(m) CRightNorValue(m)],[m-0.5 m+0.5],'color',[0.6,0,0.6],'LineWidth',1.5);
            line([cOnsetTSort(m) cOnsetTSort(m)],[m-0.5 m+0.5],'color',[0.6,0,0.6],'LineWidth',1.5);
        end
        hold off;
        
        subplot(3,2,6);
        imagesc(SingleRightOmitData(CRightOmitInds,:),clims);
        hold on;
        title(['Right Omit Corr Trials for ROI' num2str(n)]);
        set(gca,'xtick',XTick,'xticklabel',XTickLabel,'FontSize',20);
        xlabel('Time(s)');
        ylabel('Trials');
        cOnsetT = OnsetFrame(CorrROmtInds);
        cOnsetTSort = cOnsetT(CRightOmitInds);
        for m=1:length(CRightOmitInds)
            line([CRightOmitValue(m) CRightOmitValue(m)],[m-0.5 m+0.5],'color',[0.6,0,0.6],'LineWidth',1.5);
            line([cOnsetTSort(m) cOnsetTSort(m)],[m-0.5 m+0.5],'color',[0.6,0,0.6],'LineWidth',1.5);
        end
        hold off;
        %     h=colorbar;
        h_bar=colorbar;
        plot_position_2=get(h_bar,'position');
        set(h_bar,'position',[plot_position_2(1)*1.07 plot_position_2(2) plot_position_2(3)*0.35 plot_position_2(4)]);
        set(get(h_bar,'Title'),'string','\DeltaF/F_0');
        saveas(h_AllC,sprintf('%s%s_CorrData_ATsort_ROI%d',CorrDirStr,Pre_filename,n),'fig');
        saveas(h_AllC,sprintf('%s%s_CorrData_ATsort_ROI%d',CorrDirStr,Pre_filename,n),'png');
        close(h_AllC);
        
        %#########################################################################################################
        %error trials plot
        SingleROIDataER=squeeze(ErroData(:,n,:));
        SingleROIDataERL = SingleROIDataER(ErroLeftInds,:);
        SingleROIDataERR = SingleROIDataER(ErroRightInds,:);
        
        SingleLeftData=SingleROIDataERL(ErroLeftNorInds,:);
        SingleRightData=SingleROIDataERR(ErroRightNorInds,:);
        SingleLeftOmitData=SingleROIDataERL(ErroLeftOmitInds,:);
        SingleRightOmitData=SingleROIDataERR(ErroRightOmitInds,:);
        AllErrorDataSave(n).LeftErroData=SingleLeftData;
        AllErrorDataSave(n).RightErroData=SingleRightData;
        AllErrorDataSave(n).LeftDataModu=SingleLeftOmitData;
        AllErrorDataSave(n).RightDataModu=SingleRightOmitData;
        
        h_AllE=figure('position',[200 100 1300 1000],'paperpositionmode','auto');
        subplot(2,2,1);
        imagesc(SingleLeftData(ELeftNorInds,:),clims);
        hold on;
        title(['Left Normal Error Trials for ROI' num2str(n)]);
        set(gca,'xtick',XTick,'xticklabel',XTickLabel,'FontSize',20);
        xlabel('Time(s)');
        ylabel('Trials');
        cOnsetT = OnsetFrame(ErroLNorInds);
        cOnsetTSort = cOnsetT(ELeftNorInds);
        for m=1:length(ELeftNorInds)
            line([ELeftNorValue(m) ELeftNorValue(m)],[m-0.5 m+0.5],'color',[0.6,0,0.6],'LineWidth',1.5);
            line([cOnsetTSort(m) cOnsetTSort(m)],[m-0.5 m+0.5],'color',[0.6,0,0.6],'LineWidth',1.5);
        end
        hold off;
        
        subplot(2,2,3);
        imagesc(SingleLeftOmitData(ELeftOmitInds,:),clims);
        hold on;
        title(['Left Omit Error Trials for ROI' num2str(n)]);
        set(gca,'xtick',XTick,'xticklabel',XTickLabel,'FontSize',20);
        xlabel('Time(s)');
        ylabel('Trials');
        cOnsetT = OnsetFrame(ErroLOmtInds);
        cOnsetTSort = cOnsetT(ELeftOmitInds);
        for m=1:length(ELeftOmitInds)
            line([ELeftOmitValue(m) ELeftOmitValue(m)],[m-0.5 m+0.5],'color',[0.6,0,0.6],'LineWidth',1.5);
            line([cOnsetTSort(m) cOnsetTSort(m)],[m-0.5 m+0.5],'color',[0.6,0,0.6],'LineWidth',1.5);
        end
        hold off;
        
        subplot(2,2,2);
        imagesc(SingleRightData(ERightNorInds,:),clims);
        hold on;
        title(['Right Normal Error Trials for ROI' num2str(n)]);
        set(gca,'xtick',XTick,'xticklabel',XTickLabel,'FontSize',20);
        xlabel('Time(s)');
        ylabel('Trials');
        cOnsetT = OnsetFrame(ErroRNorInds);
        cOnsetTSort = cOnsetT(ERightNorInds);
        for m=1:length(ERightNorInds)
            line([ERightNorValue(m) ERightNorValue(m)],[m-0.5 m+0.5],'color',[0.6,0,0.6],'LineWidth',1.5);
            line([cOnsetTSort(m) cOnsetTSort(m)],[m-0.5 m+0.5],'color',[0.6,0,0.6],'LineWidth',1.5);
        end
        hold off;
        
        subplot(2,2,4);
        imagesc(SingleRightOmitData(ERightOmitInds,:),clims);
        hold on;
        title(['Right Omit Error Trials for ROI' num2str(n)]);
        set(gca,'xtick',XTick,'xticklabel',XTickLabel,'FontSize',20);
        xlabel('Time(s)');
        ylabel('Trials');
        cOnsetT = OnsetFrame(ErroROmtInds);
        cOnsetTSort = cOnsetT(ERightOmitInds);
        for m=1:length(ERightOmitInds)
            line([ERightOmitValue(m) ERightOmitValue(m)],[m-0.5 m+0.5],'color',[0.6,0,0.6],'LineWidth',1.5);
            line([cOnsetTSort(m) cOnsetTSort(m)],[m-0.5 m+0.5],'color',[0.6,0,0.6],'LineWidth',1.5);
        end
        hold off;
        %     h=colorbar;
        h_bar=colorbar;
        plot_position_2=get(h_bar,'position');
        set(h_bar,'position',[plot_position_2(1)*1.07 plot_position_2(2) plot_position_2(3)*0.35 plot_position_2(4)]);
        set(get(h_bar,'Title'),'string','\DeltaF/F_0');
        
        saveas(h_AllE,sprintf('%s%s_ErroData_ATsort_ROI%d',ErroDirStr,Pre_filename,n),'png');
        saveas(h_AllE,sprintf('%s%s_ErroData_ATsort_ROI%d',ErroDirStr,Pre_filename,n),'fig');
        close(h_AllE);
        
    end
    
    
    %#############################################################################
    %correct data extraction for both types of data
    %this will saved as correct left right, and correct left right omit data
    save AllDataReserved.mat AllCorrDataSave AllCorrTimeSave AllErrorDataSave AllErroTimeSave NewAllClim -v7.3
    save DifferntTypeInds.mat TypeInds -v7.3
end
%##############################################################################
%doing ttest analysis for all the data follows from former analysis
% [CorrLeftNorStatRes,CorrLeftNorDataSel]=statest(AllData(CorrLNorInds,:,:),CorrLeftNorTime,FrameRate);
% [CorrRightNorStatRes,CorrRightNorDataSel]=statest(AllData(CorrRNorInds,:,:),CorrLeftNorTime,FrameRate);
% [CorrLeftOmitStatRes,CorrLeftOmitDataSel]=statest(AllData(CorrLOmtInds,:,:),CorrLeftOmitTime,FrameRate);
% [CorrRightOimtStaRes,CorrRightOmitDataSel]=statest(AllData(CorrROmtInds,:,:),CorrRightOmitTime,FrameRate);
%
% [ErroLeftNorStatRes,ErroLeftNorDataSel]=statest(AllData(ErroLNorInds,:,:),ErroLeftNorTime,FrameRate);
% [ErroRightNorStatRes,ErroRightNorDataSel]=statest(AllData(ErroRNorInds,:,:),ErroRightNorInds,FrameRate);
% [ErroLeftOmitStatRes,ErroLeftOmitDataSel]=statest(AllData(ErroLOmtInds,:,:),ErroLeftOmitTime,FrameRate);
% [ErroRightOimtStaRes,ErroRightOmitDataSel]=statest(AllData(ErroROmtInds,:,:),ErroRightOmitTime,FrameRate);

if nargout > 0
    varargout(1) = {TypeInds};
    return;
end
% plot the mean trace for two different trial types, for left and right
% comparation
DataTimes = [AllCorrTimeSave.LeftCorrTime,AllCorrTimeSave.RightCorrTime,AllCorrTimeSave.LeftTimeModu,AllCorrTimeSave.RightTimeModu];
DataTimeNumb = [length(AllCorrTimeSave.LeftCorrTime),length(AllCorrTimeSave.RightCorrTime),...
    length(AllCorrTimeSave.LeftTimeModu),length(AllCorrTimeSave.RightTimeModu)];
FrameNum = size(AllCorrDataSave(1).LeftCorrData,2);  % total frame number for each trial
% xtick = 1:xtimes(end);
AlignedFrameNum = min(DataTimes);  % the min frame number for alignment
FrameLength = max(DataTimes) - AlignedFrameNum;

xtimes = (1:FrameLength)/FrameRate;
FrameAdjust = arrayfun(@(x,y,z,a) StrcDataExtraction(x,AllCorrTimeSave,AlignedFrameNum,FrameLength),AllCorrDataSave,'UniformOutput',false);
MeanTrace = cellfun(@(x) CellDataMean(x),FrameAdjust);
%%
% plot all ROI trace for comparation
cd('MeanTrace_plot');
for nnROI = 1 : length(MeanTrace)
    hcROI = figure('position',[150 300 1600 600],'Paperpositionmode','auto');
    cROIdata = MeanTrace{nnROI};
    subplot(1,2,1)
    hold on
    plot(xtimes,cROIdata(1,:),'b','LineWidth',1.8);
    plot(xtimes,cROIdata(3,:),'b','LineWidth',1.8,'LineStyle','--');
    yssss = axis;
    line([AlignedFrameNum AlignedFrameNum]/FrameRate,[yssss(3) yssss(4)],'color',[.8 .8 .8],'LineWidth',1.4);
    legend('CorrLeftNormal','CorrLeftOmit','AnswerTime');
    xlabel('Time(s)');
    ylabel('Mean \DeltaF/F_0');
    title('Left trials plot');
    
    subplot(1,2,2)
    hold on
    plot(xtimes,cROIdata(2,:),'r','LineWidth',1.8);
    plot(xtimes,cROIdata(4,:),'r','LineWidth',1.8,'LineStyle','--');
    yssss = axis;
    line([AlignedFrameNum AlignedFrameNum]/FrameRate,[yssss(3) yssss(4)],'color',[.8 .8 .8],'LineWidth',1.4);
    legend('CorrRightNormal','CorrRightOmit','AnswerTime');
    xlabel('Time(s)');
    ylabel('Mean \DeltaF/F_0');
    title('Right trials plot');
    
    suptitle(sprintf('ROI%d compare plot',nnROI));
    saveas(hcROI,sprintf('ROI%d_meanTrace_plot',nnROI),'png');
    saveas(hcROI,sprintf('ROI%d_meanTrace_plot',nnROI));
    close(hcROI);
end
cd ..;
%%
cd ..;

% StrcDataExtraction(AllCorrDataSave(1),AllCorrTimeSave,AlignedFrameNum,FrameLength),AllCorrDataSave
function DataSelectAll = StrcDataExtraction(StrcData,StrcTime,AlignFrame,FrameLength)
fieldNameData = fieldnames(StrcData);
fieldNameTime = fieldnames(StrcTime);
fieldLength = length(fieldNameData);
DataSelectAll = cell(fieldLength,1);
for nn = 1 : fieldLength
    Dataname = fieldNameData{nn};
    Timename = fieldNameTime{nn};
    if length(StrcTime.(Timename)) ~= size(StrcData.(Dataname),1)
        error('Two field names have different data size, please check your data input.');
    end
    RepeatNum = length(StrcTime.(Timename));
    cSelectData = zeros(RepeatNum,FrameLength);
    for mm = 1 : RepeatNum
        cStrcTime = StrcTime.(Timename)(mm);
        Frameadjust = cStrcTime - AlignFrame;
        cSelectData(mm,:) = StrcData.(Dataname)(mm,(Frameadjust+1):(Frameadjust+FrameLength));
    end
    DataSelectAll(nn) = {cSelectData};
end

function MeanDataCell = CellDataMean(CellData)
DataLength = length(CellData);
FrameLength = size(CellData{1},2);
MeanDataAll = zeros(DataLength,FrameLength);
for nxnx = 1 : DataLength
    cDataSet = CellData{nxnx};
    MeanDataAll(nxnx,:) = mean(cDataSet);
end
MeanDataCell = {MeanDataAll};