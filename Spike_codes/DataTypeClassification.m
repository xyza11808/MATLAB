function [GrDataAvgs,GrDataSEMs,GroupTrNums] = DataTypeClassification(Data, GrInds, varargin)
% classified data according to given group inds, calculate the mean and SEM
[GrType,~,SortedGrInds] = unique(GrInds);
NumGroups = length(GrType);
DataPoints = size(Data,2);

GrDataAvgs = zeros(NumGroups, DataPoints);
GrDataSEMs = zeros(NumGroups, DataPoints);
GroupTrNums = zeros(NumGroups, 1);
for cGr = 1 : NumGroups
    cGr_Inds = SortedGrInds == cGr;
    cGr_Num = sum(cGr_Inds);
    if cGr_Num == 1
        GrDataAvgs(cGr,:) = Data(cGr_Inds,:);
        GrDataSEMs(cGr,:) =  zeros(1,DataPoints);
    elseif cGr_Num > 1 && cGr_Num <= 3
        GrDataAvgs(cGr,:) = mean(Data(cGr_Inds,:),'omitnan');
        GrDataSEMs(cGr,:) =  zeros(1,DataPoints);
    elseif cGr_Num > 2
        GrDataAvgs(cGr,:) = mean(Data(cGr_Inds,:),'omitnan');
        GrDataSEMs(cGr,:) =  std(Data(cGr_Inds,:),'omitnan')/sqrt(cGr_Num);
    else
        GrDataAvgs(cGr,:) = zeros(1,DataPoints);
        GrDataSEMs(cGr,:) = zeros(1,DataPoints);
    end
    GroupTrNums(cGr) = cGr_Num;
end
Isplot = 0;
if nargin > 2
    if ~isempty(varargin{1})
        Isplot = varargin{1};
    end
end
if Isplot
    figure('position',[100 100 1020 840]);
    hold on
    NumPoints = size(GrDataAvgs,2);
    PlottedClusNum = size(GrDataAvgs,1);
    ybase = 5;
    ystep = 3;

    TraceTickCent = zeros(PlottedClusNum,1);
    for cplot = 1 : PlottedClusNum
        cTraceData = GrDataAvgs(cplot,:);
        cTraceData_minSub = cTraceData - min(cTraceData);
        cTraceData_plot = cTraceData_minSub + ybase;
        plot(cTraceData_plot,'k','linewidth',1.5);
        text(NumPoints+10, mean(cTraceData_plot),num2str(GroupTrNums(cplot),'%d'),'Color','m');
        TraceTickCent(cplot) = mean(cTraceData_plot);
        ybase = ybase + ystep + max(cTraceData_minSub);
    end

    BlockChangePoints = NumPoints/2 + 0.5;
%     yscales = get(gca,'ylim');
    line(BlockChangePoints*[1 1],[0 ybase],'Color',[1 0 0 0.3],'linewidth',2);
    set(gca,'ylim',[0 ybase],'ytick',TraceTickCent,'yticklabel',GrType(:),...
        'xtick',[NumPoints/4 NumPoints*3/4],'xticklabel',{'LowBlock';'HighBlock'});
    ylabel('Clusters');
    % title('Correlation threshold, Correct trials');
end
    

