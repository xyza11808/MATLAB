%detects and sorts spike of a simulated file. calculates statistics about performance.
%plots various statistics and diagnostic tools.
%
%
%parameters need to be modified before this file can be run.
%reorder needs to be modified manually after sorting to match found
%clusters to theoretical clusters before performance analysis can be
%conducted.
%
%other parameters to modify: extractionThreshold, levelNr (which noise
%level to analyze), realWaveformsInd (which waveforms to use for simulated
%neurons).
%
%params: simNr -> 1,2,3 simulation nr
%levelNr: noise level (1-4)
%export: 0 (no), 1 ( yes -> only detect, store in file and exit. to compare
%with offline sorting algos.
%doPlot: yes/no 
%
%urut/dec04; major changes for revision urut/nov05
%urut/may07: revised for new alignment/detection methods.
function [perf,nrAssigned,assigned,params] = runSimulatedEval(simNr, levelNr, parameterSets, export, doPlot)
colors={'r','b','g','m','c','y','k'};

%% set parameters
%global settings
params=[];
params.bandPass=[300 3000];
params.nrNoiseTraces=0;
params.prewhiten=0;
params.samplingFreq=25000;
params.limit=100;

%simNr=1;
%levelNr=1;
thresholdMethod=1; %1 raw, 2 pre-whiten
upsample=1; %yes/no

switch( parameterSets )
    case 1
        %wavelet detection
        params.extractionThreshold = 0;
        params.alignMethod=3; %1 pos, 2 neg, 3 mixed
        params.peakAlignMethod=4; %1 findPeak, 2 none, 3 power, 4 mteo
        params.detectionMethod=5;
        dp3=[];
        dp3.scalesRange=[0.2 1.0];
        dp3.waveletName='bior1.5';
        params.detectionParams=dp3;
    case 2
        %power detection
        params.extractionThreshold = 4;
        params.alignMethod=3; %1 pos, 2 neg, 3 mixed
        params.peakAlignMethod=1; %1 findPeak, 2 none, 3 power, 4 mteo
        params.detectionMethod=1; %1 power, 5 WDM
        dp1=[];
        dp1.kernelSize=18;
        params.detectionParams=dp1;
    otherwise
        error('invalid parameter set nr');
end

%% load files
loadSimulationFiles;
reorder = loadSimulationFiles_order(simNr, levelNr, parameterSets);
nrNeurons=length(realWaveformsInd);

spiketrainDown=spiketrains{levelNr};
noiseStd=noiseStds(levelNr);

%% --- detect spikes

%scale arbitrarily - should not change any of the results (control)
addNoise=0;
upscale=1;

%whiten to remove correlations (make noise white)
if thresholdMethod == 2
    x=spiketrainDown(1:50000);
    [a,e]=lpc(x,3);
    a=real(a);
    e=sqrt(e);
    spiketrainDown=filter(a,e,spiketrainDown);
end

spiketrainDown=spiketrainDown*upscale;
[filteredSignal, rawTraceSpikes,spikeWaveforms, spikeTimestamps, runStd2,upperlim,noiseTraces] = detectArtificialSpikes( spiketrainDown + randn(1,length(spiketrainDown))*addNoise*noiseStd*upscale/10, params );

%estimate std from raw signal
stdEstimate=std(filteredSignal);

%spikeWaveformsUnshifted=spikeWaveforms;
%[spikeWaveforms,spikeTimestampsShifted,shifts] = realigneSpikes(spikeWaveforms,spikeTimestamps,3,stdEstimate, peakAlignMethod);  %3==type is negative, do not remove any if too much shift

transformedSpikes=[];
if thresholdMethod==2
    %--correlated noise removal.
    %white noise needs to be added to guarantee numerical stability of
    %covariance matrix. this is a problem but unavoidable with this
    %approach. for real data this is often a serious problem (rank
    %deficient noise).
    
    %estimate from data
    %     nrSamples=250000;
    %     autocorr = xcorr( spiketrainDown(1:nrSamples)+randn(1,nrSamples)*addNoise*noiseStd*upscale/10, 64, 'biased');
    %     covUp = autocorr(65:end-1);
    %     
    %    C = toeplitz( covUp );

    if upsample
        C=eye(256);
    else
        C=eye(64);
    end
    
    cdet=det(C);
    if cdet==0
        error('det=0. this data is rank deficient.');
    end
    if cdet<1e-100
        warning(['det is badly conditioned. = ' num2str(cdet)]);
    end

    Cinv = inv( C );
    
    %[transformedSpikes,transformedBack,Rinv] = transformBasis ( spikeWaveformsUnshifted, Cinv );
    %spikeWaveformsUp=transformedSpikes;
    transformedSpikes=spikeWaveforms;
end

%upsample and realign
if upsample
    spikeWaveformsUp=upsampleSpikes(spikeWaveforms);
    
    switch (params.peakAlignMethod)
        case 1 %findPeak
            [spikeWaveformsUp,newTimestamps,shifts] = realigneSpikes(spikeWaveformsUp,spikeTimestamps, params.alignMethod, stdEstimate, params.peakAlignMethod);  %3==type is negative, do not remove any if too much shift
        case 4 %MTEO
            [spikeWaveformsUp,newTimestamps, shifts] = realigneSpikes(spikeWaveformsUp, spikeTimestamps, [], [], 3); %3 ->only adjust peak,already aligned.
    end    
    transformedSpikes=spikeWaveformsUp;
else
    spikeWaveformsUp=spikeWaveforms;
end

if upsample && export
    save(['simSpikes-sim' num2str(simNr) '-n' num2str(levelNr)], 'spikeWaveformsUp', 'spiketimes', 'simNr', 'levelNr', 'spikeTimestamps');
    return;
end


%--- if pre-whitening is used
%[transformedSpikes,transformedBack,Rinv] = transformBasis ( spikeWaveformsUp,Cup );
%spikeWaveformsUp=transformedSpikes;
%C=cov(transformedSpikes);
%Cinv = inv( C );
%--- end pre-whiteneing

%--debugging figures
% figure(200)
% subplot(2,2,1)
% if size(transformedSpikes,1)>1
%     plot( transformedSpikes' )
% end
% %if, in the transformed spikes, there are huge peaks, this means that the
% %covariance matrix is numerically unstable (because of non white noise).
% subplot(2,2,2)
% plot( spikeWaveforms' )

% subplot(2,2,3)
% plot(covUp);

%  
%  pp=size(spikeWaveformsUp,2)
% figure(201);
% for i=1:pp
%     subplot(10,10,i)
%     plot( 1:pp, C(1:pp,i),'r');
%     xlim([1 pp+4]);
% end
% figure(202);
% for i=1:64
%     subplot(8,8,i)
%     plot( 1:pp, Cinv(1:pp,i),'r');
%     xlim([1 pp+4]);
% end
% Cinv2=inv(C);
% figure(203);
% pp=64
% for i=1:64
%     subplot(8,8,i)
%     plot( 1:pp, Cinv2(1:pp,i*3),'r');
%     xlim([1 pp+4]);
% end

%range,for each neuron at peak (95) which is considered missaligned
%(defined by hand)
% missAligned(1,1:2)=[0 3];
% missAligned(2,1:2)=[-3 0];
% missAligned(3,1:2)=[0 3];
% missAlignedStat=[];
% 
% %--- find all spikes which would, in theory, belong to one neuron
% figure(71)
% for i=1:nrNeurons
%     subplot(3,3,i)
% 
%     inds = findAllOrigTimestamps ( spiketimes{i}, spikeTimestamps);
%     %hold on
%     plot( transformedSpikes( inds,:)', colors{i})
%     %hold off
% 
%     subplot(3,3,i+3)
%     plot( spikeWaveforms( inds,:)', colors{i})
%     
%     subplot(3,3,i+6)
%     
%     plot( spikeWaveformsUp( inds,:)', colors{i})
%     
%     missAlignedStat(i) = length ( find( spikeWaveformsUp(inds,95) > missAligned(i,1) & spikeWaveformsUp(inds,95) < missAligned(i,2) ));
% end
% missAlignedStat


% [transformedSpikes2,Sspectrum] = removeWhitenoise(transformedSpikes, 4);
%spikeWaveformsUp=upsampleSpikes(transformedSpikes);
% spikeWaveformsUp = realigneSpikes(spikeWaveformsUp,spikeTimestamps,3);  %3==type is negative, do not remove any if too much shift
% figure(75)
% plot( transformedSpikes2' );

%% illustrate simulated spiketrain, spikes marked
%raw trace and zoom in, for paper
if doPlot
    figure(15)
    %fromInd=5000;
    %tillInd=25000;

    fromInd=30000;
    tillInd=60000;

    fromIndZoom=36500;
    tillIndZoom=41000;

    subplot(2,1,1)
    plot(filteredSignal(fromInd:tillInd));
    hold on
    for i=1:nrNeurons
        spikeTimesThisNeuron = spiketimes{i};
        toPlot = spikeTimesThisNeuron ( find(spikeTimesThisNeuron<=tillInd & spikeTimesThisNeuron>=fromInd));
        if length(toPlot)>0
            plot(toPlot-fromInd , min(rawTraceSpikes)/2,[colors{i} 'x'],'MarkerSize',10,'LineWidth',3);
        end
    end
    hold off
    xlim([1 tillInd-fromInd]);
    ylim([-1.3 1.3]);
    ylabel('Amplitude');
    tickLabels=str2num(get(gca,'XTickLabel'))*10000/25; %convert to ms
    set(gca,'XTickLabel', tickLabels );


    subplot(2,1,2)

    plot(filteredSignal(fromInd:tillInd));
    hold on
    for i=1:nrNeurons
        spikeTimesThisNeuron = spiketimes{i};
        toPlot = spikeTimesThisNeuron ( find(spikeTimesThisNeuron<=tillInd & spikeTimesThisNeuron>=fromInd));
        if length(toPlot)>0
            plot(toPlot-fromInd , min(rawTraceSpikes)/2,[colors{i} 'x'],'MarkerSize',10,'LineWidth',3);
        end
    end
    hold off

    xlim([fromIndZoom-fromInd tillIndZoom-fromInd]);
    ylim([-1.3 1.3]);
    ylabel('Amplitude');
    xlabel('Time [ms]');
    tickLabels=str2num(get(gca,'XTickLabel'))/25; %convert to ms
    set(gca,'XTickLabel', tickLabels );

    %% illustrate detection
    figure(14)
    fromInd=1;
    tillInd=25000;
    subplot(4,1,1)
    plot(filteredSignal(fromInd:tillInd));
    hold on
    for i=1:nrNeurons
        spikeTimesThisNeuron = spiketimes{i};
        toPlot = spikeTimesThisNeuron ( find(spikeTimesThisNeuron<=tillInd & spikeTimesThisNeuron>=fromInd));
        if length(toPlot)>0
            plot(toPlot-fromInd , min(rawTraceSpikes)/2,[colors{i} 'x'],'MarkerSize',10,'LineWidth',3);
        end
    end
    hold off
    title(['Sim ' num2str(simNr) ' Noise level ' num2str(levelNr) ' , Filtered 300-3000Hz']);
    xlim([1 tillInd-fromInd]);
    ylim([-1.1 1.1]);

    subplot(4,1,2);
    if length(runStd2)>0
        plot(fromInd:tillInd, runStd2(fromInd:tillInd), 'b', fromInd:tillInd, upperlim(fromInd:tillInd),'r' );
    end


    subplot(4,1,3)
    plot( rawTraceSpikes(fromInd:tillInd) );
    hold on
    for i=1:nrNeurons
        spikeTimesThisNeuron = spiketimes{i};
        toPlot = spikeTimesThisNeuron ( find(spikeTimesThisNeuron<=tillInd & spikeTimesThisNeuron>=fromInd));
        if length(toPlot)>0
            plot(toPlot-fromInd , min(rawTraceSpikes)/2,[colors{i} 'x'],'MarkerSize',10,'LineWidth',3);
        end
    end
    hold off
    xlim([1 tillInd-fromInd]);

end
%------



% figure(99)
% 
% rr=randperm(126)
% 
% 
% 
% 
% 
% scaled = allMeans(realWaveformsInd , :);
% 
% SNR=[];
% scalingFactorSpikes=[];
% for i=1:length(realWaveformsInd)
%     
%     
%     %to scale all of them to one, uncomment following line
%     %maxAmp = max(abs(allMeans(realWaveformsInd(i), :)));
% 
%     %to scale all with same factor
%     maxAmp = max(max(abs(allMeans(realWaveformsInd, :))));
%     
%     
%     scalingFactorSpikes(i) = 1/maxAmp;
%     
%     scaled(i,:) = scaled(i,:)*scalingFactorSpikes(i);
%     
%     SNR(i) = norm(scaled(i,:))/(sqrt(256)*noiseStd);
% end
% mean(SNR)
% 
% plot(scaled','LineWidth',3);
% 
% %plot( allMeans(realWaveformsInd , :)','LineWidth',3);
% legend('a','b','c','d','e');
% title(['Simulation ' num2str(simNr) ' mean waveforms ']);
% xlim([10 250]);
% ylim([-1.1 1.1]);
% 
% 
% %mean peak amplitude to calculate SNR
% meanPeakAmpl = scalingFactorSpikes * mean(max(abs(allMeans( realWaveformsInd,:)')));
% meanPeakAmpl/noiseStd;



% figure(1)
% subplot(1,2,1)
% plot( allMeans( realWaveformsInd, : )','LineWidth',3 );
% legend('1','2','3');
% 
% subplot(1,2,2);
% plot( allMeans( noiseWaveformsInd, : )' );

% figure(20)
% subplot(4,1,1)
% plot(spiketrainNoise);
% subplot(4,1,2)
% plot(spiketrain,'r');
% 
% hold on
% for i=1:nrNeurons
%     plot( spiketimes{i}*4, min(spiketrain),[colors{i} 'x'],'MarkerSize',10,'LineWidth',3);
% end
% hold off
% 
% subplot(4,1,3);
% plot( spiketrainDown);
% title('Downsampled, 25kHz');
% xlim([0 nrSamples/4]);
% hold on
% for i=1:nrNeurons
%     plot( spiketimes{i}, min(spiketrain),[colors{i} 'x'],'MarkerSize',10,'LineWidth',3);
% end
% hold off


%---- analyse noise
%look at autocorrelation to assure that it is similar to what we see in
%real data
% 
% C=cov(noiseTraces);
% figure(4)
% plot(1:size(C,2), C(1,:),'LineWidth',3);
% title('Noise autocorrelation');
% xlim([0 size(C,2)]);

%xlim([0 nrSamples/4]);
%title('waveforms detected');

%for i=1:3
%subplot(4,1,i);
%xlim([100000 125000]);
%end


% figure(12)
% subplot(2,2,1);
% plot(spikeWaveforms', 'r');
% title('Waveforms as detected (raw)');
% xlim([1 size(spikeWaveforms,2)]);
% 
% subplot(2,2,2);
% plot(spikeWaveformsUp', 'r');
% title('Waveforms (upsampled and re-aligned)');
% xlim([1 size(spikeWaveformsUp,2)]);

% subplot(2,2,3);
% plot(transformedSpikes', 'r');
% title('transformed');
% xlim([1 size(transformedSpikes,2)]);

%% ---sort
sortTill=9999999;

%stdEstimate=1;
if thresholdMethod==1
    %threshold is variance
    [assigned, nrAssigned, baseSpikes, baseSpikesID] = sortSpikesOnline( spikeWaveformsUp, stdEstimate, sortTill );
else    
    %threshold is value from chi2 test
    
    alpha=0.1;
    %v=size(spikeWaveformsUp,2);
    
    if upsample
        %v=256*2/3;    
        v=150;
    else
        v=64/2;  %64 datapoints. however,waveforms only change on approx 40 of it
    end
    
    chi2Val = chi2inv( 1-alpha, v)
    chi2Val = chi2Val
    [assigned, nrAssigned, baseSpikes, baseSpikesID] = sortSpikesOnline( spikeWaveformsUp, chi2Val, sortTill, thresholdMethod, Cinv, transformedSpikes );
end

%% plot sorting result
if doPlot

    figure(13);
    close(gcf);
    figure(13);
    subplot(2,2,1)
    hold on
    %for i=nrNeurons+2:-1:1
    for i=1:nrNeurons+2
        if size(nrAssigned,1)-i<1
            continue;
        end

        tmpInds = find( nrAssigned(end-i+1,1)==assigned);
        if length(tmpInds)==0
            continue;
        end

        plot ( spikeWaveformsUp ( tmpInds, : )', colors{i} );
    end
    hold off

    xlim([0 size(spikeWaveformsUp,2)]);
    xlabel('1=r,2=b,3=g,4=m,5=c,6=y,7=k');

    title('found');

    subplot(2,2,2);
    hold on
    for i=1:nrNeurons
        plot ( scalingFactorSpikes(i)*allMeans(realWaveformsInd(i),:) , colors{i}, 'LineWidth', 3 );
    end
    hold off
    xlabel('1=r,2=b,3=g,4=m,5=c,6=y,7=k');

    title('orig means');

    %map original # of neurons to clusters found (do this manually after a
    %resort for each set,because they come out in arbitrary order).
    % reorder=[1 2 3;
    %          4 2 1];

    subplot(2,2,3)
    %figure(88)
    hold on
    allInds=[];
    for i=1:nrNeurons

        tmpInd = size(nrAssigned,1)-reorder(2,i)+1;

        if tmpInd<1
            break;
        end
        inds = find( nrAssigned(tmpInd,1)==assigned);
        allInds=[allInds inds];
    end

    %noise
    plot ( spikeWaveformsUp( setdiff( 1:length(assigned), allInds),:)', 'k');


    %for i=1:1:nrNeurons
    %for i=nrNeurons:-1:1

    %order neurons as they are originally 1,2,3....,   regardless of color
    orderNeurons = sort(reorder(2,:));
    for preInd=1:length(orderNeurons)
        i = find( reorder(2,:) == orderNeurons(preInd) );
        inds = find( nrAssigned(end-reorder(2,i)+1,1)==assigned);
        allInds=[allInds inds];
        plot ( spikeWaveformsUp ( inds, : )', colors{i} );
    end

    hold off
    xlim([0 size(spikeWaveformsUp,2)]);
    title('found,re-ordered');
    %ylim([-1.5 1.5]);
    hold off

    subplot(2,2,4)
    plot ( spikeWaveformsUp( setdiff( 1:length(assigned), allInds),:)', 'k');


    %hold on
    % for i=nrNeurons:-1:1
    %     plot ( spikeWaveformsUp ( find( nrAssigned(end-reorder(2,i)+1,1)==assigned), : )', colors{i} );
    % end
    % hold off
    % xlim([0 256]);
    % title('found,re-ordered');
    % ylim([-1.5 1.5]);



    %----
end

%% evaluate performance

%---- how many are correctly detected
[perf, indsNoiseWaveforms] = evalPerformance(nrNeurons, spikeTimestamps, spiketimes, reorder, nrAssigned, assigned);

perf

%% more plots (PCA)

if doPlot
    %--- PCA
    % origWaveformsTogether=[];
    % origWaveformsInds=[];
    % for i=1:nrNeurons
    %     origWaveformsInds(i,:) = [size(origWaveformsTogether,1)+1 size(origWaveformsTogether,1)+size(waveformsOrig{i},1)];
    %     origWaveformsTogether = [origWaveformsTogether; waveformsOrig{i}];
    % end

    [pc,score,latent,tsquare] = princomp(spikeWaveformsUp);
    % [pc2,score2,latent2,tsquare2] = princomp(transformedSpikes);
    % [pc3,score3,latent3,tsquare3] = princomp(origWaveformsTogether);

    % plot pca illustration
    figure(8888)
    close(gcf);
    figure(8888)

    subplot(2,2,2)
    hold on
    indsAll=[];
    for i=1:nrNeurons
        inds = find( nrAssigned(end-reorder(2,i)+1,1)==assigned);
        indsAll=[indsAll inds];
        plot(score(inds,1), score(inds,2),['.' colors{reorder(1,i)}]);
    end

    indsNoise = setdiff( 1:size(score,1), indsAll);
    plot(score(indsNoise,1), score(indsNoise,2),['.k']);

    hold off
    title('output of sorting ');

    subplot(2,2,1)
    hold on
    indsAll=[];

    for i=1:nrNeurons
        inds = findAllOrigTimestamps ( spiketimes{i}, spikeTimestamps);
        indsAll=[indsAll inds];

        plot(score(inds,1), score(inds,2),['.' colors{i}]);
    end
    indsNoise = setdiff( 1:size(score,1), indsAll);
    plot(score(indsNoise,1), score(indsNoise,2),['.k']);
    hold off
    title([ 'Ground truth (as detected/realigned) N:' num2str(levelNr) ] );
    %
    % subplot(2,2,3)
    % hold on
    % for i=1:nrNeurons
    %     inds = findAllOrigTimestamps ( spiketimes{i}, spikeTimestamps);
    %
    %     plot(score2(inds,1), score2(inds,2),['.' colors{i}]);
    % end
    % hold off
    % title([ 'Ground truth (decorrelated) N:' num2str(levelNr) ] );
    %
    % subplot(2,2,4)
    % hold on
    % for i=1:nrNeurons
    %     inds = origWaveformsInds(i,1):origWaveformsInds(i,2);
    %     plot(score3(inds,1), score3(inds,2),['.' colors{i}]);
    % end
    % hold off
    % title([ 'Ground truth (orig,as inserted) N:' num2str(levelNr) ] );

    %--- PCA end
end

return;

%all trouble causing wrong detections
figure(13)
subplot(2,2,4)
hold on
plot(1:256, spikeWaveformsUp(indsNoiseWaveforms,:),'r')
hold off


%------

%xlim([1 256]);
%hold off
%title('orig (ground truth)');
%ylim([-1.5 1.5]);

%investigate failures
figure(77)
plot( 20:240,waveformsOrig{3}','r');
hold on
plot(1:256,spikeWaveformsUp ( find( nrAssigned(end-5+1,1)==assigned), : )', 'b');
hold off






transformedSpikesRealigned = realigneSpikes(transformedSpikes,spikeTimestamps,3); 

figure(68)
for i=3:3

    inds = findAllOrigTimestamps ( spiketimes{i}, spikeTimestamps);
    hold on
    subplot(2,1,1)
    plot( transformedSpikes( inds,:)', colors{i})
    subplot(2,1,2)
    plot( transformedSpikesRealigned( inds,:)', colors{i})
    hold off
end



%spikeWaveformsUp = 


figure(78)
subplot(2,2,1)
plot( spikeWaveformsUp( inds,:)', 'r')
            
subplot(2,2,2)
plot( transformedSpikes( inds,:)', 'r')

subplot(2,2,3)
plot( transformedSpikes2( inds,:)', 'r')

exportfig(gcf,['PCAprojN' num2str(levelNr) '.eps'],'format','eps','fontsize',12,'fontmode','fixed','width',30,'height',60,'color','cmyk')


%--- projection test

%significance test between all clusters
clusters = [];
for i=1:nrNeurons
    clusters(i) = nrAssigned(end-reorder(2, i)+1,1);  %get the cluster #
end

pairs=[];
c=0;
for i=1:length(clusters)
        for j=i+1:length(clusters)
                c=c+1;
                pairs(c,1:4)=[clusters(i) clusters(j) i j];
        end
end

%change this for each specific configuration,so that histograms have same
%color as mean waveforms to enable easy comparison
colorsInOrder={'b','g','r','c','m'};

%plot all projections
figure(19)
for i=1:size(pairs,1)
    subplot(4,3,i);

    colorsPair = { colorsInOrder{pairs(i,3)}, colorsInOrder{pairs(i,4)}};
    
    [d,residuals1,residuals2,Rsquare1, Rsquare2] = figureClusterOverlap(transformedSpikes, spikeWaveformsUp, assigned, pairs(i,1), pairs(i,2), '',2,colorsPair);
    set(gca,'FontSize',14);
    %set(gca,'YTickLabel','');
    ylabel([num2str(pairs(i,3)) '/' num2str(pairs(i,4)) 'Dist: ' num2str(d,2) ]);
    %xlims=xlim;
    
    xlim([-5 max([residuals1 residuals2])]);
    
    rVals = [' R^2 = ' num2str(Rsquare1,2) '/' num2str(Rsquare2,2)];
    
    text(-4.5,0.4, rVals);
    title([num2str(pairs(i,3)) '->' num2str(pairs(i,4)) ' - D=' num2str(d,2)]);
end


exportfig(gcf,'projectionTestN1.eps','format','eps','fontsize',12,'fontmode','fixed','width',30,'height',60,'color','cmyk')




save('simulation3Params.mat','reorderN1','reorderN2','reorderN3','reorderN4');