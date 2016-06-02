%
%script to manually merge clusters
%
%urut/feb05
%

basePath='/data/MK_122110/';

sortVersion='sortLFP';
figsVersion='figsLFP';

%sortVersion='sortRange400-Norm';
%figsVersion='figsRange400-Norm';

finalVersion='final';

%no parameters below
%========
basePathOut=[basePath '/' sortVersion '/'];
outPath = [basePathOut ];

basePathFigs=[basePath '/' figsVersion '/'];
basePathFigsFinal =[basePathFigs finalVersion '/'];

if exist(basePathFigsFinal)==0
    mkdir(basePathFigsFinal);
end
if exist(outPath)==0
    mkdir(outPath);
end

disp(['mergeClusters.m; currently processing ' basePath '. Using:' basePathOut ' and ' basePathFigs]);



continueLoop=true;

while (continueLoop)
    channel=input('Channel [Axx]:','s');
    threshold = input('Threshold : ','s');
    
    %default prefix is 'A' if none is given
    if ~isempty(str2num(channel(1)))
        channel = ['A' channel];
    end
    
    fname = [basePathOut threshold '/' channel '_sorted_new.mat'];
    
    if exist(fname)==2
        outPath1 = [basePathOut threshold '/'];
        
        disp(['loading:' fname]);
        load(fname);
        
        disp( ['current use (n=' num2str(size(newSpikesNegative,1)) '). Cls=' num2str(useNegative') ]);
        
        useNegativeNew = str2num( input('Clusters to merge [a,b] : ','s') );
        
        disp(['new: ' num2str(useNegativeNew)]);
        
        if length(useNegativeNew)>2
            disp('error, can only merge two clusters at any time');
            continue;
        end
        
        %test whether entered cluster numbers are valid
        if length( intersect( useNegativeNew, useNegative) ) < length(useNegativeNew)
            disp('error,invalid cluster nr entered. canceled.');
            continue;
        end
        
        reply = input('Merge OK? [Y|N] ','s');
        if reply=='Y' || reply=='y'
            
            indsToReplace = find( assignedNegative == useNegativeNew(2) );
            assignedNegative(indsToReplace) = useNegativeNew(1);
            
            %remove the element. dont use setdiff,since it changes the order of the elments
            useNegativeTmp=[];
            for i=1:length(useNegative)
                if useNegative(i)~=useNegativeNew(2)
                    useNegativeTmp = [ useNegativeTmp ;useNegative(i) ];
                end
            end
            useNegative = useNegativeTmp;
            
            if exist('useNegativeMerged')
                useNegativeMerged = [ useNegativeMerged useNegativeNew(2) ];
            else
                useNegativeMerged = useNegativeNew(2);
            end
            
            fnameOut=[outPath1 channel '_sorted_new.mat'];
            disp(['storing: ' fnameOut]);
            save(fnameOut, 'useMUA', 'versionCreated', 'noiseTraces','allSpikesNoiseFree','allSpikesCorrFree','newSpikesPositive', 'newSpikesNegative', 'newTimestampsPositive', 'newTimestampsNegative','assignedPositive','assignedNegative', 'usePositive', 'useNegative', 'useNegativeMerged', 'useNegativeMerged','stdEstimateOrig','stdEstimate','paramsUsed','savedTime');
            
            disp('file stored, need to manually regenerate figures! ');
            
        end
    else
        disp(['file does not exist ' fname]);
    end
    
    continueReply = input('Continue [Y|N] : ','s');
    if continueReply=='Y' || continueReply=='y'
        continueLoop=true;
    else
        continueLoop=false;
    end
end
