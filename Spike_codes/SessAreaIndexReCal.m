function SessAreaIndexReCal(cPath, ProbNPSess,BrainRegionStrc)

TargetRegionNamesAll = fieldnames(BrainRegionStrc.BrainRegions);
NumofTargetAreas = length(TargetRegionNamesAll);
UnitMaxampChnInds = ProbNPSess.ChannelUseds_id;

UnitChnAreaIndexAll = ProbNPSess.ChannelAreaStrs{1}(UnitMaxampChnInds);

totalUnitNum = length(UnitMaxampChnInds);
SessAreaIndexStrc = struct();
IsUnitAreTarget = false(totalUnitNum, 1);
IstargetfieldExist = false(NumofTargetAreas+1,1);
for cNameNum = 1 : NumofTargetAreas
    [Lia, Lib] = ismember(UnitChnAreaIndexAll,BrainRegionStrc.BrainRegions.(TargetRegionNamesAll{cNameNum}));
    if sum(Lia)
        SessAreaIndexStrc.(TargetRegionNamesAll{cNameNum}) = struct('MatchedInds',BrainRegionStrc.BrainRegions.(TargetRegionNamesAll{cNameNum}),...
            'MatchedUnitInds',find(Lia),'MatchUnitRealIndex',ProbNPSess.UsedClus_IDs(Lia),'MatchUnitRealChn',...
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
        'MatchedUnitInds',find(~IsUnitAreTarget),'MatchUnitRealIndex',ProbNPSess.UsedClus_IDs(~IsUnitAreTarget),...
        'MatchUnitRealChn',UnitMaxampChnInds(~IsUnitAreTarget),'MatchedBrainAreas',unique(UnitChnAreaIndexAll(~IsUnitAreTarget)));
    IstargetfieldExist(end) = true;
end
SessAreaIndexStrc.UsedAbbreviations = IstargetfieldExist;
SessAreaIndex_saveName = fullfile(cPath,'SessAreaIndexDataNewAlign2.mat');
save(SessAreaIndex_saveName,'SessAreaIndexStrc','-v7.3');
