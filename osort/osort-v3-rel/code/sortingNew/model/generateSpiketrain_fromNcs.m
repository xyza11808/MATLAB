%
% takes a real raw trace that only contains noise from a Ncs file and uses it to build a simulated file.
%
%urut/april07

basepath='/data2/simulated/sim6/';
%rawFile='/data2/KP_032307/rawOld/A10.Ncs';  %Ncs file that contains no spikes, only noise

rawFile='/data2/FC_092306/raw/A10.Ncs';  %Ncs file that contains no spikes, only noise

fileFormat=1;
%Fs=32556;
Fs=25000;

fromInd=1000;
toInd=fromInd+Fs*1000*1000;

[timestamps,dataSamples] = getRawData( rawFile, ceil(fromInd/512), ceil(toInd/512), fileFormat );
[headerInfo, scaleFact, fileExists] = getRawHeader( rawFile )
scaleFactor=str2num(headerInfo{15}(end-14:end));

dataSamples=dataSamples*scaleFactor*1e6;

%bandpass filter if necessary
n = 4; 
Wn = [300 3000]/(Fs/2);
[b,a] = butter(n,Wn);
filtered=filter(b,a,dataSamples);


toUse=filtered(Fs*370:Fs*870);

clear filtered
clear dataSamples;

%pick X s trace without noise
%figure(1);
%plot( toUse );
%figure(2)
%plot(cut2(5000:20000));

%periodogram(dataSamples,[],'twosided',512,Fs)

%resample to 100kHz
wantFs=4*25000;
cut2=interp( toUse, 4);

    
figure(2);
plot( cut2(1:10000));


clear dataSamples
clear timestamps

%load existing one
load([basepath 'simTmp.mat']);

spiketrain=cut2';

clear cut2
clear fromInd
clear toInd
clear toUse

%make new spiketimes
realWaveforms=3;
firingRate=[1 1 1];
realWaveformsInd=[44 81 42];
peakOffsets=[95 95 124];
    
%plot raw waveforms for inspection
figure;
plot(allMeans(realWaveformsInd,:)');
%line([124 124],[-1500 1500]);

spiketimes=generateSpiketrain_times( realWaveforms, firingRate, refractory, nrSamples, Fs, peakOffsets);

%cut timestamps short
%lengthLim=25000*100; %Xs

%cut length
%for i=1:length(spiketimes)
%       tmp=spiketimes{i};
%       spiketimes{i}=  tmp( find(tmp<lengthLim));
%end


save([basepath 'simTmp.mat']);
