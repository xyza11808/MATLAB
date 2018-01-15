function [ClusterInterMean,OutMean,hhf] = Within2BetOrRandRatio(DisMatrix,ClusterInds,CompareType,varargin)
% settled function 
if size(DisMatrix,1) ~= size(DisMatrix,2)
    error('Matrix should be symmetric.');
end
if islogical(ClusterInds)
    ncCluster = sum(ClusterInds);
    if length(ClusterInds) ~= size(DisMatrix)
        error('Inds Vector should have the same rows as given matrix data');
    end
else
    ncCluster = length(ClusterInds);
    if max(ClusterInds) > size(DisMatrix)
        error('Inds outside matrix dimension');
    end
end
nIters = 1000;
if nargin > 4
    if ~isempty(varargin{1})
        nIters = varargin{1};
    end
end 

switch CompareType
    case 'Rand'
        cClusterDisMtx = DisMatrix(ClusterInds,ClusterInds);
        ClusterDis = cClusterDisMtx(logical(tril(ones(size(cClusterDisMtx)),-1)));
        ClusterInterMean = mean(ClusterDis);
        
        nRowsAll = size(DisMatrix,1);
        OutMean = zeros(nIters,1);
        parfor n = 1 : nIters
            RandInds = randsample(nRowsAll,ncCluster);
            RandIndsDisMtx = DisMatrix(RandInds,RandInds);
            RandIndsDisVec = RandIndsDisMtx(logical(tril(ones(size(RandIndsDisMtx)),-1)));
            OutMean(n) = mean(RandIndsDisVec);
        end
        DisRatio = OutMean/ClusterInterMean;
        [~,p] = ttest(DisRatio,1);
        [RatioCount,RatioCent] = hist(DisRatio,min(DisRatio):0.01:max(DisRatio));
        hhf = figure('position',[100,200,450,380]);
        plot(RatioCent,RatioCount/nIters,'k','linewidth',2);
        yscales = get(gca,'ylim');
        line([1,1],yscales,'Color',[.7 .7 .7],'linewidth',1.6,'linestyle','--');
        line([mean(DisRatio),mean(DisRatio)],yscales,'Color','r','linewidth',1.6,'linestyle','--');
        xlabel('Rand/Inter Distance ratio');
        ylabel('Fraction');
        title(sprintf('p = %.3e',p));
        ylim(yscales);
        set(gca,'FontSize',16);
        text(mean(DisRatio),yscales(2)*0.2+yscales(1)*0.8,{'Mean=';sprintf('%.3f',mean(DisRatio))},...
            'FontSize',18,'Color','b','HorizontalAlignment','center');
%         saveas(hhf,'Prefered frequency within distance with random distance ratio');
%         saveas(hhf,'Prefered frequency within distance with random distance ratio','png');
%         close(hhf);
    case 'Bet'
        cClusterDisMtx = DisMatrix(ClusterInds,ClusterInds);
        ClusterDis = cClusterDisMtx(logical(tril(ones(size(cClusterDisMtx)),-1)));
        ClusterInterMean = mean(ClusterDis);
        
        if islogical(ClusterInds)
            BetClusterMtx = DisMatrix(ClusterInds,~ClusterInds);
            OutMean = mean(BetClusterMtx(:));
        else
            AllROIs = size(DisMatrix,1);
            BetClusterInds = true(AllROIs,1);
            BetClusterInds(ClusterInds) = false;
            BetClusterMtx = DisMatrix(~BetClusterInds,BetClusterInds);
            OutMean = mean(BetClusterMtx(:));
        end
        hhf = [];
    otherwise
        warning('Undefined calculation type, quit analysis.\n');
        return;
end