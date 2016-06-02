%
%summary plot of aligned waveforms. also clusters waveforms to illustrate number of clusters (rather than quality of sorting).
%
%urut/april07
function plotSimulatedAlignPerf(w, errors, hits, nonHits, noiseLevel)

subplot(2,2,1)
plot( 1:64, w(hits,1:64)', 'r');
hold on
if length(nonHits)>0
    plot(1:64, w(nonHits,1:64)', 'k');
end
hold off
subplot(2,2,2)
[c,s] = princomp(w);

sortTill=9999;
[assigned, nrAssigned, baseSpikes, baseSpikesID] = sortSpikesOnline( w, noiseLevel, sortTill );

colors={'r','b','g','m','c','y','k'};
nrNeuronsToPlot=5;
subplot(2,2,3)
hold on
%for i=nrNeurons+2:-1:1
for i=1:nrNeuronsToPlot+2
    if size(nrAssigned,1)-i<1
        continue;
    end
    
    tmpInds = find( nrAssigned(end-i+1,1)==assigned);
    if length(tmpInds)==0
        continue;
    end
    
    subplot(2,2,3)
    hold on
    plot ( w ( tmpInds, : )', colors{i} );
    
    subplot(2,2,2)
    hold on
    plot( s(tmpInds,1), s(tmpInds,2), ['.' colors{i}]);

    %subplot(2,2,4)
    %hold on
    %plot ( mean(w ( tmpInds, : ))', colors{i} );
    
end
hold off

%histogram of alignment errors
subplot(2,2,4)
hist(errors,40);
xlabel('error [ms]');
title(['alignment error estimate m=' num2str(mean(errors),2) ' s.d.=' num2str(std(errors),2) 'ms']);
%xlim([-0.5 0.5]);