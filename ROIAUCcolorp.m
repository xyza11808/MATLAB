function ROIAUCcolorp(TCourStrc,StartT,varargin)
% this function is used to plot time couse AUC in a colorplot, so that the
% single cell discrimination ability of left and right can be visualized in
% population scale
StimTLength = 0.3;
if nargin > 2
    if ~isempty(varargin{1})
        StimTLength = varargin{1};
    end
end
SessionDesp = 'Fluo Data';
if nargin > 3
    if ~isempty(varargin{2})
        SessionDesp = varargin{2};
    end
end

xTickT = TCourStrc.tickTime;
ROIWinAuc = TCourStrc.ROIBinAUC;
yTickIndex = 1:size(ROIWinAuc,1);
nROIs = size(ROIWinAuc,1);
[~,maxinds] = max(ROIWinAuc,[],2);
[~,SortInds] = sort(maxinds);


if ~isdir('./PopuROI_TimeCourse_AUC/')
    mkdir('./PopuROI_TimeCourse_AUC/');
end
cd('./PopuROI_TimeCourse_AUC/');

h_roi = figure('position',[500 210 840 700]);
imagesc(xTickT,yTickIndex,ROIWinAuc(SortInds,:),[0.5 1]);
patch([StartT StartT StartT+StimTLength StartT+StimTLength],[0.5 nROIs+0.5 nROIs+0.5 0.5],1,'EdgeColor','None','FaceColor','g','Facealpha',0.4);
line([StartT StartT],[0.5 nROIs+0.5],'Color',[.8 .8 .8],'LineWidth',1.8);
xlabel('Time (s)');
ylabel('nROIs');
title('ROI time course auc');
colorbar;
set(gca,'FontSize',20);
saveas(h_roi,sprintf('TimeCourse AUC plot %s',SessionDesp));
saveas(h_roi,sprintf('TimeCourse AUC plot %s',SessionDesp),'png');
close(h_roi);

cd ..;