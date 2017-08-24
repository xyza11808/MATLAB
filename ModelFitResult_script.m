TagROI = 25;
cROIdata = squeeze(NMData(:,TagROI,(start_frame+round(frame_rate*0.2)):(start_frame+round(frame_rate*1.2))));
cTrRespData = mean(cROIdata,2);

FreqTypes = unique(NMOctaves);
FreqRespData = zeros(length(FreqTypes),1);
for cFreq = 1 : length(FreqTypes)
    cFreqInds = NMOctaves == FreqTypes(cFreq);
    FreqRespData(cFreq) = mean(cTrRespData(cFreqInds));
end
GrNum = length(FreqTypes)/2;
if mod(length(FreqTypes),2)
    FreqRespData(ceil(GrNum)) = [];
    GrNum = floor(GrNum);
end
IsRevert = 0;
if mean(FreqRespData(1:GrNum)) > mean(FreqRespData(end-GrNum+1:end))
    FreqRespData = flipud(FreqRespData);
    IsRevert = 1;
end
%% using merged model, not performs good
[~,MaxInds] = max(FreqRespData);
opts = statset('nlinfit');
opts.RobustWgtFun = 'bisquare';
OctaveAll = unique(NMOctaves);
q0 = [OctaveAll(MaxInds),0.6,0]; % tuning peak, tuning width, boundary octave
p0 = rand(3,1);

FuncUsed = FuncHandle('loggauss',q0);
%
% [bCurvefit,~,~,~,bMSE,~] = nlinfit(NMOctaves(:),cTrRespData(:),FuncUsed,p0,opts);
[bCurvefit,~,~,~,bMSE,~] = nlinfit(OctaveAll(:),FreqRespData(:),FuncUsed,p0,opts);
%
Fitx = linspace(-1,1,500);
FitY = FuncUsed(bCurvefit,Fitx);
hhf = figure;
hold on
scatter(OctaveAll,FreqRespData,50,'ro');
plot(Fitx,FitY,'k','linewidth',1.5);

%
GaussPartFun = @(p,x) p*exp((-1)*((x - q0(1)).^2)./(2*(q0(2)^2)));
LogPartFun = @(a,x) (a(1)./(1+exp(-(x - q0(3))./a(2))));
plot(Fitx,GaussPartFun(bCurvefit(1),Fitx),'b','linewidth',1.5);
plot(Fitx,LogPartFun(bCurvefit([2,3]),Fitx),'m','linewidth',1.5);
DirectFitPointData = FuncUsed(bCurvefit,OctaveAll(:));

%%
% extract RF datasets
clearvars typeData
[fn,fp,fi] = uigetfile('UnevenPassdata.mat','Please select the passive response data');
load(fullfile(fp,fn));
%% FreqTypes = unique()
fprintf('Please select the used frequency index:\n');
disp(FreqTypes')
fprintf('\n');
FrqInds = input('Please input the used frequency inds:\n','s');
FreqIndex = str2num(FrqInds);
RFDataAll = squeeze(typeData(:,1,FreqIndex));
RFmeanTraceAll = cellfun(@mean,RFDataAll,'UniformOutput',false);
nROIs = size(RFmeanTraceAll,1);
nROIresp = zeros(nROIs,length(FreqIndex));
%
for cROI = 1 : nROIs
    cROIdataC = (squeeze(RFmeanTraceAll(cROI,:)))';
    cROIdata = cell2mat(cROIdataC);
    cRespData = mean(cROIdata(:,round(FrameRate*1.2):round(FrameRate*1.7)),2);
    nROIresp(cROI,:) = cRespData;
end
%% Select ROI data
% RFdata = [332.7 146.1 105.5 45.74 25.77 10.17];
RFdata = nROIresp(TagROI,:);
if mean(RFdata(1:GrNum)) > mean(RFdata(end-GrNum+1:end))
    RFdata = fliplr(RFdata);
end
[PeakValue,maxInds] = max(RFdata);
RFoctave = OctaveAll(:);
Fitx = linspace(min(OctaveAll),max(OctaveAll),500);
RFfunc = FuncHandle('gauss');
beta0 = [PeakValue,OctaveAll(maxInds),0.6];
opts.MaxIter = 10000;
bRFguass = nlinfit(RFoctave(:),RFdata(:),RFfunc,beta0,opts);
figure;
hold on
plot(RFoctave(:),RFdata(:),'ro');
plot(Fitx,RFfunc(bRFguass,Fitx),'k','linewidth',1.4);

%%
FittedY = RFfunc(bRFguass,OctaveAll);
DiffYPassTask = FreqRespData - FittedY';
figure;
hold on
plot(RFoctave,DiffYPassTask,'r-o')

%%
% IsRevert = 0;
% if mean(DiffYPassTask(1:3)) > mean(DiffYPassTask(4:6))
%     DiffYPassTask = flipud(DiffYPassTask);
%     IsRevert = 1;
% end
CategFun = FuncHandle('logit');
Taskoctave = OctaveAll(:);
Fitx = linspace(min(OctaveAll),max(OctaveAll),500);
% RFfunc = FuncHandle('gauss');
cbeta0 = [0,mean(DiffYPassTask(4:6)),1];
% cbeta0 = rand(4,1);
opts.MaxIter = 10000;
bCategFit = nlinfit(Taskoctave,DiffYPassTask(:),CategFun,cbeta0,opts);
%%
cFitata = CategFun(bCategFit,Fitx);
% if IsRevert
%     cFitata = fliplr(cFitata);
% end
plot(Fitx,cFitata,'b','linewidth',1.4);
% TestFun = CategFun([mean(DiffYPassTask)*(-1),mean(DiffYPassTask(1:3)),0.0001],Fitx);
% plot(Fitx,TestFun,'c','linewidth',1.4);
%%
hallf = figure;
hold on
plot(OctaveAll,FreqRespData,'ro');
TwoPartSum = RFfunc(bRFguass,Fitx) + cFitata;
plot(Fitx,TwoPartSum,'k','linewidth',1.4);
%%
FitSumPointData = RFfunc(bRFguass,Taskoctave) + CategFun(bCategFit,Taskoctave);
FitSumSquareError = sum((FreqRespData - FitSumPointData).^2);
DetFitSquareError = sum((FreqRespData - DirectFitPointData).^2);
figure(hallf);
title(sprintf('Square error sum = %.3e',FitSumSquareError));
figure(hhf);
title(sprintf('Square error sum = %.3e',DetFitSquareError));
