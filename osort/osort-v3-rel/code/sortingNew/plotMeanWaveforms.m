%
%shows mean waveforms and merged mean waveforms
%
%urut/april04
function plotMeanWaveforms( meanWaveforms, meanClusters, threshold, stdEstimate, label)
if size(meanWaveforms,1)==0
    return;
end

plotLims=[-2200 2200];

[weights,weightsInv] = setDistanceWeight(1:256,1);

subplot(2,3,1)


plot(meanWaveforms(1,:), 'g', 'LineWidth',2);
hold on
plot(meanWaveforms(1,:)+stdEstimate,'g--','LineWidth',2);
plot(meanWaveforms(1,:)-stdEstimate,'g--','LineWidth',2);


plot(meanWaveforms(2,:), 'r', 'LineWidth',2);
plot(meanWaveforms(2,:)+stdEstimate,'r--','LineWidth',2);
plot(meanWaveforms(2,:)-stdEstimate,'r--','LineWidth',2);



hold off

subplot(2,3,2);
hold on
for i=1:size(meanWaveforms,1)
    linewidth = 3-(i*0.4);
    if linewidth<0.5
        linewidth=.5;
    end
    plot(meanWaveforms(i,:)','LineWidth',linewidth);
end
hold off
legend('C1','C2','C3','C4','C5');

xlim([1 256]);
ylim(plotLims);
ylabel( [label],'FontSize',12 );

subplot(2,3,3);
if size(meanClusters,1)>0
    nrClustersToPlot=size(meanClusters,1);
    if nrClustersToPlot>7
        nrClustersToPlot=7;
    end
    
    plot(1:256, meanClusters(1:nrClustersToPlot,:)','LineWidth',2);
    xlim([1 256]);
    ylim(plotLims);
end
legend('1','2','3','4','5','6','7');

subplot(2,3,4);
if size(meanClusters,1)>7
    plot(1:256, meanClusters(8:end,:)','LineWidth',2);
    xlim([1 256]);
    ylim(plotLims);
end
legend('8','9','10','11','12','13','14');

subplot(2,3,5)
if size(meanClusters,1)>0
    plot(1:256, meanClusters','LineWidth',2);
    xlim([1 256]);
    ylim(plotLims);
end


subplot(2,3,6)
plot(weights);
xlim([1 256]);


% figure
% plot(1:256, meanClusters','LineWidth',2);
% hold on
% hold off
% xlim([1 256]);
% ylim([-1200 1500]);
% 
% legend('1','2','3','4','5','6','7','8');
% 
% title(label);
% 
% save('c:\temp\P2S2A11meanClusters','meanClusters');
