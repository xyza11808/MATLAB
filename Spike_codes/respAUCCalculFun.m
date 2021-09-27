function [RepType_Unit_AUC,RepTypes, RespFRChange] = ...
    respAUCCalculFun(BaseFR, RespFR, UsedTrInds, Repeats, varargin)
% this function is used to calculate the respose AUC, which is compared
% with the baseline response values

UsedTrBase = BaseFR(UsedTrInds,:);
UsedTrResp = RespFR(UsedTrInds,:);
UsedRepeats = Repeats(UsedTrInds);
UnitNums = size(UsedTrResp,2);

RepTypes = unique(UsedRepeats);
NumRepType = length(RepTypes);
RepType_Unit_AUC = zeros(NumRepType,UnitNums,5);
RespFRChange = zeros(NumRepType,UnitNums);
for cRep = 1 : NumRepType
    cRepInds = UsedRepeats == RepTypes(cRep);
    cRep_respFR = UsedTrResp(cRepInds,:);
    cRep_baseFR = UsedTrBase(cRepInds,:);
    RespFRChange(cRep,:) = mean(cRep_respFR) - mean(cRep_baseFR);
    
    UnitRespAUC = zeros(UnitNums,5);
    for cUnit = 1 : UnitNums
        cUnitResp = cRep_respFR(:,cUnit);
        cUnitRespNum = length(cUnitResp);
        cUnitResp = cUnitResp + rand(cUnitRespNum,1)*1e-6;
        cUnitBase = cRep_baseFR(:,cUnit)+rand(cUnitRespNum,1)*1e-6;
        [AUC, IsRespRev] = AUC_fast_utest([cUnitResp; cUnitBase],...
            [ones(cUnitRespNum,1);zeros(cUnitRespNum,1)]);
        
        [~,~,SigValue] = ROCSiglevelGeneNew([[cUnitResp; cUnitBase],...
            [ones(cUnitRespNum,1);zeros(cUnitRespNum,1)]],500,1,0.01);
        
        AllTrBaseline = UsedTrBase(:,cUnit);
        NumTotalBaseresp = length(AllTrBaseline);
        AllTrBaseline = AllTrBaseline+rand(NumTotalBaseresp,1)*1e-6;
        [AUCAll, IsRespAll] = AUC_fast_utest([cUnitResp; AllTrBaseline],...
            [ones(cUnitRespNum,1);zeros(NumTotalBaseresp,1)]);
        
        UnitRespAUC(cUnit,:) = [AUC, IsRespRev, AUCAll, IsRespAll, SigValue];
        
    end
    RepType_Unit_AUC(cRep,:,:) = UnitRespAUC;
end
    
    
        






