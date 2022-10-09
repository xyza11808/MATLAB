% sess unit PSTH data expension
UsedUnitNum = size(UnitPSTHdataAll,1);
PSTHframeBins = size(UnitPSTHdataAll{1,1},3);
ExpendTraceAll = cell(UsedUnitNum,7);
for cU = 1 : UsedUnitNum
    
    cU_lowCorr_AvgData = (squeeze(UnitPSTHdataAll{cU,1}(:,1,:)))';
    cU_lowErro_AvgData = (squeeze(UnitPSTHdataAll{cU,1}(:,2,:)))';
    cU_highCorr_AvgData = (squeeze(UnitPSTHdataAll{cU,1}(:,3,:)))';
    cU_highErro_AvgData = (squeeze(UnitPSTHdataAll{cU,1}(:,4,:)))';

    % expend all freq and blocks
    cU_ExpendTrace = [cU_lowCorr_AvgData(:);cU_highCorr_AvgData(:)];

    cU_lowCorr_SEMData = (squeeze(UnitPSTHdataAll{cU,2}(:,1,:)))';
    cU_lowErro_SEMData = (squeeze(UnitPSTHdataAll{cU,2}(:,2,:)))';
    cU_highCorr_SEMData = (squeeze(UnitPSTHdataAll{cU,2}(:,3,:)))';
    cU_highErro_SEMData = (squeeze(UnitPSTHdataAll{cU,2}(:,4,:)))';
    
    cU_SEM_expend = [cU_lowCorr_SEMData(:);cU_highCorr_SEMData(:)];
    
    % expend all error trials
    cU_ErroExpendTrace = [cU_lowErro_AvgData(:);cU_highErro_AvgData(:)];
    cU_SEMErroTrace = [cU_lowErro_SEMData(:);cU_highErro_SEMData(:)];
     
    ExpendTraceAll(cU,:) = {cU_ExpendTrace',cU_SEM_expend',cU_ErroExpendTrace',cU_SEMErroTrace',...
        UnitPSTHdataAll{cU,3},UnitPSTHdataAll{cU,4},UnitPSTHdataAll{cU,5}};
    
end
%%
UnitPSTHMtx = cat(1,ExpendTraceAll{:,1});
UnitPSTHzs = zscore(UnitPSTHMtx,0,2);
AreaStrs = ExpendTraceAll(:,end);
