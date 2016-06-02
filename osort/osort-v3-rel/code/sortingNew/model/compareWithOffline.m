%
% run simulated data with Klustakwik to compare performance.
%
%urut/nov05

basepath='C:\Documents and Settings\Administrator\Desktop\ueli\code\sortingNew\model\';
cd(basepath);
colors={'r','b','g','m','c','y','k',[0.5 0.5 0.5],[1 0 0.5]};

simNrs=[1 2 3];
for kk=1:length(simNrs)
    simNr=simNrs(kk);
    noiseLevels=1:4;

    %-- load data from the simulation
    load([basepath '\sim' num2str(simNr) '\simulation' num2str(simNr) '.mat']);
    switch (simNr)
        case 1
            realWaveformsInd=([  81 122 77 ]);
        case 2
            realWaveformsInd=([ 49 36 81 ]);
        case 3
            realWaveformsInd=([92 61  77 70 44]);
    end
    nrNeurons=length(realWaveformsInd);

    %--do sorting
    allClu2=[];
    for i=1:length(noiseLevels)
        filename = ['simSpikes-sim' num2str(simNr) '-n' num2str(i)];
        load(filename);

        exportMode=2; %2 raw, 1 PCA
        exportToKlusta('c:\temp\', simNr*10+i, spikeWaveformsUp, exportMode);        
        clu = importFromKlusta(simNr*10+i, spikeWaveformsUp);
        cd(basepath);

        allClu2{i} = clu;
        
        cluNrs = unique(clu);
        nrClusters = length(cluNrs);
        
        figure(500+simNr);
        subplot(2,2,i);
        hold on
        for j=1:nrClusters  %first is always noise,don't display
            if j>length(colors)
                disp('more clusters than colors');
                break;
            end
            plot( 1:size(spikeWaveformsUp,2), spikeWaveformsUp( find(clu==cluNrs(j)) ,:), 'color',colors{j});
        end
        hold off
    end
    
    %-- map to original clusters    
    figure(simNr)
    hold on
    for i=1:nrNeurons
        plot ( scalingFactorSpikes(i)*allMeans(realWaveformsInd(i),:) , colors{i}, 'LineWidth', 3 );
    end
    hold off
    xlabel('1=r,2=b,3=g,4=m,5=c,6=y,7=k');
    title('orig means');
    
    %--debug -- remapping
    figure(simNr*1000)
    for j=1:nrClusters  %first is always noise,don't display
        subplot(4,4,j)
        plot( 1:size(spikeWaveformsUp,2), spikeWaveformsUp( find(clu==cluNrs(j)) ,:), 'color',colors{j});
        title(['n=' num2str(length(find(clu==cluNrs(j)))) ' i=' num2str(j)]);
    end
        
    perfKlusta=[];
    %eval performance
    for i=1:length(noiseLevels)
        filename = ['simSpikes-sim' num2str(simNr) '-n' num2str(i)];
        load(filename);

        %convert clu structure to nrAssigned structure
        clu = allClu{i};
        cluNrs = unique(clu);
        nrClusters = length(cluNrs);
        nrAssigned=[];
        for j=1:nrClusters
            nrAssigned(j,1:2) = [cluNrs(j) length( find(clu==cluNrs(j)))];
        end
        nrAssigned = flipud(nrAssigned);
        
        %set up re-mapping (manual matching)
        reorder=[];
        %99 -> doesnt exist.
        switch (simNr)
            case 1
                switch(i)
                    case 1
                        reorder=[1 2 3; 4 3 2];
                    case 2
                        reorder=[1 2 3; 2 3 4];
                    case 3
                        reorder=[1 2 3; 3 5 2];
                    case 4
                        reorder=[1 2 3; 3 2 4];
                end
            case 2
                switch(i)
                    case 1
                        reorder=[1 2 3; 5 2 4];
                    case 2
                        reorder=[1 2 3; 6 3 8];
                    case 3
                        reorder=[1 2 3; 4 5 3];
                    case 4
                        reorder=[1 2 3; 99 2 3];
                end
            case 3
                switch(i)
                    case 1
                        reorder=[1 2 3 4 5; 6 3 4 2 8];
                    case 2
                        reorder=[1 2 3 4 5; 3 7 2 6 4];
                    case 3
                        reorder=[1 2 3 4 5; 99 4 99 3 2];
                    case 4
                        reorder=[1 2 3 4 5; 99 2 99 3 4];
                end                
        end
        
        %confirm the remapping
        figure(200+simNr);
        subplot(2,2,i);
        hold on

        allInds=[];
        inds=[];
        orderNeurons = sort(reorder(2,:));
        for preInd=1:length(orderNeurons)
            if orderNeurons(preInd)==99
                inds{preInd} =[];
                continue;
            end
            
            ii = find( reorder(2,:) == orderNeurons(preInd) );
            inds{preInd} = find( nrAssigned(end-reorder(2,ii)+1,1)==clu);
            allInds=[allInds inds{preInd}'];
        end        
        
        %plot noise (unsorted)
        plot ( spikeWaveformsUp( setdiff( 1:length(clu), allInds),:)', 'k');
        
        %plot sorted
        for preInd=1:length(orderNeurons)
             ii = find( reorder(2,:) == orderNeurons(preInd) );
             if length(inds{preInd})>0
                plot ( spikeWaveformsUp ( inds{preInd}, : )', colors{ii} );
            end
        end
        hold off
        
        %if some clusters were not found,assign to noise (not relevant for
        %perf calculation,since they are excluded.
        indsEmpty = find(reorder(2,:)==99);
        if length(indsEmpty)>0
            reorder(2,indsEmpty)=ones(1,length(indsEmpty));
        end
        
        [perf, indsNoiseWaveforms] = evalPerformance(nrNeurons, spikeTimestamps, spiketimes, reorder,nrAssigned,clu);
        
        
        %exclude clusters that weren't found
        if length(indsEmpty)>0
            perf = perf( setdiff(1:size(perf,1),indsEmpty),:);    
        end
        
        perfKlusta{i}=perf;
        

    end
    save(['results-klusta-S' num2str(simNr) '.mat'],'perfKlusta');
    

end
