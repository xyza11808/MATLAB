cclr
abffile1 = '2018_07_19_0049_epsc.abf';
[d,si,h] = abfload(abffile1);
% cd(abffile1(1:end-4));
%%
fRate = 10000; % sample rate
excludedTime = 0.5; % seconds, the data before this time will be excluded
Used_datas = d(((excludedTime*fRate+1):end),:,:);
Nsweep = 1;

% sweepData = squeeze(Used_datas(:,:,Nsweep));
sweeplen = size(Used_datas,1);

%%
if ~isempty(ExSweepInds)
    Used_datas(:,:,ExSweepInds) = [];
end
SweepNum = size(Used_datas,3);
%%
Targetswinds = [17,21,32];
TargetswNum = length(Targetswinds);
UsedSWInds = zeros(TargetswNum,1);
if ~isempty(ExSweepInds)
    for ctSW = 1 : TargetswNum
        UsedSWInds(ctSW) = Targetswinds(ctSW) - sum(Targetswinds(ctSW) > ExSweepInds);
    end
else
    UsedSWInds = Targetswinds;
end

NeuData_permu = permute(Used_datas, [1,3,2]);
Neu1Data = squeeze(NeuData_permu(:,UsedSWInds,1));
Neu2Data = squeeze(NeuData_permu(:,UsedSWInds,2));

Neu1Traceraw = Neu1Data(:);
Neu2Traceraw = Neu2Data(:);

IsEPSC = mean(Neu1Traceraw) < 0;

Neu1ST_mtx = reshape(Neu1_SubtrendData,sweeplen,[]);
Neu2ST_mtx = reshape(Neu2_SubtrendData,sweeplen,[]);

Neu1ST_Usedmtx = Neu1ST_mtx(:,UsedSWInds);
Neu2ST_Usedmtx = Neu2ST_mtx(:,UsedSWInds);
Neu1ST_UsedTrace = Neu1ST_Usedmtx(:);
Neu2ST_UsedTrace = Neu2ST_Usedmtx(:);

UsedswNum = length(UsedSWInds);

sweepEdges = 1:sweeplen:length(Neu1ST_UsedTrace);
x_edge_mtx = [sweepEdges;sweepEdges;nan(1,UsedswNum)];
x_edge_ticks = x_edge_mtx(:);

hhf = figure('position',[400 200 520 780]);
subplot(211)
hold on
plot(Neu1Traceraw,'k');
if IsEPSC
    plot(-Neu1ST_UsedTrace,'r','linewidth',1);
else
    plot(Neu1ST_UsedTrace,'r','linewidth',1);
end
yscales = get(gca,'ylim');
ytick_mtx = (repmat(([yscales,NaN])',UsedswNum,1))';
Plot_yticks = ytick_mtx(:);
plot(x_edge_ticks, Plot_yticks, 'g','linewidth',1.2);
text(sweepEdges,repmat(yscales(2)*0.8,UsedswNum,1),cellstr(num2str((1:UsedswNum)','%d')));
title('Neu1 select sweep plot')

subplot(212)
hold on
plot(Neu2Traceraw,'k');
if IsEPSC
    plot(-Neu2ST_UsedTrace,'r','linewidth',1);
else
    plot(Neu2ST_UsedTrace,'r','linewidth',1);
end
yscales = get(gca,'ylim');
ytick_mtx = (repmat(([yscales,NaN])',UsedswNum,1))';
Plot_yticks = ytick_mtx(:);
plot(x_edge_ticks, Plot_yticks, 'g','linewidth',1.2);
text(sweepEdges,repmat(yscales(2)*0.8,UsedswNum,1),cellstr(num2str((1:UsedswNum)','%d')));
title('Neu2 select sweep plot')
%%
saveas(hhf,'F:\xy\exanpleNeuplots\np36\Full sweep plot save');
saveas(hhf,'F:\xy\exanpleNeuplots\np36\Full sweep plot save','png');
saveas(hhf,'F:\xy\exanpleNeuplots\np36\Full sweep plot save','pdf');

%% plot target region trace only

Targetswinds = [17,21,32];
TargetswNum = length(Targetswinds);
UsedSWInds = zeros(TargetswNum,1);
if ~isempty(ExSweepInds)
    for ctSW = 1 : TargetswNum
        UsedSWInds(ctSW) = Targetswinds(ctSW) - sum(Targetswinds(ctSW) > ExSweepInds);
    end
else
    UsedSWInds = Targetswinds;
end

NeuData_permu = permute(Used_datas, [1,3,2]);
Neu1Data = squeeze(NeuData_permu(:,UsedSWInds,1));
Neu2Data = squeeze(NeuData_permu(:,UsedSWInds,2));

Neu1Traceraw = Neu1Data(:);
Neu2Traceraw = Neu2Data(:);

IsEPSC = mean(Neu1Traceraw) < 0;

Neu1ST_mtx = reshape(Neu1_SubtrendData,sweeplen,[]);
Neu2ST_mtx = reshape(Neu2_SubtrendData,sweeplen,[]);

Neu1ST_Usedmtx = Neu1ST_mtx(:,UsedSWInds);
Neu2ST_Usedmtx = Neu2ST_mtx(:,UsedSWInds);
Neu1ST_UsedTrace = Neu1ST_Usedmtx(:);
Neu2ST_UsedTrace = Neu2ST_Usedmtx(:);

% find peaks and return datas nearby
[pks,locs] = findpeaks(Neu1ST_UsedTrace,'MinPeakHeight',prctile(Neu1ST_UsedTrace,95),...
    'MinPeakDistance',fRate);
UsedScales = zeros(length(locs),2);
for cloc = 1 : length(locs)
    %
    ccloc = locs(cloc);
    ccloc_sweepNum = floor(ccloc/sweeplen);
    cc_left_inds = max(ccloc - 0.5*fRate + 1, ccloc_sweepNum*sweeplen+1);
    cc_right_inds = min(ccloc + fRate,(ccloc_sweepNum+1)*sweeplen);
    if cloc > 1
        if cc_left_inds < UsedScales(cloc-1,2)
            UsedScales(cloc-1,2) = cc_right_inds;
        else
            UsedScales(cloc,:) = [cc_left_inds,cc_right_inds];
        end
        
    else
        UsedScales(cloc,:)  = [cc_left_inds,cc_right_inds];
    end
    %
end
%
UsedScales(UsedScales(:,1) < 1,:) = [];
plotScaleNum = size(UsedScales,1);

UsedswNum = length(UsedSWInds);

sweepEdges = 1:sweeplen:length(Neu1ST_UsedTrace);
x_edge_mtx = [sweepEdges;sweepEdges;nan(1,UsedswNum)];
x_edge_ticks = x_edge_mtx(:);

hsef = figure('position',[400 200 520 780]);
subplot(211)
hold on
xbase = 0;
for cSW = 1 : plotScaleNum
    cScale = UsedScales(cSW,1):UsedScales(cSW,2);
    cScale_xtick = (1:length(cScale)) + xbase + 1;
    plot(cScale_xtick, Neu1Traceraw(cScale),'k');
    if IsEPSC
        plot(cScale_xtick,-Neu1ST_UsedTrace(cScale),'r','linewidth',1);
    else
        plot(cScale_xtick,Neu1ST_UsedTrace(cScale),'r','linewidth',1);
    end
    xbase = xbase + length(cScale) + 1000;
end
set(gca,'xlim',[0 xbase]);
% yscales = get(gca,'ylim');
% ytick_mtx = (repmat(([yscales,NaN])',UsedswNum,1))';
% Plot_yticks = ytick_mtx(:);
% plot(x_edge_ticks, Plot_yticks, 'g','linewidth',1.2);
% text(sweepEdges,repmat(yscales(2)*0.8,UsedswNum,1),cellstr(num2str((1:UsedswNum)','%d')));
title('Neu1 select sweep plot')

subplot(212)
hold on
xbase = 0;
for cSW = 1 : plotScaleNum
    cScale = UsedScales(cSW,1):UsedScales(cSW,2);
    cScale_xtick = (1:length(cScale)) + xbase + 1;
    plot(cScale_xtick, Neu2Traceraw(cScale),'k');
    if IsEPSC
        plot(cScale_xtick,-Neu2ST_UsedTrace(cScale),'r','linewidth',1);
    else
        plot(cScale_xtick,Neu2ST_UsedTrace(cScale),'r','linewidth',1);
    end
    xbase = xbase + length(cScale) + 1000;
end
set(gca,'xlim',[0 xbase]);
title('Neu2 select sweep plot')

%%
saveas(hhf,'F:\xy\exanpleNeuplots\np36\Nearpeak sweep plot save');
saveas(hhf,'F:\xy\exanpleNeuplots\np36\Nearpeak sweep plot save','png');
saveas(hhf,'F:\xy\exanpleNeuplots\np36\Nearpeak sweep plot save','pdf');

