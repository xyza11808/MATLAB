% extract Data and calculate deltaf/f
clear
clc
[filename,SessPath,Findex]=uigetfile('*.mat','Select your 2p analysis storage data','MultiSelect','on');
if ~Findex
    disp('Quit analysis...\n');
    return;
end
cd(SessPath);
% files=dir('*.mat');
for i=1:length(filename)
    RealFileName=filename{i};
    x=load(RealFileName);
    if (isfield(x,'CaTrials') || isfield(x,'CaSignal'))
%     if strncmp(RealFileName,'CaTrials',8)
        export_filename_raw=RealFileName(1:end-4);
        fieldN=fieldnames(x);
        CaTrials=x.(fieldN{1});
        SimpleDataStore=0;
%     elseif strncmp(RealFileName,'CaSignal',8)
%         export_filename_raw=RealFileName(1:end-4);
    end
    if isfield(x,'SavedCaTrials')
        export_filename_raw=RealFileName(1:end-4);
        fieldN=fieldnames(x);
        CaTrials=x.(fieldN{1});
        SimpleDataStore=1;
    end
    if isfield(x,'ROIinfo')
        ROIinfo=x.ROIinfo;
        SimpleROIinfo=0;
    elseif isfield(x,'ROIinfoBU')
        ROIinfo=x.ROIinfoBU;
        SimpleROIinfo=1;
    end
    
    disp(['loading file ',RealFileName,'...']);
end
FrameRate = round(1000/CaTrials.FrameTime);
RawDataAll = CaTrials.f_raw;
[f_raw_trials,f_percent_change,exclude_inds]=FluoChangeCa2NPl(CaTrials,[],[],5,'Ana',ROIinfo,[]);

%%
nROIs = CaTrials.nROIs;
ROISessTrace = [];
ROIrawTrace = [];
for cROI = 1 : nROIs
    cROIdataCell = cellfun(@(x) x(cROI,:),f_percent_change,'UniformOutput',false);
    cRawData = cellfun(@(x) x(cROI,:),RawDataAll,'UniformOutput',false);
    cROIdata = cell2mat(cROIdataCell');
    ROISessTrace(cROI,:) = cROIdata;
    ROIrawTrace(cROI,:) = cell2mat(cRawData');
end

%
hh_f = figure;
imagesc(ROISessTrace,[0 200]);
colorbar;
saveas(hh_f,'ROI colormap plot save');
saveas(hh_f,'ROI colormap plot save','png');
save RawDataSave.mat f_percent_change ROISessTrace ROIrawTrace -v7.3

%
if ~isdir('./ROI_SigTrace_Plot/')
    mkdir('./ROI_SigTrace_Plot/');
end
cd('./ROI_SigTrace_Plot/');

ROIPeakIndsAll = cell(size(ROISessTrace,1),1);
ROIpeakTraceAll = cell(size(ROISessTrace,1),1);
for cROI = 1 : size(ROISessTrace,1)
    %
    cROIdataRaw = ROISessTrace(cROI,:);
    nFrames = length(cROIdataRaw);
    xInds = 1:nFrames;
    [PeakPosInds, PeakAreaInds,IsPeakTraceExist] = CusLocalPeakSearch(cROIdataRaw,[],[]);
    UsedPeakPoints = PeakPosInds(logical(IsPeakTraceExist));
    SigTrans = cROIdataRaw;
    SigTrans(~PeakAreaInds) = nan;
    hf = figure('position',[10 100 1600 300]);
    plot(xInds,cROIdataRaw,'linewidth',0.8,'Color','k');
    hold on
    plot(xInds(UsedPeakPoints),cROIdataRaw(UsedPeakPoints),'co','linewidth',3,'MarkerSize',14)
    plot(xInds,SigTrans,'r','linewidth',2)
    %
    saveas(hf,sprintf('ROI%d SigEvents detection plot',cROI));
    saveas(hf,sprintf('ROI%d SigEvents detection plot',cROI),'png');
    close(hf);
    ROIPeakIndsAll{cROI} = UsedPeakPoints;
    ROIpeakTraceAll{cROI} = PeakAreaInds;
end
save SigtransientsNum.mat ROIPeakIndsAll ROIpeakTraceAll -v7.3
cd ..;
%%
figure;
plot(ROIrawTrace(2,:))

%%
figure;
plot(ROISessTrace(2,:))
nFrames = size(ROISessTrace,2);
%%
cROIRawData = ROIrawTrace(2,:);
[Counts,Centers] = hist(cROIRawData,100);
% figure
% bar(Centers,Counts);
[~,MaxInds] = max(Counts);
ModValue = Centers(MaxInds);
cChangeData = (cROIRawData - ModValue)/ModValue*100;
figure;
yyaxis left
plot(cROIRawData);

yyaxis right
plot(cChangeData);

DataDiff = diff(cChangeData);
DataDiff = [DataDiff(1),DataDiff];
figure;
plot(DataDiff)

%%
cROI = 13;
FrameRate = round(1000/CaTrials.FrameTime);
cROIdata = ROIrawTrace(cROI,:);
[SubTempData_2,~]=BLSubStract(cROIdata',8,FrameRate*20);
[SubTempData_3,~]=BLSubStract(cROIdata',8,FrameRate*30);

hhf = figure;
yyaxis left
plot(cROIdata);

yyaxis right
hold on
plot(SubTempData_2,'b');
plot(SubTempData_3,'r');


%% detect peak position
cROIdataRaw = ROISessTrace(2,:);
nFrames = length(cROIdataRaw);
SplineData = fit((1:nFrames)',(ROISessTrace(2,:))','Smoothingspline');
SplineRealData = feval(SplineData,(1:nFrames)');
findpeaks(SplineRealData,'MinPeakHeight',ans*3,'MinPeakDistance',28)
hold on

%%
% summrized session data together
[fn,fp,fi] = uigetfile('*.txt','Please select session path file');
if ~fi
    return;
end
%%
fPath = fullfile(fp,fn);
fid = fopen(fPath);
tline = fgetl(fid);
nSess = 1;
SessPeakData = {};
SessNumData = {};

while ischar(tline)
    if isempty(strfind(tline,'ROI_SigTrace_Plot'))
        tline = fgetl(fid);
        continue;
    end
    
    cFilepath = fullfile(tline,'SigtransientsNum.mat');
    cSessData = load(cFilepath);
    SessPeakData{nSess} = cSessData.ROIPeakIndsAll;
    cPeaknum = cellfun(@length,cSessData.ROIPeakIndsAll);
    SessNumData{nSess} = cPeaknum;
    nSess = nSess + 1;
    tline = fgetl(fid);
end

%%
GrTypes = {'0\_5Af','1\_5Af','1Af','2Af','EventBf'};
SessNumMtx = cell2mat(SessNumData);
GrdistPlot(SessNumMtx,GrTypes);
ylabel('EventNum')
MaxV = max(max(SessNumMtx));
line([0.5 4.5],[MaxV MaxV]+4,'Color','k','Linewidth',1.8)
text(2.5,MaxV+5,'***','HorizontalAlignment','center','FontSize',24)
set(gca,'ylim',[0 MaxV+10])
