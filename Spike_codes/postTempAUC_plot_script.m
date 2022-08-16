
clearvars NSMUnitOmegaSqrData AUCValidInfoDatas
ksfolder = strrep(cSessFolder,'F:\','E:\NPCCGs\');
%%
figSavefolder = fullfile(ksfolder, 'AnovanAnA');

% if exist(fullfile(figSavefolder,'SigAnovaTracedataSave.mat'),'file')
%     return;
% end

AnovaDatafile = fullfile(figSavefolder,'SigAnovaTracedataSave.mat');
load(AnovaDatafile,'AreaValidInfoDatas');
load(fullfile(figSavefolder,'TemporalAUCdataSave.mat'));

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
AccumedUnitNums = [0;cumsum(AreaUnitNumbers)];
% AreaInds = 6;

NumofExistAreas = length(ExistAreaNames);
AUCLabelTypeStrs = {'Blocktype','Choice'};
AUC2AnovaFactorInds = [3,1]; % firsgt AUC correponded to the third factor in anova, second correponded to the fisrt factor


AUCValidInfoDatas = cell(NumofExistAreas,2);
for AreaInds = 1 : NumofExistAreas

    cAreaNames = ExistAreaNames{AreaInds};
    cA_UnitInds = (AccumedUnitNums(AreaInds)+1):AccumedUnitNums(AreaInds+1);
    cA_UnitDatas = AllUnit_temporalAUC(:,cA_UnitInds,:); % in third dimension, first is blocktype, second is choice decoding 
    
    cA_unitNums = size(cA_UnitDatas,2);
    factorNum = size(cA_UnitDatas,3);
    AllFactorAbove = AreaValidInfoDatas{AreaInds, 1};
    IsUnitHaveNaN= AreaValidInfoDatas{AreaInds, 2};
    
    FactorTracesAll = cell(factorNum,6);
    SigUnitDatasAll = cell(factorNum,2);
    %
    for cFactor = 1 : factorNum
        cfUsedAreaInds = logical(AllFactorAbove(:,AUC2AnovaFactorInds(cFactor))) & ~IsUnitHaveNaN;

        cfUsedAllDatas_cell = cA_UnitDatas(:,cfUsedAreaInds,cFactor);
        cfUsedAllDatas = cellfun(@(c) c(1),cfUsedAllDatas_cell);
        cfThresholdData = cellfun(@(c) c(3),cfUsedAllDatas_cell);
        
        cf_avgTraces = mean(cfUsedAllDatas,2);
        ValidUnitNumbers = size(cfUsedAllDatas,2);
        cf_Trace_sem = std(cfUsedAllDatas,[],2)/sqrt(ValidUnitNumbers);
        
        ThresholdMeanTrace = mean(cfThresholdData,2);
        
        FactorTracesAll(cFactor,:) = {cf_avgTraces, cf_Trace_sem, ThresholdMeanTrace, cfUsedAreaInds, ...
            numel(cfUsedAreaInds) ,mean(cfUsedAreaInds)};
        
        SigUnitDatasAll(cFactor,:) = {cfUsedAllDatas, cfThresholdData};
    end

    AUCValidInfoDatas(AreaInds,:) = {FactorTracesAll, SigUnitDatasAll};
    %
    % plot the results
%     TotalCalcuNumber = size(NSMUnitOmegaSqrData,1);
%     CaledStimOnsetBin = 149; % stimonset bin is 151, and the calculation window is 50ms (5 bins)
%     winGoesStep = 0.01; % seconds
    TotalUnitNumbers = (((1:TotalCalcuNumber)-CaledStimOnsetBin) * winGoesStep)';
%     titleStrs = {'Choice','Sound','Blocktypes'};
    FactorSigUnitFrac = cell2mat(FactorTracesAll(:,6));

    huf = figure('position',[100 100 860 280]);
    for caInds = 1 : factorNum
        ax = subplot(1,factorNum,caInds);
        hold on

        semPatch_x = [TotalUnitNumbers;flipud(TotalUnitNumbers)];
        semPatch_y = [FactorTracesAll{caInds,1}+FactorTracesAll{caInds,2};...
            flipud(FactorTracesAll{caInds,1}-FactorTracesAll{caInds,2})];
        patch(semPatch_x,semPatch_y,1,'EdgeColor','none','faceColor',[0.8 0.4 0.4],'facealpha',0.3);

        plot(TotalUnitNumbers,FactorTracesAll{caInds,3},'Color',[.7 .7 .7],'linewidth',1.2);
        plot(TotalUnitNumbers,FactorTracesAll{caInds,1},'Color','r','linewidth',1.2);

        yscales = get(gca,'ylim');
        line([0 0],yscales,'Color','c','linewidth',1.0,'linestyle','--');
        set(ax,'ylim',yscales);
        title(sprintf('%s Sigfrac = %.2f',AUCLabelTypeStrs{caInds},FactorSigUnitFrac(caInds)));
        xlabel('Time (s)');
        ylabel('EV');
    end


    annotation('textbox',[0.02 0.5 0.1 0.05],'String',cAreaNames,'Color','b','FitBoxToText','on','Edgecolor','none');
    
    saveName = fullfile(figSavefolder,sprintf('%s temporal AUC plotsave',cAreaNames));
    
    saveas(huf,saveName);
    
    print(huf,saveName,'-dpng','-r0');
    print(huf,saveName,'-dpdf','-bestfit');
    close(huf);
    
end

dataSavePath = fullfile(figSavefolder,'TempAUCTracedata.mat');
save(dataSavePath,'ExistAreaNames','AUCValidInfoDatas','AreaUnitNumbers','ExistField_ClusIDs','-v7.3')

