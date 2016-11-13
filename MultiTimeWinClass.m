function MultiTimeWinClass(RawDataAll,StimAll,TrialResult,AlignFrame,FrameRate,trOutcome)
% this function is try to generating different time window to calculate
% classification performance within given time win, and plot the
% classificatio rate change time course

if ~isdir('./mWin_perfPlot/')
    mkdir('./mWin_perfPlot/');
end
cd('./mWin_perfPlot/');
    
nFrame = size(RawDataAll,3);
MultiTScale = -0.5:0.5:((nFrame - AlignFrame)/FrameRate);
MultiTScale(MultiTScale == 0) = []; 
fprintf('Time window number is %d.\n',length(MultiTScale));

TrWinClassPerf = zeros(length(MultiTScale),1);
% TrWinClassModel = cell(length(MultiTScale),1000);
TrWinClassPerfAll = zeros(length(MultiTScale),1000);
for nn = 1 : length(MultiTScale)
    CurrentWin = MultiTScale(nn);
    if abs(CurrentWin) < 1
        TimeWin = CurrentWin;
    else
        TimeWin = [CurrentWin-0.5,CurrentWin];
    end
    [MinTloss,AllTloss,~] = TbyTAllROIclass(RawDataAll,StimAll,TrialResult,AlignFrame,FrameRate,...
        TimeWin,[],[],[],trOutcome,1);
    TrWinClassPerf(nn) = MinTloss;
    TrWinClassPerfAll(nn,:) = AllTloss;
%     TrWinClassModel(nn,:) = TrainM;
end

MlWinClassScore = 1 - mean(TrWinClassPerfAll,2);
MlWinClassSem = std(TrWinClassPerfAll,[],2)/sqrt(size(TrWinClassPerfAll,2));
xTime = [MultiTScale,fliplr(MultiTScale)];
WinPerf = [(MlWinClassScore + MlWinClassSem);flipud(MlWinClassScore - MlWinClassSem)];
h_TWinPlot = figure('position',[500 250 1050 720]);
hold on;
patch(xTime,WinPerf,1,'facecolor',[.8 .8 .8],...
              'edgecolor','none',...
              'facealpha',0.7);
plot(MultiTScale,MlWinClassScore,'k','LineWidth',1.6);
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

save MWinCLassData.mat MultiTScale TrWinClassPerf TrWinClassPerfAll -v7.3
cd ..;