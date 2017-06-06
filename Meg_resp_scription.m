%%
%loading all analysis result
clear;
clc;
ResultPath=uigetdir(pwd,'Please Select your tif file analysis result save path');
cd(ResultPath);
files=dir('*.mat');
for n=1:length(files)
    load(files(n).name);
end
if ~exist('CaTrials','var')
    CaTrials=SavedCaTrials;
    TrialNum=CaTrials.TrialNum;
    AllDataRaw=CaTrials.f_raw;
else
    TrialNum=length(CaTrials);
    SingleTrialSize=size(CaTrials(1).f_raw);
    AllDataRaw=uint16(zeros(TrialNum,SingleTrialSize(1),SingleTrialSize(2)));
    % if isfield(CaTrials,'RingF')
    %     for n=1:TrialNum
    %         AllDataRaw(n,:,:)=uint16(CaTrials(n).f_raw-CaTrials(n).RingF);
    %     end
    % else
    for n=1:TrialNum
        AllDataRaw(n,:,:)=uint16(CaTrials(n).f_raw);
    end
end
FrameNum=CaTrials(1).nFrames;
FrameTime=FrameNum*(CaTrials(1).FrameTime)/1000;
nROIs=CaTrials(1).nROIs;
FrameRate=floor(1000/CaTrials(1).FrameTime);
TimeTicklabel=0:5:(FrameNum/FrameRate);
TimeTick=TimeTicklabel*FrameRate;
TimeTrace=((1:FrameNum)/FrameRate);
SessionTickLable=0:50:(FrameNum/FrameRate)*TrialNum;
SessionTick=SessionTickLable*FrameRate;

if ~exist('ROIinfo','var')
    ROIinfo=ROIinfoBU;
end
% end

%%
%empty ROI exclude1
AllROImask=ROIinfo(1).ROImask;
EmptyROI=cellfun(@isempty,AllROImask);
nROIs=nROIs-sum(EmptyROI);
AllDataRaw(:,EmptyROI,:)=[];

baselineC=input('Is this session is a baseline test?\n','s');
if strcmpi(baselineC,'n')
%     ROImeanMaxValue=zeros(nROIs,1);
    ROIMaxValuesave=zeros(nROIs,1);
    isbaseline=0;
else
    [fileMax,fileMpath,~]=uigetfile('AllTrialsData.mat','Select your test group results');
    x=load(fullfile(fileMpath,fileMax));
%     ROImeanMaxValue=x.ROIMaxiumValue;
    ROIMaxValuesave=x.ROIMaxValuesave;
    isbaseline=1;
end


MegOnTime=4;   %this part should be modified according to the real data
MagDurTime = 2;
% sessionType=2;  %this part should be modified according to the real data
MegOnFrame=MegOnTime*FrameRate;
time_scale=1;  %[2,5,10]
% time_scale=1;
frame_scale=time_scale*FrameRate;
sessionDesp={'MegOn test','Baseline test','Control','Sound pips'};
CoefTimescale=[-1,5];  %using 5s before and after stimuli to calculate ROI correlation
CoefFramescale=CoefTimescale*FrameRate;

StimOnTime=MegOnTime;
StimOnFrame=StimOnTime*FrameRate;
if StimOnFrame == 0
    StimOnFrame=1;
end
StimOffTime=StimOnTime+MagDurTime;  %or user defined time
StimOffframe=round(StimOffTime*FrameRate);
% StimOffframe=FrameNum;
if StimOffframe~=FrameNum
    DurTime=0.3;
    Stim_struct.t_eventOn=StimOnFrame;
    Stim_struct.eventDur=round(DurTime*FrameRate);
else
    Stim_struct=[];
end

%Stim parameters
stimType={'Sine','Square'};
StimAmp = 8; % mT
stimIndex=3;

if stimIndex == 1
    % singe wave
    StimT=0.1; %Hz
%     StimAmp=0; %mT
    StimOnTime=1:(StimOffframe-StimOnFrame);
    StimOnData=StimAmp*sin(2*pi*StimT*(StimOnTime/FrameRate));
    if size(StimOnData,1)~=1
        StimOnData=StimOnData';
    end
    StimData=[zeros(1,StimOnFrame),StimOnData,zeros(1,FrameNum-StimOffframe)];
elseif stimIndex == 2
    % constant square
%     StimAmp=16; %mT
    StimOnTime=1:(StimOffframe-StimOnFrame);
    StimOnData=StimAmp*ones(1,StimOffframe-StimOnFrame);
    if size(StimOnData,1)~=1
        StimOnData=StimOnData';
    end
    StimData=[zeros(1,StimOnFrame),StimOnData,zeros(1,FrameNum-StimOffframe)];
%     StimData=[zeros(1,StimOnFrame),StimOnData,zeros(1,length(StimOnData)),StimOnData,zeros(1,FrameNum-(StimOnFrame+3*length(StimOnData)))];
%     if length(StimData)>FrameNum
%         StimData(1001:end)=[];
%     end
elseif stimIndex == 3
    % changed square wave
    StimPeriod = 0.5; %Hz
    PeriodTime = 1/StimPeriod;
    MagDurF = round(MagDurTime*FrameRate);
    PeriodF = round(PeriodTime*FrameRate);
    TimeSign = [ones(1,ceil(PeriodF/2)),(-1)*ones(1,(PeriodF - ceil(PeriodF/2)))];
    if MagDurTime <= PeriodTime
        RealTimeSignF = TimeSign(1 : MagDurF);
    else
        FullPeriodNum = floor(MagDurF/PeriodF);
        FullPeriodSign = repmat(TimeSign,1,FullPeriodNum);
        LeftLength = MagDurF - (PeriodF*FullPeriodNum);
        AllPeriodSign = [FullPeriodSign,TimeSign(1:LeftLength)];
        RealTimeSignF = AllPeriodSign;
    end
    StimData = StimAmp * [zeros(1,StimOnFrame),RealTimeSignF,zeros(1,FrameNum-StimOffframe)];
end

%%
%f0 calculation and fluo change calculation
ROIfbase=zeros(1,nROIs);
ROImean=zeros(1,nROIs);
RespMaxValue=zeros(1,nROIs);
AllDataChange=zeros(TrialNum,nROIs,FrameNum);
AllDataNor=zeros(TrialNum,nROIs,FrameNum);


if ~isdir('./SumDataSaveNew/')
    mkdir('./SumDataSaveNew/');
end
cd('./SumDataSaveNew/');
for n=1:nROIs
    tempData=double(squeeze(AllDataRaw(:,n,:)));
    h=figure;
    subplot(2,1,1);
    hold on
    imagesc(tempData);
    set(gca,'xtick',TimeTick,'xticklabel',TimeTicklabel);
    yscales = get(gca,'ylim');
    xscales = get(gca,'xlim');
    line([StimOnFrame,StimOnFrame],[0.5 TrialNum+0.5],'Color',[.7 .7 .7],'LineWidth',2);
    line([StimOffframe,StimOffframe],[0.5 TrialNum+0.5],'Color',[1 0 1],'LineWidth',2);
    ylim([0.5 TrialNum+0.5]);
    xlim([0 size(tempData,2)]);
    colorbar;
    
    subplot(2,1,2);
    AllTrace=reshape(tempData',[],1);
    plot(AllTrace);
%     xtimeSession=get(gca,'xtick');
%     xtimeSessionLabel=round(xtimeSession/FrameRate);
    set(gca,'xtick',SessionTick,'xticklabel',SessionTickLable);
    title(sprintf('Raw Fluo ROI%d',n));
    saveas(h,sprintf('ROI%dRawPlot.png',n));
    close(h);
%     baselinevalueRaw=tempData(:,1:MegOnTime);
%     [Num,Centers]=hist(tempData(:),40);
%     [~,I]=max(Num);
%     ROIfbase(n)=Centers(I);

%     [p,~,mu]=polyfit(1:length(AllTrace),AllTrace',5);
%     Fit_f0=polyval(p,1:length(AllTrace),[],mu);
%     baseShift=Fit_f0-Fit_f0(1);
%     temp_fadjust=AllTrace'-baseShift;
    temp_fadjust=AllTrace';
    adjustDataMatrix=reshape(temp_fadjust,FrameNum,[]);
    baselinevalueAD=adjustDataMatrix(1:MegOnFrame,:);
    respvalueAD=adjustDataMatrix(MegOnFrame:end,:);
    RespMaxValue(n) = max(respvalueAD(:));
%     temp_fadjust=AllTrace;
    ROIfbase(n)=mean(baselinevalueAD(:));
    ROImean(n)=mean(baselinevalueAD(:));
%     [Num,Centers]=hist(temp_fadjust,40);
%     [~,I]=max(Num);
%     ROIfbase(n)=Centers(I);
    
    temp_fchange=((temp_fadjust-ROIfbase(n))./ROIfbase(n))*100;
    ZStemp_fchange=zscore(temp_fchange);
    ZStemp_fchangeMatrix=reshape(ZStemp_fchange,FrameNum,[]);
    fchangeMatrix=reshape(temp_fchange,FrameNum,[]);
%     AllDataChange(:,n,:)=fchangeMatrix';
    %if ROI resp is very robust, the baseline value might be all negtive,
    %exclude this condition
%     BaseValueVector=fchangeMatrix(1:MegOnTime,:);
%     
%     if mode(BaseValueVector(:))<0 || mean(BaseValueVector(:))<0 || median(BaseValueVector(:))<0
%         [Num,Centers]=hist(baselinevalueAD(:),40);
%         [~,I]=max(Num);
%         ROIfbase(n)=Centers(I);
%         temp_fchange=((temp_fadjust-ROIfbase(n))./ROIfbase(n))*100;
%         fchangeMatrix=reshape(temp_fchange,FrameNum,[]);
%     end
    
    h2=figure;
    plot(temp_fchange);
    yaxis=axis;
    hold on
    for k=1:TrialNum
        MegOnFrameTrial=MegOnFrame+(k-1)*FrameNum;
        line([MegOnFrameTrial MegOnFrameTrial],[yaxis(3) yaxis(4)],'color',[1 0 1],'LineWidth',1);
    end
%     xtimeSession=get(gca,'xtick');
%     xtimeSessionLabel=round(xtimeSession/FrameRate);
    set(gca,'xtick',SessionTick,'xticklabel',SessionTickLable);
    title(sprintf('Fluo change ROI%d',n));
    saveas(h2,sprintf('ROI%d_FChange_plot.png',n));
    saveas(h2,sprintf('ROI%d_FChange_plot.fig',n));
    close(h2);
%     fchangeMatrix=reshape(temp_fchange,FrameNum,[]);
%     temp_fchange=((double(AllDataRaw(:,n,:))-ROIfbase(n))/ROIfbase(n))*100;
    AllDataChange(:,n,:)=fchangeMatrix';
%     temp_fchange=fchangeMatrix';
%     if ~isbaseline
%         ROIMaxValuesave(n)=max(temp_fchange(:));
%     end
    AllDataNor(:,n,:)=ZStemp_fchangeMatrix';
%     temp_fchange(temp_fchange<0)=0;
%     AllDataNor(:,n,:)=temp_fchange./repmat(max(temp_fchange,[],2),1,FrameNum);
    
end

save AllTrialsData.mat AllDataRaw AllDataChange AllDataNor ROIfbase ROIMaxValuesave RespMaxValue -v7.3
cd ..;

%%
%example ROI plot
ExampROIinds = [3,8,12,13,17,18,23,25,27,29,31,32,36,41,42];
save ROIinds.mat ExampROIinds -v7.3
GapsBetTrace = 50;  %gaps between each trace
AfterMegT = 5;  % seconds after Meg start
BeforeMegT = 1; %Time choossed for baseline
BeforeMegF = floor(BeforeMegT * FrameRate); 
SelectEndFrame = BeforeMegF + floor(AfterMegT * FrameRate);
h_example = figure('position',[200 50 1600 1000],'color','w');
hold on
yBase = 0;
for n = 1 : length(ExampROIinds)
    cROINum = ExampROIinds(n);
    cROIData = (squeeze(AllDataChange(:,cROINum,:)))';
    cPartData = cROIData;
%     yBaseAdd = max(cROIData(:));
    if (FrameNum - SelectEndFrame - (MegOnFrame - BeforeMegF)) > floor(5 * FrameRate)
        cPartData(1:(MegOnFrame - BeforeMegF),:) = [];
        cPartData((SelectEndFrame + floor(5 * FrameRate) + 1):end,:) = [];
        FrameNumNew = size(cPartData,1);
    else
        cPartData(1:(MegOnFrame - BeforeMegF),:) = [];
        cPartData((SelectEndFrame + floor(5 * FrameRate) + 1):end,:) = [];
        FrameNumNew = size(cPartData,1);
%         BeforeMegF = MegOnFrame;
    end
    cPartData(SelectEndFrame:end,:) = nan;
    yBaseAdd = max(cPartData(:));
    cROITrace = cPartData(:);
    TrialLength = length(cROITrace);
    plot(cROITrace + yBase,'color','b');
    for k=1:TrialNum
        MegOnFrameTrial=BeforeMegF+(k-1)*FrameNumNew;
        line([MegOnFrameTrial MegOnFrameTrial],[min(cROITrace)+yBase max(cROITrace)+yBase],'color',[1 0 1],'LineWidth',1);
    end
    
    yBase = yBase + max(yBaseAdd) + GapsBetTrace;
end
TrialLength = TrialLength + FrameRate*2;
%%
xtickPartStart = 0:FrameNumNew:FrameNumNew*TrialNum;
xtickPartEnd = SelectEndFrame:FrameNumNew:FrameNumNew*TrialNum;
xtickLine = BeforeMegF+((1:TrialNum)-1)*FrameNumNew;
xtickAll = sort([xtickPartStart,xtickPartEnd,xtickLine]);
xticklabel = repmat({'0',num2str(BeforeMegT),num2str(BeforeMegT+AfterMegT)},1,TrialNum);
set(gca,'xtick',xtickAll,'xticklabel',xticklabel);
set(gca,'ytick',[],'ycolor','w')
xlabel('Time(s)');
% xscales = get(gca,'xlim');
line([TrialLength TrialLength],[100,200],'LineWidth',2,'color','k');
text((TrialLength),150,'100% \DeltaF/f_0');
ylim([-50 yBase]);
% ylabel('\DeltaF/f_0');
title('Example ROI plot---Sound Response');
saveas(h_example,'Example ROI plot.png');
saveas(h_example,'Example ROI plot.fig');
close(h_example);

%%
%test for each ROI and to see whether is significant response to Meg
BeforeMegFL = FrameRate;
AfterMegFL = 2 * FrameRate;
ROIpvalue = zeros(nROIs,2);
ROImean = zeros(nROIs,3);
for nR = 1 : nROIs
    cROIdata = squeeze(AllDataChange(:,nR,:));
    ROIthres = 1.4826*mad(reshape(cROIdata',[],1),1); 
%     ROIthres = std(reshape(cROIdata',[],1));
    BMegData = cROIdata(:,max([1,(MegOnFrame - BeforeMegFL)]):MegOnFrame);
    AMegData = cROIdata(:,(MegOnFrame+1):(MegOnFrame+AfterMegFL));
    [h,p] = ttest2(BMegData(:),AMegData(:),'Tail','left');
    ROIpvalue(nR,:) = [h,p];
    ROImean(nR,1:2) = [mean(BMegData(:)),mean(AMegData(:))];
    ROImean(nR,3) = ROIthres;
end
ROISigInds = (ROIpvalue(:,2) < 0.05) & (ROImean(:,2) > ROImean(:,3));
FracROISig = sum(ROISigInds)/length(ROISigInds);
fprintf('Significant ROIs fraction in response to Meg is %.4f.\n',FracROISig);


%%
%calculate the onset time distribution for sig ROIs
SigROIdata = AllDataChange(:,ROISigInds,:);
SigROIRealinds = find(ROISigInds);
ROIonset = zeros(nROIs,TrialNum);
ROIonsetMean = zeros(nROIs,1);
ROIonsetPeak = zeros(nROIs,TrialNum);
for nSR = 1 : sum(ROISigInds)
    cSRdata = (squeeze(AllDataChange(:,SigROIRealinds(nSR),:)))';
    exDataPart = cSRdata(MegOnFrame:MegOnFrame+FrameRate,:);
    c4PeakData = cSRdata(MegOnFrame:MegOnFrame+(FrameRate*2),:);
    for nT = 1 : TrialNum
        cTrace = smooth(exDataPart(:,nT),5);
        TraceDiff = diff([cTrace(1);cTrace]);
        TraceDiffT = TraceDiff > 0;
        for TraceDataInds = 1:length(TraceDiffT)-3
            if sum(TraceDiffT(TraceDataInds:TraceDataInds+2)) == 3
                ROIonset(SigROIRealinds(nSR),nT) = TraceDataInds;
                break;
            end
        end
        
        cPeakTrace = smooth(c4PeakData(:,nT));
        ROIonsetPeak(SigROIRealinds(nSR),nT) = max(cPeakTrace);
    end
    %mean Trace for Onset calculation
    cAvgTrace = mean(exDataPart,2);
    mTraceDiff = diff([cAvgTrace(1);cAvgTrace]);
    for TraceDataInds = 1:length(TraceDiffT)-3
        if sum(TraceDiffT(TraceDataInds:TraceDataInds+2)) == 3
            ROIonsetMean(SigROIRealinds(nSR),1) = TraceDataInds;
            break;
        end
     end
end
RealROIonsetT = ROIonset / FrameRate;
ROIonsetMean = ROIonsetMean / FrameRate;
save ROIOnsetT.mat RealROIonsetT ROIonsetPeak ROISigInds SigROIRealinds ROIonsetMean -v7.3
% save ROInesetMean.mat ROIonsetMean -v7.3
%%
%Meg and sound Amp comparation
isAmpCompare = 1;
if isAmpCompare
    [fn1,fp1,~] = uigetfile('ROIOnsetT.mat','Please Select the Meg response Amp data');
    MegStrc = load(fullfile(fp1,fn1));
    
    [fn2,fp2,~] = uigetfile('ROIOnsetT.mat','Please Select the Sound response Amp data');
    SoundStrc = load(fullfile(fp2,fn2));
    
    %peak value compare
    if ~isequal(MegStrc.ROISigInds,SoundStrc.ROISigInds)
%         warning('Select data have different inds strc, please check it out')
        IndsDiff = MegStrc.ROISigInds + SoundStrc.ROISigInds;
%         RealInds = MegStrc.ROISigInds;
        ExcludInds = IndsDiff == 2;
        fprintf('%.3f of nonOverlap inds being excluded from Sig inds.\n',sum(ExcludInds)/(2*length(ExcludInds)));
        RealInds = false(size(IndsDiff));
        RealInds(ExcludInds) = true;
    end
    MegPeak = mean(MegStrc.ROIonsetPeak(RealInds,:),2);
    SoundPeak = mean(SoundStrc.ROIonsetPeak(RealInds,:),2);
    h_peakCom = figure('position',[200 200 1350 900]);
    subplot(1,2,1)
    plot(MegPeak,SoundPeak,'ro','MarkerSize',10);
    maxData = max([max(MegPeak),max(SoundPeak)]);
    line([0,maxData+50],[0,maxData+50],'LineStyle','--','LineWidth',0.9,'color',[.8 .8 .8]);
    axis square
    xlabel('Meg response peak');
    ylabel('Sound response peak');
    title('Peak comparation plot');
    
    subplot(1,2,2)
    hold on
    [N1,C1] = hist(MegPeak(:));
    [N2,C2] = hist(SoundPeak(:));
    plot(C1,N1,'r-o','LineWidth',1);
    plot(C2,N2,'b-o','LineWidth',1);
    legend('MegResp Peak','SoundResp peak');
    legend boxoff
    title('Distribution of peakvalue');
    
    [h,p] = ttest(MegPeak,SoundPeak);
    suptitle(sprintf('Meg & Sound compare with p = %.3f',p));
    
    saveas(h_peakCom,'Peak Value Compare Plot.png');
    saveas(h_peakCom,'Peak Value Compare Plot.fig');
    close(h_peakCom);
    
    %Onset time compare
    h_onset = figure;
    hold on
    MegOnset = MegStrc.RealROIonsetT(RealInds,:);
    SoundOnset = SoundStrc.RealROIonsetT(RealInds,:);
    [N1,C1] = hist(MegOnset(:));
    [N2,C2] = hist(SoundOnset(:));
    plot(C1,N1,'r-o','LineWidth',1);
    plot(C2,N2,'b-o','LineWidth',1);
    legend('MegResp Onset','SoundResp Onset');
    legend boxoff
    MegOnsetMean = mean(MegOnset(:));
    SoundOnsetMean = mean(SoundOnset(:));
    title(sprintf('Distribution of onset MegM = %.3f, SMean = %.3f',MegOnsetMean,SoundOnsetMean));
    saveas(h_onset,'Onset Time Distribution.png');
    saveas(h_onset,'Onset Time Distribution.fig');
    close(h_onset);
    
    h_onsetMean = figure;
    hold on
    MagOnsetMean = MegStrc.ROIonsetMean(RealInds);
    SoundOnsetMean = SoundStrc.ROIonsetMean(RealInds);
    plot(MagOnsetMean,SoundOnsetMean,'bo','MarkerSize',8);
    maxData = max([max(MagOnsetMean),max(SoundOnsetMean)]);
    line([0,maxData+0.2],[0,maxData+0.2],'LineStyle','--','LineWidth',0.9,'color',[.8 .8 .8]);
    axis square
    xlabel('Mag Onset Time(s)');
    ylabel('Sound Onset Time(s)');
    [h,p]=ttest(MagOnsetMean,SoundOnsetMean,'tail','right');
    title({sprintf('Onset Time Compare, p = %0.3e',p),sprintf('MagMean = %.3f, SudMean= %.3f',mean(MagOnsetMean),mean(SoundOnsetMean))});
    saveas(h_onsetMean,'MeanTrace Onset Distribution.png');
    saveas(h_onsetMean,'MeanTrace Onset Distribution.fig');
%     close(h_onsetMean);
end

%%
%plot single ROIs response change across different trials
if ~isdir('./Single_ROI_plot/')
    mkdir('./Single_ROI_plot/');
end
cd('./Single_ROI_plot/');
if ~isdir('./ROI_Mean_plot/')
    mkdir('./ROI_Mean_plot/');
end


AllROIMean=zeros(nROIs,FrameNum);
AllROIMeanNor=zeros(nROIs,FrameNum);
AllROIMeanZS=zeros(nROIs,FrameNum);
CoefROIMatrixNOr=zeros(nROIs,CoefFramescale(2)-CoefFramescale(1)+1);
CoefROIMatrixZS=zeros(nROIs,CoefFramescale(2)-CoefFramescale(1)+1);
CoefROIMatrixRaw=zeros(nROIs,CoefFramescale(2)-CoefFramescale(1)+1);

BeforeRespNor=zeros(nROIs,length(frame_scale));
AfterRespNor=zeros(nROIs,length(frame_scale));
BeforeRespRaw=zeros(nROIs,length(frame_scale));
AfterRespRaw=zeros(nROIs,length(frame_scale));

for n=1:nROIs
    hROI=figure;
%     hold on;
    SingleROIData=squeeze(AllDataChange(:,n,:));
%     subplot(2,1,1);
    imagesc(SingleROIData,[0 300]);  %,[0 min(400,max(SingleROIData(:)))]
    set(gca,'xtick',TimeTick,'xticklabel',TimeTicklabel);
    ylabel('# Trials');
    line([StimOnFrame,StimOnFrame],[0.5 TrialNum+0.5],'Color',[.7 .7 .7],'LineWidth',2);
    line([StimOffframe,StimOffframe],[0.5 TrialNum+0.5],'Color',[1 0 1],'LineWidth',2);
    ylim([0.5 TrialNum+0.5]);
    xlim([0 size(tempData,2)]);
    colorbar;
%     plot(SingleROIData','color',[.8 .8 .8],'LineWidth',0.5);
    MeanROITrace=mean(SingleROIData);
    SEMROITrace=std(SingleROIData)/sqrt(size(SingleROIData,1));
    AllROIMean(n,:)=MeanROITrace;
%     if ~isbaseline
%         ROImeanMaxValue(n)=max(MeanROITrace);
%     end
    AllROIMeanNor(n,:)=mean(squeeze(AllDataNor(:,n,:)));   %./(ROImeanMaxValue(n))
    AllROIMeanZS(n,:)=zscore(MeanROITrace);
    CoefROIMatrixNOr(n,:)=AllROIMeanNor(n,(MegOnFrame+CoefFramescale(1)+1):(MegOnFrame+CoefFramescale(2)+1));
    CoefROIMatrixZS(n,:)=AllROIMeanZS(n,(MegOnFrame+CoefFramescale(1)+1):(MegOnFrame+CoefFramescale(2)+1));
    CoefROIMatrixRaw(n,:)=MeanROITrace((MegOnFrame+CoefFramescale(1)+1):(MegOnFrame+CoefFramescale(2)+1));
    %#########################
    %extracting Normalized ROI data from Normalized trace
    for m=1:length(frame_scale)
        BeforeRespNor(n,m)=mean(AllROIMeanNor(n,max([1,MegOnFrame-frame_scale(m)+1]):MegOnFrame));
        AfterRespNor(n,m)=mean(AllROIMeanNor(n,MegOnFrame:(MegOnFrame+frame_scale(m))));
        BeforeRespRaw(n,m)=mean(MeanROITrace(max([1,MegOnFrame-frame_scale(m)+1]):MegOnFrame));
        AfterRespRaw(n,m)=mean(MeanROITrace(MegOnFrame:(MegOnFrame+frame_scale(m))));
    end
    saveas(hROI,sprintf('SingleROI%dLineplot.png',n));
    saveas(hROI,sprintf('SingleROI%dLineplot.fig',n));
    close(hROI);
    
    h_2=figure;
%     plot(MeanROITrace,'LineWidth',2,'color','g');
    h_save=plot_meanCaTrace(MeanROITrace,SEMROITrace,1:FrameNum,h_2,Stim_struct,StimData,'Meg Intensity (mT)');
%     h_save=plot_meanCaTrace(MeanROITrace,SEMROITrace,1:FrameNum,h_2,[]);
%     set(h_save.meanPlot,'color','r');
    set(gca,'xtick',TimeTick,'xticklabel',TimeTicklabel);
    title(sprintf('ROI%d',n));
%     xlabel('Time (s)');
%     ylabel('\DeltaF/F_0');
    
    if ~isfield(h_save,'Allaxes')
        yscale=get(gca,'ylim');
        if yscale(2) <= -20
            close all;
            continue;
        end
        set(gca,'ylim',[-40 yscale(2)]);
    else
        yscale=get(h_save.Allaxes(1),'ylim');
        if yscale(2) <= -20
            close all;
            continue;
        end
        ylim(h_save.Allaxes(1),[-40 yscale(2)]);
    end
    saveas(h_2,sprintf('./ROI_Mean_plot/ROI%dMeanplot.png',n));
    saveas(h_2,sprintf('./ROI_Mean_plot/ROI%dMeanplot.fig',n));
    close(h_2);
end
save ROIMeanResu.mat AllROIMeanNor AllROIMean -v7.3
save ScatterResult.mat BeforeRespNor AfterRespNor -v7.3
save coefMatrixData.mat CoefROIMatrixNOr CoefROIMatrixZS CoefROIMatrixRaw -v7.3

cd ..;
%%
%population trace plot
%before clustering different ROIs together, every ROI should be normalized
%first
if ~isdir('Popu_trace_plot')
    mkdir('Popu_trace_plot');
end
cd('Popu_trace_plot');
PopuMeanTrace=zeros(TrialNum,FrameNum);

for m=1:TrialNum
    hTrial=figure;
%     hold on;
    SingleTrialData=squeeze(AllDataChange(m,:,:));
    subplot(2,1,1);
    imagesc(SingleTrialData,[0 200]);
    colorbar;
    set(gca,'xtick',TimeTick,'xticklabel',TimeTicklabel);
    title('Single Trial Popu Resp');
    xlabel('Time (s)');
    ylabel('ROIs');
    TrialMeanTrace=mean(SingleTrialData);
    subplot(2,1,2);
    plot(TrialMeanTrace,'color','c','LineWidth',1.5);
    set(gca,'xtick',TimeTick,'xticklabel',TimeTicklabel);
    title(sprintf('Trial%d',m));
    xlabel('Time (s)');
    ylabel('\DeltaF/F_0');
    yscale=get(gca,'ylim');
    if yscale>0
        set(gca,'ylim',[0 yscale(2)]);
    end
    saveas(hTrial,sprintf('Trial%dpopuPlot.png',m));
    saveas(hTrial,sprintf('Trial%dpopuPlot.fig',m));
    close(hTrial);
end
cd ..;


%%
%plot of normalized mean trace.
if ~isdir('Popu_MeanColor_plot')
    mkdir('Popu_MeanColor_plot');
end
cd('Popu_MeanColor_plot');

h_allROI=figure;
imagesc(AllROIMeanNor,[-0.5,2]);
colormap jet;
colorbar;
set(gca,'xtick',TimeTick,'xticklabel',TimeTicklabel);
xlabel('Time(s)');
ylabel('ROIs');
yaxis=axis;
line([MegOnFrame MegOnFrame],[yaxis(3) yaxis(4)],'color',[1 0 1],'LIneWidth',2);
title('ZScore population response');
saveas(h_allROI,'ZSPoupu_RespColor.png');
saveas(h_allROI,'ZSPoupu_RespColor.fig');
close(h_allROI);

h_allROImean=figure;
hold on;
MeanTrace=mean(AllROIMeanNor);
SEMTrace=std(AllROIMeanNor)/sqrt(size(AllROIMeanNor,1));
h_save=plot_meanCaTrace(MeanTrace,SEMTrace,1:FrameNum,h_allROImean,[]);
set(h_save.meanPlot,'color','r');
set(gca,'xtick',TimeTick,'xticklabel',TimeTicklabel);
title('ZS. Popu Resp');
xlabel('Time (s)');
ylabel('ROIs');
yaxis=axis;
line([MegOnFrame MegOnFrame],[yaxis(3) yaxis(4)],'color',[.8 .8 .8],'LIneWidth',2);
saveas(h_allROImean,'ZSPoupu_RespMean.png');
saveas(h_allROImean,'ZSPoupu_RespMean.fig');
close(h_allROImean);

h_allROIRaw=figure;
imagesc(AllROIMean,[0 100]);
colormap jet;
colorbar;
set(gca,'xtick',TimeTick,'xticklabel',TimeTicklabel);
xlabel('Time(s)');
ylabel('ROIs');
yaxis=axis;
line([MegOnFrame MegOnFrame],[yaxis(3) yaxis(4)],'color',[1 0 1],'LIneWidth',2);
title('Raw population response');
saveas(h_allROIRaw,'RawPoupu_RespColor.png');
saveas(h_allROIRaw,'RawPoupu_RespColor.fig');
close(h_allROIRaw);

h_allROIRawMean=figure;
hold on;
MeanTrace=mean(AllROIMean);
SEMTrace=std(AllROIMean)/sqrt(size(AllROIMean,1));
h_save=plot_meanCaTrace(MeanTrace,SEMTrace,1:FrameNum,h_allROIRawMean,[]);
set(h_save.meanPlot,'color','r');
set(gca,'xtick',TimeTick,'xticklabel',TimeTicklabel);
title('Raw Popu Resp');
xlabel('Time (s)');
ylabel('ROIs');
yaxis=axis;
line([MegOnFrame MegOnFrame],[yaxis(3) yaxis(4)],'color',[.8 .8 .8],'LIneWidth',2);
saveas(h_allROIRawMean,'RawPoupu_RespMean.png');
saveas(h_allROIRawMean,'RawPoupu_RespMean.fig');
close(h_allROIRawMean);

cd ..;
%%
%Single ROI Normalization color plot

if ~isdir('./Nor_ROI_colorplot/')
    mkdir('./Nor_ROI_colorplot/');
end
cd('./Nor_ROI_colorplot/');
NewPopuData=zeros(nROIs,FrameNum);

for n=1:nROIs
    TempNorROIData=squeeze(AllDataNor(:,n,:));
    NewPopuData(n,:)=mean(TempNorROIData);
    h_SingleROIc=figure;
    imagesc(TempNorROIData,[-0.5 2]);
    colorbar;
    set(gca,'xtick',TimeTick,'xticklabel',TimeTicklabel);
    xlabel('Time(s)');
    ylabel('Trials');
    title('Nor. population response');
    saveas(h_SingleROIc,sprintf('ROI%d_Norcolorplot.png',n));
    saveas(h_SingleROIc,sprintf('ROI%d_Norcolorplot.fig',n));
    close(h_SingleROIc);
end

if ~isdir('./New_colorplot/')
    mkdir('./New_colorplot/');
end
cd('./New_colorplot/');
h_AllNewNor=figure;
imagesc(NewPopuData,[-0.5 1]);
colorbar;
set(gca,'xtick',TimeTick,'xticklabel',TimeTicklabel);
xlabel('Time(s)');
ylabel('ROIs');
title('New Nor. population response');
saveas(h_AllNewNor,'NewNorPoupuRespMean.png');
saveas(h_AllNewNor,'NewNorPoupuRespMean.fig');
close(h_AllNewNor);
cd ..;

cd ..;

%%
%wave component analysis

StimOnTrace=MeanTrace(StimOnFrame:end);
StimLength=length(StimOnTrace);
wave_analysis(StimOnTrace,FrameRate,StimLength/FrameRate,[],[0 0.5]);
 

%%
%everySingle Trace fft analysis
if ~isdir('./Wave_comp_analysis/')
    mkdir('./Wave_comp_analysis/');
end
cd('./Wave_comp_analysis/');

for n=1:nROIs
    SingleTrace=AllROIMeanNor(n,:);
    SinStimOnTrace=SingleTrace(StimOnFrame:end);
    filename=sprintf('Wave_Component_Analysis_ROI%d',n);
    wave_analysis(SinStimOnTrace,FrameRate,StimLength/FrameRate,filename,[0 0.5]);
end

cd ..;

%%
%plot the diff matrix between baseline activity and MegOn activity
%values below zero will be set to zero before make a diff
[filenameC,filepathC,~]=uigetfile('ROIMeanResu.mat','Select your baseline activity matrix');
CMatrixStruct=load(fullfile(filepathC,filenameC));
CMatrix=CMatrixStruct.AllROIMeanNor;
CMatrix(CMatrix<0)=0;


[filenameT,filepathT,~]=uigetfile('ROIMeanResu.mat','Select your experimetal activity matrix');
TMatrixStruct=load(fullfile(filepathT,filenameT));
TMatrix=TMatrixStruct.AllROIMeanNor;
TMatrix(TMatrix<0)=0;

if ~isdir('./DIff_resp_plot/')
    mkdir('./DIff_resp_plot/');
end
cd('./DIff_resp_plot/');

diffMatrix=TMatrix-CMatrix;
h_diffmtx=figure;
imagesc(diffMatrix);
colorbar;
set(gca,'xtick',TimeTick,'xticklabel',TimeTicklabel);
xlabel('Time(s)');
ylabel('ROIs');
title('Population response diff');
savepath=uigetdir(pwd,'Select your data saving path');
saveas(h_diffmtx,sprintf('%s/Base_Meg_diffplot.png',savepath));
saveas(h_diffmtx,sprintf('%s/Base_Meg_diffplot.fig',savepath));
close(h_diffmtx);

cd ..;

%%
%for single session scatter plot
if ~isdir('./scatter_plot/')
    mkdir('./scatter_plot/');
end
cd('./scatter_plot/');
for n=1:length(time_scale)
    h_scatterPlot=figure;
    hold on
    xMax=max(AfterRespRaw(:,n));
    yMax=max(BeforeRespRaw(:,n));
    axislims=max([xMax,yMax]);
    scatter(AfterRespRaw(:,n),BeforeRespRaw(:,n),40,'o','g','LineWidth',1.5);
    line([0,axislims],[0,axislims],'color',[.8 .8 .8],'LineStyle','--','LineWidth',2);
    xlim([0 axislims]);
    ylim([0 axislims]);
    xlabel('After Stimuli');
    ylabel('Before Stimuli');
    title(sprintf('%s %ds win plot',sessionDesp{sessionType},time_scale(n)));
    hold off
    saveas(h_scatterPlot,sprintf('%s_%ds_win_plot.png',sessionDesp{sessionType},time_scale(n)));
    saveas(h_scatterPlot,sprintf('%s_%ds_win_plot.fig',sessionDesp{sessionType},time_scale(n)));
    close(h_scatterPlot);
end

cd ..;

%%
%this section will be used to plot scatters before and after Meg onset

% MegOnTime=10;   %this part should be modified according to the real data
% sessionType=1;
% MegOnFrame=MegOnTime*FrameRate;
% time_scale=[2,5,10];
% frame_scale=time_scale*FrameRate;
% sessionDesp={'MegOn test','Baseline test','Control'};

sessionType=1;  %define the population rep type for sum plot
add_char='y';
m=1;
h_all=figure;
hold on

while ~strcmpi(add_char,'n')
    [fname,fpath,findex]=uigetfile('ScatterResult.mat','Please select your previous ROI analysis result');
    if ~findex
        add_char='n';
        break;
    end
    x=load(fullfile(fpath,fname));
    if m==1
        BeforeRespAll=x.BeforeRespNor;
        AfterRespAll=x.AfterRespNor;
    else
        BeforeRespAll=[BeforeRespAll;x.BeforeRespNor];
        AfterRespAll=[AfterRespAll;x.AfterRespNor];
    end
    add_char=input('Do you want to add another session data?\n','s');
    m=m+1;
    
end
dataLegnth=size(BeforeRespAll,1);
% TitleDesp=sessionDesp{1};

if ~isdir('./scatter_plot/')
    mkdir('./scatter_plot/');
end
cd('./scatter_plot/');
for n=1:length(time_scale)
    h_scatterPlot=figure;
    hold on
    xMax=max(AfterRespAll(:,n));
    yMax=max(BeforeRespAll(:,n));
    axislims=max([xMax,yMax]);
    scatter(AfterRespAll(:,n),BeforeRespAll(:,n),40,'o','g','LineWidth',1.5);
    line([0,axislims],[0,axislims],'color',[.8 .8 .8],'LineStyle','--','LineWidth',2);
    xlim([0 axislims]);
    ylim([0 axislims]);
    xlabel('After Stimuli');
    ylabel('Before Stimuli');
    title(sprintf('%s %ds win plot',sessionDesp{sessionType},time_scale(n)));
    hold off
    saveas(h_scatterPlot,sprintf('%s_%ds_win_plot.png',sessionDesp{sessionType},time_scale(n)));
    saveas(h_scatterPlot,sprintf('%s_%ds_win_plot.fig',sessionDesp{sessionType},time_scale(n)));
    close(h_scatterPlot);
end

cd ..;

%%
%thisi section is used for calculate population coef using Nor. data
if ~exist('CoefROIMatrixNOr','var')
    [ffname,ffpath,~]=uigetfile('*.mat','Select your Nor. data save file');
    xx=load(fullfile(ffpath,ffname));
    if isfield(xx,'AllROIMeanNor')
        ALLNordata=xx.AllROIMeanNor;
       CoefROIMatrix=ALLNordata(:,(MegOnFrame+CoefFramescale(1)):(MegOnFrame+CoefFramescale(2))); 
    elseif isfield(xx,{'CoefROIMatrixNOr','CoefROIMatrixZS','CoefROIMatrixRaw'})
        CoefROIMatrixNOr=xx.CoefROIMatrixNOr;
        CoefROIMatrixZS=xx.CoefROIMatrixZS;
        CoefROIMatrixRaw=xx.CoefROIMatrixRaw;
    end
end

if isbaseline
    [indexf,indexpath,~]=uigetfile('SortIndex.mat','select experimental group indexfile');
    Indexfile=load(fullfile(indexpath,indexf));
end

if ~isdir('./Popu_coef_plot/')
    mkdir('./Popu_coef_plot/');
end
cd('./Popu_coef_plot/');

h_coefNor=figure;
coefMatrix=corrcoef(CoefROIMatrixNOr');
if ~isbaseline
    yy=mean(coefMatrix);
    [~,INor]=sort(yy);
else
    INor=Indexfile.INor;
end
imagesc(coefMatrix(INor,INor),[0 1]);
colorbar;
ylabel('# ROIs');
title('Corelation Nor. coef between ROIs');
saveas(h_coefNor,'Popultion_coefNor_plot.png');
saveas(h_coefNor,'Popultion_coefNor_plot.fig');
close(h_coefNor);

h_coefZS=figure;
coefMatrix=corrcoef(CoefROIMatrixZS');
if ~isbaseline
    yy=mean(coefMatrix);
    [~,IZS]=sort(yy);
else
   IZS =Indexfile.IZS;
end
imagesc(coefMatrix(IZS,IZS),[0 1]);
colorbar;
ylabel('# ROIs');
title('Corelation ZS coef between ROIs');
saveas(h_coefZS,'Popultion_coefZS_plot.png');
saveas(h_coefZS,'Popultion_coefZS_plot.fig');
close(h_coefZS);

h_coefRaw=figure;
coefMatrix=corrcoef(CoefROIMatrixRaw');
if ~isbaseline
    yy=mean(coefMatrix);
    [~,IRaw]=sort(yy);
else
    IRaw=Indexfile.IRaw;
end
imagesc(coefMatrix(IRaw,IRaw),[0 1]);
colorbar;
ylabel('# ROIs');
title('Corelation Raw coef between ROIs');
saveas(h_coefRaw,'Popultion_coefRaw_plot.png');
saveas(h_coefRaw,'Popultion_coefRaw_plot.fig');
close(h_coefRaw);

save SortIndex.mat INor IZS IRaw -v7.3
cd ..;



%%
%ROI onset time accumulative plot
add_char='y';
m=1;
AllMegOnset = [];
AllSoundOnset = [];
h_all=figure;
hold on

while ~strcmpi(add_char,'n')
    [fname,fpath,findex]=uigetfile('*.mat','Please select your MegOnset result');
    if ~findex
        add_char='n';
        break;
    end
    MegStrc = load(fullfile(fpath,fname));
    OnsetTAll = MegStrc.RealROIonsetT;
    TrueInds = OnsetTAll ~= 0;
    OnsetTTrue = OnsetTAll(TrueInds);
    AllMegOnset = [AllMegOnset;OnsetTTrue];
    add_char=input('Do you want to add another session data?\n','s');
end
[Count,Center]=hist(AllMegOnset);
plot(Center,Count,'r-o','LineWidth',1);
saveas(h_all,'All MagOnset Distribution.png');
saveas(h_all,'All MagOnset Distribution.fig')
close(h_all);

%%
%sound onset time distribution
add_char='y';
while ~strcmpi(add_char,'n')
    [fname,fpath,findex]=uigetfile('*.mat','Please select your SoundOnset result');
    if ~findex
        add_char='n';
        break;
    end
    SoudStrc = load(fullfile(fpath,fname));
    OnsetTAll = SoudStrc.RealROIonsetT;
    TrueInds = OnsetTAll ~= 0;
    OnsetTTrue = OnsetTAll(TrueInds);
    AllSoundOnset = [AllSoundOnset;OnsetTTrue];
    add_char=input('Do you want to add another session data?\n','s');
end
h_all=figure;
[Count,Center]=hist(AllSoundOnset);
plot(Center,Count,'r-o','LineWidth',1);
saveas(h_all,'All MagOnset Distribution.png');
saveas(h_all,'All MagOnset Distribution.fig')
close(h_all);

%%
%Plot together
MegMean = mean(AllMegOnset);
SoundMean = mean(AllSoundOnset);
h_allPlot = figure;
hold on;
b=bar([1,3],[MegMean,SoundMean],'c','facealpha',0.2,'LineWidth',1);
BarWidth = b.BarWidth;
MegRandXinds = (1-BarWidth/2)+rand(length(AllMegOnset),1);
SodRandXinds = (3-BarWidth/2)+rand(length(AllSoundOnset),1);
MSEM = std(AllMegOnset)/sqrt(length(AllMegOnset));
SSEM = std(AllSoundOnset)/sqrt(length(AllSoundOnset));
plot(MegRandXinds,AllMegOnset,'o','color',[.8 .8 .8],'MarkerSize',4);
plot(SodRandXinds,AllSoundOnset,'o','color',[.8 .8 .8],'MarkerSize',4);
errorbar([1,3],[MegMean,SoundMean],[MSEM,SSEM],'bo','Linewidth',1.4);
set(gca,'xtick',[1,3],'xticklabel',{'MagOn','SoundOn'});
[h,p]=ttest2(AllMegOnset(:),AllSoundOnset(:));
ylabel('Onset Time(s)');
title({sprintf('MagMean = %.3f, SoundMean = %.3f',MegMean,SoundMean),sprintf('Pvalue = %.3f',p)});

%%
saveas(h_allPlot,'ComparePlot.png');
saveas(h_allPlot,'ComparePlot.fig');
close(h_allPlot);
