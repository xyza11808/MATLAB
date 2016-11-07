function varargout=Reward_Get_TimeAlign(Data,LickTime,behavResults,TrialResult,FrameRate,TraceTime,varargin)
%this function will be used for extrating first lick time that mouse
%actually get water reward
%time that is actually happens late than 3s before trace time ends will not
%be counted in order to save enough data for final plot, the least answer
%time before will also be counted in the final trace plot
isplot = 1;
if ~isempty(varargin)
    isplot = varargin{1};
end
TrialTypes=behavResults.Trial_Type;
TrialStimOnT=behavResults.Time_stimOnset;
RewardGivenT=behavResults.Time_reward;
% RespDelay=behavSettings.responseDelay;

LickStr={'LickTimeLeft','LickTimeRight'};
CorrTrialInds=TrialResult==1;
CorrTrialTypes=TrialTypes(CorrTrialInds);
CorrTrialStimOnT=TrialStimOnT(CorrTrialInds);
CorrRewardGivenT=RewardGivenT(CorrTrialInds);
% CorrRespDelay=RespDelay(CorrTrialInds);
CorrLickTime=LickTime(CorrTrialInds);
CorrData=Data(CorrTrialInds',:,:);


CorrLTrialInds=CorrTrialTypes==0;
CorrRTrialInds=CorrTrialTypes==1;
CorrLData=CorrData(CorrLTrialInds,:,:);
CorrRData=CorrData(CorrRTrialInds,:,:);
RewardGetTime=zeros(1,sum(CorrTrialInds));
OutLierinds=false(1,sum(CorrTrialInds));

for n=1:sum(CorrTrialInds)
    LickCorrTime=CorrLickTime(n).(LickStr{CorrTrialTypes(n)+1});
    TrialAnswerT=CorrRewardGivenT(n);
    FirstRewardT=LickCorrTime(find(LickCorrTime>TrialAnswerT,1,'first'));
    if isempty(FirstRewardT) || FirstRewardT > ((TraceTime-3)*1000)
        OutLierinds(n)=true;
        continue;
    else
        RewardGetTime(n)=FirstRewardT;
    end
end

CorrTrialTypes(OutLierinds)=[];
CorrTrialStimOnT(OutLierinds)=[];
% CorrRespDelay(OutLierinds)=[];
% CorrLickTime(OutLierinds)=[];
CorrData(OutLierinds,:,:)=[];
DataSize=size(CorrData);

RewardGetTime(OutLierinds)=[];
MinRewardT=min(RewardGetTime);
MaxRewardT=max(RewardGetTime);
AlignAfterT=(TraceTime*1000)-MaxRewardT;
BeforeFrameLength=floor((MinRewardT/1000)*FrameRate)-1;
AfterFrameLength=floor((AlignAfterT/1000)*FrameRate)-1;
RewardGetFrame=floor((RewardGetTime/1000)*FrameRate);

AlignData=zeros(DataSize(1),DataSize(2),BeforeFrameLength+AfterFrameLength);

for n=1:length(RewardGetTime)
    AlignData(n,:,:)=CorrData(n,:,(RewardGetFrame(n)-BeforeFrameLength+1):(RewardGetFrame(n)+AfterFrameLength));
end
AlignedTraceLength=BeforeFrameLength+AfterFrameLength;
Linds=CorrTrialTypes==0;
Rinds=CorrTrialTypes==1;
if isplot
    if ~isdir('./Trial_color_plot/')
        mkdir('./Trial_color_plot/');
    end

    if ~isdir('./Trial_Trace_plot/')
        mkdir('./Trial_Trace_plot/');
    end
end
XTick=0:FrameRate:AlignedTraceLength;
Xticklabel=XTick./FrameRate;
Event.t_eventOn=BeforeFrameLength;
Event.isPatchPlot=0;
LeftDataAll = AlignData(Linds,:,:);
RightDatAll = AlignData(Rinds,:,:);
LRMeanSemData = zeros(DataSize(2),4,BeforeFrameLength+AfterFrameLength);

for m=1:DataSize(2)  %ROI number
    TempData=squeeze(AlignData(:,m,:));
    ColorScale=[0 min(max(TempData(:)),300)];
    LeftData=TempData(Linds,:);
    RightData=TempData(Rinds,:);
    LeftDataMean=mean(LeftData);
    RightDataMean=mean(RightData);
    LeftDataSEM=std(LeftData)./sqrt(DataSize(1));
    RightDataSEM=std(RightData)./sqrt(DataSize(1));
    LRMeanSemData(m,1,:) = LeftDataMean;
    LRMeanSemData(m,2,:) = LeftDataSEM;
    LRMeanSemData(m,3,:) = RightDataMean;
    LRMeanSemData(m,4,:) = RightDataSEM;
    
    if isplot
        h_colorplot=figure;
        hold on
        subplot(2,1,1)
        imagesc(LeftData,ColorScale);
        hLbar=colorbar;
        set(get(hLbar,'Title'),'string','\DeltaF/F_0');
        yaxis=axis();
        line([BeforeFrameLength BeforeFrameLength],[yaxis(3) yaxis(4)],'LineWidth',2.5,'color',[.8 .8 .8]);
        set(gca,'xtick',XTick,'xticklabel',Xticklabel);
        title('Left Trials');

        subplot(2,1,2)
        imagesc(RightData,ColorScale);
        hRbar=colorbar;
        set(get(hRbar,'Title'),'string','\DeltaF/F_0');
        yaxis=axis();
        line([BeforeFrameLength BeforeFrameLength],[yaxis(3) yaxis(4)],'LineWidth',2.5,'color',[1 0 1]);
        set(gca,'xtick',XTick,'xticklabel',Xticklabel);
        title('Right Trials');

        suptitle(sprintf('Color plot for ROI%d',m));
        saveas(h_colorplot,sprintf('./Trial_color_plot/Answertime_Align_ROI%d.png',m));
        saveas(h_colorplot,sprintf('./Trial_color_plot/Answertime_Align_ROI%d.fig',m));
        close(h_colorplot);

        h_meanTrace=figure;
        hold on;
        H_L=plot_meanCaTrace(LeftDataMean,LeftDataSEM,1:AlignedTraceLength,h_meanTrace,Event);
        H_R=plot_meanCaTrace(RightDataMean,RightDataSEM,1:AlignedTraceLength,h_meanTrace,Event);
        set(H_L.meanPlot, 'color','b');
        set(H_R.meanPlot, 'color','r');
        set(gca,'xtick',XTick,'xticklabel',Xticklabel);
        ylabel('\DeltaF/F_0');
        xlabel('Time (s)');
        title(sprintf('Aligned Mean Trace for ROI%d',m));
        saveas(h_meanTrace,sprintf('./Trial_Trace_plot/AT_mean_ROI%d.png',m));
        saveas(h_meanTrace,sprintf('./Trial_Trace_plot/AT_mean_ROI%d.fig',m));
        close(h_meanTrace);
    end
    
end
save Aligned_data_answerT.mat AlignData CorrTrialTypes BeforeFrameLength AfterFrameLength -v7.3

if nargout
    AnswerAlignData.Data=AlignData;
    AnswerAlignData.TrialType=CorrTrialTypes;
    AnswerAlignData.AlignFrame=BeforeFrameLength;
    AnswerAlignData.AllMeanData = LRMeanSemData;
    AnswerAlignData.LeftDataAll = LeftDataAll;
    AnswerAlignData.RightDataAll = RightDatAll;
    varargout{1} = AnswerAlignData;
    if nargout > 1
        RewardTime.RealRTime = RewardGetTime;
        RewardTime.Inds = CorrTrialInds;
        varargout{2} = RewardTime;
    end
end
