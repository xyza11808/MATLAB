%
% this file pre-computes data for later usage in other files (calcDetection.m, calcAlignPerf, plotDetectionROC_precomputed
% results are stored in files. this is done such that this function can be executed multiple times in parallel on different CPUs (with different parameters)
%
%urut/may07

function calcDetectionROC_precompute(simNrs, levels)
if nargin<=1
	levels=1:4;
end

params=[];
params.bandPass=[300 3000];
params.extractionThreshold = 5; 
params.nrNoiseTraces=0;
params.prewhiten=0;
params.samplingFreq=25000;
params.limit=100;
params.alignMethod=3; %1 pos, 2 neg, 3 mixed
params.peakAlignMethod=1; %1 findPeak, 2 none, 3 power, 4 mteo
params.detectionMethod=1;
params.detectionParams=[]; 

for j=1:length(simNrs)
    simNr=simNrs(j);
    for i=1:length(levels)
        levelNr=levels(i)

        thresholds=[];
        thresholds{1}=[3.5 4 4.5 5 6 6.5];
        thresholds{2}=[ 3.5 4 4.5 5 6];
        thresholds{3}=[-0.1 0 0.1 0.2]; %the bigger the more "liberal" is the threshold

        %define detection parameters
        dp1=[];
        dp1.kernelSize=18;
        dp3=[];
        dp3.scalesRange=[0.2 1.0];
        dp3.waveletName='bior1.5';
        detectionParams{1}=dp1;
        detectionParams{2}=[];
        detectionParams{3}=dp3;

        methods=[1 3 5];
        all=[];
        TPall=[];
        FPall=[];

        allWaveforms=[];
        allHits=[];
        allTimes=[];
        allErrors=[];
     
        for i=1:length(methods)
            params.detectionParams=detectionParams{i};
            params.detectionMethod=methods(i);

            [allTmp, TPallTmp, FPallTmp,waveforms,hits,times,alignErrors] = calcDetectionROC_perLevel(simNr, levelNr, thresholds{i}, params);

            all{i}=allTmp;
            TPall{i}=TPallTmp;
            FPall{i}=FPallTmp;
            allWaveforms{i}=waveforms;
            allHits{i}=hits;
            allTimes{i}=times;
            allErrors{i}=alignErrors;
        end

        %'_a' num2str(params.peakAlignMethod)  
        save(['/home/urut/tmpSim_sim_' num2str(simNr) '_l_' num2str(levelNr) '.mat']);
    end
end