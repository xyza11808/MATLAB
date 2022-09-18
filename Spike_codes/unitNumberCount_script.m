Areawise_unitnums= cell(NumUsedSess,NumAllTargetAreas);
for cS = 1 :  NumUsedSess
%     cSessPath = SessionFolders{cS}; %(2:end-1)
    cSessPath = strrep(SessionFolders{cS},'F:\','E:\NPCCGs\'); % 'E:\NPCCGs\'
%     cSessPath = strrep(SessionFolders{cS},'F:','F:\ksOutput_backup'); %(2:end-1)
    
    ksfolder = fullfile(cSessPath,'ks2_5');
    try
        
        NewSessAreaStrc = load(fullfile(ksfolder,'SessAreaIndexDataAligned.mat'));
%         UnitSltFile = fullfile(ksfolder,'Regressor_ANA','UnitSelectiveTypes2.mat');
%         UnitSltDataStrc = load(UnitSltFile);
        RegressorDatafile = fullfile(ksfolder,'Regressor_ANA','RegressorDataAligned.mat');
        RegressorDataStrc = load(RegressorDatafile,'AreaUnitNumbers','NewAdd_ExistAreaNames');
    catch ME
        fprintf('Error exists in session %d.\n',cS);
    end
    
    NewAdd_ExistAreaNames = RegressorDataStrc.NewAdd_ExistAreaNames;
%     NewAdd_NumExistAreas = length(NewAdd_ExistAreaNames);
    Numfieldnames = length(NewAdd_ExistAreaNames);
    AreaUnitNumbers = RegressorDataStrc.AreaUnitNumbers;
    AreaUnitCountCumsum = cumsum([0;AreaUnitNumbers]); % for matrix indexing
    
    NumAreas = length(NewAdd_ExistAreaNames);
    if NumAreas < 1
        warning('There is no target units within following folder:\n %s \n ##################\n',cSessPath);
        continue;
    end
    %
    for cAreaInds = 1 : NumAreas 
        cAreaStr = NewAdd_ExistAreaNames{cAreaInds};
        AreaMatchInds = matches(BrainAreasStr,cAreaStr,'IgnoreCase',true);
        
%         AreaUnitIndsRange = (AreaUnitCountCumsum(cAreaInds)+1):AreaUnitCountCumsum(cAreaInds+1);
        
        Areawise_unitnums(cS,AreaMatchInds) = {AreaUnitNumbers(cAreaInds)};
        
    end
end


%%
AreaNumsSum = zeros(NumAllTargetAreas,1);
for cA = 1 : NumAllTargetAreas
    cA_AllNum = cat(1,Areawise_unitnums{:,cA});
    if ~isempty(cA_AllNum)
        AreaNumsSum(cA) = sum(cA_AllNum);
    end
end

%%
AllExistAreaStrInds = find(~isnan(SelfBrainInds2Allen(:,1)));
NumAHSAreas = length(AllExistAreaStrInds);
AHSAreaUnitNums = zeros(NumAHSAreas,1);
for cAA =  1 : NumAHSAreas
    cA_AHS_Str = NEBrainStrs{SelfBrainInds2Allen(AllExistAreaStrInds(cAA),1)};
    FindMatches = matches(BrainAreasStr,cA_AHS_Str,'IgnoreCase',true);
    if ~any(FindMatches)
        fprintf('Something wrong for area %s.\n',cA_AHS_Str);
    else
        AHSAreaUnitNums(cAA) = AreaNumsSum(FindMatches);
    end
end


    


