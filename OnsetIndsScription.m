
RawData=plotROIdata;
SmoothData=smooth(plotROIdata,10/length(plotROIdata),'rloess');  %using 10 data points to do the rloess smooth
smoothdiff=diff([SmoothData(1);SmoothData]);
smoothdiffPT=smoothdiff>0;
smoothdiffPTsmooth=smooth(double(smoothdiffPT),9);   %at least 9 data points should be positive diff if their are stim onset data
EstimateHalfOnsetInds=fix(smoothdiffPTsmooth)==1;
EstimateHalfOnsetIndsD=double(EstimateHalfOnsetInds);

LongerOnsetInds=[0;diff(EstimateHalfOnsetIndsD)];
ADHalfOnsetLogical=LongerOnsetInds==1;
ADHalfOnsetRealInds=find(double(ADHalfOnsetLogical));

%find smooth data onset inds for each selected onset inds
OnsetRealInds=zeros(size(ADHalfOnsetRealInds));
for n=1:length(ADHalfOnsetRealInds)
    CurrentInds=ADHalfOnsetRealInds(n);
    while smoothdiff(CurrentInds)>0
        CurrentInds=CurrentInds-1;
    end
    OnsetRealInds(n)=CurrentInds;
end

%Adjust real onset inds from raw data    
RawDatdiff=[0;diff(RawData)];
RawDatdiffLogical=RawDatdiff>0;
RawOnsetRealInds=zeros(size(OnsetRealInds));
for m=1:length(OnsetRealInds)-3
    CurrentInds=OnsetRealInds(m);
    while sum(RawDatdiffLogical(CurrentInds:CurrentInds+2))<3
        CurrentInds=CurrentInds+1;
    end
    RawOnsetRealInds(m)=CurrentInds-1;
end

RawOnsetRealInds(RawOnsetRealInds==0)=[];

%false error correction
for k=1:length(RawOnsetRealInds)
    CurrentInds=RawOnsetRealInds(k);
    AfterOnsetData=RawData(CurrentInds:CurrentInds+20);
    DiffDelta=max(AfterOnsetData)-min(AfterOnsetData);
    if DiffDelta<mad(RawData)
        RawOnsetRealInds(k)=0;
    end
end
RawOnsetRealInds(RawOnsetRealInds==0)=[];

%%
figure;plot(plotROIdata)
hold on
scatter(RawOnsetRealInds,plotROIdata(RawOnsetRealInds),30,'o','r')