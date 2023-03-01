function NPhandle2AreaStrc(NewNPClusHandle, BrainRegionStrc, cPath)
% All input variable is required for this function to perform normally

% % TargetBrainArea_file = 'K:\Documents\me\projects\NP_reversaltask\BrainAreaANDIndex.mat';
% TargetBrainArea_file = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\BrainAreaANDIndex.mat';
%
% BrainRegionStrc = load(TargetBrainArea_file); % BrainRegions
TargetRegionNamesAll = fieldnames(BrainRegionStrc.BrainRegions);
% sortingcode_string = 'ks2_5';
NumofTargetAreas = length(TargetRegionNamesAll);

UnitMaxampChnInds = NewNPClusHandle.ChannelUseds_id; % already had +1 for matlab indexing
%     UnitNumsAll(cP) = length(UnitMaxampChnInds);

%     UnitChnAreasAll = ProbNPSess.ChannelAreaStrs(UnitMaxampChnInds,:);
%     UnitChnAreaIndexAll = cell2mat(UnitChnAreasAll(:,2));
UnitChnAreaIndexAll = NewNPClusHandle.ChannelAreaStrs{1}(UnitMaxampChnInds);

totalUnitNum = length(UnitMaxampChnInds);
SessAreaIndexStrc = struct();
IsUnitAreTarget = false(totalUnitNum, 1);
IstargetfieldExist = false(NumofTargetAreas+1,1);
for cNameNum = 1 : NumofTargetAreas
    [Lia, Lib] = ismember(UnitChnAreaIndexAll,BrainRegionStrc.BrainRegions.(TargetRegionNamesAll{cNameNum}));
    if sum(Lia)
        SessAreaIndexStrc.(TargetRegionNamesAll{cNameNum}) = struct('MatchedInds',BrainRegionStrc.BrainRegions.(TargetRegionNamesAll{cNameNum}),...
            'MatchedUnitInds',find(Lia),'MatchUnitRealIndex',NewNPClusHandle.UsedClus_IDs(Lia),'MatchUnitRealChn',...
            UnitMaxampChnInds(Lia),'MatchedBrainAreas',unique(UnitChnAreaIndexAll(Lia)));
        IstargetfieldExist(cNameNum) = true;
        IsUnitAreTarget(Lia)=true;
    else
        SessAreaIndexStrc.(TargetRegionNamesAll{cNameNum}) = struct();
    end
end

OtherRegionsUnit = ~IsUnitAreTarget;
if sum(OtherRegionsUnit)
    SessAreaIndexStrc.Others = struct('MatchedInds',unique(UnitChnAreaIndexAll(~IsUnitAreTarget)),...
        'MatchedUnitInds',find(~IsUnitAreTarget),'MatchUnitRealIndex',NewNPClusHandle.UsedClus_IDs(~IsUnitAreTarget),...
        'MatchUnitRealChn',UnitMaxampChnInds(~IsUnitAreTarget),'MatchedBrainAreas',unique(UnitChnAreaIndexAll(~IsUnitAreTarget)));
    IstargetfieldExist(end) = true;
end
SessAreaIndexStrc.UsedAbbreviations = IstargetfieldExist;
SessAreaIndex_saveName = fullfile(cPath,'SessAreaIndexDataNewAlign.mat');
save(SessAreaIndex_saveName,'SessAreaIndexStrc','-v7.3');
