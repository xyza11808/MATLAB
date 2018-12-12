function hf = FourColDataPlots(datas,varargin)
% plots four column datas

PlotTypes = varargin{1};  % cell str array for discription of each column
ScatterColorGoven = 0;
if nargin > 2
    if ~isempty(varargin{2})
        ScatterColor = varargin{2};
        ScatterColorGoven = 1;
    end
end
RowSize = size(datas,1);
GrLabelBase = ones(RowSize,1);
hf = figure('position',[100 100 420 340]);
hold on

plot([1,2],(datas(:,1:2))','Color',[.7 .7 .7],'linewidth',1.6);
plot([3,4],(datas(:,3:4))','Color',[.7 .7 .7],'linewidth',1.6);
for cCol = 1 : 4
    if ScatterColorGoven
        plot(cCol*GrLabelBase,datas(:,cCol),'o','Color',ScatterColor{cCol},'linewidth',1.2);
    else
        plot(cCol*GrLabelBase,datas(:,cCol),'o','Color',[.7 .7 .7],'linewidth',1.2);
    end
end

set(gca,'xtick',1:4,'xticklabel',PlotTypes(:));
xlim([0.5 4.5])
set(gca,'FontSize',12);

