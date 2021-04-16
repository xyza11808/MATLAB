function [ClusterTypes,ClusterBestChn] = templateChnCal(SpikeClus,SpTemplates,tempMaxChn)
% this function is used to extract maxmum response channel for each
% sp cluster, used to locate single unit position

ClusterTypes = unique(SpikeClus);
NumberClusters = length(ClusterTypes);
ClusterBestChn = zeros(NumberClusters,1);
for Clus = 1:NumberClusters
    Clus_SPIds = (SpikeClus == ClusterTypes(Clus));
    clus_sp_templates = SpTemplates(Clus_SPIds);
    [temps,tempcount] = uniAndcount(clus_sp_templates);
    if length(tempcount) > 1
        [~,maxCountInds] = max(tempcount);
        UsedTemplate = temps(maxCountInds)+1;
    else
        UsedTemplate = temps+1;
    end
    ClusterBestChn(Clus) = tempMaxChn(UsedTemplate); % -1 for zero indexing
    
end


