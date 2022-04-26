

clearvars AUCValuesAll SessAreaUnitlagDatas SigUnitCrossCoef SessAreaIndexStrc

% load(fullfile(cSessFolder,'NPClassHandleSaved.mat'));
load(fullfile(cSessFolder,'BaselinePredofBlocktype','SingleUnitAUC.mat'),'AUCValuesAll');
try
    load(fullfile(cSessFolder,'Old_BaselinePredofBT','SigUnitAUCCrosscorr','SigUnitCoefDatas.mat'));
catch
    load(fullfile(cSessFolder,'BaselinePredofBlocktype','SigUnitAUCCrosscorr','SigUnitCoefDatas.mat'));
end
load(fullfile(cSessFolder,'SessAreaIndexData.mat'));
%%
SessAreaInds = SessAreaIndexStrc.UsedAbbreviations;
AllAreaNames = fieldnames(SessAreaIndexStrc);
AllAreaNames_Used = AllAreaNames(1:end-1);

ExistAreaNames = AllAreaNames_Used(SessAreaInds);
NumofAreas = length(ExistAreaNames);

AllSigUnitInds = cell2mat(SigUnitCrossCoef(:,1));
SessAreaUnitlagDatas = cell(NumofAreas,2);
for cA = 1 : NumofAreas
    cA_UnitInds = SessAreaIndexStrc.(ExistAreaNames{cA}).MatchedUnitInds;
    [Lia,Lib] = ismember(AllSigUnitInds, cA_UnitInds);
    if any(Lia)
        MatchedSigUnitInds = find(Lia);
        Matched_SigUnitDatas = SigUnitCrossCoef(MatchedSigUnitInds,:);
        NumMatchedInds = numel(MatchedSigUnitInds);
        
        cA_CoefSigUnitData = cell(NumMatchedInds,5);
        Is_cUU_Used = false(NumMatchedInds,1);
        for cUU = 1 : NumMatchedInds
            cUU_cellDatas = Matched_SigUnitDatas(cUU,:);
            cUU_UnitInds = cUU_cellDatas{1};
            if ~isnan(cUU_cellDatas{5})
%                 cUU_CoefPeak = cUU_cellDatas{6}+51; % real inds
                cUU_Alllag_coef = cUU_cellDatas{2};
%                 AroundPeakScales = [max(1,cUU_CoefPeak-10) min(cUU_CoefPeak+10,length(cUU_Alllag_coef))];
%                 if sum(abs(cUU_Alllag_coef(AroundPeakScales(1):AroundPeakScales(2))) > cUU_cellDatas{4}(1))
                if sum(abs(cUU_Alllag_coef) > cUU_cellDatas{4}(1)) > 20
                    cA_CoefSigUnitData(cUU,:) = {cUU_UnitInds, cUU_cellDatas{5}, cUU_cellDatas{6},...
                        AUCValuesAll(cUU_UnitInds,1), AUCValuesAll(cUU_UnitInds,2)};
                    Is_cUU_Used(cUU) = true;
                end
            end
        end
        cA_CoefSigUnit_usedData = cA_CoefSigUnitData(Is_cUU_Used,:);
    else
       cA_CoefSigUnitData = {}; 
        
    end
    SessAreaUnitlagDatas(cA,:) = {ExistAreaNames{cA}, cA_CoefSigUnit_usedData};
end

fileSaveName = fullfile(cSessFolder,'AreaWise_AUCSigUnitlags.mat');
save(fileSaveName,'SessAreaUnitlagDatas','-v7.3');
