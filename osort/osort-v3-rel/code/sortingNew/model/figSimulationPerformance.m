%plots performance comparison figures between algorithms
%
%perfAll is a cell array of cell arrays. each cell array part of perfAll is
%a collection of performance tables for all noise levels of the simulation.
%
%perfOrig is the same as perfAll, except that it contains all the clusters,
%not only the once that could be matched. perfOrig is used to calculate the
%total number of spikes which would theoretically be sortable.
%
%urut/nov05
function figSimulationPerformance( perfAll,  perfOrig, plabels, ptitle, maxNrClusters)
colors={'r','g','b','y','c','m','k'};
symbols={'x','o','d','.'};

figure(876)

TPs=[];
FPs=[];
misses=[];
for j=1:length(perfAll)
    perf = perfAll{j};
    perf2 = perfOrig{j};    
    
    for i=1:length(perf)
        perfTable = perf{i};    
        perfTableOrig = perf2{i};    

        %as % of detected
        %TPs(j,i) = mean( perfTable(:,5) ./ perfTable(:,2) );
        %FPs(j,i) = mean( perfTable(:,6) ./ perfTable(:,2) );

        %as % of assigned
        totNr=perfTable(:,5)+perfTable(:,6);
        TPs(j,i) = mean( perfTable(:,5) ./ totNr );
        FPs(j,i) = mean( perfTable(:,6) ./ totNr );
        
        allDetected = sum(perfTableOrig(:,2));
        allCorrectAssigned = sum(perfTable(:,5));
        
        misses(j,i) = allCorrectAssigned/allDetected;
        
        nrCls(j,i) = size(perfTable,1)/maxNrClusters;
    end
    nrLevels=i;
end

%conver to percent
TPs=TPs*100;
FPs=FPs*100;
nrCls=nrCls*100;
misses=1-misses;
misses=misses*100;

styles={'r-h', 'b--o', 'k:d','m-.v'};
subplot(2,2,1)
plot( 1:nrLevels, TPs(1,:),styles{1}, 1:nrLevels, TPs(2,:),styles{2},1:nrLevels, TPs(3,:),styles{3},1:nrLevels, TPs(4,:),styles{4},'linewidth',2);  
ylim([min(TPs(:))-10 105]);
legend(plabels);
xlabel('Noise level');
ylabel('true positive %');
title(ptitle);

subplot(2,2,2)
plot( 1:nrLevels, FPs(1,:),styles{1}, 1:nrLevels, FPs(2,:),styles{2},1:nrLevels, FPs(3,:),styles{3},1:nrLevels, FPs(4,:),styles{4},'linewidth',2);  
ylim([0 105]);
legend(plabels);
xlabel('Noise level');
ylabel('false positive %');


subplot(2,2,3)
plot( 1:nrLevels, nrCls(1,:),styles{1}, 1:nrLevels, nrCls(2,:),styles{2},1:nrLevels, nrCls(3,:),styles{3},1:nrLevels, nrCls(4,:),styles{4},'linewidth',2);  
ylim([0 110]);
legend(plabels);
xlabel('Noise level');
ylabel('clusters detected %');
