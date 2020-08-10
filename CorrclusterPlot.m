function varargout = CorrclusterPlot(CorrMtx,labels,Tltstr)
% function used for clusterred correlation matrix
PlotCorMtx = CorrMtx;
[~, Inds] = sort(labels);
GroupTypes = unique(labels);
NumGrs = numel(GroupTypes);
GroupTypeNum = zeros(numel(GroupTypes),1);
for cGr = 1 : NumGrs
    GroupTypeNum(cGr) = sum(labels == GroupTypes(cGr));
end
Grcumsum = cumsum(GroupTypeNum);

hf  = figure('position',[100 100 420 340]);
imagesc(PlotCorMtx(Inds,Inds))
for cGr = 1 : NumGrs
    line([Grcumsum(cGr)+0.5 Grcumsum(cGr)+0.5],[0.5 NumROIs+0.5],'Color','r','linewidth',1.5); % vertical line
    line([0.5 NumROIs+0.5],[Grcumsum(cGr)+0.5 Grcumsum(cGr)+0.5],'Color','r','linewidth',1.5); % horizontal line
end
% set(gca,'xtick',)
title(Tltstr)
if nargout > 0
    varargout{1} = hf;
    if nargout > 1
        varargout{2} = GroupTypeNum;
    end
end