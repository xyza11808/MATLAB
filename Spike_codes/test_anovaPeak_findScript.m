
cA = 1;
FactorStrs = {'Choice','Stim','BlockType'};
% hf = figure('position',[100 100 1200 340]);
% figure;
% cf = 2;
nFactors = size(AllArea_anovaEVdatas,3);
% AllArea_BTAnova_freqwise

for cf = 1 : nFactors
    cfRealData = AllArea_anovaEVdatas{cA,cf,1};
    cfThresData = AllArea_anovaEVdatas{cA,cf,2};
    
    cA_AvgTrace = mean(cfRealData,2);
    cA_ThresAvg = mean(cfThresData,2);
    
    hf = figure('position',[100 100 380 260]);
    hold on
    plot(UnitCalWinTimes, cfRealData,'Color',[.7 .7 .7]);
    plot(UnitCalWinTimes, cA_AvgTrace,'k','linewidth',1.5);
    plot(UnitCalWinTimes, cA_ThresAvg,'c','linewidth',1,'linestyle','--');
    line([0 0],[0 0.3],'Color','m','linewidth',1,'linestyle','--');
    set(gca,'xlim',[-1.5 3.5])
    xlabel('Times');
    ylabel(FactorStrs{cf});
    title('MOs EV');
    saveas(hf,sprintf('%s MOs EV plot save',FactorStrs{cf}));
    saveas(hf,sprintf('%s MOs EV plot save',FactorStrs{cf}),'png');
%     [pks,locs,w,p] = findpeaks(cA_AvgTrace,'MinPeakDistance',50,'MinPeakProminence',cA_ThresAvg,'MinPeakHeight',0.01,...
%         'Annotate','extents','WidthReference','halfheight');
    
    

end

%%
close
cU = 121;
cU_Trace = cfRealData(:,cU);
figure;
sgf = sgolayfilt(cU_Trace,3,41);
HeightThres = max(sgf)/3;
findpeaks(sgf,'MinPeakDistance',20,'MinPeakProminence',0.01,'MinPeakHeight',HeightThres,...
        'Annotate','extents','WidthReference','halfheight');
%

hold on
plot(cU_Trace,'r');
% plot(sgf,'r')
[NegPeak, NegLocs] = findpeaks(-sgf,'MinPeakDistance',20,...
        'Annotate','extents','WidthReference','halfheight');







