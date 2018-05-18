function varargout = SessionSumColorplot(dataligned,alignF,TrialOutcomes,TrialStimFreq,FrameRate,varargin)
% this function is specifically used for plot the summary plot of current
% session data and returm the current response for across session summary
% plot

TrialSelect = 1; % 0 for non-missing trials, 1 for all correct trials, and 2 for all trials
if nargin > 5
    if ~isempty(varargin{1})
        TrialSelect = varargin{1};
    end
end 
isplot = 0;
if nargin > 6
    if ~isempty(varargin{2})
        isplot = varargin{2};
    end
end

TimeScale = [0.2,1.5];
isMultiWin = 0;
nTimeWins = 1;
if nargin > 7
    if ~isempty(varargin{3})
        if iscell(varargin{3})
            TimeScales = varargin{3};
            isMultiWin = 1;
            fprintf('Multiple timescale input, storing data for every single time scale.\n');
            nTimeWins = length(TimeScales);
        else
            TimeScale = varargin{3};
        end
    end
end

switch TrialSelect
    case 0
        TrialInds = TrialOutcomes ~= 2;
    case 1
        TrialInds = TrialOutcomes == 1;
    case 2
        TrialInds = true(length(TrialOutcomes),1);
    otherwise
        error('Error trial selection type, Please check your input data.');
end
        
[nTrials,nROIs,nFrames] = size(dataligned);
if length(TrialOutcomes) ~= nTrials
    error('Input dimension mismatch.');
end
UsingTrData = dataligned(TrialInds,:,:);
DataAllMean = squeeze(mean(UsingTrData));
FrameDis = [alignF - 1, nFrames - alignF - 1];
DataNor = zeros(size(DataAllMean));
for nmnm = 1 : nROIs
    DataNor(nmnm,:) = zscore(DataAllMean(nmnm,:));
end
[~,maxInds] = max(DataNor,[],2);
[~,SortRowInds] = sort(maxInds);
xticks = 0:FrameRate:size(DataNor,2);
xtickalabels = xticks/FrameRate;

if ~isdir('./Session_Sum_plot/')
    mkdir('./Session_Sum_plot/');
end
cd('./Session_Sum_plot/');

if isplot
    h_colorall = figure;
    imagesc(DataNor(SortRowInds,:),[-1 1]);
    line([alignF,alignF],[0.5,nFrames+0.5],'color',[.8 .8 .8],'LineWidth',1.8);
    colorbar;
    xlabel('Time (s)');
    ylabel('nROIs');
    set(gca,'xtick',xticks,'xticklabel',xtickalabels);
    title('Session mean response color plot');
    saveas(h_colorall,'Session Mean Resp Color plot');
    saveas(h_colorall,'Session Mean Resp Color plot','png');
    close(h_colorall);
end 
save SessionSumData.mat DataAllMean DataNor FrameDis SortRowInds FrameRate alignF -v7.3
cSessDataStrc.RawData = DataAllMean;
cSessDataStrc.NorData = DataNor;
if nargout > 0
    varargout{1} = cSessDataStrc;
end
%%
% plot the hist for maxinds distribution for peak position selection
% using only maxium peak inds is after 0.2s after stimulus onset and within 1.5s window after
% sound onset
MultiTimeWinData = cell(nTimeWins,1);
SigROIInds = cell(nTimeWins,1);
for ntimes = 1 : nTimeWins
    if ~isMultiWin
        cTimeRange = TimeScale;
    else
        cTimeRange = TimeScales{ntimes};
        MiliSeconds = cTimeRange * 1000;
        cTimeFolderName = sprintf('./%d_%dms_timeWin/',MiliSeconds(1),MiliSeconds(2));
        if ~isdir(cTimeFolderName)
            mkdir(cTimeFolderName);
        end
        cd(cTimeFolderName);
    end
    
    PeakRange = round([(alignF+cTimeRange(1)*FrameRate) (alignF+cTimeRange(2)*FrameRate)]);
    PossInds = (maxInds > PeakRange(1)) & (maxInds < PeakRange(2));
    ROIInds = find(PossInds);
    fprintf('Possible sound responsive ROI number is %d out of %d.\n',length(ROIInds),length(PossInds));
    nPossROIs = length(ROIInds);
    IsROISigResp = ones(nPossROIs,1);
    for nxnm = 1 : nPossROIs
        cROIinds = ROIInds(nxnm);
        cROIdata = DataAllMean(cROIinds,:);
        ROIThres = mad(cROIdata,1)*1.4826*3; % the threshold value is three times of estimated std
        if max(cROIdata) < ROIThres
            IsROISigResp(nxnm) = 0;
        end
    end
    LowRespROINum = nPossROIs - sum(IsROISigResp); % number of ROIs to be excluded because of weak response peak
    SelectROIinds = ROIInds(logical(IsROISigResp));
    LowPeakROIinds = ROIInds(~(logical(IsROISigResp)));
    % nPossROIs(~(logical(IsROISigResp))) = [];
    fprintf('%d out of %d ROIs were excluded from analysis because of low response peak value.\n',LowRespROINum,nPossROIs);
%     %%
%     % test plot of all 
%     hTrace = figure('position',[350 340 930 700]);
%     hold on;
%     plot(DataAllMean(SelectROIinds,:)','color','k','LineWidth',1.6);
%     if ~isempty(LowPeakROIinds)
%         plot(DataAllMean(LowPeakROIinds,:)','color',[.5 .5 .5],'LineWidth',1.4);
%     end
%     yrange = get(gca,'ylim');
%     line([PeakRange(1) PeakRange(1)],yrange,'color',[.7 .7 .7],'LineWidth',1.6);
%     line([PeakRange(2) PeakRange(2)],yrange,'color',[.7 .7 .7],'LineWidth',1.6);
%     ylim(yrange);
%     xlabel('Frames');
%     ylabel('Mean \DeltaF/F_0(%)');
%     title('Possible Sound Responsive ROI response');
%%
    TrialStimFreq = double(TrialStimFreq);
    save PosSoundRespInds.mat SelectROIinds LowPeakROIinds dataligned TrialStimFreq TrialInds PeakRange alignF FrameRate maxInds -v7.3
    %%
    % Exract the mean response peak for each 
    SelectTrFreqs = TrialStimFreq(TrialInds);
    SelectTrData = dataligned(TrialInds,:,:);
    FreqTypes = unique(SelectTrFreqs);
    nFreqs = length(FreqTypes);
    SigROIFreqResp = zeros(length(SelectROIinds),nFreqs);
    SigROIFreqTrace = cell(length(SelectROIinds),nFreqs);
    SigSingleTrFreqData = cell(length(SelectROIinds),nFreqs);
    for nSigROIs = 1 : length(SelectROIinds)
        cROIdata = squeeze(SelectTrData(:,SelectROIinds(nSigROIs),:));
        for nf = 1 : nFreqs
            cFreq = FreqTypes(nf);
            cFreqInds = SelectTrFreqs == cFreq;
            cFreqTrData = cROIdata(cFreqInds,:);
            MeancFreqData = mean(cFreqTrData);
            SigROIFreqResp(nSigROIs,nf) = max(MeancFreqData(PeakRange(1):PeakRange(2)));
            SigROIFreqTrace(nSigROIs,nf) = {MeancFreqData};
            SigSingleTrFreqData(nSigROIs,nf) = {cFreqTrData(:,PeakRange(1):PeakRange(2))};
        end
    end
    save FreqWiseRespSave.mat FreqTypes SigROIFreqResp SigROIFreqTrace SelectROIinds PeakRange SigSingleTrFreqData -v7.3
    
    if isMultiWin
        cd ..;
        MultiTimeWinData{ntimes} = SigSingleTrFreqData;
        SigROIInds{ntimes} = SelectROIinds;
    end
end
%%
if isMultiWin
    save MultiWinSave.mat MultiTimeWinData TimeScales alignF FrameRate dataligned TrialStimFreq TrialInds SigROIInds -v7.3
end
cd ..;