function MultiTimeWinClf(RawDataAll,StimAll,TrialResult,AlignFrame,FrameRate,Parastrc,varargin)
% this function is try to generating different time window to calculate
% classification performance within given time win, and plot the
% classificatio rate change time course

TimeStep = 0.5; % time step for each time window
if ~isempty(varargin)
    if ~isempty(varargin{1})
        TimeStep = varargin{1};
    end
end

if ~isdir('./mWin_perfPlot/')
    mkdir('./mWin_perfPlot/');
end
cd('./mWin_perfPlot/');
Parastrc.isDataOutput = 1;
nFrame = size(RawDataAll,3);
MultiTScale = -0.5:TimeStep:((nFrame - AlignFrame)/FrameRate);
MultiTScale(MultiTScale == 0) = []; 
PlotxTick = MultiTScale;
BaseScaleInds = MultiTScale < 0;
PlotxTick(BaseScaleInds) = PlotxTick(BaseScaleInds) + TimeStep;
fprintf('Time window number is %d.\n',length(MultiTScale));

% TrWinClassPerf = zeros(length(MultiTScale),1);
% TrWinClassModel = cell(length(MultiTScale),1000);
TrWinClassPerfAll = zeros(length(MultiTScale),1000);
TimeWinValue = cell(length(MultiTScale),1);
for nn = 1 : length(MultiTScale)
    CurrentWin = MultiTScale(nn);
    if abs(CurrentWin) < (TimeStep*1.8)
        TimeWin = CurrentWin;
    else
        if CurrentWin < 0
            TimeWin = [CurrentWin,CurrentWin+TimeStep];
        else
            TimeWin = [CurrentWin-TimeStep,CurrentWin];
        end
    end
    TimeWinValue{nn} = TimeWin;
    Parastrc.TimeWinLen = TimeWin;
    AllTloss = TbyTAllROIFORclass(RawDataAll,StimAll,TrialResult,AlignFrame,FrameRate,Parastrc);
%     TrWinClassPerf(nn) = MinTloss;
    TrWinClassPerfAll(nn,:) = AllTloss;
%     TrWinClassModel(nn,:) = TrainM;
end

MlWinClassScore = 1 - mean(TrWinClassPerfAll,2);
MlWinClassSem = std(TrWinClassPerfAll,[],2)/sqrt(size(TrWinClassPerfAll,2));
xTime = [PlotxTick,fliplr(PlotxTick)];
WinPerf = [(MlWinClassScore + MlWinClassSem);flipud(MlWinClassScore - MlWinClassSem)];
h_TWinPlot = figure('position',[500 250 1050 720]);
hold on;
patch(xTime,WinPerf,1,'facecolor',[.8 .8 .8],...
              'edgecolor','none',...
              'facealpha',0.7);
plot(PlotxTick,MlWinClassScore,'k','LineWidth',1.6);
xlims = get(gca,'xlim');
line(xlims,[0.5,0.5],'Color',[.8 .8 .8],'LineWidth',1.6,'LineStyle','--');
line([0 0],[0.4 1],'Color',[.8 .8 .8],'LineWidth',1.6,'LineStyle','--');
ylim([0.4 1]);
xlabel('TimeScale(s)');
ylabel('Classification correct');
title('Time win classification');
set(gca,'FontSize',16);
saveas(h_TWinPlot,'Time Win Correct rate plot');
saveas(h_TWinPlot,'Time Win Correct rate plot','png');
close(h_TWinPlot);

save MWinCLassData.mat MultiTScale TrWinClassPerfAll -v7.3
cd ..;