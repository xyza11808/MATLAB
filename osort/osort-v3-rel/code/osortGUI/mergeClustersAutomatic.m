%
%merges two clusters and saves an updated file.
%this is the function version of the script mergeClusters.m
%
%
function mergeClustersAutomatic(figureoutpath,cluster,channel1,channel2);
display(['merging clusters: ' num2str(cluster) '...']);

global PATH;
outPath = [PATH];

basePathFigs=[figureoutpath];

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

l = length(useNegativeNew);
for i = 1:l
    indsToReplace = find( assignedNegative == useNegativeNew(i) );
    assignedNegative(indsToReplace) = useNegativeNew(1);

    %remove the element. dont use setdiff,since it changes the order of the elments
    useNegativeTmp=[];
    for i=1:length(useNegative)
        if useNegative(i)~=useNegativeNew(1)
            useNegativeTmp = [ useNegativeTmp ;useNegative(i) ];
        end
    end
    useNegative = useNegativeTmp;
end

if exist('useNegativeMerged')
    useNegativeMerged = [ useNegativeMerged useNegativeNew(2) ];
else
    useNegativeMerged = useNegativeNew(2);
end

save([outPath '\A' channel2 '_sorted_merged.mat'], 'useMUA', 'versionCreated', 'noiseTraces','allSpikesNoiseFree','allSpikesCorrFree','newSpikesPositive', 'newSpikesNegative', 'newTimestampsPositive', 'newTimestampsNegative','assignedPositive','assignedNegative', 'usePositive', 'useNegative', 'useNegativeMerged', 'useNegativeMerged','stdEstimateOrig','stdEstimate','paramsUsed','savedTime');

display('finished merging');