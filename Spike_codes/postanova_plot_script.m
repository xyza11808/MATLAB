
clearvars NSMUnitOmegaSqrData AllNullThres_Mtx AreaValidInfoDatas
% ksfolder = strrep(cSessFolder,'F:\','E:\NPCCGs\');

%%
figSavefolder = fullfile(ksfolder, 'AnovanAnA');

% if exist(fullfile(figSavefolder,'SigAnovaTracedataSave.mat'),'file')
%     return;
% end

AnovaDatafile = fullfile(figSavefolder,'OmegaSqrDatas.mat');
load(AnovaDatafile,'NSMUnitOmegaSqrData','AllNullThres_Mtx','CalWinUnitOmegaSqrs');
AreaIndexStrc = load(fullfile(ksfolder,'SessAreaIndexDataNew.mat'));
AllFieldNames = fieldnames(AreaIndexStrc.SessAreaIndexStrc);
UsedNames = AllFieldNames(1:end-1);
ExistAreaNames = UsedNames(AreaIndexStrc.SessAreaIndexStrc.UsedAbbreviations);

if strcmpi(ExistAreaNames(end),'Others')
    ExistAreaNames(end) = [];
end

%%
Numfieldnames = length(ExistAreaNames);
oExistField_ClusIDs = [];
oAreaUnitNumbers = zeros(Numfieldnames,1);
for cA = 1 : Numfieldnames
    cA_Clus_IDs = AreaIndexStrc.SessAreaIndexStrc.(ExistAreaNames{cA}).MatchUnitRealIndex;
    cA_clus_inds = AreaIndexStrc.SessAreaIndexStrc.(ExistAreaNames{cA}).MatchedUnitInds;
    oExistField_ClusIDs = [oExistField_ClusIDs;[cA_Clus_IDs,cA_clus_inds]]; % real Clus_IDs and Clus indexing inds
    oAreaUnitNumbers(cA) = numel(cA_clus_inds);
end

%%
SeqAreaUnitNums = oAreaUnitNumbers;
AccumedUnitNums = [0;cumsum(oAreaUnitNumbers)];
SeqAreaNames = ExistAreaNames;
SeqFieldClusIDs = oExistField_ClusIDs;
% AreaInds = 6;
%%
NonRevFreqOs = cellfun(@(x) mean(x(:,1),'omitnan'),CalWinUnitOmegaSqrs(:,:,3)); % the third factor corresponded to blocktype factor 
RevFreqOs = cellfun(@(x) mean(x(:,2),'omitnan'),CalWinUnitOmegaSqrs(:,:,3));% size of NumCalculation * NumUnits

clearvars CalWinUnitOmegaSqrs
%%
NumofExistAreas = length(SeqAreaNames);

AreaValidInfoDatas = cell(NumofExistAreas,5);
AreaWise_BTfreqseqDatas = cell(NumofExistAreas,3);
for AreaInds = 1 : NumofExistAreas

    cAreaNames = SeqAreaNames{AreaInds};
    cA_UnitInds = (AccumedUnitNums(AreaInds)+1):AccumedUnitNums(AreaInds+1);
    cA_UnitDatas = NSMUnitOmegaSqrData(:,cA_UnitInds,:);
    cA_UnitNullDatas = AllNullThres_Mtx(:,cA_UnitInds,:);
    cA_UnitBTOsDatas_nonRev = NonRevFreqOs(:,cA_UnitInds);
    cA_UnitBTOsDatas_Revfreq = RevFreqOs(:,cA_UnitInds);
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
    
    % freqtype sepecific blocktype varaince analysis
    cA_BT_unitDatas = {cA_UnitBTOsDatas_nonRev,cA_UnitBTOsDatas_Revfreq};
    BTVarTraces = cell(2,5);
    BTVarThresAvg = cell(2,1);
    BTVarSigUnitDatasAll = cell(2,2);
    for cc = 1 : 2
        ccData = cA_BT_unitDatas{cc};
        
        cfUsedAreaInds = logical(AllFactorAbove(:,factorNum)) & (~(sum(isnan(ccData))))';
        
        cBTUsedDatas = ccData(:,cfUsedAreaInds);
        cBT_AvgTrace = mean(cBTUsedDatas,2);
        cValidUnitNums = size(cBTUsedDatas,2);
        cBT_Trace_sem = std(cBTUsedDatas,[],2)/sqrt(cValidUnitNums);
        BTVarTraces(cc,:) = {cBT_AvgTrace,cBT_Trace_sem,cValidUnitNums,numel(IsUnitHaveNaN) ,mean(cfUsedAreaInds)};
        
        ccThresData = squeeze(cA_UnitNullDatas(:,cfUsedAreaInds,factorNum));
        BTVarThresAvg{cc} = mean(ccThresData,2);
        
        BTVarSigUnitDatasAll(cc,:) = {cBTUsedDatas, ccThresData};
    end
    AreaWise_BTfreqseqDatas(AreaInds,:) = {BTVarTraces, BTVarThresAvg, BTVarSigUnitDatasAll};
    
    % plot the results
    TotalCalcuNumber = size(NSMUnitOmegaSqrData,1);
    CaledStimOnsetBin = 149; % stimonset bin is 151, and the calculation window is 50ms (5 bins)
    winGoesStep = 0.01; % seconds
    TotalUnitNumbers = (((1:TotalCalcuNumber)-CaledStimOnsetBin) * winGoesStep)';
    titleStrs = {'Choice','Sound','Blocktypes'};
    FactorSigUnitFrac = cell2mat(FactorTracesAll(:,4:5));
    FactorSigUnitNums = cell2mat(FactorTracesAll(:,3));
    huf = figure('position',[100 100 1080 600]);
    for caInds = 1 : factorNum
        ax = subplot(2,factorNum,caInds);
        hold on

        semPatch_x = [TotalUnitNumbers;flipud(TotalUnitNumbers)];
        semPatch_y = [FactorTracesAll{caInds,1}+FactorTracesAll{caInds,2};...
            flipud(FactorTracesAll{caInds,1}-FactorTracesAll{caInds,2})];
        patch(semPatch_x,semPatch_y,1,'EdgeColor','none','faceColor',[0.8 0.4 0.4],'facealpha',0.3);

        plot(TotalUnitNumbers,FactorThresAvg{caInds},'Color',[.7 .7 .7],'linewidth',1.2);
        plot(TotalUnitNumbers,FactorTracesAll{caInds,1},'Color','r','linewidth',1.2);

        yscales = get(gca,'ylim');
        line([0 0],yscales,'Color','c','linewidth',1.0,'linestyle','--');
        text(-0.3,yscales(2)*0.8,num2str(FactorSigUnitFrac(caInds,1),'nTotal=%d'),'HorizontalAlignment','center');
        set(ax,'ylim',yscales);
        title(sprintf('%s Sigfrac = %.2f (%d)',titleStrs{caInds},FactorSigUnitFrac(caInds,2),FactorSigUnitNums(caInds)));
        xlabel('Time (s)');
        ylabel('EV');
    end
    
    BTSeqStrs = {'NonRevF\_BT','RevF\_BT'};
    BTSigUnitFrac = cell2mat(BTVarTraces(:,4:5));
    BTSigUnitNums = cell2mat(BTVarTraces(:,3));
    for cA = 1:2
       cax = subplot(2,factorNum,factorNum+cA);
       hold on
       
        semPatch_x = [TotalUnitNumbers;flipud(TotalUnitNumbers)];
        semPatch_y = [BTVarTraces{cA,1}+BTVarTraces{cA,2};...
            flipud(BTVarTraces{cA,1}-BTVarTraces{cA,2})];
        patch(semPatch_x,semPatch_y,1,'EdgeColor','none','faceColor',[0.8 0.4 0.4],'facealpha',0.3);

        plot(TotalUnitNumbers,BTVarThresAvg{cA},'Color',[.7 .7 .7],'linewidth',1.2);
        plot(TotalUnitNumbers,BTVarTraces{cA,1},'Color','r','linewidth',1.2);

        yscales = get(cax,'ylim');
        line([0 0],yscales,'Color','c','linewidth',1.0,'linestyle','--');
        text(-0.3,yscales(2)*0.8,num2str(BTSigUnitFrac(cA,1),'nTotal=%d'),'HorizontalAlignment','center');
        set(cax,'ylim',yscales);
        title(sprintf('%s Sigfrac = %.2f (%d)',BTSeqStrs{cA},BTSigUnitFrac(cA,2),BTSigUnitNums(cA)));
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
%%
dataSavePath = fullfile(figSavefolder,'SigAnovaTracedataSave.mat');
save(dataSavePath,'SeqAreaNames','AreaValidInfoDatas','AreaWise_BTfreqseqDatas',...
    'AccumedUnitNums','SeqFieldClusIDs','SeqAreaUnitNums','CaledStimOnsetBin','winGoesStep','-v7.3');

