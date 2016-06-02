%
%calculates the std of the align error for all simulations for a given noise level
%
%doUpsample:upsample and correct error yes/no
%doNormalizeError:subtract median from error yes/no
%
%
function [allStds,allMeans, errorsNormalized,params] = calcAlignPerf_allSims(simNrs, levelNr, alignMethods, basepath, Fs, doUpsample, doNormalizeErrors)
if nargin<7
    doNormalizeErrors=0;
end

allStds=[]; % each column is one alignMethod, each row is a cluster
allMeans=[]; % each column is one alignMethod, each row is a cluster
errorsNormalized=[];
params=[];


methodToPlot=3; %WDM
thresholdToUse=[0];


%% compare mean alignment error for different methods

for j=1:length(alignMethods)
    useAlignMethod=alignMethods(j);
    clCounter=0;
    
    for i=1:length(simNrs)
        simNr=simNrs(i);
    
        %load the appropriate files
        basepath2=[basepath num2str(useAlignMethod) '/'];
        load([basepath2 'tmpSim_sim_' num2str(simNr) '_l_' num2str(levelNr) '.mat'], 'thresholds','allHits','allErrors','allWaveforms','allTimes','params');
    
        %process all clusters in this file

        %find values of this method/threshold
        Ts=thresholds{methodToPlot};
        indT=find(Ts==thresholdToUse);
        hits = allHits{methodToPlot}{indT};
        errors = allErrors{methodToPlot}{indT} * 1/Fs*1000; %convert to ms
        w=allWaveforms{methodToPlot}{indT};  %waveforms
        timesFound=allTimes{methodToPlot}{indT};

        %if upsample is enabled, re-compute error after upsampling 4x
        if doUpsample
          spiketimes = loadSimulationFilesVars(simNr,levelNr,'spiketimes');   

          wUp=upsampleSpikes(w);
          [newSpikes,newTimestamps, shifted] = realigneSpikes(wUp, timesFound, [], [], 3); %3 ->only adjust peak,already aligned.
          shiftedT=shifted./4; %nr steps in the 25kHz space
          fixedTimestamps = newTimestamps+shiftedT;

          %re-evaluate the error made
          alignErrors2 = evalSimulatedAlignPerf( spiketimes, fixedTimestamps,  hits );
          alignErrors2 = alignErrors2*1/Fs*1000; %are in terms of 25kHz sampling rate.

          errors=alignErrors2;
        end
        
        nrClusters = length(unique(hits(:,2)));
        
        for k=1:nrClusters
            indThisCluster = find( hits(:,2) == k );    
            errorsThisCluster = errors(indThisCluster);
    
            %subtract median of each error cluster (wont change variance)
            if doNormalizeErrors
                errorsThisCluster = errorsThisCluster - median(errorsThisCluster);
            end
            
            clCounter=clCounter+1;
            
            allStds(clCounter,j) = std(errorsThisCluster);
            allMeans(clCounter,j) = mean(errorsThisCluster);
            errorsNormalized{j}{clCounter} = errorsThisCluster;
        end
    
    end
end
