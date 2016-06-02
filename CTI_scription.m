RealCTI=[];
FitCTI=[];
RealCTISum=[];
FitCTISum=[];
m=1;

%%
[filename,filepath,~]=uigetfile('randCurveFit.mat','Select the data file contains both behav points and fitted points');
datafile=load(fullfile(filepath,filename));
cd(filepath);

%%
FittedPoints=datafile.fityAll;
RealPoints=datafile.realy;
FittedPointsAll(m,:)=FittedPoints;
RealPointsAll(m,:)=RealPoints;
PointsNUm=length(FittedPoints);
SignedFunc=[(-1)*ones(1,PointsNUm/2) ones(1,(PointsNUm/2))]';
SumscalorFit=sum((FittedPoints-0.5).*SignedFunc)/(PointsNUm/2);
SumscalorReal=sum((RealPoints-0.5).*SignedFunc')/(PointsNUm/2);

MeanFitLeft=mean(FittedPoints(1:PointsNUm/2));
MeanFitRight=mean(FittedPoints((PointsNUm/2+1):end));
MeanRealLeft=mean(RealPoints(1:PointsNUm/2));
MeanRealRight=mean(RealPoints((PointsNUm/2+1):end));
RealCorrFactor=2/(RealPoints(end)-RealPoints(1)+1);
FitCorrFactor=2/(FittedPoints(end)-FittedPoints(1)+1);
RealCTI(m)=(abs(MeanRealRight-MeanRealLeft))*RealCorrFactor;
FitCTI(m)=(abs(MeanFitRight-MeanFitLeft))*FitCorrFactor;
RealCTISum(m)=SumscalorFit*RealCTI(m);
FitCTISum(m)=SumscalorReal*FitCTI(m);

m=m+1;


%%
% m=1;
SignedFunc=[(-1)*ones(1,PointsNUm/2) ones(1,(PointsNUm/2))]';
for n=1:size(FittedPointsAll,1)
    FittedPoints=FittedPointsAll(n,:);
    RealPoints=RealPointsAll(n,:);
    PointsNUm=length(FittedPoints);
    
    SumscalorFit=sum((FittedPoints-0.5).*SignedFunc')/(PointsNUm/2);
    SumscalorReal=sum((RealPoints-0.5).*SignedFunc')/(PointsNUm/2);

    MeanFitLeft=mean(FittedPoints(1:PointsNUm/2));
    MeanFitRight=mean(FittedPoints((PointsNUm/2+1):end));
    MeanRealLeft=mean(RealPoints(1:PointsNUm/2));
    MeanRealRight=mean(RealPoints((PointsNUm/2+1):end));
    RealCorrFactor=2/(RealPoints(end)-RealPoints(1)+1);
    FitCorrFactor=2/(FittedPoints(end)-FittedPoints(1)+1);
    RealCTI(n)=(abs(MeanRealRight-MeanRealLeft))*RealCorrFactor;
    FitCTI(n)=(abs(MeanFitRight-MeanFitLeft))*FitCorrFactor;
    RealCTISum(n)=SumscalorFit*RealCTI(n);
    FitCTISum(n)=SumscalorReal*FitCTI(n);
end
cd('E:\');
save IndexSumdata.mat RealCTI FitCTI RealCTISum FitCTISum -v7.3
%%
h=figure;
hold on
plot(ones(1,length(RealCTI))*0.5,RealCTI,'ro',0.5,mean(RealCTI),'rp','MarkerSize',10);
plot(ones(1,length(RealCTI))*1.5,RealCTISum,'r*',1.5,mean(RealCTISum),'rp','MarkerSize',10);
plot(ones(1,length(RealCTI))*2.5,FitCTI,'ko',2.5,mean(FitCTI),'kp','MarkerSize',10);
plot(ones(1,length(RealCTI))*3.5,FitCTISum,'k*',3.5,mean(FitCTISum),'kp','MarkerSize',10);
xlim([0 4])
set(gca,'xtick',[1 3])
set(gca,'xticklabel',{'BehavData','NeuroData'})
ylabel('Index')


%%
%load plot data from a fig file

axesOBJ=get(gcf,'Children');
dataOBJ=get(axesOBJ,'Children');
xdata=get(dataOBJ,'XData');
ydata=get(dataOBJ,'YData');

