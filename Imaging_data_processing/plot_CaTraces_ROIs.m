function h_fig = plot_CaTraces_ROIs(F, ts, ROIs)
%
%
%
% - NX 5/2009

y_lim = [min(min(F))/2 max(max(F))];
x_lim = [min(ts)-1 max(ts)+1];

nROI = size(F,1); % total number of ROIs in the Result file
if ~exist('ROIs','var') || isempty(ROIs)
    ROIs = (1:nROI);
end;

spacing = 1/(length(ROIs)+3.5); % n*x + 3.5x = 1, space between plottings;

sc = get(0,'ScreenSize');
h_fig = figure('position', [100, sc(4)/4-100, sc(3)/3, sc(4)/3], 'color','w');
hold on;
% delete(get(h_fig,'Children'));

% h_axes1 = axes('Position',[0 0 1 1], 'Visible','off', 'Color', 'none');
cmap = colormap('HSV');
colorstep = floor(size(cmap,1)/(nROI+1));

ht = title('CaTraces over ROIs', 'Color', 'w', 'FontSize', 21, 'Position',[.5 .94 0], 'Interpreter','none');
% uistack(gca, 'top');

% plot Ca signals for all ROIs to multiple axes in the same figure.
set(gca, 'visible', 'off');
for i = 1:length(ROIs)
    % h(i) = axes('position',[0.028, i*0.06, 0.97, 0.22]);
  %  axes(h_axes1);
    roiColor = cmap((ROIs(i)-1)*colorstep +1,:);
    h(i) = axes('position',[0.05, i*spacing, 0.9, 3.5*spacing]);
    plot(ts,F(ROIs(i),:), 'color', roiColor);
    text(0.01, 0.3, sprintf('%d',ROIs(i)), 'fontsize',18,'Unit','Normalized', 'color',roiColor);
    set(h(i),'visible','off', 'color','none','YLim',y_lim,...
        'XLim',x_lim);
end;
set(gcf,'color','k');
set(h(1),'visible','on', 'box','off','XColor','w','YColor','w','FontSize',15);
