
% ksfolder = pwd;

UnitRespDatafile = fullfile(ksfolder,'UsedUnitSPtimeAndTimeAmp','FRDataSave.mat');
UnitRespDataStrc = load(UnitRespDatafile);
NumofUnit = size(UnitRespDataStrc.UnitFRDatas,1);
AllUnit_SmallBinFR = cell(NumofUnit,2);
for cU = 1 : NumofUnit
    cU_10sBinCents = UnitRespDataStrc.UnitFRDatas{cU,3};
    cU_10sBinFRs = UnitRespDataStrc.UnitFRDatas{cU,4};
    NumBlocks = length(UnitRespDataStrc.AfterBlockSWTrOnTime);
    BlockBinFRs = zeros(5,NumBlocks);
    for cB = 1 : NumBlocks
        if cB == 1
            cBTimeScales = [UnitRespDataStrc.TaskStartTime,...
                UnitRespDataStrc.AfterBlockSWTrOnTime(cB)];
        else
            cBTimeScales = [UnitRespDataStrc.AfterBlockSWTrOnTime(cB-1),...
                UnitRespDataStrc.AfterBlockSWTrOnTime(cB)];
        end
        cBTimeScales_stepbin = linspace(cBTimeScales(1),cBTimeScales(2),6);
        BinFRAvgs = zeros(5,1);
        for cBin = 1 : 5
            cBinCentsInds = cU_10sBinCents >= cBTimeScales_stepbin(cBin) & ...
                cU_10sBinCents < cBTimeScales_stepbin(cBin+1);
            BinFRAvgs(cBin) = mean(cU_10sBinFRs(cBinCentsInds));
        end
        BlockBinFRs(:,cB) = BinFRAvgs;
    end
    AllUnit_SmallBinFR(cU,:) = {BlockBinFRs,BlockBinFRs(:)};
end

%%

IsCUAbnorm = false(NumofUnit,1);
for cU = 1 : NumofUnit
   cUBlocksFRs = AllUnit_SmallBinFR{cU,2}; 
    
    if all(cUBlocksFRs <= 0.2) || max(cUBlocksFRs) < 1
        continue;
    end
    IsUnitAbnorm = 0;
    if ~(min(cUBlocksFRs) >= max(cUBlocksFRs)/2 && max(cUBlocksFRs) >= 10)
        if prctile(cUBlocksFRs,80) >= 5 % if the maximum FR is high
            AllLowFRInds = double(cUBlocksFRs < 0.2);
            if ~any(AllLowFRInds)
                continue;
            end
            ConsVec = consecTRUECount(AllLowFRInds);
            if any(ConsVec >= 3) % if any consecutive bins have lower FRs
                IsUnitAbnorm = 1;
            end
        else
            AllLowFRInds = double(cUBlocksFRs < 0.1);
            if ~any(AllLowFRInds)
                continue;
            end
            ConsVec = consecTRUECount(AllLowFRInds);
            if any(ConsVec >= 3) % if any consecutive bins have lower FRs
                IsUnitAbnorm = 1;
            end
        end
    else
        AllLowFRInds = double(cUBlocksFRs < 0.2);
        if ~any(AllLowFRInds)
            continue;
        end
        ConsVec = consecTRUECount(AllLowFRInds);
        if any(ConsVec >= 3) % if any consecutive bins have lower FRs
            IsUnitAbnorm = 1;
        end
        
    end
    IsCUAbnorm(cU) = IsUnitAbnorm > 0;
end

DataSavefile = fullfile(ksfolder,'UsedUnitSPtimeAndTimeAmp','IsCuFRAbnormal.mat');
save(DataSavefile,'IsCUAbnorm','-v7.3');

%%
% % close;
% % cU = 254;
% % IsCUAbnorm = false(NumofUnit,1);
% for cU = 1 : NumofUnit
%     cUBlocksFRs = AllUnit_SmallBinFR{cU,2};
%     hf = figure;
%     hold on
%     plot(cUBlocksFRs,'k-o');
%     yscales = get(gca,'ylim');
%     for cB = 1 : NumBlocks
%         cBInds = cB*5+0.5;
%         line([cBInds cBInds],yscales,'Color','m','linewidth',1.4);
%     end
%     set(gca,'ylim',yscales);
%     title(sprintf('IsNorm = %d',IsCUAbnorm(cU)));
% end


