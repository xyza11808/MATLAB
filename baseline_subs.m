%this scription is used to test baseline substraction methods
[filename,filepath,~]=uigetfile('*.mat','Select calcium analysis data');
cd(filepath);
x=load(fullfile(filepath,filename));
try
    CaTrialStruc=x.CaTrials;
catch
    CaTrialStruc=x.SavedCaTrials;
end
nTrials=length(CaTrialStruc);
if nTrials==1
    nTrials=CaTrialStruc(1).TrialNum;
    SingleCas=1;
else
    SingleCas=0;
end
nROIs=CaTrialStruc(1).nROIs;
nFrames=CaTrialStruc(1).nFrames;
FrameRate=floor(1000/CaTrialStruc(1).FrameTime);

if ~SingleCas
    RawDataAll=zeros(nTrials,nROIs,nFrames);
    RIngRawData=zeros(nTrials,nROIs,nFrames);
    for n=1:nTrials
        RawDataAll(n,:,:)=CaTrialStruc(n).f_raw;
        RIngRawData(n,:,:)=CaTrialStruc(n).RingF;
    end
else
    RawDataAll=CaTrialStruc(1).f_raw;
    RIngRawData=CaTrialStruc(1).RingF;
end


%%
f = [0 0.5 0.7 0.3];
for nnnnnn = 1 : 4
FactorAdj = f(nnnnnn);
if ~isdir(sprintf('./RawDatPlot_F%d/',FactorAdj*100))
    mkdir(sprintf('./RawDatPlot_F%d/',FactorAdj*100));
end
cd(sprintf('./RawDatPlot_F%d/',FactorAdj*100));

AJData=zeros(size(RawDataAll));
F0Raw=zeros(nROIs,1);
F0Aj=zeros(nROIs,1);
for n=1:nROIs
    TempROIData=(squeeze(RawDataAll(:,n,:)))';
    TempNPData=(squeeze(RIngRawData(:,n,:)))';
    h=figure('position',[200 100 1300 1000],'paperpositionmode','auto');
    subplot(3,1,1)
    RawStd=mad(TempROIData(:),1);
    plot(TempROIData(:));
    RawYlim=get(gca,'ylim');
    title(sprintf('Raw Data ROI%d with Std=%.2f',n,RawStd));
    
    subplot(3,1,2)
    plot(TempNPData(:));
    coeecoef=corrcoef(TempROIData(:),TempNPData(:));
    title(sprintf('Raw Neuropil Data,Coef with Raw=%.3f',coeecoef(1,2)));
    
    baseline=mean(TempNPData(:));
    CorrectData=TempROIData-FactorAdj*TempNPData;  
%     CorrectRate=sum(CorrectData(:)<baseline)/numel(CorrectData);
%     CorrectData(CorrectData<baseline)=baseline;  %avoid over-correction
   
    [N,C]=hist(TempROIData(:),100);
    [~,I]=max(N);
    F0Raw(n)=C(I);
    [N,C]=hist(CorrectData(:),100);
    [~,I]=max(N);
    F0Aj(n)=C(I);
    
    
    AJData(:,n,:)=CorrectData';
    subplot(3,1,3)
    plot(CorrectData(:));
    ylim(RawYlim);
    title({'Neuropile corrected data',sprintf('F_0Raw=%.2f,F_0NP=%.2f F_0AJe=%.2f',F0Raw(n),baseline,F0Aj(n))});
    
    saveas(h,sprintf('Raw Data ROI%d.png',n));
    saveas(h,sprintf('Raw Data ROI%d.fig',n));
    close(h);
end

cd ..;

%
%NP delta f/f0 plus population ROIs corrcoef matrix
if ~isdir(sprintf('./DeltaFluo_DatPlot_F%d/',FactorAdj*100))
    mkdir(sprintf('./DeltaFluo_DatPlot_F%d/',FactorAdj*100));
end
cd(sprintf('./DeltaFluo_DatPlot_F%d/',FactorAdj*100));
FAjchange = zeros(size(RawDataAll));
FRawChange = zeros(size(RawDataAll));
for n=1:nROIs
    TempROIData=(squeeze(RawDataAll(:,n,:)))';
    TempAJData=(squeeze(AJData(:,n,:)))';
    RawDeltaF=(TempROIData-F0Raw(n))/F0Raw(n)*100;
    AJDeltaF=(TempAJData-F0Aj(n))/F0Aj(n)*100;
    FAjchange(:,n,:)=AJDeltaF';
    FRawChange(:,n,:)=RawDeltaF';
    xTime=(1:numel(RawDeltaF))/FrameRate;
%     [f_raw_trials,f_percent_change,exclude_inds]=FluoChangeCal(CaTrialStruc,behavResults,behavSettings,3,'2afc',ROIinfoBU);
    
%     h=figure('position',[200 100 1300 1000],'paperpositionmode','auto');
% %     [hAx,hLine1,hLine2]=plotyy(xTime,RawDeltaF(:),xTime,AJDeltaF(:));
% %      set(hLine1,'color','b')
% %      set(hLine2,'color','r')
%      plot(xTime,RawDeltaF(:),'k',xTime,AJDeltaF(:),'r');
%      legend('Raw \DeltaF/f_0','Adjust \DeltaF/f_0','location','northeast');
%      ylabel('\DeltaF/f_0');
%      xlabel('Time (s)');
%      saveas(h,sprintf('FChange Data ROI%d.png',n));
%      saveas(h,sprintf('FChange Data ROI%d.fig',n));
%      close(h);
     %
     hcolor=figure('position',[200 100 1300 1000],'paperpositionmode','auto');
     subplot(1,2,1);
     imagesc(AJDeltaF');
     colorbar;
%      RawcLim=get(gca,'clim');
     title('Color plot');
     
     subplot(1,2,2)
     hold on;
     ybase = 0;
     for nRTrial = 1 : nTrials
        cTrace = AJDeltaF(:,nRTrial);
        plot(cTrace+ybase,'k','LineWidth',1.2);
        ybase = ybase + max(cTrace) + 30;
     end
     ylim([-20 ybase+50]);
%      colorbar;
     title('Adjusted Fchange Color plot');
     %
     suptitle(sprintf('ROI%d color plot',n));
     saveas(hcolor,sprintf('FChange Data colorplot ROI%d.png',n));
     saveas(hcolor,sprintf('FChange Data colorplot ROI%d.fig',n));
     close(hcolor);
end

cd ..;
end
%%
[filename,filepath,~]=uigetfile('*.mat','Select ROI info mat file');
cd(filepath);
x=load(fullfile(filepath,filename));
if isfield(x,'ROIinfoBU')
    AllROIinfo=x.ROIinfoBU;
else
    AllROIinfo=x.ROIinfo(1);
end

%%%%
%%
AllROImask=AllROIinfo.ROImask;
AllRingMask=AllROIinfo.Ringmask;
emptyinds=cellfun(@isempty,AllROImask);
if sum(emptyinds)
    AllROImask(AllROImask)=[];
    AllRingMask(AllROImask)=[];
end
nROIs=length(AllRingMask);

sumROImask=AllROImask{1};
sumRingMask=AllRingMask{1};
for n=2:nROIs
    currentROImask=AllROImask{n};
    CurrentRIngMask=AllRingMask{n};
    TempsumROImask=sumROImask+currentROImask;
    TempsumRingMask=sumRingMask+CurrentRIngMask;
    overlapIndsROI=find(TempsumROImask==2);
    overlapIndsRing=find(TempsumRingMask==2);
    if ~isempty(overlapIndsROI)
        currentROImask(overlapIndsROI)=false;
        TempsumROImask=sumROImask+currentROImask;
    end
    if ~isempty(overlapIndsRing)
        CurrentRIngMask(overlapIndsRing)=false;
        TempsumRingMask=sumRingMask+CurrentRIngMask;
    end
    sumROImask=TempsumROImask;
    sumRingMask=TempsumRingMask;
end
ROImaskValue=sumROImask*2;
ROIRingMask=ROImaskValue+sumRingMask;

h=figure;
imagesc(ROIRingMask)
colormap jet
colorbar
saveas(h,'ROI mask plot.png');
saveas(h,'ROI mask plot.fig');

%%
%ROI position correlation with ROI corrcoef
centerROI=ROI_insite_label(AllROIinfo,0);
if ~isdir('./Raw data coerrcoef/')
    mkdir('./Raw data coerrcoef/');
end
cd('./Raw data coerrcoef/');
ROICoefDisCorr(RawDataAll,centerROI);
cd ..;

if ~isdir('./NP data coerrcoef/')
    mkdir('./NP data coerrcoef/');
end
cd('./NP data coerrcoef/');
ROICoefDisCorr(RIngRawData,centerROI);
cd ..;

if ~isdir('./AJ data coerrcoef/')
    mkdir('./AJ data coerrcoef/');
end
cd('./AJ data coerrcoef/');
ROICoefDisCorr(FAjchange,centerROI);
cd ..;

%%
%f change coeff
if ~isdir('./Fchange coerrcoef/')
    mkdir('./Fchange coerrcoef/');
end
cd('./Fchange coerrcoef/');

centerROI=ROI_insite_label(AllROIinfo,0);
if ~isdir('./RawFchange data coerrcoef/')
    mkdir('./RawFchange data coerrcoef/');
end
cd('./RawFchange data coerrcoef/');
ROICoefDisCorr(FRawChange,centerROI);
cd ..;

% if ~isdir('./AJFchange data coerrcoef/')
%     mkdir('./RawFchange data coerrcoef/');
% end
% cd('./RawFchange data coerrcoef/');
% ROICoefDisCorr(RawDataAll,centerROI);
% cd ..;

cd ..;
%%
RawDataAllsub=zeros(nTrials,nROIs,nFrames);
FchanDataAllsub=zeros(nTrials,nROIs,nFrames);
ROIThres=zeros(1,nROIs);
ROIBaseline=zeros(1,nROIs);
for m=1:nROIs
    ROIData=squeeze(RawDataAll(:,m,:));
    [SubData,~,SubchangeData,SerialF0]=BLSubStract(ROIData',8,FrameRate*15);
    RawDataAllsub(:,m,:)=SubData';
% % %     ROIChangeData=((SubData'-f0)/f0)*100;

%     [~,ncenters]=hist(SubData(:),80);
%     BelowHalfPercent=sum(SubData(:)<median(ncenters))/length(SubData(:));
%     if BelowHalfPercent>=0.95
%         f0=prctile(SubData(:),5);
%     elseif BelowHalfPercent<=0.5
%         f0=median(SubData(:));
%     else
%         f0=prctile(SubData(:),(1-BelowHalfPercent)*100);
%     end

    [ncounts,ncenters]=hist(SubData(:),100);
    [~,I]=max(ncounts);
    f0=ncenters(I);
    ROIChangeData=((SubData'-f0)/f0)*100;
    FchanDataAllsub(:,m,:)=SubchangeData';
    
    ROIThres(m)=mad(ROIChangeData(:),1)*1.4826;
    [ncounts,ncenters]=hist(ROIChangeData(:),80);
    [~,I]=max(ncounts);
    fbase=ncenters(I);
    ROIBaseline(m)=fbase;
end

%%
%ROI color plot
for n=1:nROIs
    ROIData=squeeze(RawDataAll(:,n,:));
    h_ROI=figure;
    subplot(2,1,1);
    imagesc(ROIData,[0 min(500,max(ROIData(:)))]);
    colorbar
    title(sprintf('ROI Number %d',n));
    
    subplot(2,1,2)
    hist(ROIData(:),100);
    
    saveas(h_ROI,sprintf('Color_plot_ROI%d.png',n));
    close(h_ROI);
end

%%
% ROInum=1;
if ~isdir('./baseline_correction_percentile/')
    mkdir('./baseline_correction_percentile/');
end
cd('./baseline_correction_percentile/');
for ROInum=1:nROIs
    h=figure;
    subplot(2,1,1)
    RawDataROI=squeeze(RawDataAll(:,ROInum,:));
    imagesc(RawDataROI,[0 400]);
%     plot(reshape(RawDataROI',[],1));
    title('Raw data')

    subplot(2,1,2)
    SubDataROI=squeeze(FchanDataAllsub(:,ROInum,:));
    imagesc(SubDataROI,[0 400]);
%     plot(reshape(SubDataROI',[],1));
    scale=axis;
    line([scale(1),scale(2)],[ROIBaseline(ROInum),ROIBaseline(ROInum)],'color','r','LineWidth',2);
%     line([scale(1),scale(2)],[ROIBaseline(ROInum)+2*ROIThres(ROInum),ROIBaseline(ROInum)+2*ROIThres(ROInum)],'color','g','LineWidth',2);
    title('Substracted data')
    suptitle(sprintf('ROI%d',ROInum));
    saveas(h,sprintf('test_saveROI%d.png',ROInum));
    saveas(h,sprintf('test_saveROI%d.fig',ROInum));
    close(h);
end
cd ..;

%%
%significant trace detection
ISSigTransient=zeros(size(FchanDataAllsub));
EventsOnInds=zeros(size(FchanDataAllsub));
EventsOffInds=zeros(size(FchanDataAllsub));
for ROInum=1:nROIs
    for TrialNum=1:nTrials
        singleTrace=squeeze(FchanDataAllsub(TrialNum,ROInum,:));
        EventsOn=0;
        EventsOff=0;
        mm=1;
        while mm<=length(singleTrace)
            if singleTrace(mm)>(ROIBaseline(ROInum)+2*ROIThres(ROInum)) && ~EventsOn
                EventsOn=1;
                EventsOff=0;
                ISSigTransient(TrialNum,ROInum,mm)=1;
                EventsOnInds(TrialNum,ROInum,mm)=1;
            else
                mm=mm+1;
                continue;
            end
            if EventsOn
                while singleTrace(mm)>(ROIBaseline(ROInum)+0.5*ROIThres(ROInum))
                    ISSigTransient(TrialNum,ROInum,mm)=1;
                    mm=mm+1;
                    if mm>length(singleTrace)
                        break;
                    end
                end
                if mm>length(singleTrace)  %reach the end of trace
                    EventsOn=0;
                    EventsOff=0;
                    EventsOffInds(TrialNum,ROInum,end)=1;
                else                       %stopped within trace
                    EventsOn=0;
                    EventsOff=1;
                    EventsOffInds(TrialNum,ROInum,mm-1)=1;
                end
            end
        end
    end
end


%%
ROInum=1;
ROIdata=squeeze(FchanDataAllsub(:,ROInum,:));
plotROIdata=reshape(ROIdata',[],1);
SigInds=squeeze(ISSigTransient(:,ROInum,:));
plotSigInds=reshape(SigInds',[],1);
SigPlorData=plotROIdata;
SigPlorData(~plotSigInds)=NaN;  %ignoring non-sig data points
% inds=find(plotSigInds);
figure;
hold on;
plot(plotROIdata,'color',[.8 .8 .8]);
plot(SigPlorData,'color','r','LineWidth',2);
hold off

figure;
SigPlorData=plotROIdata;
SigPlorData(~plotSigInds)=0;
plot(SigPlorData);


%%
ROInum=1;
fs=55;
ROIdata=squeeze(FchanDataAllsub(:,ROInum,:));
plotROIdata=reshape(ROIdata',[],1);
figure;
plot(plotROIdata,'color','b');
xdft = fft(plotROIdata);
N=length(plotROIdata);
magY=abs(xdft(1:N/2+1))*2/length(plotROIdata);
freq = ((1:N/2+1)-1)'*fs/N; 
figure;
magY(1)=0;  %remove DC
plot(freq,magY);


%%
fd=0.1;
fu=2;
fs=55;
Fst=0.15;
% [B,A]=fir1(44,[fd fu]/(fs/2));
% limited_noise=filter(B,A,plotROIdata);  %this filter is usable

[B,A]=fir1(44,0.1,'low');
limited_noise=filter(B,A,plotROIdata);  %zero-phase filtering
% d=fdesign.bandpass('Fp1,Fp2',0.01,10,55);
% Hd = design(d,'equiripple');
% filterdata=filter(Hd,plotROIdata);
figure;
plot(limited_noise,'color','g')
% xlim([2000 3000])

% d = fdesign.bandpass('N,Fp1,Fp2,Ast1,Ap,Ast2',44,fd/(fs/2),fu/(fs/2),60,1,60);
% low pass filter
d=fdesign.lowpass('Fp,Fst,Ap,Ast',fd,Fst,1,80);
M = designmethods(d);
Hd = design(d,'equiripple');
afterfilter=filter(Hd,plotROIdata);
figure;
plot(afterfilter,'color','r')
 

%%
fs=55;
xdft = fft(limited_noise);
N=length(limited_noise);
magY=abs(xdft(1:N/2+1))*2/length(limited_noise);
freq = ((1:N/2+1)-1)'*fs/N; 
figure;
% magY(1)=0;  %remove DC
plot(freq,magY);

%%
n = 0:159;
x = cos(pi/8*n)+cos(pi/2*n)+sin(3*pi/4*n);

% d = fdesign.bandpass('N,Fp1,Fp2,Ast1,Ap,Ast2',44,3/8,5/8,60,1,60);
d = fdesign.bandpass('Fst1,Fp1,Fp2,Fst2,Ast1,Ap,Ast2',1/4,3/8,5/8,6/8,60,1,60);
Hd = design(d,'equiripple');

figure;
y = filter(Hd,x);
freq = 0:(2*pi)/length(x):pi;
xdft = fft(x);
ydft = fft(y);
plot(freq,abs(xdft(1:length(x)/2+1)));
hold on;
plot(freq,abs(ydft(1:length(x)/2+1)),'r','linewidth',2);
legend('Original Signal','Bandpass Signal');


%%
fs=55;
fd=0.1;
fu=10;
xdft = fft(plotROIdata);
RMxdft = xdft;
N=length(plotROIdata);
DCvalue = xdft(1);
Freq = ((1:N/2+1)-1)'*fs/N; 
BandPassFreqInds = Freq > fd & Freq < fu;
BandPassFreqIndsAll = logical([BandPassFreqInds;flipud(BandPassFreqInds(2:end))]);
RMxdft(~BandPassFreqIndsAll) = complex(0);
RMxdft(1) = DCvalue;
magY = abs(RMxdft(1:N/2+1))*2/N;

RMsignal=ifft(RMxdft,N);
figure;
subplot(2,1,1)
plot(plotROIdata,'color','b');
xlim([2000,3000])
title('Raw data')

subplot(2,1,2)
plot(real(RMsignal),'color','r');
xlim([2000,3000])
title('Freq remove signal');


%%
fitdata=plotROIdata(6000:6480);  %for ROI1 
TimeSpan=length(fitdata);
xTime=1:TimeSpan;
t0=54;
t1=158;

BeforeBaseline=mean(fitdata(1:t0));
AJfitdata=fitdata-BeforeBaseline;

t0All=OnsetTEMT();  %this should be a function used for onset time estimate and return is result
for nTimeOn=1:length(t0All)
    t0=t0All(nTimeOn);
    options=fitoptions('Method', 'NonlinearLeastSquares','Robust','LAR','Startpoint',[10,1,1,1,1],...
        'Algorithm','Trust-Region','Lower',[2,-Inf,-Inf,-Inf,-Inf],...
        'Upper',[100,Inf,Inf,Inf,Inf],'MaxIter',100000);  %
    ft=fittype('EventsFitFun(x,TauOn,A1,Tau1,A2,Tau2)','coefficients',{'TauOn','A1',...
        'Tau1','A2','Tau2'},'independent','x');
    fitobj=fit(xTime',AJfitdata,ft,options);
    
end

%%
TauOn=fitobjAJ.TauOn;
A1=fitobjAJ.A1;
Tau1=fitobjAJ.Tau1;
A2=fitobjAJ.A2;
Tau2=fitobjAJ.Tau2;
fitdata=EventsFitFun(xTime',TauOn,A1,Tau1,A2,Tau2);
residues=AJfitdata-fitdata;
figure;
plot(residues)
%%
%double peak fitting options
% options=fitoptions('Method', 'NonlinearLeastSquares','Robust','Bisquare','Startpoint',[10,1,1,1,1,1,1,1,1],...
%         'Algorithm','Trust-Region','Lower',[2,-Inf,-Inf,-Inf,-Inf,-Inf,-Inf,-Inf,-Inf],...
%         'Upper',[100,Inf,Inf,Inf,Inf,Inf,Inf,Inf,Inf],'MaxIter',100000);  %
%     ft=fittype('EventsFitFun(x,TauOn,A1,Tau1,A2,Tau2,A3,Tau3,A4,Tau4)','coefficients',{'TauOn','A1',...
%         'Tau1','A2','Tau2','A3','Tau3','A4','Tau4'},'independent','x');


%%
% peeling algorithm fitting of raw data
FitDataAll=zeros(size(plotROIdata));
FitInds=zeros(size(plotROIdata));
PlotDataBU1=plotROIdata;
plotROIdata=plotROIdata-min(plotROIdata);
PlotDataBU2=plotROIdata;
t0All=onset;
toffAll=offset;

%  [t0All,toffAll]=OnsetTEMT();  %this should be a function used for onset time estimate and return is result
%Onset time should be inds of single session data

%%

for OnsetInds=1:length(t0All)
    OnsetTime=t0All(OnsetInds);
    OffTime=toffAll(OnsetInds);
    DataScale=(OnsetTime-30):OffTime;
    if DataScale(1)<1
        DataScale=1:OffTime;
        continue;
    end
    FitInds(DataScale(31:end))=1;
    AJfitdata=PlotDataBU2(DataScale);
    AJbaselineValue=AJfitdata(30);
%     BeforeONMean=mean(AJfitdata(1:30));
    
     AJfitdata(AJfitdata<0)=0;
    xTime=1:length(AJfitdata);
    options=fitoptions('Method', 'NonlinearLeastSquares','Robust','LAR','Startpoint',[10,1,1,1,1],...
        'Algorithm','Trust-Region','Lower',[2,-Inf,0,-Inf,0],...
        'Upper',[40,Inf,200,Inf,200],'MaxIter',100000);  %
    ft=fittype('EventsFitFun(x,TauOn,A1,Tau1,A2,Tau2)','coefficients',{'TauOn','A1',...
        'Tau1','A2','Tau2'},'independent','x');
    try
        AJfitdata(1:30)=0;
        fitobjAJ=fit(xTime',AJfitdata,ft,options);
        baselineC=0;
    catch
        try
            AJfitdata=PlotDataBU2(DataScale);
            AJfitdata=AJfitdata-AJbaselineValue;
            fitobjAJ=fit(xTime',AJfitdata,ft,options);
            baselineC=1;
        catch
            AJfitdata(31:end)=AJfitdata(31:end)-AJbaselineValue;
            AJfitdata(AJfitdata<0)=0;
            fitobjAJ=fit(xTime',AJfitdata,ft,options);
            baselineC=1;
        end
    end
    
    
    TauOn=fitobjAJ.TauOn;
    A1=fitobjAJ.A1;
    Tau1=fitobjAJ.Tau1;
    A2=fitobjAJ.A2;
    Tau2=fitobjAJ.Tau2;
    fitdata=EventsFitFun(xTime',TauOn,A1,Tau1,A2,Tau2);
    if baselineC
        AJfitdata=zeros(size(fitdata));
        AJfitdata(31:end)=fitdata(31:end)+AJbaselineValue;
    else
        AJfitdata=fitdata;
    end
    plotROIdata(DataScale)=plotROIdata(DataScale)-AJfitdata;
    FitDataAll(DataScale(31:end))=AJfitdata(31:end);
end
residues=plotROIdata;
plotROIdata=PlotDataBU1;
figure;
subplot(2,1,1)
plot(plotROIdata);
title('Raw Data');

subplot(2,1,2)
plot(FitDataAll);
title('fitData');

figure;
FitInds=logical(FitInds);
FitDataNewAll=FitDataAll;
FitDataNewAll(~FitInds)=plotROIdata(~FitInds);
plot(FitDataNewAll);

for n=1:length(t0All)
    FitDataNewAll(t0All(n))=mean(FitDataNewAll(t0All(n)-2:t0All(n)+2));
    FitDataNewAll(toffAll(n))=mean(FitDataNewAll(toffAll(n)-2:toffAll(n)+2));
end
figure;
plot(FitDataNewAll);


%%
%zero-phase filter
d1 = designfilt('lowpassfir', 'FilterOrder', 40, 'PassbandFrequency', 0.1, 'StopbandFrequency', 0.15, 'DesignMethod', 'equiripple');
y = filtfilt(d1,plotROIdata);
figure;
plot(y);


%%
%plot of raw data compared with NP corrected data
[filename,filepath,~]=uigetfile('DiffFluoResult.mat','Select your data file contains both raw data and fchange data');
xData=load(fullfile(filepath,filename));
RawData=xData.RawData;
FchangeData=xData.FChangeData;
dataSize=size(RawData);

ROIRawData=reshape(permute(RawData,[2,3,1]),dataSize(2),dataSize(1)*dataSize(3));
ROIFChange=reshape(permute(FchangeData,[2,3,1]),dataSize(2),dataSize(1)*dataSize(3));

cd(filepath);
if ~isdir('./Data_compare_plot/')
    mkdir('./Data_compare_plot/');
end

%
[Behavfname,Behavfpath,~]=uigetfile('*.mat','Select the corresponded behavior analysis result');
BehavData=load(fullfile(Behavfpath,Behavfname));
StimOnTime=BehavData.behavResults.Time_stimOnset;
StimOnFrame=floor((double(StimOnTime)/1000)*FrameRate);

%
cd('./Data_compare_plot/');
for n=1:dataSize(2)
    CROIdataRaw=ROIRawData(n,:);
    CROIdataChge=ROIFChange(n,:);
    h=figure;  
    hold on;
    plot(CROIdataRaw,'color','k');
    plot(CROIdataChge,'color','r');
    y=axis;
    for TrialNum=1:dataSize(1)
        xINDS=StimOnFrame(TrialNum)+(TrialNum-1)*dataSize(3);
        line([xINDS xINDS],[y(3) y(4)],'color',[.8 .8 .8],'LineWidth',0.5);
    end
    legend('RawData','FchangeData');
    saveas(h,sprintf('ROI%d Session plot.png',n));
    saveas(h,sprintf('ROI%d Session plot.fig',n));
    close(h);
end
cd ..;
