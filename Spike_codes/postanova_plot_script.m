
clearvars NSMUnitOmegaSqrData AllNullThres_Mtx AreaValidInfoDatas
ksfolder = strrep(cSessFolder,'F:\','E:\NPCCGs\');
figSavefolder = fullfile(ksfolder, 'AnovanAnA');

if exist(fullfile(figSavefolder,'SigAnovaTracedataSave.mat'),'file')
    return;
end

AnovaDatafile = fullfile(figSavefolder,'OmegaSqrDatas.mat');
load(AnovaDatafile,'NSMUnitOmegaSqrData','AllNullThres_Mtx');
AreaIndexStrc = load(fullfile(ksfolder,'SessAreaIndexData.mat'));
AllFieldNames = fieldnames(AreaIndexStrc.SessAreaIndexStrc);
UsedNames = AllFieldNames(1:end-1);
ExistAreaNames = UsedNames(AreaIndexStrc.SessAreaIndexStrc.UsedAbbreviations);

if strcmpi(ExistAreaNames(end),'Others')
    ExistAreaNames(end) = [];
end
%%
Numfieldnames = length(ExistAreaNames);
ExistField_ClusIDs = [];
AreaUnitNumbers = zeros(Numfieldnames,1);
for cA = 1 : Numfieldnames
    cA_Clus_IDs = AreaIndexStrc.SessAreaIndexStrc.(ExistAreaNames{cA}).MatchUnitRealIndex;
    cA_clus_inds = AreaIndexStrc.SessAreaIndexStrc.(ExistAreaNames{cA}).MatchedUnitInds;
    ExistField_ClusIDs = [ExistField_ClusIDs;[cA_Clus_IDs,cA_clus_inds]]; % real Clus_IDs and Clus indexing inds
    AreaUnitNumbers(cA) = numel(cA_clus_inds);
end

%%
AccumedUnitNums = [1;cumsum(AreaUnitNumbers)];
% AreaInds = 6;

NumofExistAreas = length(ExistAreaNames);

AreaValidInfoDatas = cell(NumofExistAreas,5);
for AreaInds = 1 : NumofExistAreas

    cAreaNames = ExistAreaNames{AreaInds};
    cA_UnitInds = (AccumedUnitNums(AreaInds)+1):AccumedUnitNums(AreaInds+1);
    cA_UnitDatas = NSMUnitOmegaSqrData(:,cA_UnitInds,:);
    cA_UnitNullDatas = AllNullThres_Mtx(:,cA_UnitInds,:);
    cA_unitNums = size(cA_UnitDatas,2);

    factorNum = size(cA_UnitNullDatas,3);
    IsUnitHaveNaN = zeros(cA_unitNums,1);
    AllFactorAbove = zeros(cA_unitNums, factorNum);
    for cInds = 1 : cA_unitNums
        cIndsAnovaData = squeeze(cA_UnitDatas(:,cInds,:));
        if any(any(isnan(cIndsAnovaData)))
            IsUnitHaveNaN(cInds) = 1;
            continue;
        end
        cIndsNullThresData = squeeze(cA_UnitNullDatas(:,cInds,:));
        AboveThresValues = cIndsAnovaData > cIndsNullThresData;

        IsfactorAbove = zeros(factorNum,1);
        for cf = 1:factorNum
            if mean(AboveThresValues(:,cf)) > 0.7
                IsfactorAbove(cf) = 1;
            elseif any(AboveThresValues(:,cf))
                cfConsecus = consecTRUECount(AboveThresValues(:,cf));
                if any(cfConsecus > 30)
                    IsfactorAbove(cf) = 1;
                end
            end
        end
        AllFactorAbove(cInds,:) = IsfactorAbove;

    end


    %
    FactorTracesAll = cell(factorNum,5);
    FactorThresAvg = cell(factorNum,1);
    SigUnitDatasAll = cell(factorNum,2);
    for cFactor = 1 : factorNum
        cfUsedAreaInds = logical(AllFactorAbove(:,cFactor)) & ~IsUnitHaveNaN;

        cfUsedAllDatas = cA_UnitDatas(:,cfUsedAreaInds,cFactor);
        cf_avgTraces = mean(cfUsedAllDatas,2);
        ValidUnitNumbers = size(cfUsedAllDatas,2);
        cf_Trace_std = std(cfUsedAllDatas,[],2)/sqrt(ValidUnitNumbers);

        FactorTracesAll(cFactor,:) = {cf_avgTraces, cf_Trace_std, ValidUnitNumbers, ...
            numel(IsUnitHaveNaN) ,mean(cfUsedAreaInds)};

        cfThresData = squeeze(cA_UnitNullDatas(:,cfUsedAreaInds,cFactor));
        FactorThresAvg{cFactor} = mean(cfThresData,2);
        
        SigUnitDatasAll(cFactor,:) = {cfUsedAllDatas, cfThresData};
    end

    AreaValidInfoDatas(AreaInds,:) = {AllFactorAbove, IsUnitHaveNaN, FactorTracesAll, FactorThresAvg, SigUnitDatasAll};
    
    % plot the results
    TotalCalcuNumber = size(NSMUnitOmegaSqrData,1);
    CaledStimOnsetBin = 149; % stimonset bin is 151, and the calculation window is 50ms (5 bins)
    winGoesStep = 0.01; % seconds
    TotalUnitNumbers = (((1:TotalCalcuNumber)-CaledStimOnsetBin) * winGoesStep)';
    titleStrs = {'Choice','Sound','Blocktypes'};
    FactorSigUnitFrac = cell2mat(FactorTracesAll(:,5));

    huf = figure('position',[100 100 1080 280]);
    for caInds = 1 : factorNum
        ax = subplot(1,factorNum,caInds);
        hold on

        semPatch_x = [TotalUnitNumbers;flipud(TotalUnitNumbers)];
        semPatch_y = [FactorTracesAll{caInds,1}+FactorTracesAll{caInds,2};...
            flipud(FactorTracesAll{caInds,1}-FactorTracesAll{caInds,2})];
        patch(semPatch_x,semPatch_y,1,'EdgeColor','none','faceColor',[0.8 0.4 0.4],'facealpha',0.3);

        plot(TotalUnitNumbers,FactorThresAvg{caInds},'Color',[.7 .7 .7],'linewidth',1.2);
        plot(TotalUnitNumbers,FactorTracesAll{caInds,1},'Color','r','linewidth',1.2);

        yscales = get(gca,'ylim');
        line([0 0],yscales,'Color','c','linewidth',1.0,'linestyle','--');
        set(ax,'ylim',yscales);
        title(sprintf('%s Sigfrac = %.2f',titleStrs{caInds},FactorSigUnitFrac(caInds)));
        xlabel('Time (s)');
        ylabel('EV');
    end


    annotation('textbox',[0.02 0.5 0.1 0.05],'String',cAreaNames,'Color','b','FitBoxToText','on','Edgecolor','none');
    
    saveName = fullfile(figSavefolder,sprintf('%s anovan EV plotsave',cAreaNames));
    
    saveas(huf,saveName);
    
    print(huf,saveName,'-dpng','-r0');
    print(huf,saveName,'-dpdf','-bestfit');
    close(huf);
    
end

dataSavePath = fullfile(figSavefolder,'SigAnovaTracedataSave.mat');
save(dataSavePath,'ExistAreaNames','AreaValidInfoDatas','AreaUnitNumbers','ExistField_ClusIDs','-v7.3')

