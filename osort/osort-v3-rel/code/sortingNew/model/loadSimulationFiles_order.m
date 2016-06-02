%
%loads the appropriate reorder variable
%the reorder variable determines which detected cluster matches to which simulated cluster (because the order of the sorting output is "random")
%
function reorder = loadSimulationFiles_order(simNr, levelNr, paramSet)

if simNr<=3
    basepath='/home/urut/code/sortingNew/model/';
    fname=[basepath '/sim' num2str(simNr) '/simulation' num2str(simNr) 'Params_' num2str(paramSet) '.mat'];
    if exist(fname)
        load(fname);        
    end
else
    basepath='/data2/simulated/';
    
    fname=[basepath '/sim' num2str(simNr) '/simulation' num2str(simNr) 'Params_' num2str(paramSet) '.mat'];
    if exist(fname)
        load(fname);        
    end    
end


switch(levelNr)
    case 1
        if exist('reorderN1')
            reorder=reorderN1;
        end
    case 2
        if exist('reorderN2')
            reorder=reorderN2;
        end
    case 3
        if exist('reorderN3')
            reorder=reorderN3;
        end
    case 4
        if exist('reorderN4')
            reorder=reorderN4;
        end
end
if ~exist('reorder')
    %default
    reorder=[1 2 3;1 2 3];
    warning('no order definition found');
end
