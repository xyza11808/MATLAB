%
% plots, for a pair of clusters, the mean waveforms and ISI for easier
% comparison (on top of each other)
%
% plotMode:1 waveforms, 2 ISIs, 3 projection test
%
%
%urut/sept09
function plotClusterPairs( waveforms, assigned, timestamps, allSpikesDecorrelated, clNr1, clNr2, plotMode, col1, col2, titlep  )
    
indsCl1 = find( assigned == clNr1 );
indsCl2 = find( assigned == clNr2 );

addStr='';
switch(plotMode)
    case 1
        %plot waveforms
        m1=mean( waveforms(indsCl1,:) );
        m2=mean( waveforms(indsCl2,:) );
        
        s1=std( waveforms(indsCl1,:) );
        s2=std( waveforms(indsCl2,:) );
        
        N=length(m1);
        
        errorbar( 1:N, m1, s1, col1 );
        hold on
        errorbar( 1:N, m2, s2, col2 );
        hold off
        
        xlim([1 N]);
        title([titlep ' ' num2str(clNr1) '/n=' num2str(length(indsCl1)) ' vs ' num2str(clNr2) '/n=' num2str(length(indsCl2)) ]);
    case 2
        %plot ISI
        edges = 0:2:201; %in ms
        
        t1 = timestamps(indsCl1);
        t2 = timestamps(indsCl2);
        
        d1 = diff(t1/1000);
        d2 = diff(t2/1000);
        
        n1 = histc(d1,edges);
        n2 = histc(d2,edges);
        
        %normalize by peak
        %n1 = n1./sum(n1);
        %n2 = n2./sum(n2);
        
        n1 = n1./max(n1);
        n2 = n2./max(n2);
        
        plot( edges, n1, col1, edges, n2, col2, 'linewidth', 2);
        
        xlim([ -2 200]);
        ylim([0 1.1]);
    case 3
        %projection test
        
        %distance
        %d = mahal(m2, waveforms(indsCl1,:))
        
        [m1,m2, residuals1, residuals2, overlap,d ] = projectionTest( allSpikesDecorrelated(indsCl1,:), allSpikesDecorrelated(indsCl2,:) ); 
        [bc1,fhat1,h1] = estimatePDF(residuals1,30);
        [bc2,fhat2,h2] = estimatePDF(residuals2,30);        
        xDist=-4:.1:4;
        distPlot=normpdf(xDist,0,1);

        plot(xDist,distPlot,'k','LineWidth',1);
        
        hold on
        plot(xDist+d,distPlot,'k','LineWidth',1);
        h1=bar(bc1, fhat1,  col1, 'BarWidth', 1 );
        h2=bar(bc2, fhat2,  col2 , 'BarWidth', 1);
        hold off        
        set(h1,'EdgeColor','none');
        set(h2,'EdgeColor','none');
        ylabel( ['d=' num2str(d)] );
        
        xlim([ min([bc1 bc2]) max([bc1 bc2])] );
end



