function defineUsableClusters_forGUI(figureoutpath,cluster,channel1,channel2);

global PATH;
outPath = [PATH 'final\'];

basePathFigs=[figureoutpath];
basePathFigsFinal =[basePathFigs 'final\'];

if exist(basePathFigsFinal)==0
    mkdir(basePathFigsFinal);
end
if exist(outPath)==0
    mkdir(outPath);
end

fname = [PATH channel1];

load(fname);

useNegativeNew = cluster;

%test whether entered cluster numbers are valid
if length( intersect( useNegativeNew, useNegative) ) < length(useNegativeNew)
    error('error,invalid cluster nr entered. canceled.')
end

useNegativeOrig=useNegative;
useNegative=useNegativeNew;

useNegativeExcluded = setdiff(useNegativeOrig,useNegative);

save([outPath 'A' channel2 '_sorted_selected.mat'], 'useMUA', 'versionCreated', 'noiseTraces','allSpikesNoiseFree','allSpikesCorrFree','newSpikesPositive', 'newSpikesNegative', 'newTimestampsPositive', 'newTimestampsNegative','assignedPositive','assignedNegative', 'usePositive', 'useNegative', 'useNegativeExcluded', 'stdEstimateOrig','stdEstimate','paramsUsed','savedTime');

%copy the figs, only of the chosen clusters
for kk=1:length(useNegative)
    try
    copyfile([basePathFigs 'A' channel2 '_CL_' num2str(useNegative(kk)) '_THM_*.png'], [basePathFigsFinal]);
    catch
        %ignore if figs don't exist
    end
end
