% --> files loaded in here are precomputed in calcDetectionROC_CPU2.m

simNr=6;
levelNr=4;

load(['/home/urut/tmpSim_sim_' num2str(simNr) '_l_' num2str(levelNr)  '.mat']);



figure(88+levelNr+simNr*10);
ptitle=['simNr=' num2str(simNr) ' level=' num2str(levelNr) ' align=' num2str(params.peakAlignMethod)];
plotDetectionROC( TPall, FPall, thresholds, {['PDM K' num2str(dp1.kernelSize)],'T',['WDM ' num2str(dp3.scalesRange) ' ' dp3.waveletName]}, [0 1.0], [0 1], ptitle)

%==== generate figures from pre-computed files
%
basepath='/home/urut/';

%% ROC plots

figure(5);

levelNrs=[3 4];
simNrs=[1 2 3 6];
nSims=length(simNrs);
nLevels=length(levelNrs);

for ii=1:nLevels
    for jj=1:nSims
        
        subplot(nLevels, nSims, jj+(ii-1)*nSims)
        
        load([basepath 'tmpSim_sim_' num2str(simNrs(jj)) '_l_' num2str(levelNrs(ii))  '.mat']);

        ptitle=['simNr=' num2str(simNrs(jj)) ' level=' num2str(levelNrs(ii)) ' align=' num2str(params.peakAlignMethod)];
        plotDetectionROC( TPall, FPall, thresholds, {['PDM K' num2str(dp1.kernelSize)],'T',['WDM ' num2str(dp3.scalesRange) ' ' dp3.waveletName]}, [0 0.5], [0 1], ptitle)
    
    end
end

%% summary plots TP/FP at given threshold
%this makes  the simX_detection_summary.eps plots
%

figure(6);

TsToPlot=[5 4 0];   %order algos: 1,3,5, in order they are in file

levelNrs=[ 1 2 3 4];
simNrs=[1 2 3 4 6];
nSims=length(simNrs);
nLevels=length(levelNrs);

thresholdOrder=[2  1 3];

for ii=1:nLevels
    selectTP=[];
    selectFP=[];
    selectDP=[];
    for jj=1:nSims
        fname = [basepath 'tmpSim_sim_' num2str(simNrs(jj)) '_l_' num2str(levelNrs(ii))  '.mat']
        load(fname, 'thresholds','TPall','FPall');

        for kk=1:3
           indTmp=thresholdOrder(kk);
           
           Ts=thresholds{indTmp};
           TP=TPall{indTmp};
           FP=FPall{indTmp};
           
           ind = find( Ts == TsToPlot(indTmp) );
           
           %selectTP(jj,kk) = norminv(TP(ind))- norminv(FP(ind));

           selectTP(jj,kk) = TP(ind);
           selectFP(jj,kk) = FP(ind);
           
        end
        
    end
    
    subplot(1,4,ii)
    
    if size(selectTP,1)>1
        m1=[mean(selectTP); mean(selectFP)];
        s1=[std(selectTP); std(selectFP)];
    else
        m1=[ selectTP; selectFP ];
        s1=[ 0 0 0; 0 0 0];
    end
    n1=[size(selectTP,1)];
    se1=s1./sqrt(n1);
    
    bar(m1','grouped');
    %bar(m1');
    legend('TP','FP');
    hold on
    errorbar( [1:3]-.15, m1(1,:), se1(1,:),'.');
    errorbar( [1:3]+.15, m1(2,:), se1(2,:),'.');
    hold off
    set(gca,'XTickLabel',{'TDM','PDM','WDM'});
    title(['sim(s) ' num2str(simNrs) ' level ' num2str(levelNrs(ii))]);
    ylabel('fraction of total');
    
    ylim([ 0 1]);
end

