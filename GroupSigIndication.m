function hf = GroupSigIndication(x, y, p, hf,varargin)
% this function is just used for label the significance level on the top of
% bar or group plots to indicates whether two groups is significantly
% difference or not
if (length(x) ~= length(y)) || length(x) ~= 2
    error('Error Input, only two points is accepable currently.');
end
% if x(1) ~= x(2)
%     warning('The significance line should be an horizantal line, but plot it out anyway.');
% end
x = sort(x);
yScaleFactor = 1.15;
if nargin > 4
    if ~isempty(varargin{1})
        yScaleFactor = varargin{1};
    end
end
UppreYthres = max(y);
if nargin > 5
    if ~isempty(varargin{2})
        UppreYthres = varargin{2};
    end
end
MarkSize = 9;
if nargin > 6
    if ~isempty(varargin{3})
        MarkSize = varargin{3};
    end
end

if ~ishandle(hf)
    hf = figure;
    hold on;
    bar(x,y,0.3,'FaceColor',[.2 .2 .2],'EdgeColor','none');
    set(gca,'xtick',x,'xticklabel',{'Group1','Group2'});
else
    if isa(hf,'matlab.ui.Figure')
        figure(hf);
    elseif isa(hf,'matlab.graphics.axis.Axes')
        axes(hf);
    else
        error('Invalid input handle');
    end
end
TextUppSacle = 0.1;
LineUpperScale = 0.1;
StarLineWidth = 1;
if p > 0.05
    Plotx = x;
    Ploty = max(y)*yScaleFactor;
%     PlotyTickLen = max(y)*0.01;
    if Ploty < UppreYthres
        Ploty = UppreYthres + LineUpperScale * UppreYthres;
    end
    plot(Plotx,[Ploty,Ploty],'k','LineWidth',2);
%     plot([Plotx(1),Plotx(1)],[Ploty, Ploty - PlotyTickLen],'k','LineWidth',2);
%     plot([Plotx(2),Plotx(2)],[Ploty, Ploty - PlotyTickLen],'k','LineWidth',2);
    StarPosx = mean(x);
    StarPosy = Ploty + max(y)*TextUppSacle;
    text(StarPosx,StarPosy,sprintf('p = %.4f',p),'HorizontalAlignment','center');
elseif p > 0.01
    Plotx = x;
    Ploty = max(y)*yScaleFactor;
%     PlotyTickLen = max(y)*0.01;
    if Ploty < UppreYthres
        Ploty = UppreYthres + LineUpperScale * UppreYthres;
    end
    plot(Plotx,[Ploty,Ploty],'k','LineWidth',2);
%     plot([Plotx(1),Plotx(1)],[Ploty, Ploty - PlotyTickLen],'k','LineWidth',2);
%     plot([Plotx(2),Plotx(2)],[Ploty, Ploty - PlotyTickLen],'k','LineWidth',2);
    StarPosx = mean(x);
    StarPosy = Ploty + max(y)*TextUppSacle;
    plot(StarPosx,StarPosy,'k*','MarkerSize',MarkSize,'Linewidth',StarLineWidth);
elseif p > 0.001
    Plotx = x;
    Ploty = max(y)*yScaleFactor;
%     PlotyTickLen = max(y)*0.01;
    if Ploty < UppreYthres
        Ploty = UppreYthres + LineUpperScale * UppreYthres;
    end
    plot(Plotx,[Ploty,Ploty],'k','LineWidth',2);
%     plot([Plotx(1),Plotx(1)],[Ploty, Ploty - PlotyTickLen],'k','LineWidth',2);
%     plot([Plotx(2),Plotx(2)],[Ploty, Ploty - PlotyTickLen],'k','LineWidth',2);
    InterspaceInds = linspace(x(1),x(2),8);
%     StarPosy = max(y)*yScaleFactor;
    StarPosy = Ploty + max(y)*TextUppSacle;
    plot(InterspaceInds([4,5]),[StarPosy StarPosy],'k*','MarkerSize',MarkSize,'Linewidth',StarLineWidth);
else
    Plotx = x;
    Ploty = max(y)*yScaleFactor;
%     PlotyTickLen = max(y)*0.01;
    if Ploty < UppreYthres
        Ploty = UppreYthres + LineUpperScale * UppreYthres;
    end
    plot(Plotx,[Ploty,Ploty],'k','LineWidth',2);
%     plot([Plotx(1),Plotx(1)],[Ploty, Ploty - PlotyTickLen],'k','LineWidth',2);
%     plot([Plotx(2),Plotx(2)],[Ploty, Ploty - PlotyTickLen],'k','LineWidth',2);
    InterspaceInds = linspace(x(1),x(2),9);
%     StarPosy = max(y)*yScaleFactor;
    StarPosy = Ploty + max(y)*TextUppSacle;
    plot(InterspaceInds([4,5,6]),[StarPosy StarPosy StarPosy],'k*','MarkerSize',MarkSize,'Linewidth',StarLineWidth);
end
