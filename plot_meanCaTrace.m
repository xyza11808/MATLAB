function H = plot_meanCaTrace(mean_trace, se_trace, ts, h_fig, opt,linestyle, varargin)

if ~isempty(varargin)
    SecondYData=varargin{1};
    Sydescription=varargin{2};
    issceondY=1;
else
    issceondY=0;
end

if ~isempty(opt)
    t_eventOn = opt.t_eventOn;
    if isfield(opt,'eventDur')
        t_eventOff = t_eventOn + opt.eventDur;
    else
       t_eventOff=max(ts);
    end
    if isfield(opt,'isPatchPlot')
        patchPlot=opt.isPatchPlot;
    else
        patchPlot=1;
    end
end
if ~isempty(linestyle)
    plotstyle = linestyle;
else
    plotstyle = {'r','linewidth',1.5};
end

mean_trace = (mean_trace(:))';
se_trace = (se_trace(:))';
uE =  mean_trace + se_trace;
lE =  mean_trace - se_trace;
yP=[lE,fliplr(uE)];
xP=[ts(:);flipud(ts(:))];
patchColor = [.8 .8 .8];
faceAlpha = 0.6;

figure(h_fig);
hold on;
H.ep = patch(xP,yP,1,'facecolor',patchColor,...
              'edgecolor','none',...
              'facealpha',faceAlpha);
yaxis = axis();
if ~isempty(opt) && patchPlot
    H.eventPatch = patch([t_eventOn, t_eventOn, t_eventOff, t_eventOff],...
        [yaxis(3), yaxis(4), yaxis(4),yaxis(3)],1,...
        'facecolor',[.1 .8 .1],'Edgecolor','none', 'facealpha',0.8);
elseif isfield(opt,'isPatchPlot')
    H.eventPatch = line([t_eventOn t_eventOn],[yaxis(3) yaxis(4)],'LineWidth',2.5,'color',[.8 .8 .8]);
end

if ~issceondY
    H.meanPlot = plot(ts, mean_trace,plotstyle{:});
else
    [hax,hlineL,hlineR]=plotyy(ts,mean_trace,ts,SecondYData);
    H.meanPlot = hlineL;
    H.SecondP = hlineR;
    H.Allaxes=hax;
    ylabel(hax(1),'\DeltaF/F_0');
    ylabel(hax(2),Sydescription);
%     ylim(hax(2),[-45 30]);
    xlabel('Time (s)');
    set(hlineL,'color','r','linewidth',1.5);
    set(hlineR,'color','g','linewidth',1);
    set(hax(2),'Ycolor','g');
    set(hax(1),'Ycolor','r');
end
end