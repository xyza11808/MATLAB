%verification of alignment performance
%
% this file is for debugging/playing arround; it isnt used for any of the real simulations.
%


%====== verify that power signal has info about alignment

simNr=1;
lNr=4;
levelNr=lNr;
Fs=25000;
%load(['/data2/simulated/sim6/simulation6_100s_level_' num2str(lNr) '.mat']);
%load(['~/code/sortingNew/model/sim' num2str(simNr) '/simulation' num2str(simNr) '.mat']);
loadSimulationFiles;

%power signal

kernelSizes=[25];
runStd2=zeros(1,length(spiketrains{lNr}));
v=[];
for i=1:length(kernelSizes)
    tmp = runningStd(spiketrains{lNr}, kernelSizes(i)); 
    v(i) = std(tmp);
    
    runStd2 = runStd2 + [tmp zeros(1,kernelSizes(i)-1) ]./v(i);
end

runTEO = MTEO(spiketrains{lNr}, [1 2 3]);


f=1;t=127740;
figure(22);
subplot(3,1,1)
plot([f:t]/Fs, spiketrains{lNr}(f:t) );
subplot(3,1,2)
plot([f:t]/Fs, runStd2(f:t) );
title('power');

subplot(3,1,3)
plot([f:t]/Fs, runTEO(f:t) );
title('MTEO');


rawTEO=[];
rawWaveforms=[];
powerWaveforms=[];
powerDiff=[];

maxPos=[];
i=1;
wSize=[25 35];

%sim4/l3: correctLoc=[30 35; 35 42; 30 40; 30 40; 30 40];
correctLoc=[35 45; 35 45; 25 35];

for i=1:length(spiketimes)
    times=spiketimes{i};

    for j=1:length(times)
        t=round(times(j));
        
        rTEO = ( runTEO(t-wSize(1):t+wSize(2)) );
        rSig = spiketrains{lNr}(t-wSize(1):t+wSize(2));
        pSig = runStd2(t-wSize(1):t+wSize(2));                
        diffPsig = diff(pSig);
        
        max1 = find(rSig==max(rSig));
        max1 = max1(1);
        max2 = find(pSig==max(pSig));
        max2 = max2(1);
        max3 = find(diffPsig==min(diffPsig));
        max3 = max3(1);
        max4 = find(rTEO==max(rTEO));
        max4 = max4(1);
        max5 = find(abs(rSig)==max(abs(rSig)));
        max5 = max5(1);
                
        peakInd=findPeakPower(rSig, rTEO);


        
        rawWaveforms(j,:) = rSig;
        rawTEO(j,:) = rTEO;
        powerWaveforms(j,:) = pSig;        
        powerDiff(j,:) = diffPsig;
        
        maxPos(j,:) = [ max1 max2 max3 max4 max5 peakInd];
    end

    figure(90+i);
    till=length(times);
    %till=100;
    subplot(3,2,1)
    plot( 1:sum(wSize)+1,rawWaveforms(1:till,:),'r');
    xlim([1 60]);
    
    subplot(3,2,2)
    plot( 1:sum(wSize),powerDiff(1:till,:),'r');
    xlim([1 60]);
    
    
    subplot(3,2,3)
    hist(maxPos(1:till,5),20);
    %xlim([1 60]);
    nrCorrect = length(find ( maxPos(1:till,5) > correctLoc(i,1) & maxPos(1:till,5) < correctLoc(i,2) ));
    title(['raw % corr ' num2str( nrCorrect/till*100)]);

    
    subplot(3,2,4)
%     hist(maxPos(1:till,4),30);
%     xlim([1 60]);
%     nrCorrect = length(find ( maxPos(1:till,4) > correctLoc(i,1)-3 & maxPos(1:till,4) < correctLoc(i,2)-3 ));
%     title(['TEO % corr ' num2str( nrCorrect/till*100)]);

    hist(maxPos(1:till,6),30);
    %xlim([1 60]);
    nrCorrect = length(find ( maxPos(1:till,6) > correctLoc(i,1) & maxPos(1:till,6) < correctLoc(i,2) ));
    title(['MTEO % corr ' num2str( nrCorrect/till*100)]);
    
    subplot(3,2,5)
    hist(maxPos(1:till,3),30);
    %xlim([1 60]);
    nrCorrect = length(find ( maxPos(1:till,3) > correctLoc(i,1) & maxPos(1:till,3) < correctLoc(i,2) ));
    title(['POWER % corr ' num2str( nrCorrect/till*100)]);

    subplot(3,2,6)
    %plot( 1:sum(wSize)+1,powerWaveforms(1:till,:),'r');
    plot( 1:sum(wSize)+1,rawTEO(1:till,:),'r');
    xlim([1 60]);

end
