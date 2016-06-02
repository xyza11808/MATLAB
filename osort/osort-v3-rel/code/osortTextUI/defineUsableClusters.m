%
%script to manually set the valid clusters that should be used for further analysis. sets the variable useNegative in a XX_new_sorted.mat
%
%urut/feb05
%

basePath='/data/MK_122110/';

%subdirs to use
sortVersion='sortLFP';
figsVersion='figsLFP';

%sortVersion='sortRange400-Norm';
%figsVersion='figsRange400-Norm';

finalVersion='final';

%====
basePathOut=[basePath '/' sortVersion '/'];
outPath = [basePathOut '/' finalVersion '/'];

basePathFigs=[basePath '/' figsVersion '/'];
basePathFigsFinal =[basePathFigs finalVersion '/'];

if exist(basePathFigsFinal)==0
    mkdir(basePathFigsFinal);
end
if exist(outPath)==0
    mkdir(outPath);
end

disp(['defineUsableClusters.m; currently processing ' basePath ' .Using: ' basePathOut ' and ' basePathFigs]);


continueLoop=true;

while (continueLoop)
    channel = input('Channel [Axx] :','s');
    threshold = input('Threshold : ','s');
    
    %default prefix is 'A' if none is given
    if ~isempty(str2num(channel(1)))
        channel = ['A' channel];
    end
    
    fname = [basePathOut threshold '/' channel '_sorted_new.mat'];
    
    if exist(fname)==2
        load(fname);
        ['current use (n=' num2str(size(newSpikesNegative,1)) ')' ]
        useNegative
        
        useNegativeNew = str2num( input('Clusters to use [a,b,c,d] : ','s') );        
        useNegativeNew
        
        %test whether entered cluster numbers are valid
        if length( intersect( useNegativeNew, useNegative) ) < length(useNegativeNew)
            disp('error,invalid cluster nr entered. canceled.');
            %keyboard;
            continue;
        end
        
        %calc stats
        nrTot=0;
        nrTotNew=0;
        for kk=1:length(useNegative)
            nrTot = nrTot + length(find(assignedNegative==useNegative(kk)));
        end
        for kk=1:length(useNegativeNew)
            nrTotNew = nrTotNew + length(find(assignedNegative==useNegativeNew(kk)));
        end
        nrNonNoise = length(find(assignedNegative<99999999));
        
        percDetected = nrTotNew/length(assignedNegative);
        percAssigned = nrTotNew/nrNonNoise;
        disp(['Tot found:' num2str(length(assignedNegative)) ' Tot non-noise:' num2str(nrNonNoise) ' TotAssignedBefore:' num2str(nrTot) ' TotAssignedNew:' num2str(nrTotNew) ' % of detected:' num2str(percDetected) ' % of assigned:' num2str(percAssigned)]);
        
        reply = input('New OK? [Y|N] ','s');
        if reply=='Y' || reply=='y'
            useNegativeOrig=useNegative;
            useNegative=useNegativeNew;
            
            useNegativeExcluded = setdiff(useNegativeOrig,useNegative);
            
            fname=[outPath channel '_sorted_new.mat'];
            disp(['storing: ' fname]);
            save(fname, 'useMUA', 'versionCreated', 'noiseTraces','allSpikesNoiseFree','allSpikesCorrFree','newSpikesPositive', 'newSpikesNegative', 'newTimestampsPositive', 'newTimestampsNegative','assignedPositive','assignedNegative', 'usePositive', 'useNegative', 'useNegativeExcluded', 'stdEstimateOrig','stdEstimate','paramsUsed','savedTime');
            
            %copy the figs, only of the chosen clusters
            for kk=1:length(useNegative)
                
                fnameFrom=[basePathFigs threshold '/' channel '_CL_' num2str(useNegative(kk)) '_THM_*.png'];
                fnameTo=[basePathFigs finalVersion];
                
                disp(['copying from:' fnameFrom ' to ' fnameTo]);
                copyfile(fnameFrom, fnameTo);
            end
            ['file stored']
        end
    else
        ['file does not exist ' fname]
    end
    
    continueReply = input('Continue [Y|N] : ','s');
    if continueReply=='Y' || continueReply=='y'
        continueLoop=true;
    else
        continueLoop=false;
    end
end
