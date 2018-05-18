function varargout = CompareScatterPlot(xData,yData,varargin)
% this function is just used for scatter plots of given data when wants to
% compare the x,y data values
% should be paired values

if numel(xData) ~= numel(yData)
    error('x and y must have same number of values');
end

[Coefr,Coefp] = corrcoef(xData,yData);
[~,p] = ttest(xData,yData);

hf = figure('position',[100 100 400 300]);
plot(xData,yData,'o','Color','k','linewidth',1.2);
Caxes = figaxesScaleUni(gca);
cScales = get(Caxes,'xlim');
line(cScales,cScales,'Color',[.7 .7 .7],'linewidth',1.2,'linestyle','--');
set(Caxes,'box','off');
xlabel('xData');
ylabel('yData');
title(sprintf('Pairedt = %.3e',p));
set(Caxes,'FontSize',14);
if nargout > 0
    varargout{1} = hf;
    if nargout > 1
        varargout{2} = [p,Coefr(2,1),Coefp(2,1)];
    end
end
