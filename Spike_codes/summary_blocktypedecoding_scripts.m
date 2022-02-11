cclr

% AllSessFolderPathfile = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\processed_ksfolder_paths.xlsx';
AllSessFolderPathfile = 'H:\file_from_N\Documents\me\projects\NP_reversaltask\processed_ksfolder_paths.xlsx';

BrainAreasStrC = readcell(AllSessFolderPathfile,'Range','B:B',...
        'Sheet',1);
BrainAreasStrCC = BrainAreasStrC(2:end);
BrainAreasStrCCC = cellfun(@(x) x(2:end-1),BrainAreasStrCC,'UniformOutput',false);
EmptyInds = cellfun(@isempty,BrainAreasStrCCC);
BrainAreasStr = BrainAreasStrCCC(~EmptyInds);
%%
SessionFoldersC = readcell(AllSessFolderPathfile,'Range','A:A',...
        'Sheet',1);
SessionFolders = SessionFoldersC(2:end);
NumUsedSess = length(SessionFolders);
NumAllTargetAreas = length(BrainAreasStr);

Areawise_sessDecPerf = cell(NumUsedSess,NumAllTargetAreas,3);
Areawise_UnitAUC = cell(NumUsedSess,NumAllTargetAreas,2);
Areawise_PopuPredCC = cell(NumUsedSess,NumAllTargetAreas,2);
Areawise_BehavChoiceDiff = cell(NumUsedSess,NumAllTargetAreas);
for cS = 1 : NumUsedSess
%     cSessPath = SessionFolders{cS}(2:end-1);
    cSessPath = strrep(SessionFolders{cS}(2:end-1),'F:','I:\ksOutput_backup');
    
    SessblocktypeDecfile = fullfile(cSessPath,'ks2_5','BaselinePredofBlocktype','PopudecodingDatas.mat');
    SessUnitAUCfile = fullfile(cSessPath,'ks2_5','BaselinePredofBlocktype','SingleUnitAUC.mat');
    behavFilePath = fullfile(cSessPath,'ks2_5','BehavSwitchData.mat');
%     UnitAreafile = fullfile(cSessPath,'ks2_5','SessAreaIndexData.mat');
    
    SessblocktypeDecDataStrc = load(SessblocktypeDecfile,'ExistAreas_Names','SVMDecodingAccuracy','logRegressorProbofBlock');
    SessUnitAUCStrc = load(SessUnitAUCfile,'AUCValuesAll');
    BehavBlockchoiceDiff = load(behavFilePath,'H2L_choiceprob_diff');
%     UnitAreaStrc = load(UnitAreafile);
    
    NumAreas = length(SessblocktypeDecDataStrc.ExistAreas_Names);
    if NumAreas < 1
        warning('There is no target units within following folder:\n %s \n ##################\n',cSessPath);
        continue;
    end
    
    for cAreaInds = 1 : NumAreas
        cAreaStr = SessblocktypeDecDataStrc.ExistAreas_Names{cAreaInds};
        cAreaSVMperf = SessblocktypeDecDataStrc.SVMDecodingAccuracy{cAreaInds,1};
        cAreaSVMShufthres = prctile(SessblocktypeDecDataStrc.SVMDecodingAccuracy{cAreaInds,2},95);
        cAreaUnitInds = SessblocktypeDecDataStrc.SVMDecodingAccuracy{cAreaInds,4};
        
        AreaMatchInds = matches(BrainAreasStr,cAreaStr);
        Areawise_sessDecPerf(cS,AreaMatchInds,:) = {cAreaSVMperf, cAreaSVMShufthres, numel(cAreaUnitInds)}; % realperf, shufthres, observation numbers
        
        % set AUC values
        Areawise_UnitAUC(cS,AreaMatchInds,1) = {SessUnitAUCStrc.AUCValuesAll(cAreaUnitInds,1)};
        Areawise_UnitAUC(cS,AreaMatchInds,2) = {SessUnitAUCStrc.AUCValuesAll(cAreaUnitInds,3)};
        
        Areawise_BehavChoiceDiff(cS,AreaMatchInds) = {BehavBlockchoiceDiff.H2L_choiceprob_diff};
        
        cAreaCCData = SessblocktypeDecDataStrc.logRegressorProbofBlock{1,5};
        cAreaCC_values = smooth(cAreaCCData{1},5);
        cAreaCC_lags = cAreaCCData{2};
        cAreaCC_CoefThres = cAreaCCData{3}(1);
        [MaxValue, MaxInds] = max(cAreaCC_values);
        MaxValue_lags = cAreaCC_lags(MaxInds);
        
        Areawise_PopuPredCC(cS,AreaMatchInds,1) = {MaxValue_lags};
        Areawise_PopuPredCC(cS,AreaMatchInds,2) = {[MaxValue, cAreaCC_CoefThres]};
        
    end
end

%% summary figure plots saved position
% sumfigsavefolder = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\summaryDatas\blocktype_baseline_encoding';
sumfigsavefolder = 'H:\file_from_N\Documents\me\projects\NP_reversaltask\summaryDatas\blocktype_baseline_encoding';
if ~isfolder(sumfigsavefolder)
    mkdir(sumfigsavefolder);
end

%%
AllAreaSess_SVMperfs = squeeze(Areawise_sessDecPerf(:,:,1));
AllAreaSess_SVMThres = squeeze(Areawise_sessDecPerf(:,:,2));
AllAreaSess_SVMunitnums = squeeze(Areawise_sessDecPerf(:,:,3));

NonEmptyInds = find(cellfun(@(x) ~isempty(x),AllAreaSess_SVMperfs));
[row,AreaInds] = ind2sub([NumUsedSess,NumAllTargetAreas],NonEmptyInds);

AllSVMperfDatas_Vec = cell2mat(AllAreaSess_SVMperfs(NonEmptyInds));
AllSVMthresDatas_Vec = cell2mat(AllAreaSess_SVMThres(NonEmptyInds));
AllSVMnumberDatas_Vec = cell2mat(AllAreaSess_SVMunitnums(NonEmptyInds));

SVMperfSigInds = AllSVMperfDatas_Vec > AllSVMthresDatas_Vec;

hf = figure('position',[100 100 840 640]);
hold on
% three dimensional plot, each dimension is area, unitnum, SVMperf
plot3(AreaInds(SVMperfSigInds), AllSVMnumberDatas_Vec(SVMperfSigInds), ...
    AllSVMperfDatas_Vec(SVMperfSigInds),'o','MarkerSize',12,...
    'MarkerFaceColor','k','MarkerEdgeColor','r','linewidth',1.4);
plot3(AreaInds(~SVMperfSigInds), AllSVMnumberDatas_Vec(~SVMperfSigInds), ...
    AllSVMperfDatas_Vec(~SVMperfSigInds),'o','MarkerSize',12,...
    'MarkerFaceColor',[.7 .7 .7],'MarkerEdgeColor','b','linewidth',1.4);
set(gca,'xlim',[0 NumAllTargetAreas+1],'xtick',1:NumAllTargetAreas,...
    'xticklabel',BrainAreasStr(:));
grid on
xlabel('Brain areas');
ylabel('Unit Numbers');
zlabel('SVMperef');
view(gca,11,50);
title('SVM decoding perf')
%%
saveas(hf,fullfile(sumfigsavefolder,'SVMperf 3d plot save'));
saveas(hf,fullfile(sumfigsavefolder,'SVMperf 3d plot save'),'png');

% %%
% h2df = figure;
% hold on
% scatter(AreaInds,AllSVMnumberDatas_Vec,AllSVMperfDatas_Vec*100+8,'o','MarkerEdgeColor','b',...
%               'MarkerFaceColor',[.7 .7 .7],'LineWidth',1);
% scatter(AreaInds(SVMperfSigInds),AllSVMnumberDatas_Vec(SVMperfSigInds),8,'*','MarkerEdgeColor','r',...
%               'MarkerFaceColor','none','LineWidth',1.5);

%% single unit AUC plot
RealAUCs = squeeze(Areawise_UnitAUC(:,:,1));
AUCThres = squeeze(Areawise_UnitAUC(:,:,2));

AUCedges = 0:0.05:1;
AUCcent = AUCedges(1:end-1)+0.025;
for cArea = 1 : NumAllTargetAreas
    cArea_realAUC = cell2mat(RealAUCs(:,cArea));
    cArea_AUCthres = cell2mat(AUCThres(:,cArea));
    if isempty(cArea_realAUC)
        continue;
    end
    SigAUCvalues = cArea_realAUC(cArea_realAUC > cArea_AUCthres);
    h3f = figure('position',[100 100 460 230]);
    ax1 = subplot(121);
    hold on
    h1 = histogram(ax1,cArea_realAUC,AUCedges);
    h2 = histogram(ax1,SigAUCvalues,AUCedges);
    yscales = get(ax1,'ylim');
    h1.EdgeColor = 'none';
    h2.EdgeColor = 'none';
    h1.FaceColor = [.7 .7 .7];
    h2.FaceColor = 'k';
    xlabel('AUC')
    ylabel('Unit counts');
    title(BrainAreasStr{cArea});
    line(mean(SigAUCvalues)*[1 1],yscales,'Color','r','linewidth',1.4);
    set(gca,'ylim',yscales);
    text(mean(SigAUCvalues)+0.01,yscales(2)*0.75,{'AvgSigAUC';num2str(mean(SigAUCvalues),'%.3f')},...
    'FontSize',6);
    text(0.01,yscales(2)*0.9,{'UnitNumber';num2str(numel(cArea_realAUC),'%d')},...
        'FontSize',6);
    
    ax2 = subplot(122);
    SigAUCFrac = mean(cArea_realAUC > cArea_AUCthres);
    labels = {sprintf('SigUnits(%.2f%%)',SigAUCFrac*100),'NotSigUnits'};
    p = pie(ax2, [SigAUCFrac 1-SigAUCFrac],labels);
    p(1).EdgeColor = 'none';
    p(1).FaceColor = 'k';
    p(3).EdgeColor = 'none';
    p(3).FaceColor = [.7 .7 .7];
    p(2).FontSize = 6;
    p(4).FontSize = 6;
    
    
    savename = fullfile(sumfigsavefolder,sprintf('BrainRegion_unitAUCdis_%s',BrainAreasStr{cArea}));
    saveas(h3f,savename);
    saveas(h3f,savename,'png');
    close(h3f);
    
end

%%
sumDatasaveName = fullfile(sumfigsavefolder,'SummarizedBlocktypedecodingData.mat');
save(sumDatasaveName,'Areawise_UnitAUC','Areawise_sessDecPerf',...
    'BrainAreasStr','SessionFolders','-v7.3')
%% partial correlation analysis
% load and calculate behavior datas
AllSVMperfDatas_Vec = cell2mat(AllAreaSess_SVMperfs(NonEmptyInds));
AllSVMnumberDatas_Vec = cell2mat(AllAreaSess_SVMunitnums(NonEmptyInds));

AllSessBehav_choiceDiff_Vec = cell2mat(Areawise_BehavChoiceDiff(NonEmptyInds));


%% population prediction corss correlation analysis

AllAreaSess_CCmaxlag = squeeze(Areawise_PopuPredCC(:,:,1));
AllAreaSess_CCmaxCoef = squeeze(Areawise_PopuPredCC(:,:,2));

NonEmptyInds = find(cellfun(@(x) ~isempty(x),AllAreaSess_CCmaxlag));
[row,AreaInds] = ind2sub([NumUsedSess,NumAllTargetAreas],NonEmptyInds);

% AllCC_maxlags = cell2mat(AllAreaSess_CCmaxlag(NonEmptyInds));
% AllCC_maxValues = cell2mat(AllAreaSess_CCmaxCoef(NonEmptyInds));
% SigCoefInds = AllCC_maxValues(:,1) > AllCC_maxValues(:,2);

%% Correlation peak lag plots
% plot(AreaInds, AllCC_maxlags,'ko')
AreaLagAvgs = zeros(NumAllTargetAreas,3);
AreaSigLagAvgs = zeros(NumAllTargetAreas,3);
IsAreaAllEmpty = false(NumAllTargetAreas,1);
IsArea_SigCCAllEmpty = false(NumAllTargetAreas,1);
for cArea = 1 : NumAllTargetAreas
    cA_lagsAll = cell2mat(AllAreaSess_CCmaxlag(:,cArea));
    if isempty(cA_lagsAll)
        AreaLagAvgs(cArea,:) = nan(1,3);
        IsAreaAllEmpty(cArea) = true;
    elseif length(cA_lagsAll) < 3
        AreaLagAvgs(cArea,:) = [mean(cA_lagsAll),0,numel(cA_lagsAll)];
    else
        AreaLagAvgs(cArea,:) = [mean(cA_lagsAll), std(cA_lagsAll)/sqrt(numel(cA_lagsAll)), numel(cA_lagsAll)];
    end
    
    cA_CCvalueAll = cell2mat(AllAreaSess_CCmaxCoef(:,cArea));
    if isempty(cA_CCvalueAll)
        AreaSigLagAvgs(cArea,:) = nan(1,3);
        IsArea_SigCCAllEmpty(cArea) = true;
    else
        cA_SigInds = cA_CCvalueAll(:,2) > cA_CCvalueAll(:,1);
        cA_CCSiglagAll = cA_lagsAll(cA_SigInds);
        if isempty(cA_CCSiglagAll)
            AreaSigLagAvgs(cArea,:) = nan(1,3);
            IsArea_SigCCAllEmpty(cArea) = true;
        elseif size(cA_CCSiglagAll,1) < 3
            AreaSigLagAvgs(cArea,:) = [mean(cA_CCSiglagAll),0,numel(cA_CCSiglagAll)];
        else
            AreaSigLagAvgs(cArea,:) = [mean(cA_CCSiglagAll), std(cA_CCSiglagAll)/sqrt(numel(cA_CCSiglagAll)), numel(cA_CCSiglagAll)];
        end
    end

end

UsedAreaDatas = AreaLagAvgs(~IsAreaAllEmpty,:);
UsedAreaNames = BrainAreasStr(~IsAreaAllEmpty);
NumUsedAreas = length(UsedAreaNames);

UsedAreaDatas_sig = AreaLagAvgs(~IsArea_SigCCAllEmpty,:);
UsedAreaNames_sig = BrainAreasStr(~IsArea_SigCCAllEmpty);
NumUsedAreas_sig = length(UsedAreaNames_sig);


[SortLagValues, SortInds] = sort(UsedAreaDatas(:,1),'descend');
SEMValues = UsedAreaDatas(SortInds,2);
AreaNums = UsedAreaDatas(SortInds,3);

AreaNames = UsedAreaNames(SortInds);

h5f = figure('position',[100 100 880 540]);
subplot(121)
hold on
errorbar(SortLagValues, (1:NumUsedAreas)', SEMValues,'horizontal', 'ko', 'linewidth',1.4);
xscales = get(gca,'xlim');
text((xscales(2)+10)*ones(NumUsedAreas,1), 1:NumUsedAreas, cellstr(num2str(AreaNums(:),'%d')),'Color','m',...
    'FontSize',8);
set(gca,'xlim',[xscales(1) xscales(2)+12])
set(gca,'ytick',1:NumUsedAreas,'yticklabel',AreaNames(:));
xlabel('Peak lags');

[SortLagValues_sig, SortInds_sig] = sort(UsedAreaDatas_sig(:,1),'descend');
SEMValues_sig = UsedAreaDatas_sig(SortInds_sig,2);
AreaNums_sig = UsedAreaDatas_sig(SortInds_sig,3);

AreaNames_sig = UsedAreaNames_sig(SortInds_sig);

subplot(122)
hold on
errorbar(SortLagValues_sig, (1:NumUsedAreas_sig)', SEMValues_sig,'horizontal', 'ko', 'linewidth',1.4);
xscales = get(gca,'xlim');
text((xscales(2)+10)*ones(NumUsedAreas_sig,1), 1:NumUsedAreas_sig, cellstr(num2str(AreaNums_sig(:),'%d')),'Color','m',...
    'FontSize',8);
set(gca,'xlim',[xscales(1) xscales(2)+12])
set(gca,'ytick',1:NumUsedAreas_sig,'yticklabel',AreaNames_sig(:));
xlabel('Peak lags');
title('Sig coef session lags')
%%
saveName = fullfile(sumfigsavefolder,'Areawise Crosscoef peakcoef lag plot');
saveas(h5f,saveName);
saveas(h5f,saveName,'png');






