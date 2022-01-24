
DevThreshold = 0.1; % mannually defined criteria
AllmdFit_devExplain_median = cellfun(@median,UnitFitmds_All(:,2));
AboveThresUnit = find(AllmdFit_devExplain_median > DevThreshold);
RealUnitInds = ProbNPSess.UsedClus_IDs(AboveThresUnit);
NumUsedUnits = length(AboveThresUnit);
fprintf('Number of significant units is %d.\n', NumUsedUnits);
%%
UnitUsedCoefs = cell(NumUsedUnits,1);
for cUsed_Unit = 1 : NumUsedUnits
    cUnit_allCoefs = UnitFitmds_All{AboveThresUnit(cUsed_Unit),1};
    AboveThresDevInds = UnitFitmds_All{AboveThresUnit(cUsed_Unit),2} > DevThreshold;
    cUnit_UsedCoefs = cUnit_allCoefs(AboveThresDevInds);
    %
    cUnit_coef_pvalues = cellfun(@(x) (x.pValue)',cUnit_UsedCoefs,'UniformOutput',false);
    cUnit_coef_pvalueMtx = cell2mat(cUnit_coef_pvalues);
    cUnit_coef_SigInds = mean(cUnit_coef_pvalueMtx < 0.05) > 0.7; % more than 70% of the p values is significant
    cUnit_coefs = cellfun(@(x) (x.Estimate)',cUnit_UsedCoefs,'UniformOutput',false);
    cUnit_coefsMtx = cell2mat(cUnit_coefs);
    cUnit_coefsMtx(cUnit_coef_pvalueMtx > 0.05) = NaN;
    AvgCoefs = mean(cUnit_coefsMtx,'omitnan');
    cUnitCoefs_final = zeros(1,numel(cUnit_coef_SigInds));
    cUnitCoefs_final(cUnit_coef_SigInds) = AvgCoefs(cUnit_coef_SigInds);
    %
    UnitUsedCoefs{cUsed_Unit} = cUnitCoefs_final;
    
end



