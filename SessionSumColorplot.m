function SessionSumColorplot(dataligned,alignF,TrialOutcomes,FrameRate,varargin)
% this function is specifically used for plot the summary plot of current
% session data and returm the current response for across session summary
% plot

TrialSelect = 1; % 0 for non-missing trials, 1 for all correct trials, and 2 for all trials
if nargin > 4
    if ~isempty(varargin{1})
        TrialSelect = varargin{1};
    end
end 
isplot = 0;
if nargin > 5
    if ~isempty(varargin{2})
        isplot = varargin{2};
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
DataAllMean = squeeze(mean(dataligned(TrialInds,:,:)));
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
    imagesc(DataNor(SortRowInds,:),[-2 2]);
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
save SessionSumData.mat DataAllMean DataNor FrameDis SortRowInds FrameRate -v7.3
cd ..;