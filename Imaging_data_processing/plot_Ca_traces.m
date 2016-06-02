function plot_Ca_traces(trialID, ephysID, Scale, varargin)
%
% ephysID = 0, load stimulus parameter from a separate file
% NX Feb 2009
%
%% plot Ca traces of all ROIs

Ca_result_file = dir(['*0' num2str(trialID) '_Result.mat']);
load(Ca_result_file(1).name);
[path, mainFilename] = fileparts(Result.FileName);

if Result.AnalysisMode.BGSubMode
    y = Result.CellImage(1:end-1,:).*100;
else
    y = Result.CellImage.*100;
end;
t = Result.xValues/1000;
if exist('Scale')
    y_lim = Scale(1:2);
    if length(Scale)>2
        x_lim = Scale(3:4);
    else
        x_lim = [min(t)-1 max(t)+1];
    end;
else
    y_lim = [min(min(y))/2 max(max(y))];
    x_lim = [min(t)-1 max(t)+1];
end;

nROI = size(y,1); % total number of ROIs in the Result file
if ~isempty(varargin)
    ROIs = varargin{1};
else
    ROIs = (1:nROI);
end;

spacing = 1/(length(ROIs)+3.5); % n*x + 3.5x = 1, space between plottings;

sc = get(0,'ScreenSize');
cmap = colormap('HSV');
colorstep = round(size(cmap,1)/(nROI+1));
h_fig = figure('position', [100, sc(4)/4-100, sc(3)*3/4, sc(4)*3/4], 'color','k');
hold on;
% delete(get(h_fig,'Children'));

set(gca,'Position',[0 0 1 1], 'Visible','on', 'Color', 'none');
ht = title(mainFilename, 'Color', 'w', 'FontSize', 21, 'Position',[.5 .94 0], 'Interpreter','none');
% uistack(gca, 'top');

% plot Ca signals for all ROIs to multiple axes in the same figure.
for i = 1:length(ROIs)
    % h(i) = axes('position',[0.028, i*0.06, 0.97, 0.22]);
    h(i) = axes('position',[0.03, i*spacing, 0.96, 3.5*spacing]);
    plot(t,y(ROIs(i),:), 'color', cmap((ROIs(i)-1)*colorstep +1,:));
    set(h(i),'visible','off', 'color','none','YLim',y_lim,...
        'XLim',x_lim);
end;
set(h(1),'visible','on', 'box','off','XColor','w','YColor','w','FontSize',15);

%% Plot whisker motion
if exist('whisker_avgMotion','dir')
    cd('whisker_avgMotion');
    wsk_file = dir(['*' num2str(trialID) '*']);
    if ~isempty(wsk_file)
        wskMotion = load(wsk_file(1).name);
    end;
    cd ..
end;
if exist('wskMotion', 'var')
    figure(h_fig);
    tmp = get(h(end), 'position');
    pos = tmp + [0, spacing-0.02, 0, 0];
    h_wsk = axes('position', pos);
    plot(wskMotion.t, wskMotion.avgPixSpeed, 'color', [.7 .7 .7]);
    if max(wskMotion.avgPixSpeed)> 8
        y_lim_w = [min(wskMotion.avgPixSpeed) 8];
    else
        y_lim_w = [min(wskMotion.avgPixSpeed) max(wskMotion.avgPixSpeed)];
    end;
    set(h_wsk,'visible','off', 'color','none',...
        'XLim',x_lim, 'YLim', y_lim_w);
    uistack(h_wsk, 'bottom');
end;

%% Plot pulses (pole or aire puff) if any
if exist('ephysID') & ~isempty(ephysID)
    id = ephysID;
else
    id = trialID;
end;
if id == 0
    xsgfile = [];
else
    xsgfile = dir(['NX0001\*0' num2str(id) '.xsg']);
end;
if ~isempty(xsgfile)
    load(['NX0001\' xsgfile(1).name], '-mat');
    if header.stimulator.stimulator.stimOnArray(1) % this channel is on
        delay = header.stimulator.stimulator.pulseParameters{1}.squarePulseTrainDelay;
        pulseNum=header.stimulator.stimulator.pulseParameters{1}.squarePulseTrainNumber;
        isi = header.stimulator.stimulator.pulseParameters{1}.squarePulseTrainISI;
        dur = header.stimulator.stimulator.pulseParameters{1}.squarePulseTrainWidth;
        pulseName = header.stimulator.stimulator.pulseParameters{1}.name;
        axes(h(1)); hold on;
        y1 = get(gca, 'YLim');
        xa = zeros(1, pulseNum); ya = ones(size(xa)).*y1(1);
        xb = zeros(1,pulseNum); yb = ya;
        for i = 1:pulseNum, xa(i)=isi*(i-1)+delay; xb(i)=xa(i)+dur; end;
        
        if strncmpi('air',pulseName, 3) % if stimulus is air puff, plot differently
            xb = xa;
            yb = ya + 40;
            h_pulse = line([xa; xb],[ya; yb], 'LineWidth', 3, 'Color', 'y');
        else % pole delivery
            h_pulse = line([xa; xb],[ya; yb], 'LineWidth', 10, 'Color', 'w');
        end;
    end;
elseif id == 0 % load the stimulus parameters from a separate file
%     delay = input('delay: ');
%     pulseNum = input('pulseNum: ');
%     isi = input('ISI: ');
%     dur = input('pulse duration: ');
%     pulseName = input('pulse name: ');
    load('NX0001\stimParam7-11.mat');
    axes(h(1)); hold on;
    y1 = get(gca, 'YLim');
    xa = zeros(1, pulseNum); ya = ones(size(xa)).*y1(1);
    xb = zeros(1,pulseNum); yb = ya;
    for i = 1:pulseNum, xa(i)=isi*(i-1)+delay; xb(i)=xa(i)+dur; end;
    
    if strncmpi('air',pulseName, 3) % if stimulus is air puff, plot differently
        xb = xa;
        yb = ya + 40;
        h_pulse = line([xa; xb],[ya; yb], 'LineWidth', 3, 'Color', 'y');
    else % pole delivery
        h_pulse = line([xa; xb],[ya; yb], 'LineWidth', 10, 'Color', 'w');
    end;
end;

%% Show the average Image and the ROIs
figure('Position', [sc(3)*0.7, 30, sc(3)*0.3, sc(4)*0.35]);
imagesc(Result.ROIInfo.CurrentAverageImage, [0 200]); colormap(gray);
set(gca,'Position', [0.05, 0.05, 0.9, 0.9]);
for i = 1:nROI
    PolyPosition = squeeze(Result.ROIInfo.CellPolygon(:,:,i));
    line(PolyPosition(:,1), PolyPosition(:,2), 'Color', cmap((i-1)*colorstep+1,:), 'LineWidth', 1);
    text(nanmean(PolyPosition(:,1)), nanmean(PolyPosition(:,2)), int2str(i), 'color', [1 0 0]);
end;

