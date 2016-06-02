%
%plots the 10 biggest clusters (or less if not available).
%
%urut/april04
function plotClusters(allSpikes, allTimestamps, assigned, label)


spikeLength=size(allSpikes,2);

clusters = unique( assigned );
nrClusters=length(clusters);

%plot detected clusters
cl=1;
till=size(allSpikes,1);
for i=1:nrClusters
        cluNr = clusters(i);
    
        subplot(5,4,cl*4-3);
    
        spikesToDraw = allSpikes( find(assigned==cluNr),:);
    
        %dont draw very small clusters
        if size(spikesToDraw,1)<=100
            continue;
        end
        
        plot(1:spikeLength, spikesToDraw, 'r');
        
        title([label 'C' num2str(cluNr) ' n=' num2str(size(spikesToDraw,1))]);
        hold on
        plot(1:spikeLength, mean(spikesToDraw), 'b', 'linewidth', 2);
        hold off
        ylim( [-1000 2000] );
        xlim( [1 256] );

        set(gca,'XTickLabel',{});
        set(gca,'YTickLabel',{});
        
        subplot(5,4,cl*4-2);
    
     
        timestamps = allTimestamps( find(assigned==cluNr) );
        
        d = diff(timestamps);
        d = d/1000; %in ms
     
        edges=0:5:320;
        n=histc(d,edges);
        bar(edges,n,'histc');
        xlim( [0 300] );
        title(['C' num2str(cluNr)]);
        %set(gca,'XTickLabel',{});
        set(gca,'YTickLabel',{});

        %end

%         subplot(5,4,cl*4-1);
%         edges=0:5:700;
%         n=histc(d,edges);
%         bar(edges,n,'histc');
%         xlim( [0 700] );
%         title(['C' num2str(cluNr)]);
%         set(gca,'YTickLabel',{});

        %STD of waveforms
        %S = std( spikesToDraw );
        %plot(1:256,S,'r');
        %title('STD');
        %line([95 95],[1 1000],'color','m');
        %ylim([50 500]);
        
        %power spectrum
        %subplot(5,4,cl*4);
	    %n = convertToSpiketrain(timestamps);
	    %[f,Pxxn,tvect,Cxx] = calculatePowerspect(n);
        %plot(f,Pxxn,'r');
        %xlim( [0 100] );
        
        cl=cl+1;
        
        if cl*4>5*4
            break;
        end

end
