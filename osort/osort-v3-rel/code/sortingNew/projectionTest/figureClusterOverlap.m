%plots projection test between two clusters clNr1 and clNr2
%
%
%mode: 1=plot everything (6 subplots)
%      2=plot only one subplot and do not issue any subplot commands
%      3=no plotting (only calculation)
%colors: two string values, eg {'r','b'} for the color of the histogram
%
%bug: in R14,this color values somehow don't work and need to be specificed directly with
% set(h,'FaceColor',....),with h returned from bar (see below).
%
%urut/dec04
function [d,residuals1,residuals2,Rsquare1, Rsquare2] = figureClusterOverlap(allSpikesDecorrelated, allSpikesOrig, assigned, clNr1, clNr2, plabel, mode, colors)
colors

spikes1 = allSpikesDecorrelated(find(assigned==clNr1),:);
spikes2 = allSpikesDecorrelated(find(assigned==clNr2),:);

spikes1Orig = allSpikesOrig(find(assigned==clNr1),:);
spikes2Orig = allSpikesOrig(find(assigned==clNr2),:);

[m1,m2, residuals1, residuals2, overlap,d ] = projectionTest( spikes1,spikes2 );

[bc1,fhat1,h1]=estimatePDF(residuals1,30);
[bc2,fhat2,h2]=estimatePDF(residuals2,30);

%this is used for calculating Rsquare
dist1 = normpdf(bc1,0,1);
dist2 = normpdf(bc2-d,0,1);
[Rsquare1] = calcRsquare( fhat1, dist1 );
[Rsquare2] = calcRsquare( fhat2, dist2 );

%more sampling points for plotting purposes
xDist=-4:.1:4;
distPlot=normpdf(xDist,0,1);

if mode==1
    
	subplot(3,2,1)
        bar(bc1, fhat1,  colors{1});
	hold on
        plot(xDist,distPlot,'k','LineWidth',2.5);
	hold off
	
	xlabel(['m1=0; m2=' num2str(norm(m1-m2))]);
	title([plabel ' % overlap is: d (1%>=5, 5%>=3.2,7.5%>=2.8) =' num2str(d,2) ' emp=' num2str(overlap(1)*100,2) '/' num2str(overlap(2)*100,2) '%'],'FontSize',14);
	ylabel(['P Cl ' num2str(clNr1) ' R2=' num2str(Rsquare1,2)],'FontSize',14);
        xlim([0 0.5]);
	
	subplot(3,2,3)
        h=bar(bc2, fhat2,  colors{2});
    
        %setting the color to something unwanted and than back is necessary (bug in R14)
        %set(h,'FaceColor',[1 1 1]);
        %set(h,'FaceColor',[1 0 0]);

	hold on
        plot(xDist+d,distPlot,'k','LineWidth',2.5);
	hold off
	ylabel(['P Cl ' num2str(clNr2) ' R2=' num2str(Rsquare2,2)],'FontSize',14);
        xlim([0 0.5]);
    
    
	yMins = [min( min(min(spikes1)), min(min(spikes2)) ),  max(max(max(spikes1)), max(max(spikes2)) )     ];
	subplot(3,2,2);
	plot( 1:size(spikes1,2), spikes1(1:10:end,:)',colors{1}, 1:size(spikes2,2), spikes2(1:10:end,:)',colors{2});
	hold on
	plot(1:size(spikes2,2), mean(spikes1),'k', 1:size(spikes1,2), mean(spikes2),'k','LineWidth',3);
	hold off
	xlim([1 size(spikes2,2)]);
	ylim(yMins);
	ylabel('x*STD');
	title('decorrelated');
	
	
	yMinsOrig = [min( min(min(spikes1Orig)), min(min(spikes2Orig)) ),  max(max(max(spikes1Orig)), max(max(spikes2Orig)) )     ];
	subplot(3,2,4);
	plot( 1:size(spikes1Orig,2), spikes1Orig(1:10:end,:)',colors{1}, 1:size(spikes2Orig,2), spikes2Orig(1:10:end,:)',colors{2});
	hold on
	plot(1:size(spikes2Orig,2), mean(spikes1Orig),'k', 1:size(spikes1Orig,2), mean(spikes2Orig),'k', 'LineWidth',3);
	hold off
	xlim([1 size(spikes2Orig,2)]);
	ylim(yMinsOrig);
	title(['Original signal nBlue=' num2str(size(spikes1Orig,1)) ' nRed=' num2str(size(spikes2Orig,1))]);
    
	subplot(3,2,6);
	plot( 1:size(spikes2Orig,2), spikes2Orig(1:10:end,:)',colors{2}, 1:size(spikes1Orig,2), spikes1Orig(1:10:end,:)',colors{1});
	hold on
	plot(1:size(spikes2Orig,2), mean(spikes1Orig),'k', 1:size(spikes1Orig,2), mean(spikes2Orig),'k', 'LineWidth',3);
	hold off
	xlim([1 size(spikes2Orig,2)]);
	ylim(yMinsOrig);
     
	for i=1:2:5
        	subplot(3,2,i)
        	if min(bc1)<max(bc2)
			xlim([min(bc1) max(bc2)]);
		end
        	set(gca,'FontSize',14);
	end
end

if mode==1
    subplot(3,2,5)
end

if mode==1 || mode==2
    bar(bc1, fhat1,  colors{1});
    hold on
    h=bar(bc2, fhat2, colors{2});
    %set(h,'FaceColor',[1 1 1]);
    %set(h,'FaceColor',[1 0 0]);
    plot(xDist,distPlot,'k','LineWidth',2.5);
    plot(xDist+d,distPlot,'k','LineWidth',2.5);
    hold off
    ylim([0 0.5]);    
end
   


