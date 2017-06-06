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
UppreYthres = max(y) - 1;
if nargin > 5
    if ~isempty(varargin{2})
        UppreYthres = varargin{2};
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

if p > 0.05
    Plotx = x;
    Ploty = max(y)*yScaleFactor;
    PlotyTickLen = max(y)*0.01;
    if Ploty < UppreYthres
        Ploty = UppreYthres + 0.05 * max(y);
    end
    plot(Plotx,[Ploty,Ploty],'k','LineWidth',2);
    plot([Plotx(1),Plotx(1)],[Ploty, Ploty - PlotyTickLen],'k','LineWidth',2);
    plot([Plotx(2),Plotx(2)],[Ploty, Ploty - PlotyTickLen],'k','LineWidth',2);
    StarPosx = mean(x);
    StarPosy = Ploty + max(y)*0.05;
    text(StarPosx,StarPosy,'N.S.');
elseif p > 0.01
    Plotx = x;
    Ploty = max(y)*yScaleFactor;
    PlotyTickLen = max(y)*0.01;
    if Ploty < UppreYthres
        Ploty = UppreYthres + 0.05 * max(y);
    end
    plot(Plotx,[Ploty,Ploty],'k','LineWidth',2);
    plot([Plotx(1),Plotx(1)],[Ploty, Ploty - PlotyTickLen],'k','LineWidth',2);
    plot([Plotx(2),Plotx(2)],[Ploty, Ploty - PlotyTickLen],'k','LineWidth',2);
    StarPosx = mean(x);
    StarPosy = Ploty + max(y)*0.05;
    plot(StarPosx,StarPosy,'k*','MarkerSize',9);
elseif p > 0.001
    Plotx = x;
    Ploty = max(y)*yScaleFactor;
    PlotyTickLen = max(y)*0.01;
    if Ploty < UppreYthres
        Ploty = UppreYthres + 0.05 * max(y);
    end
    plot(Plotx,[Ploty,Ploty],'k','LineWidth',2);
    plot([Plotx(1),Plotx(1)],[Ploty, Ploty - PlotyTickLen],'k','LineWidth',2);
    plot([Plotx(2),Plotx(2)],[Ploty, Ploty - PlotyTickLen],'k','LineWidth',2);
    InterspaceInds = linspace(x(1),x(2),8);
%     StarPosy = max(y)*yScaleFactor;
    StarPosy = Ploty + max(y)*0.05;
    plot(InterspaceInds([4,5]),[StarPosy StarPosy],'k*','MarkerSize',9);
else
    Plotx = x;
    Ploty = max(y)*yScaleFactor;
    PlotyTickLen = max(y)*0.01;
    if Ploty < UppreYthres
        Ploty = UppreYthres + 0.05 * max(y);
    end
    plot(Plotx,[Ploty,Ploty],'k','LineWidth',2);
    plot([Plotx(1),Plotx(1)],[Ploty, Ploty - PlotyTickLen],'k','LineWidth',2);
    plot([Plotx(2),Plotx(2)],[Ploty, Ploty - PlotyTickLen],'k','LineWidth',2);
    InterspaceInds = linspace(x(1),x(2),9);
%     StarPosy = max(y)*yScaleFactor;
    StarPosy = Ploty + max(y)*0.05;
    plot(InterspaceInds([4,5,6]),[StarPosy StarPosy StarPosy],'k*','MarkerSize',9);
end
