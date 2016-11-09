function varargout = RFaucCalPlot(RFdata,RFStim,RFboundary,AlignFrame,FrameRate,TimeScale,varargin)
% This function is specifically used for calculate the RF data auc
isplot = 1;
if nargin > 6
    if ~isempty(varargin{1})
        isplot = varargin{1};
    end
end

if isempty(RFboundary)
    RFboundary = 16000;
end
RFTrType = double(RFStim > RFboundary);
[~,nROIs,~] = size(RFdata);

if length(TimeScale) == 1
    FrameScale = sort([AlignFrame,AlignFrame+round(TimeScale*FrameRate)]);
elseif length(TimeScale) == 2
    FrameScale = sort([AlignFrame+round(TimeScale(1)*FrameRate),AlignFrame+round(TimeScale(2)*FrameRate)]);
else
    error('Error time scale length, please check your input.');
end
if FrameScale(1) < 1
    fprintf('FrameScale less than 1, adjust to initial frame.\n');
    if FrameScale(2) < 1
        error('Matrix index out');
    end
end
if FrameScale(2) > size(RFdata,3)
    fprintf('FrameScale end larger than maxium frame index, adjust to frame end value.\n');
    if FrameScale(1) > size(RFdata,3)
        error('Matrix index out');
    end
end
SelectData = max(RFdata(:,:,FrameScale(1):FrameScale(2)),[],3);
rfROIauc = zeros(nROIs,1);
rfROIrevert = zeros(nROIs,1);
for nroi = 1 : nROIs
    cData = SelectData(:,nroi);
    ForaucData = [cData;RFTrType(:)];
    [ROCSummary,LabelMeanS]=rocOnlineFoff(ForaucData);
    rfROIauc(nroi) = ROCSummary;
    rfROIrevert(nroi) = double(LabelMeanS);
end

if isplot
    ROIabs = rfROIauc;
    ROIabs(rfROIrevert == 1) = 1 - ROIabs(rfROIrevert == 1);
    
    h_popu = figure;
    ROCsort = sort(ROIabs,'descend');
    plot(ROCsort,'o','LineWidth',1.8,'MarkerSize',12);
    xlabel('# nROIs');
    ylabel('AUC value');
    ylim([0 1]);
    title('Session AUC distribution');
    saveas(h_popu,'Session Popu AUC plot');
    saveas(h_popu,'Session Popu AUC plot','png');
    close(h_popu);
end

if nargout > 0
    varargout{1} = rfROIauc;
    varargout{2} = rfROIrevert;
    varargout{3} = ROIabs;
end