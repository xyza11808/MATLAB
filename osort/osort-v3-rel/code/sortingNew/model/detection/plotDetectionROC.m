%
% plot several ROCs to compare different detection methods
%
%plotThresholds: 0 no, 1 yes (all), 2 yes (only extremes)
%
%
%initial urut/caltech/2005
%extended urut/aug11
function plotDetectionROC( TPall, FPall, thresholds, labels, xlims, ylims, ptitle, plotThresholds,plotThresholdPrefix,plotDiagLine)
if nargin<8
    plotThresholds=1;
    plotThresholdPrefix='T';
    plotDiagLine=0;
end

colors={'r-','g-','b-','m-','r--','g--','b--','m--'};

h=[];
for i=1:length(FPall)
    if i>1
        hold on
    end
    
    if length(FPall{i}>0)
        h(i) = plot( FPall{i}, TPall{i},['d' colors{i}],'MarkerSize',10,'linewidth',2);
        
        if plotThresholds
            Ts=thresholds{i};
            for j=1:length(Ts)            
                if plotThresholds==1 || (plotThresholds==2 && (j==1 || j==length(Ts)))
                    text( FPall{i}(j), TPall{i}(j), [plotThresholdPrefix num2str(Ts(j))]);
                end            
            end        
        end
    end
end
hold off
legend(h,labels);

xlabel('P(false alarm)');
ylabel('P(hit)');
xlim(xlims);
ylim(ylims);

title(ptitle);

if plotDiagLine
    line( xlims, ylims, 'color','k','linestyle','--');
end