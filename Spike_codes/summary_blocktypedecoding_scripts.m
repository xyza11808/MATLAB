cclr

AllSessFolderPathfile = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\processed_ksfolder_paths_nAdd.xlsx';
% AllSessFolderPathfile = 'K:\Documents\me\projects\NP_reversaltask\processed_ksfolder_paths_nAdd.xlsx';

BrainAreasStrC = readcell(AllSessFolderPathfile,'Range','B:B',...
        'Sheet',1);
BrainAreasStrCC = BrainAreasStrC(2:end);
% BrainAreasStrCCC = cellfun(@(x) x,BrainAreasStrCC,'UniformOutput',false);
EmptyInds = cellfun(@(x) isempty(x) ||any( ismissing(x)),BrainAreasStrCC);
BrainAreasStr = [BrainAreasStrCC(~EmptyInds)]; %;{'Others'}

%%
SessionFoldersC = readcell(AllSessFolderPathfile,'Range','A:A',...
        'Sheet',1);
SessionFolders = SessionFoldersC(2:end);
NumUsedSess = length(SessionFolders);
NumAllTargetAreas = length(BrainAreasStr);

Areawise_sessDecPerf = cell(NumUsedSess,NumAllTargetAreas,3);
Areawise_UnitAUC = cell(NumUsedSess,NumAllTargetAreas,2);
Areawise_PopuPredCC = cell(NumUsedSess,NumAllTargetAreas,2);
Areawise_PopuSVMCC = cell(NumUsedSess,NumAllTargetAreas,2);
Areawise_popuSVMpredInfo = cell(NumUsedSess,NumAllTargetAreas,3);
Areawise_BehavChoiceDiff = cell(NumUsedSess,NumAllTargetAreas);
for cS = 1 :  NumUsedSess
%     cSessPath = SessionFolders{cS};
%     cSessPath = strrep(SessionFolders{cS},'F:','I:\ksOutput_backup');
    cSessPath = strrep(SessionFolders{cS},'F:','E:\NPCCGs');
    
    SessblocktypeDecfile = fullfile(cSessPath,'ks2_5','BaselinePredofBlocktype','PopudecodingDatas.mat');
    SessUnitAUCfile = fullfile(cSessPath,'ks2_5','BaselinePredofBlocktype','SingleUnitAUC.mat');
    behavFilePath = fullfile(cSessPath,'ks2_5','BehavSwitchData.mat');
    
    SessBT_sVMScorefile = fullfile(cSessPath,'ks2_5','BaselinePredofBlocktypeSVM','PopudecodingDatas.mat');
%     UnitAreafile = fullfile(cSessPath,'ks2_5','SessAreaIndexData.mat');
    
    SessblocktypeDecDataStrc = load(SessblocktypeDecfile,'ExistAreas_Names','SVMDecodingAccuracy','logRegressorProbofBlock');
    
    SessBT_sVMScoreStrc = load(SessBT_sVMScorefile, 'ExistAreas_Names', 'SVMSCoreProbofBlock', 'AreaPredInfo');
    
    SessUnitAUCStrc = load(SessUnitAUCfile,'AUCValuesAll');
    try
        BehavBlockchoiceDiff = load(behavFilePath,'H2L_choiceprob_diff');
    catch
        behavfilepath = fullfile(cSessPath,'ks2_5','NPClassHandleSaved.mat');
        SavePlotFolder = fullfile(cSessPath,'ks2_5');
        behavSwitchplot_script;
        clearvars behavfilepath SavePlotFolder behavResults BlockSectionInfo
        BehavBlockchoiceDiff = load(behavFilePath,'H2L_choiceprob_diff');
    end
%     UnitAreaStrc = load(UnitAreafile);
    SessAreaNames = SessblocktypeDecDataStrc.ExistAreas_Names;
    SessAreaNames(strcmpi(SessAreaNames,'Others')) = [];
    NumAreas = length(SessAreaNames);
    
    if NumAreas < 1
        warning('There is no target units within following folder:\n %s \n ##################\n',cSessPath);
        continue;
    end
    
    for cAreaInds = 1 : NumAreas
        
        cAreaStr = SessAreaNames{cAreaInds};
        
        cAreaSVMperf = SessblocktypeDecDataStrc.SVMDecodingAccuracy{cAreaInds,1};
        cAreaSVMShufthres = prctile(SessblocktypeDecDataStrc.SVMDecodingAccuracy{cAreaInds,2},95);
        cAreaUnitInds = SessblocktypeDecDataStrc.SVMDecodingAccuracy{cAreaInds,4};
        
        AreaMatchInds = matches(BrainAreasStr,cAreaStr,'IgnoreCase',true);
        Areawise_sessDecPerf(cS,AreaMatchInds,:) = {cAreaSVMperf, cAreaSVMShufthres, numel(cAreaUnitInds)}; % realperf, shufthres, observation numbers
        
        % set AUC values
        Areawise_UnitAUC(cS,AreaMatchInds,1) = {SessUnitAUCStrc.AUCValuesAll(cAreaUnitInds,1)};
        Areawise_UnitAUC(cS,AreaMatchInds,2) = {SessUnitAUCStrc.AUCValuesAll(cAreaUnitInds,3)};
        
        Areawise_popuSVMpredInfo(cS,AreaMatchInds,:) = {SessBT_sVMScoreStrc.AreaPredInfo{cAreaInds,1},...
            SessBT_sVMScoreStrc.AreaPredInfo{cAreaInds,2},...
            numel(cAreaUnitInds)};
        
        Areawise_BehavChoiceDiff(cS,AreaMatchInds) = {BehavBlockchoiceDiff.H2L_choiceprob_diff};
        if ~isempty(SessblocktypeDecDataStrc.logRegressorProbofBlock{cAreaInds,5})
            cAreaCCData = SessblocktypeDecDataStrc.logRegressorProbofBlock{cAreaInds,5};
            cAreaCC_values = smooth(cAreaCCData{1},5);
            cAreaCC_lags = cAreaCCData{2};
            cAreaCC_CoefThres = cAreaCCData{3}(1);
            [MaxValue, MaxInds] = max(cAreaCC_values);
            MaxValue_lags = cAreaCC_lags(MaxInds);
        
            Areawise_PopuPredCC(cS,AreaMatchInds,1) = {MaxValue_lags};
            Areawise_PopuPredCC(cS,AreaMatchInds,2) = {[MaxValue, cAreaCC_CoefThres]};
        end
        
        if ~isempty(SessBT_sVMScoreStrc.SVMSCoreProbofBlock{cAreaInds,5})
            cAreaSVMScoreCC = SessBT_sVMScoreStrc.SVMSCoreProbofBlock{cAreaInds,5};
            cASVMCC_values = smooth(cAreaSVMScoreCC{1},5);
            cASVMCC_lags = cAreaSVMScoreCC{2};
            cASVMCC_CoefThres = cAreaSVMScoreCC{3}(1);
            [SVMMaxValue, SVMMaxInds] = max(cASVMCC_values);
            SVMMaxValue_lags = cASVMCC_lags(SVMMaxInds);
        
            Areawise_PopuSVMCC(cS,AreaMatchInds,1) = {SVMMaxValue_lags};
            Areawise_PopuSVMCC(cS,AreaMatchInds,2) = {[SVMMaxValue, cASVMCC_CoefThres]};
        end
    end
end

%% summary figure plots saved position
sumfigsavefolder = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\summaryDatas\blocktype_baseline_encoding';
% sumfigsavefolder = 'K:\Documents\me\projects\NP_reversaltask\summaryDatas\blocktype_baseline_SVMpred';
if ~isfolder(sumfigsavefolder)
    mkdir(sumfigsavefolder);
end

%%
Areawise_sessDecPerfRaw = Areawise_sessDecPerf;
% Areawise_sessDecPerf(:,end,:) = [];
AllAreaSess_SVMperfs = (Areawise_sessDecPerf(:,:,1));
AllAreaSess_SVMThres = (Areawise_sessDecPerf(:,:,2));
AllAreaSess_SVMunitnums = (Areawise_sessDecPerf(:,:,3));

NonEmptyInds = find(cellfun(@(x) ~isempty(x),AllAreaSess_SVMperfs));
[row,AreaInds] = ind2sub([NumUsedSess,NumAllTargetAreas-1],NonEmptyInds);

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
set(gca,'xlim',[0 NumAllTargetAreas],'xtick',1:NumAllTargetAreas-1,...
    'xticklabel',BrainAreasStr(1:end-1));
grid on
xlabel('Brain areas');
ylabel('Unit Numbers');
zlabel('SVMperef');
view(gca,11,50);
title('SVM decoding perf')
%%
saveas(hf,fullfile(sumfigsavefolder,'SVMperf 3d plot save'));
saveas(hf,fullfile(sumfigsavefolder,'SVMperf 3d plot save'),'png');

%% anova analysis 
tbl = table(AllSVMperfDatas_Vec,AreaInds,AllSVMnumberDatas_Vec,...
                'VariableNames',{'SVMPerf','Areas','UnitNumber'});
tbl.Areas = categorical(tbl.Areas);

mmdl = fitlm(tbl,'SVMPerf ~ Areas+UnitNumber+Areas:UnitNumber');
anovaTable = anova(mmdl);
Areawise_sessDecPerf= Areawise_sessDecPerfRaw;
save(fullfile(sumfigsavefolder,'SVM_accuracyData.mat'),'anovaTable','Areawise_sessDecPerf','BrainAreasStr',...
    'Areawise_UnitAUC', 'Areawise_PopuPredCC', 'Areawise_PopuSVMCC',...
    'Areawise_popuSVMpredInfo', 'Areawise_BehavChoiceDiff','-v7.3')

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
AUCFigSavePath = fullfile(sumfigsavefolder,'Area_AUCDistribution');
if isfolder(AUCFigSavePath)
    rmdir(AUCFigSavePath,'s');
end
mkdir(AUCFigSavePath);

AUCedges = 0:0.05:1;
AUCcent = AUCedges(1:end-1)+0.025;
AreaWiseAUCs = cell(NumAllTargetAreas, 4);
for cArea = 1 : NumAllTargetAreas
    cArea_realAUC = cell2mat(RealAUCs(:,cArea));
    cArea_AUCthres = cell2mat(AUCThres(:,cArea));
    if isempty(cArea_realAUC)
        continue;
    end
    SigAUCvalues = cArea_realAUC(cArea_realAUC > cArea_AUCthres);
    cA_SessNum = sum(~cellfun(@isempty,RealAUCs(:,cArea)));
    AreaWiseAUCs(cArea,1:2) = {cArea_realAUC, SigAUCvalues};
    AreaWiseAUCs(cArea,4) = {cA_SessNum};
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
    
    
    savename = fullfile(AUCFigSavePath,sprintf('BrainRegion_unitAUCdis_%s',BrainAreasStr{cArea}));
    saveas(h3f,savename);
    saveas(h3f,savename,'png');
    close(h3f);
    
end
AreaWiseAUCs(:,3) = BrainAreasStr;
%%
sumDatasaveName = fullfile(sumfigsavefolder,'SummarizedBlocktypedecodingData.mat');
save(sumDatasaveName,'Areawise_UnitAUC','Areawise_sessDecPerf',...
    'BrainAreasStr','SessionFolders','AreaWiseAUCs','-v7.3')
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
AreaPopuSVMPerf = zeros(NumAllTargetAreas,6);
IsAreaAllEmpty = false(NumAllTargetAreas,1);
IsArea_SigCCAllEmpty = false(NumAllTargetAreas,1);
IsAreaSVMPerfEmpty = false(NumAllTargetAreas,1);
for cArea = 1 : NumAllTargetAreas
    cA_lagsAll = cell2mat(AllAreaSess_CCmaxlag(:,cArea));
    cA_SVMPerfReal = cat(1,AllAreaSess_SVMperfs{:,cArea});
    cA_SVMPerfShuf = cat(1,AllAreaSess_SVMThres{:,cArea});
    
    if isempty(cA_SVMPerfReal)
        IsAreaSVMPerfEmpty(cArea) = true;
    elseif numel(cA_SVMPerfReal) <=3
        AreaPopuSVMPerf(cArea,:) = [mean(cA_SVMPerfReal),0,numel(cA_SVMPerfReal),...
            mean(cA_SVMPerfShuf),0,numel(cA_SVMPerfShuf)];
    else
        AreaPopuSVMPerf(cArea,:) = [mean(cA_SVMPerfReal),std(cA_SVMPerfReal)/sqrt(numel(cA_SVMPerfReal)),numel(cA_SVMPerfReal),...
            mean(cA_SVMPerfShuf),std(cA_SVMPerfShuf)/sqrt(numel(cA_SVMPerfShuf)),numel(cA_SVMPerfShuf)];
    end
    
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

UsedAreaDatasNE = AreaLagAvgs(~IsAreaAllEmpty,:);
UsedAreaNamesNE = BrainAreasStr(~IsAreaAllEmpty);
UsedAreaSVMPerfNE = AreaPopuSVMPerf(~IsAreaAllEmpty,:);
% sessions for each area should not be less than 3
SessNumThresInds = UsedAreaDatasNE(:,3) > 2;
UsedAreaDatas = UsedAreaDatasNE(SessNumThresInds,:);
UsedAreaNames = UsedAreaNamesNE(SessNumThresInds);
UsedAreaSVMPerf = UsedAreaSVMPerfNE(SessNumThresInds,:);

NumUsedAreas = length(UsedAreaNames);

UsedAreaDatas_sigNE = AreaLagAvgs(~IsArea_SigCCAllEmpty,:);
UsedAreaNames_sigNE = BrainAreasStr(~IsArea_SigCCAllEmpty);
UsedSVMPerf_sigNE = AreaPopuSVMPerf(~IsArea_SigCCAllEmpty,:);

SigSessnumThresInds = UsedAreaDatas_sigNE(:,3) > 2;
UsedAreaDatas_sig = UsedAreaDatas_sigNE(SigSessnumThresInds,:);
UsedAreaNames_sig = UsedAreaNames_sigNE(SigSessnumThresInds);
UsedSVMPerf_sig = UsedSVMPerf_sigNE(SigSessnumThresInds,:);

NumUsedAreas_sig = length(UsedAreaNames_sig);

[SortLagValues, SortInds] = sort(UsedAreaDatas(:,1),'descend');
SEMValues = UsedAreaDatas(SortInds,2);
AreaNums = UsedAreaDatas(SortInds,3);
SortAreaAccu = UsedAreaSVMPerf(SortInds,1);

AreaNames = UsedAreaNames(SortInds);

h5f = figure('position',[100 100 880 840]);
subplot(121)
hold on
errorbar(SortLagValues, (1:NumUsedAreas)', SEMValues,'horizontal', 'k.', 'linewidth',1.4);
scatter(SortLagValues, (1:NumUsedAreas)',45,SortAreaAccu,'filled');
colormap cool
xscales = get(gca,'xlim');
text((xscales(2)+10)*ones(NumUsedAreas,1), 1:NumUsedAreas, cellstr(num2str(AreaNums(:),'%d')),'Color','m',...
    'FontSize',8);
set(gca,'xlim',[xscales(1) xscales(2)+12])
set(gca,'ytick',1:NumUsedAreas,'yticklabel',AreaNames(:));
xlabel('Peak lags');
title('logistic regressor crosscoef peaklag distribution')

[SortLagValues_sig, SortInds_sig] = sort(UsedAreaDatas_sig(:,1),'descend');
SEMValues_sig = UsedAreaDatas_sig(SortInds_sig,2);
AreaNums_sig = UsedAreaDatas_sig(SortInds_sig,3);
SortAreaAccu_sig = UsedSVMPerf_sig(SortInds_sig,1);
AreaNames_sig = UsedAreaNames_sig(SortInds_sig);

subplot(122)
hold on
errorbar(SortLagValues_sig, (1:NumUsedAreas_sig)', SEMValues_sig,'horizontal', 'k.', 'linewidth',1.4,'Marker','none');
scatter(SortLagValues_sig, (1:NumUsedAreas_sig)',45,SortAreaAccu_sig,'filled');

colormap cool
hbar = colorbar;
set(get(hbar,'title'),'String','SVM accuracy')
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

%%
% AUC value sort and plots
NumAreas = size(AreaWiseAUCs,1);
AreaAvgAUCs = nan(NumAreas,6);
for cA = 1 : NumAreas
    if isempty(AreaWiseAUCs{cA,1}) || length(AreaWiseAUCs{cA,1}) < 5 || AreaWiseAUCs{cA,4} < 3
        continue;
    else
        cA_AllAUC = AreaWiseAUCs{cA,1};
        AreaAvgAUCs(cA,1:3) = [mean(cA_AllAUC), std(cA_AllAUC)/sqrt(numel(cA_AllAUC)),numel(cA_AllAUC)];
        
        if isempty(AreaWiseAUCs{cA,2}) || length(AreaWiseAUCs{cA,2}) < 3
            continue;
        else
            cA_SigAUCs = AreaWiseAUCs{cA,2};
            AreaAvgAUCs(cA,4:6) = [mean(cA_SigAUCs), std(cA_SigAUCs)/sqrt(numel(cA_SigAUCs)),numel(cA_SigAUCs)];
        end
    end
end

h6f = figure('position',[100 100 900 760]);
ax1 = subplot(121);
hold on
ValidAreaInds = ~isnan(AreaAvgAUCs(:,1));
ValidAreas_AllStrs = BrainAreasStr(ValidAreaInds);
ValidAreas_AllAUC = AreaAvgAUCs(ValidAreaInds,1);
ValidAreas_AllAUC_SEM = AreaAvgAUCs(ValidAreaInds,2);
ValidAreas_AllAUC_nums = AreaAvgAUCs(ValidAreaInds,3);
ValidAreas_SessNums = cat(1,AreaWiseAUCs{ValidAreaInds,4});

[AllAUCSort, AllSortinds] = sort(ValidAreas_AllAUC);
AllAUCSEMs = ValidAreas_AllAUC_SEM(AllSortinds);
AllAUCNames = ValidAreas_AllStrs(AllSortinds);
AllAUC_SortNums = ValidAreas_AllAUC_nums(AllSortinds);
Sessnum_sorts = ValidAreas_SessNums(AllSortinds);

Num_UsedAreas = length(AllAUCSort);
errorbar(AllAUCSort, (1:Num_UsedAreas)', AllAUCSEMs,'horizontal', 'ko', 'linewidth',1.4);
xscales = get(ax1,'xlim');
text((xscales(2)+0.05)*ones(Num_UsedAreas,1), 1:Num_UsedAreas, cellstr(num2str(AllAUC_SortNums(:),'%d')),'Color','m',...
    'FontSize',8);
text((xscales(2)+0.07)*ones(Num_UsedAreas,1), 1:Num_UsedAreas, cellstr(num2str(Sessnum_sorts(:),'/ %d')),'Color','b',...
    'FontSize',8);
set(gca,'xlim',[xscales(1) xscales(2)+0.1])
set(gca,'ytick',1:Num_UsedAreas,'yticklabel',AllAUCNames(:));
xlabel('Averaged AUCs');
title('AllAUCAvg session lags')

ax2 = subplot(122);
hold on
ValidAreaInds = ~isnan(AreaAvgAUCs(:,4));
ValidAreas_SigStrs = BrainAreasStr(ValidAreaInds);
ValidAreas_SigAUC = AreaAvgAUCs(ValidAreaInds,4);
ValidAreas_SigAUC_SEM = AreaAvgAUCs(ValidAreaInds,5);
ValidAreas_SigAUC_Nums = AreaAvgAUCs(ValidAreaInds,6);

[SigAUCSort, SigSortinds] = sort(ValidAreas_SigAUC);
SigAUCSEMs = ValidAreas_SigAUC_SEM(SigSortinds);
SigAUCNames = ValidAreas_SigStrs(SigSortinds);
SigAUC_Nums = ValidAreas_SigAUC_Nums(SigSortinds);

Num_SigAreas = length(SigAUCSort);
errorbar(SigAUCSort, (1:Num_SigAreas)', SigAUCSEMs,'horizontal', 'ko', 'linewidth',1.4);
xscales = get(ax2,'xlim');
text((xscales(2)+0.05)*ones(Num_SigAreas,1), 1:Num_SigAreas, cellstr(num2str(SigAUC_Nums(:),'%d')),'Color','m',...
    'FontSize',8);
set(gca,'xlim',[xscales(1) xscales(2)+0.1])
set(gca,'ytick',1:Num_SigAreas,'yticklabel',SigAUCNames(:));
xlabel('Averaged AUCs');
title('Sig AUCAvg session lags')


%%
saveName = fullfile(sumfigsavefolder,'Areawise Averaged AUC sorted plot');
saveas(h6f,saveName);
saveas(h6f,saveName,'png');

%% Areawise SVM score cross correlation analysis plot


AllAreaSess_CCmaxlag = squeeze(Areawise_PopuSVMCC(:,:,1));
AllAreaSess_CCmaxCoef = squeeze(Areawise_PopuSVMCC(:,:,2));

NonEmptyInds = find(cellfun(@(x) ~isempty(x),AllAreaSess_CCmaxlag));
[row,AreaInds] = ind2sub([NumUsedSess,NumAllTargetAreas],NonEmptyInds);

% AllCC_maxlags = cell2mat(AllAreaSess_CCmaxlag(NonEmptyInds));
% AllCC_maxValues = cell2mat(AllAreaSess_CCmaxCoef(NonEmptyInds));
% SigCoefInds = AllCC_maxValues(:,1) > AllCC_maxValues(:,2);

%% Correlation peak lag plots
% plot(AreaInds, AllCC_maxlags,'ko')
AreaLagAvgs = zeros(NumAllTargetAreas,3);
AreaSigLagAvgs = zeros(NumAllTargetAreas,3);
AreaPopuSVMPerf = zeros(NumAllTargetAreas,6);
IsAreaAllEmpty = false(NumAllTargetAreas,1);
IsArea_SigCCAllEmpty = false(NumAllTargetAreas,1);
IsAreaSVMPerfEmpty = false(NumAllTargetAreas,1);
for cArea = 1 : NumAllTargetAreas
    cA_lagsAll = cell2mat(AllAreaSess_CCmaxlag(:,cArea));
    cA_SVMPerfReal = cat(1,AllAreaSess_SVMperfs{:,cArea});
    cA_SVMPerfShuf = cat(1,AllAreaSess_SVMThres{:,cArea});
    
    if isempty(cA_SVMPerfReal)
        IsAreaSVMPerfEmpty(cArea) = true;
    elseif numel(cA_SVMPerfReal) <=3
        AreaPopuSVMPerf(cArea,:) = [mean(cA_SVMPerfReal),0,numel(cA_SVMPerfReal),...
            mean(cA_SVMPerfShuf),0,numel(cA_SVMPerfShuf)];
    else
        AreaPopuSVMPerf(cArea,:) = [mean(cA_SVMPerfReal),std(cA_SVMPerfReal)/sqrt(numel(cA_SVMPerfReal)),numel(cA_SVMPerfReal),...
            mean(cA_SVMPerfShuf),std(cA_SVMPerfShuf)/sqrt(numel(cA_SVMPerfShuf)),numel(cA_SVMPerfShuf)];
    end
    
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

UsedAreaDatasNE = AreaLagAvgs(~IsAreaAllEmpty,:);
UsedAreaNamesNE = BrainAreasStr(~IsAreaAllEmpty);
UsedAreaSVMPerfNE = AreaPopuSVMPerf(~IsAreaAllEmpty,:);
% sessions for each area should not be less than 3
SessNumThresInds = UsedAreaDatasNE(:,3) > 2;
UsedAreaDatas = UsedAreaDatasNE(SessNumThresInds,:);
UsedAreaNames = UsedAreaNamesNE(SessNumThresInds);
UsedAreaSVMPerf = UsedAreaSVMPerfNE(SessNumThresInds,:);

NumUsedAreas = length(UsedAreaNames);

UsedAreaDatas_sigNE = AreaLagAvgs(~IsArea_SigCCAllEmpty,:);
UsedAreaNames_sigNE = BrainAreasStr(~IsArea_SigCCAllEmpty);
UsedSVMPerf_sigNE = AreaPopuSVMPerf(~IsArea_SigCCAllEmpty,:);

SigSessnumThresInds = UsedAreaDatas_sigNE(:,3) > 2;
UsedAreaDatas_sig = UsedAreaDatas_sigNE(SigSessnumThresInds,:);
UsedAreaNames_sig = UsedAreaNames_sigNE(SigSessnumThresInds);
UsedSVMPerf_sig = UsedSVMPerf_sigNE(SigSessnumThresInds,:);

NumUsedAreas_sig = length(UsedAreaNames_sig);

[SortLagValues, SortInds] = sort(UsedAreaDatas(:,1),'descend');
SEMValues = UsedAreaDatas(SortInds,2);
AreaNums = UsedAreaDatas(SortInds,3);
SortAreaAccu = UsedAreaSVMPerf(SortInds,1);

AreaNames = UsedAreaNames(SortInds);

h7f = figure('position',[100 100 880 840]);
subplot(121)
hold on
errorbar(SortLagValues, (1:NumUsedAreas)', SEMValues,'horizontal', 'k.', 'linewidth',1.4);
scatter(SortLagValues, (1:NumUsedAreas)',45,SortAreaAccu,'filled');
colormap cool
xscales = get(gca,'xlim');
text((xscales(2)+10)*ones(NumUsedAreas,1), 1:NumUsedAreas, cellstr(num2str(AreaNums(:),'%d')),'Color','m',...
    'FontSize',8);
set(gca,'xlim',[xscales(1) xscales(2)+12])
set(gca,'ytick',1:NumUsedAreas,'yticklabel',AreaNames(:));
xlabel('Peak lags');
title('SVM regressor crosscoef peaklag distribution')

[SortLagValues_sig, SortInds_sig] = sort(UsedAreaDatas_sig(:,1),'descend');
SEMValues_sig = UsedAreaDatas_sig(SortInds_sig,2);
AreaNums_sig = UsedAreaDatas_sig(SortInds_sig,3);
SortAreaAccu_sig = UsedSVMPerf_sig(SortInds_sig,1);

AreaNames_sig = UsedAreaNames_sig(SortInds_sig);

subplot(122)
hold on
errorbar(SortLagValues_sig, (1:NumUsedAreas_sig)', SEMValues_sig,'horizontal', 'k.', 'linewidth',1.4,'Marker','none');
scatter(SortLagValues_sig, (1:NumUsedAreas_sig)',45,SortAreaAccu_sig,'filled');

colormap cool
hbar = colorbar;
set(get(hbar,'title'),'String','SVM accuracy')
xscales = get(gca,'xlim');
text((xscales(2)+10)*ones(NumUsedAreas_sig,1), 1:NumUsedAreas_sig, cellstr(num2str(AreaNums_sig(:),'%d')),'Color','m',...
    'FontSize',8);
set(gca,'xlim',[xscales(1) xscales(2)+12])
set(gca,'ytick',1:NumUsedAreas_sig,'yticklabel',AreaNames_sig(:));
xlabel('Peak lags');
title('Sig coef session lags')
%%
saveName = fullfile(sumfigsavefolder,'Areawise SVMScore Crosscoef peakcoef lag plot');
saveas(h7f,saveName);
saveas(h7f,saveName,'png');

%% SVM prediction blocktypes mutual info calculation analysis

AllAreaSess_SVMpredMutInfo = squeeze(Areawise_popuSVMpredInfo(:,:,1));
AllAreaSess_SVMSampleInfo = squeeze(Areawise_popuSVMpredInfo(:,:,2));
AllAreaSess_SVMUnitNum = squeeze(Areawise_popuSVMpredInfo(:,:,3));
% AllAreaSess_SVMAccu = 

NonEmptyInds = find(cellfun(@(x) ~isempty(x),AllAreaSess_SVMpredMutInfo));
[row,AreaInds] = ind2sub([NumUsedSess,NumAllTargetAreas],NonEmptyInds);

UsedAreaSess_SVMpredMutInfoVec = cell2mat(AllAreaSess_SVMpredMutInfo(NonEmptyInds));
UsedAreaSess_SVMUnitVec = cell2mat(AllAreaSess_SVMUnitNum(NonEmptyInds));
UsedAreaSess_SVMAccu = cat(1,AllAreaSess_SVMperfs{NonEmptyInds});
UsedAreaSess_SVMSampleInfoVec = (AllAreaSess_SVMSampleInfo(NonEmptyInds));

IsAreaEmpty = zeros(NumAllTargetAreas,1);
AreaMutInfo_summary = cell(NumAllTargetAreas,1);
AreaMutInfoAvg_summary = nan(NumAllTargetAreas,4);
for cA = 1 : NumAllTargetAreas
    cA_SesssInds = AreaInds == cA;
    if sum(cA_SesssInds)
        cA_SessDatas = UsedAreaSess_SVMpredMutInfoVec(cA_SesssInds);
        cA_SessSVMAccu = UsedAreaSess_SVMAccu(cA_SesssInds);
        AreaMutInfo_summary(cA,1) = {cA_SessDatas};
        if numel(cA_SessDatas) > 3
            AreaMutInfoAvg_summary(cA,:) = [mean(cA_SessDatas), std(cA_SessDatas)/sqrt(numel(cA_SessDatas)),...
                numel(cA_SessDatas),mean(cA_SessSVMAccu)];
            
        else
            AreaMutInfoAvg_summary(cA,1) = mean(cA_SessDatas);
            AreaMutInfoAvg_summary(cA,4) = mean(cA_SessSVMAccu);
        end
    else
        IsAreaEmpty(cA) = 1;
    end
end
%%
NE_AreaInds = ~IsAreaEmpty & ~isnan(AreaMutInfoAvg_summary(:,2));
NE_Areas = BrainAreasStr(NE_AreaInds);
AreaMutInfo_summary_NE = AreaMutInfoAvg_summary(NE_AreaInds,:);

[SortAreaMutInfo_summary_NE, SSortInds] = sort(AreaMutInfo_summary_NE(:,1));
SortAreaMutInfo_SEM = AreaMutInfo_summary_NE(SSortInds,2);
AreaNums = AreaMutInfo_summary_NE(SSortInds,3);
SortAreaAccu = AreaMutInfo_summary_NE(SSortInds,4);
SortAreaStrs = NE_Areas(SSortInds);
NumberAreas = numel(SSortInds);

h8f = figure('position',[100 100 420 840]);

hold on
errorbar(SortAreaMutInfo_summary_NE, (1:NumberAreas)', SortAreaMutInfo_SEM,'horizontal', 'ko', 'linewidth',1.4);
scatter(SortAreaMutInfo_summary_NE, (1:NumberAreas)',45,SortAreaAccu,'filled');
colormap cool
hbar = colorbar;
set(get(hbar,'title'),'String','SVM accuracy')

xscales = get(gca,'xlim');
text((xscales(2)+0.02)*ones(NumberAreas,1), 1:NumberAreas, cellstr(num2str(AreaNums(:),'%d')),'Color','m',...
    'FontSize',8);
set(gca,'xlim',[xscales(1) xscales(2)+0.05],'ylim',[0 NumberAreas+1])
set(gca,'ytick',1:NumberAreas,'yticklabel',SortAreaStrs(:));
xlabel('Popu Mutinfo');
title('SVM pred mutinfo areawise distribution')

%%
saveName = fullfile(sumfigsavefolder,'Areawise mutinfo sorted plot');
saveas(h8f,saveName);
saveas(h8f,saveName,'png');

