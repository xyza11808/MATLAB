
% Load 2afc response data
[fn,fp,fi] = uigetfile('FreqMeanData.mat','Please Select your 2afc ROI response summary data');
if fi
    xxxx = load(fullfile(fp,fn));
    TaskRespData = xxxx.WinData;
else
    fprintf('No file selected, quit analysis.\n');
    return;
end
cd(fp);

% Load rf response data
[fnrf,fprf,firf] = uigetfile('FreqMeanData.mat','Please Select your RF ROI response summary data');
if firf
    xxx = load(fullfile(fprf,fnrf));
    RFRespData = xxx.WinData;
else
    fprintf('No file selected, quit analysis.\n');
    return;
end

% compare the ROI numbers between two input
if size(TaskRespData,2) ~= size(RFRespData,2)
    fprintf('The given two data files contains different different ROI numbers, are you sure you have chosen correct files?\n');
    fprintf('The 2afc file path is: \n %s.\n',fullfile(fp,fn));
    fprintf('The RF file path is: \n %s. \n',fullfile(fprf,fnrf));
    ContinueChar = input('Continue analysis?\n','s');
    if ~strcmpi(ContinueChar,'n')
        clc;
        fprintf('Continue analysis without extra ROIs.\n');
        ChoosenInds = min(size(TaskRespData,2),size(RFRespData,2));
        RealTaskRespData = TaskRespData(:,1:ChoosenInds);
        RealRFRespData = RFRespData(:,1:ChoosenInds);
    else
        fprintf('Quit analysis.\n');
        return;
    end
else
    RealTaskRespData = TaskRespData;
    RealRFRespData = RFRespData;
end

%%
FreqType = xxxx.FreqType;
FreqStimStr = FreqType/1000;
% calculate the gain ratio
% normalized each ROI into [0 1]
TaskDataMin = repmat(min(RealTaskRespData),size(RealTaskRespData,1),1);
TaskDataMax = repmat(max(RealTaskRespData),size(RealTaskRespData,1),1);
NorTaskData = (RealTaskRespData - TaskDataMin)./(TaskDataMax - TaskDataMin)+0.1;

RFDataMin = repmat(min(RealRFRespData),size(RealRFRespData,1),1);
RFDataMax = repmat(max(RealRFRespData),size(RealRFRespData,1),1);
NorRFData = (RealRFRespData - RFDataMin)./(RFDataMax - RFDataMin)+0.1;

% Calculate the gain ratio for each frequcy
GainRatio = NorTaskData ./ NorRFData;

ffp = uigetdir(fp,'Please select your plot save path');
cd(ffp);
for nROI = 1 : size(GainRatio,2)
    h_gains = figure;
    plot(GainRatio(:,nROI),'r-o','markerSize',12,'markerFaceColor','r','LineWidth',1.4);
    line([1,length(FreqType)],[1 1],'Color',[.8 .8 .8],'LineWidth',1.8);
%     set(gca,'xtick',1:length(FreqType),'xticklabel',cellstr(num2str(FreqStimStr(:),'%.2f')));
    xlabel('Frequency (kHz)');
    ylabel('Gain ratio');
    title(sprintf('ROI%d gain ratio',nROI));
    set(gca,'FontSize',18);
    saveas(h_gains,sprintf('ROI%d gain ratio plot',nROI));
    saveas(h_gains,sprintf('ROI%d gain ratio plot',nROI),'png');
    close(h_gains);
end
save GainRatioSave.mat GainRatio RealTaskRespData RealRFRespData -v7.3
cd(fp);
