%
%plots details about a single cluster
%
function plotSingleCluster(allSpikes, allTimestamps, assigned, label, clusterNr, spikeColor)
spikeLength=size(allSpikes,2);

cluNr=clusterNr;
spikesToDraw = allSpikes( find(assigned==cluNr),:);
timestamps = allTimestamps( find(assigned==cluNr) );

%for plotting/figures -- plot less waveforms than there are
%spikesToDraw=spikesToDraw(1:10:size(spikesToDraw,1),:);

[f,Pxxn,tvect,Cxx,edges1,n1,yGam1,edges2,n2,yGam2,mGlobal,m1,m2,percentageBelow,CV]  =getStatsForCluster(spikesToDraw, timestamps);

nrSpikes = size(spikesToDraw,1);
fEstimate= nrSpikes / ((timestamps(end)-timestamps(1))/1e6);

manualPlotMode = 0;
if manualPlotMode
    AdBitVolts= 0.000000030518510385491027;  % set manual, just for plotting
    spikesToDraw = spikesToDraw * AdBitVolts * 1e6;  %now in uV
end

subplot(3,2,1);
plot(1:spikeLength, spikesToDraw', spikeColor);
xlim( [1 spikeLength] );
ylabel([label 'C' num2str(cluNr) ' n=' num2str(nrSpikes)]);
title(['Raw waveform f=' num2str(fEstimate,3) 'Hz']);
hold on
plot(1:spikeLength, mean(spikesToDraw), 'b', 'linewidth', 2);
hold off
%ylim( [-1000 2000] );
set(gca,'XTickLabel',{});
%set(gca,'YTickLabel',{});

%xlim([50 250]);   % for plotting figures in papers
%ylim([-40 80]);

%power spectrum
subplot(3,2,2);
        
%convert to spiketrain
plot(f,Pxxn,'r','linewidth',2);        
xlim( [0 80] );
ylim( [0 max(Pxxn)*1.5+1] );  %+1 to prevent 0
xlabel('Hz');
ylabel('(spk/s)^2/Hz');

[isOk2]= checkPowerspectrum(Pxxn,f, 20.0, 100.0);  %check for peaks in powerspectrum in 20.0 ... 100.0 range
stat='yes';
if isOk2==false
    stat='no';
end

title(['Powerspectrum good=' stat]);

%std of waveform
subplot(3,2,3)
S=std(spikesToDraw);
plot(1:256, S,'r','LineWidth',2');
line([95 95],[-3000 3000],'color','m');
xlim([1 256]);
ylim([min(S)*0.5 max(S)*1.5]);
title(['\sigma. \sigma(\sigma)=' num2str(std(S))]);
ylabel('\sigma');

%autocorrelation
subplot(3,2,4)
plot(tvect,Cxx,'r','LineWidth',2);
title('Autocorrelation');
ylabel('(spk/s)^2/Hz');
xlabel('[ms]');
xlim([1 80]);

%histograms
subplot(3,2,5);
bar(edges1,n1,'histc');


title(['ISI Histogram bin=1ms, mean=' num2str(m1,3) ' below=' num2str(percentageBelow(1)) '/' num2str(percentageBelow(3)) '%']);
%set(gca,'XTickLabel',{});
%set(gca,'YTickLabel',{});

ylabel( ['CV=' num2str(CV,3)] );
hold on
plot(edges1, yGam1, 'r','linewidth',2);
hold off
xlim( [0 200] );
xlabel('ms');


subplot(3,2,6);
bar(edges2,n2,'histc');
title(['ISI Histogram bin=5ms, mean=' num2str(m2,3) ' below=' num2str(percentageBelow(2)) '%']);

hold on
plot(edges2, yGam2, 'r','linewidth',2);
hold off
xlim( [0 700] );
xlabel('ms');
