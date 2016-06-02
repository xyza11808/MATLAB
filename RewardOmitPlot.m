function RewardOmitPlot(AllData,OmitInds,TrialResult,TrialType,TimeAnswer,FrameRate,varargin)
%this function will be used for plots of all reward omit trials compared
%with normal reward trials. only correct trials will be considered here
%XIN Yu, 10, Nov, 2015

DataSize=size(AllData);
TrialNum=DataSize(1);
ROINum=DataSize(2);
FramesNum=DataSize(3);
% RewardFrame=floor((double(RewardTime)/1000)*FrameRate);
AnswerFrame=floor((double(TimeAnswer)/1000)*FrameRate);
XTick=0:FrameRate:FramesNum;
XTickLabel=XTick/FrameRate;

if nargin>6
    Pre_filename=varargin{1};
else
    Pre_filename='RewardOmit plot';
end
if nargin>7
    Allclims=varargin{2};
else
    Allclims=[];
end

CorrectInds=TrialResult==1;
ErrorInds=TrialResult==0;

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
CorrLeftOmitTime=CorrRewardTime(CorrLeftOmitInds);
CorrLeftNorTime=CorrRewardTime(CorrLeftNorInds);
CorrRightOmitTime=CorrRewardTime(CorrRightOmitInds);
CorrRightNorTime=CorrRewardTime(CorrRightNorInds);
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
ErroLeftOmitTime=ErroRewardTime(ErroLeftOmitInds);
ErroLeftNorTime=ErroRewardTime(ErroLeftNorInds);
ErroRightOmitTime=ErroRewardTime(ErroRightOmitInds);
ErroRightNorTime=ErroRewardTime(ErroRightNorInds);
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
if ~isdir('.\Reeor_trials\')
    mkdir('.\Reeor_trials\');
end
CorrDirStr='.\Corr_trials\';
ErroDirStr='.\Reeor_trials\';

AllCorrDataSave=struct('LeftCorrData',[],'RightCorrData',[],'LeftDataModu',[],'RightDataModu',[]);
AllCorrTimeSave=struct('LeftCorrTime',CorrLeftNorTime,'RightCorrTime',CorrRightNorTime,'LeftTimeModu',CorrLeftOmitTime,'RightTimeModu',CorrRightOmitTime);
AllErrorDataSave=struct('LeftErroData',[],'RightErroData',[],'LeftDataModu',[],'RightDataModu',[]);
AllErroTimeSave=struct('LeftErroTime',ErroLeftNorTime,'RightErroTime',ErroRightNorTime,'LeftTimeModu',ErroLeftOmitTime,'RightTimeModu',ErroRightOmitTime);

for n=1:ROINum
    SingleROIData=squeeze(CorrData(:,n,:));
    if isempty(Allclims)
        Clim=[];
        Clim(1)=max([0 min(SingleROIData(:))]);
        Clim(2)=max(SingleROIData(:));
        if clims(2)>(10*median(SingleROIData(:)))
            clims(2) = (clims(2)+median(SingleROIData(:)))/3;
        end
        if clims(2) > 500
            clims(2) = 400;
        end
    else
        Clim=Allclims(n,:);
    end
    
    %#########################################################################################################
    %correct trials plot
    SingleLeftData=SingleROIData(CorrLeftNorInds,:);
    SingleRightData=SingleROIData(CorrRightNorInds,:);
    SingleLeftOmitData=SingleROIData(CorrLeftOmitInds,:);
    SingleRightOmitData=SingleROIData(CorrRightOmitInds,:);
    AllCorrDataSave(n).LeftCorrData=SingleLeftData;
    AllCorrDataSave(n).RightCorrData=SingleRightData;
    AllCorrDataSave(n).LeftDataModu=SingleLeftOmitData;
    AllCorrDataSave(n).RightDataModu=SingleRightOmitData;

     %correct trials plot
    h_AllC=figure;
    subplot(3,2,[1,3]);
    imagesc(SingleLeftData(CLeftNorInds,:),Clim);
    hold on;
    title(['Left Normal Corr Trials for ROI' num2str(n)]);
    set(gca,'xtick',XTick,'xticklabel',XTickLabel);
    for m=1:length(CLeftNorInds)
        line([CLeftNorValue(m) CLeftNorValue(m)],[m-0.5 m+0.5],'color',[0.6,0,0.6],'LineWidth',1.5);
    end
    hold off;
    
    subplot(3,2,5);
    imagesc(SingleLeftOmitData(CLeftOmitInds,:),Clim);
    hold on;
    title(['Left Omit Corr Trials for ROI' num2str(n)]);
    set(gca,'xtick',XTick,'xticklabel',XTickLabel);
    for m=1:length(CLeftOmitInds)
        line([CLeftOmitValue(m) CLeftOmitValue(m)],[m-0.5 m+0.5],'color',[0.6,0,0.6],'LineWidth',1.5);
    end
    hold off;
    
    subplot(3,2,[2,4]);
    imagesc(SingleRightData(CRightNorInds,:),Clim);
    hold on;
    title(['Right Normal Corr Trials for ROI' num2str(n)]);
    set(gca,'xtick',XTick,'xticklabel',XTickLabel);
    for m=1:length(CRightNorInds)
        line([CRightNorValue(m) CRightNorValue(m)],[m-0.5 m+0.5],'color',[0.6,0,0.6],'LineWidth',1.5);
    end
    hold off;
    
    subplot(3,2,6);
    imagesc(SingleRightOmitData(CRightOmitInds,:),Clim);
    hold on;
    title(['Right Normal Corr Trials for ROI' num2str(n)]);
    set(gca,'xtick',XTick,'xticklabel',XTickLabel);
    for m=1:length(CRightOmitInds)
        line([CRightOmitValue(m) CRightOmitValue(m)],[m-0.5 m+0.5],'color',[0.6,0,0.6],'LineWidth',1.5);
    end
    hold off;
%     h=colorbar;
    h_bar=colorbar;
    plot_position_2=get(h_bar,'position');
    set(h_bar,'position',[plot_position_2(1)*1.13 plot_position_2(2) plot_position_2(3)*0.35 plot_position_2(4)]);
    set(get(h_bar,'Title'),'string','\DeltaF/F_0');
    
    saveas(h_AllC,sprintf('%s%s_CorrData_ATsort_ROI%d',CorrDirStr,Pre_filename,n),'png');
    close(h_AllC);
    
    %#########################################################################################################
    %error trials plot
    SingleROIDataER=squeeze(ErroData(:,n,:));
    SingleLeftData=SingleROIDataER(ErroLeftNorInds,:);
    SingleRightData=SingleROIDataER(ErroRightNorInds,:);
    SingleLeftOmitData=SingleROIDataER(ErroLeftOmitInds,:);
    SingleRightOmitData=SingleROIDataER(ErroRightOmitInds,:);
    AllErrorDataSave(n).LeftErroData=SingleLeftData;
    AllErrorDataSave(n).RightErroData=SingleRightData;
    AllErrorDataSave(n).LeftDataModu=SingleLeftOmitData;
    AllErrorDataSave(n).RightDataModu=SingleRightOmitData;
    
    h_AllE=figure;
    subplot(2,2,1);
    imagesc(SingleLeftData(ELeftNorInds,:),Clim);
    hold on;
    title(['Left Normal Error Trials for ROI' num2str(n)]);
    set(gca,'xtick',XTick,'xticklabel',XTickLabel);
    for m=1:length(ELeftNorInds)
        line([ELeftNorValue(m) ELeftNorValue(m)],[m-0.5 m+0.5],'color',[0.6,0,0.6],'LineWidth',1.5);
    end
    hold off;
    
    subplot(2,2,3);
    imagesc(SingleLeftOmitData(ELeftOmitInds,:),Clim);
    hold on;
    title(['Left Omit Error Trials for ROI' num2str(n)]);
    set(gca,'xtick',XTick,'xticklabel',XTickLabel);
    for m=1:length(ELeftOmitInds)
        line([ELeftOmitValue(m) ELeftOmitValue(m)],[m-0.5 m+0.5],'color',[0.6,0,0.6],'LineWidth',1.5);
    end
    hold off;
    
    subplot(2,2,2);
    imagesc(SingleRightData(ERightNorInds,:),Clim);
    hold on;
    title(['Right Normal Error Trials for ROI' num2str(n)]);
    set(gca,'xtick',XTick,'xticklabel',XTickLabel);
    for m=1:length(ERightNorInds)
        line([ERightNorValue(m) ERightNorValue(m)],[m-0.5 m+0.5],'color',[0.6,0,0.6],'LineWidth',1.5);
    end
    hold off;
    
    subplot(2,2,4);
    imagesc(SingleRightOmitData(ERightOmitInds,:),Clim);
    hold on;
    title(['Right Normal Error Trials for ROI' num2str(n)]);
    set(gca,'xtick',XTick,'xticklabel',XTickLabel);
    for m=1:length(ERightOmitInds)
        line([ERightOmitValue(m) ERightOmitValue(m)],[m-0.5 m+0.5],'color',[0.6,0,0.6],'LineWidth',1.5);
    end
    hold off;
%     h=colorbar;
    h_bar=colorbar;
    plot_position_2=get(h_bar,'position');
    set(h_bar,'position',[plot_position_2(1)*1.13 plot_position_2(2) plot_position_2(3)*0.35 plot_position_2(4)]);
    set(get(h_bar,'Title'),'string','\DeltaF/F_0');
    
    saveas(h_AllE,sprintf('%s%s_ErroData_ATsort_ROI%d',ErroDirStr,Pre_filename,n),'png');
    close(h_AllE);
    
end


%#############################################################################
%correct data extraction for both types of data
%this will saved as correct left right, and correct left right omit data
save AllDataReserved.mat AllCorrDataSave AllCorrTimeSave AllErrorDataSave AllErroTimeSave -v7.3

%##############################################################################
%doing ttest analysis for all the data follows from former analysis
[CorrLeftNorStatRes,CorrLeftNorDataSel]=statest(CorrData(CorrLeftNorInds,:,:),CorrLeftNorTime,FrameRate);
[CorrRightNorStatRes,CorrRightNorDataSel]=statest(CorrData(CorrRightNorInds,:,:),CorrLeftNorTime,FrameRate);
[CorrLeftOmitStatRes,CorrLeftOmitDataSel]=statest(CorrData(CorrLeftOmitInds,:,:),CorrLeftOmitTime,FrameRate);
[CorrRightOimtStaRes,CorrRightOmitDataSel]=statest(CorrData(CorrRightOmitInds,:,:),CorrRightOmitTime,FrameRate);

[ErroLeftNorStatRes,ErroLeftNorDataSel]=statest(ErroData(ErroLeftNorInds,:,:),ErroLeftNorTime,FrameRate);
[ErroRightNorStatRes,ErroRightNorDataSel]=statest(ErroData(ErroRightNorInds,:,:),ErroRightNorInds,FrameRate);
[ErroLeftOmitStatRes,ErroLeftOmitDataSel]=statest(ErroData(ErroLeftOmitInds,:,:),ErroLeftOmitTime,FrameRate);
[ErroRightOimtStaRes,ErroRightOmitDataSel]=statest(ErroData(ErroRightOmitInds,:,:),ErroRightOmitTime,FrameRate);


cd ..;