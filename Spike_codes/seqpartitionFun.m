function GrWithinIndsSet = seqpartitionFun(DataInds, kfolders, Grfolders)

if ~exist('kfolders','Var')
    kfolders = 10;
end

if ~exist('Grfolders','Var')
    Grfolders = [7,3]; % training and testing fraction
end
%%
NumInds = numel(DataInds);
GroupEdgeInds = round(linspace(1,NumInds,kfolders+1));

GrWithinIndsSet = cell(kfolders,2);
for cGr = 1 : kfolders
    cGrInds = GroupEdgeInds(cGr:(cGr+1));
    cGr_partition = round(linspace(cGrInds(1),cGrInds(2),sum(Grfolders)+1));
    if cGr == 1
        cGr_TrainSetInds = cGr_partition(1):cGr_partition(Grfolders(1)+1);
    else
        cGr_TrainSetInds = cGr_partition(1)+1:cGr_partition(Grfolders(1)+1);
    end
    cGr_TestSetInds = cGr_partition(Grfolders(1)+1)+1: cGrInds(2);
    GrWithinIndsSet(cGr,:) = {cGr_TrainSetInds', cGr_TestSetInds'};
end


    
    
    
    








