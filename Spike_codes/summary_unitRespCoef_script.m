

load('E:\sycDatas\Documents\me\projects\NP_reversaltask\UnitCoefSummary.mat');
%%

AllUnitCoefs = cell2mat(SessUnitCoefStrs(:,1));
AllUnitStrsANDIndex = cat(1,SessUnitCoefStrs{:,2});
AllRespUnit_index = cell2mat(AllUnitStrsANDIndex(:,2));
%%
TargetBrainArea_file = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\BrainAreaANDIndex.mat';

BrainRegionStrc = load(TargetBrainArea_file); % BrainRegions
TargetRegionNamesAll = fieldnames(BrainRegionStrc.BrainRegions);

NumAllTargetAreas = length(TargetRegionNamesAll);
AreaRespUnitIndsStrc = struct();
for cA = 1 : NumAllTargetAreas
    cA_Index = BrainRegionStrc.BrainRegions.(TargetRegionNamesAll{cA});
    [Lia, ~] = ismember(AllRespUnit_index, cA_Index);
    
    if sum(Lia)
        DataStrc = struct();
       % target regions have responsive units
       DataStrc.UnitInds = find(Lia);
       DataStrc.UInitCoefMtx =  AllUnitCoefs(Lia,:);
       AreaRespUnitIndsStrc.(TargetRegionNamesAll{cA}) = DataStrc;
    else
        DataStrc = [];
        AreaRespUnitIndsStrc.(TargetRegionNamesAll{cA}) = DataStrc;
    end
    
end





