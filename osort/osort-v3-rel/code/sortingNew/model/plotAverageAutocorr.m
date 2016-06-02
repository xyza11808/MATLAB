% plots the average autocorrelation of the noise traces and its
% significance
%
% before running this: 
% load result of running findAverageAutocorr (variable Ctot).
% or: load result of calculating Ctot from real data (findRealAvAutoCorr),
% eg Ctot-HMS1-allChannels.mat
%
%urut/jan05
figure(2);
plot( 1:64, CORRtot(:,1:end) )

%C=Ctot;
C=CORRtot;

stdCtot = std(C);
meanCtot = mean(C);


figure(1);
plot( 1:64, meanCtot(1:64), 'LineWidth', 2.0 );
hold on
h=errorbar(3:2:64, meanCtot(3:2:64), stdCtot(3:2:64),'.');
set(h,'LineWidth',1.5);
set(h,'color','r');

%significance
pVals=[];
for i=3:2:64
    [h,p] = ttest( Ctot(:,i));
    
    if p<=0.001
        plot( i, meanCtot(i)-stdCtot(i)*2, 'r*', 'MarkerSize',10);
    end
    
    pVals(i)=p;
end


hold off

xlim([1 64]);
%ylim([-0.02 0.04]);