cclr
ParantAreaListFile = fullfile('K:\Documents\me\projects\NP_reversaltask\Parent_areas_list.xlsx');
% ParantAreaListFile = fullfile('E:\sycDatas\Documents\me\projects\NP_reversaltask\Parent_areas_list.xlsx');

ParentRegionStrCell = readcell(ParantAreaListFile,'Range','A:A',...
    'Sheet','Sheet1');
IsCellStrInds = cellfun(@(x) ischar(x),ParentRegionStrCell);
IsCellStrInds(1) = false;
AllAreaStrsIndex = find(IsCellStrInds)-1;
AllParentAreaStrs = ParentRegionStrCell(AllAreaStrsIndex+1);

ChildRegStrCell = readcell(ParantAreaListFile,'Range','B:B',...
    'Sheet','Sheet1');
ChildRegUsedStrs = ChildRegStrCell(2:end);

NumParentAreas = length(AllParentAreaStrs);
NumChildAreas = length(ChildRegUsedStrs);
Child2ParentInds = zeros(NumChildAreas,1);
Child2ParentInds(AllAreaStrsIndex) = 1;
Child2ParentMapInds = cumsum(Child2ParentInds);

% used area strs will be: Child2ParentMapInds ChildRegUsedStrs
% AllParentAreaStrs
%%
SelectiveAreaDatafile = 'K:\Documents\me\projects\NP_reversaltask\summaryDatas\RegressionSummary\UnitEVscatterPlot\NoStim\SigUnit_EVsummaryData.mat';
% SelectiveAreaDatafile = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\summaryDatas\RegressionSummary\UnitEVscatterPlot\NoStim\SigUnit_EVsummaryData.mat';
AreaSelectEVStrc = load(SelectiveAreaDatafile,'AreaSigUnit_TypeRespEV','BrainAreasStr','Area_RespMtxAll');

%%

NumBrainAreas = length(AreaSelectEVStrc.BrainAreasStr);
UsedArea2ParentMap = cell(NumBrainAreas,5); % AreaSessNum, ChildAreaStr, ChildArea2ParentIndex, AreaRespFrac, AreaRespTypeEVs
IsAreaUsed = false(NumBrainAreas,1);
for cStrInds = 1 : NumBrainAreas
    
    if ~AreaSelectEVStrc.AreaSigUnit_TypeRespEV{cStrInds,4}
        continue;
    end
    cAreaStr = AreaSelectEVStrc.BrainAreasStr{cStrInds};
    
    TF = matches(ChildRegUsedStrs,cAreaStr,'IgnoreCase',true);
    if any(TF)
        AllenRegionInds = find(TF);
        if length(AllenRegionInds) > 1
            fprintf('Multiple fits exist for area <%s>.\n',cAreaStr);
            continue;
        end
        
        UsedArea2ParentMap(cStrInds,:) = {AreaSelectEVStrc.Area_RespMtxAll{cStrInds,3},ChildRegUsedStrs{TF},...
            Child2ParentMapInds(TF),AreaSelectEVStrc.Area_RespMtxAll{cStrInds,4},AreaSelectEVStrc.AreaSigUnit_TypeRespEV(cStrInds,:)};
        IsAreaUsed(cStrInds) = true;
    end
end

%% find existed Areas and then recalculate the values

FinalUsedArea2ParentCell = UsedArea2ParentMap(IsAreaUsed,:);
NumFinalUsedArea = size(FinalUsedArea2ParentCell,1);

FinalAreaDatas = cell(NumFinalUsedArea,5); % AreaStrs,ParentAreaIndex,SessNums,RespFracs,RespEVs
for cA = 1 : NumFinalUsedArea
    cA_respFracs = FinalUsedArea2ParentCell{cA,4};
    cA_unitNums = size(cA_respFracs,1);
    cA_respFracData = mean(cA_respFracs);
    
    cA_TypeEVs = FinalUsedArea2ParentCell{cA,5};
    TypeEV_summaryAll = zeros(3,3);% each row belongs to each factor type
    for cType = 1 : 3
        cTypeRespEVs = cA_TypeEVs{cType};
        if isempty(cTypeRespEVs)
            TypeEV_summary = [nan,nan,0];
        elseif length(cTypeRespEVs) < 3
            TypeEV_summary = [mean(cTypeRespEVs),nan,length(cTypeRespEVs)];
        else
            TypeEV_summary = [mean(cTypeRespEVs),std(cTypeRespEVs)/sqrt(numel(cTypeRespEVs)),length(cTypeRespEVs)];
        end
        TypeEV_summaryAll(cType,:) = TypeEV_summary;
    end
    
    FinalAreaDatas(cA,:) = {FinalUsedArea2ParentCell{cA,2},FinalUsedArea2ParentCell{cA,3},...
        FinalUsedArea2ParentCell{cA,1},[cA_respFracData,cA_unitNums],TypeEV_summaryAll};
end

AllParentIndex = cat(1,FinalAreaDatas{:,2});
[SortedPIIndex,ParentSortInds] = sort(AllParentIndex);
SortPIAreaDatas = FinalAreaDatas(ParentSortInds,:);

%%
FigSavePath = 'K:\Documents\me\projects\NP_reversaltask\summaryDatas\RegressionSummary\ParentAreaSummary';
% FigSavePath = 'E:\sycDatas\\Documents\me\projects\NP_reversaltask\summaryDatas\RegressionSummary\ParentAreaSummary';
saveDataname = fullfile(FigSavePath,'ParentAreaSumData_NoStim.mat');
save(saveDataname,'UsedArea2ParentMap','IsAreaUsed','AreaSelectEVStrc','Child2ParentMapInds',...
    'ChildRegUsedStrs','AllParentAreaStrs','FinalAreaDatas','-v7.3');

%% fraction bar plots
TypeStrs = {'Blocktype','Stim','Choice'};
BoundIndex = find([1;diff(SortedPIIndex)]); % the index should be continued positive increase values
UsedBoundIndexAll = [BoundIndex;numel(SortedPIIndex)+1];
PIBoundCents = floor((UsedBoundIndexAll(1:end-1)+UsedBoundIndexAll(2:end))/2);

PITypes = unique(SortedPIIndex);
NumPIType = length(PITypes);
BarColors = linspecer(NumPIType,'qualitative');
PIAreaStrs = AllParentAreaStrs(PITypes);

for cTypeInds = 1:3
    
    hf = figure('position',[100 100 680 370]);
    axFrac = subplot(211);
    hold on;
    
    axEvar = subplot(212);
    hold on;
    
    for cPI = 1 : NumPIType
        cPIInds = UsedBoundIndexAll(cPI):UsedBoundIndexAll(cPI+1)-1;
        cPI_CellFracs = SortPIAreaDatas(cPIInds,4);
        cPI_cType_Fracs = cellfun(@(x) x(cTypeInds),cPI_CellFracs)+1e-3;
        bar(axFrac,cPIInds,cPI_cType_Fracs,0.6,'FaceColor',BarColors(cPI,:),'EdgeColor','none');
        
        cPI_CellEvars = SortPIAreaDatas(cPIInds,5);
        cPI_cType_EVars = cellfun(@(x) x(cTypeInds,1),cPI_CellEvars)+1e-3;
        bar(axEvar,cPIInds,cPI_cType_EVars,0.6,'FaceColor',BarColors(cPI,:),'EdgeColor','k');
        SessNums = SortPIAreaDatas(cPIInds,3);
        text(axEvar,cPIInds,cPI_cType_EVars+0.04,SessNums,'Color','m','FontSize',7,'Horizontalalignment','center');
    end
    set(axFrac,'xtick',PIBoundCents,'xticklabel',PIAreaStrs);
    ytickGive = get(axFrac,'ytick');
    yscales = get(axFrac,'ylim');
    set(axFrac,'ytick',ytickGive+1e-3,'yticklabel',ytickGive,'ylim',yscales+[0,1e-3]);
    ylabel(axFrac,'Selective unit fraction');
    title(axFrac,TypeStrs{cTypeInds});
    
    set(axEvar,'xtick',1:numel(SortedPIIndex),'xticklabel',SortPIAreaDatas(:,1));
    ytickGive = get(axEvar,'ytick');
    yscales = get(axEvar,'ylim');
    set(axEvar,'ytick',ytickGive+1e-3,'yticklabel',ytickGive,'ylim',yscales+[0,1e-3]);
    ylabel(axEvar,'Explained Variance');
    % title(axEvar,TypeStrs{cTypeInds});
    
    figSaveName = fullfile(FigSavePath,sprintf('ParentArea RespFrac And EVar plot for %s',TypeStrs{cTypeInds}));
    saveas(hf,figSaveName);
    print(hf,figSaveName,'-dpdf','-bestfit');
    print(hf,figSaveName,'-dpng','-r350');
    close(hf);
    
end


% %%
% TypeStrs = {'Blocktype','Stim','Choice'};
% BoundIndex = find([1;diff(SortedPIIndex)]);
% UsedBoundIndexAll = [BoundIndex;numel(SortedPIIndex)+1];
% PIBoundCents = floor((UsedBoundIndexAll(1:end-1)+UsedBoundIndexAll(2:end))/2);
% 
% PITypes = unique(SortedPIIndex);
% NumPIType = length(PITypes);
% BarColors = linspecer(NumPIType,'qualitative');
% PIAreaStrs = AllParentAreaStrs(PITypes);
% PITypeDatas = cell(numel(PITypes),3,2); % the third dimension is fraction and EVars 
% for cTypeInds = 1:3
%     
%     for cPI = 1 : NumPIType
%         cPIInds = UsedBoundIndexAll(cPI):UsedBoundIndexAll(cPI+1)-1;
%         cPI_CellFracs = SortPIAreaDatas(cPIInds,4);
%         cPI_cType_Fracs = cellfun(@(x) x(cTypeInds),cPI_CellFracs)+1e-3;
%         PITypeDatas(cPI,cTypeInds,1) = {cPI_cType_Fracs};
%         
%         cPI_CellEvars = SortPIAreaDatas(cPIInds,5);
%         cPI_cType_EVars = cellfun(@(x) x(cTypeInds,1),cPI_CellEvars)+1e-3;
%         PITypeDatas(cPI,cTypeInds,2) = {cPI_cType_EVars};
%     end
% end

%% parent anova peaktime and peak value calculation
cclr
% load anova peak analysis data
AnovaDataSumDataPath = 'K:\Documents\me\projects\NP_reversaltask\summaryDatas\anova_analysis_datas2';
% AnovaDataSumDataPath = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\summaryDatas\anova_analysis_datas2';
saveFilePath = fullfile(AnovaDataSumDataPath,'AnovaPeak_sumPlot','AnovaPeakSumData.mat');
AnovaData = load(saveFilePath,'AreaPeakFactor_peakDatasAll','AreaBT_AvgDatasAll','BrainAreasStr');
% AreaBT_AvgDatasAll: the first column is Non-reverse trials, the second
%                     column is Reverse trial
% AreaPeakFactor_peakDatasAll: the first column is choice, the second is
%                               stimulus

% load parent str datas
ParantAreaListFile = fullfile('K:\Documents\me\projects\NP_reversaltask\Parent_areas_list.xlsx');
% ParantAreaListFile = fullfile('E:\sycDatas\Documents\me\projects\NP_reversaltask\Parent_areas_list.xlsx');

ParentRegionStrCell = readcell(ParantAreaListFile,'Range','A:A',...
    'Sheet','Sheet1');
IsCellStrInds = cellfun(@(x) ischar(x),ParentRegionStrCell);
IsCellStrInds(1) = false;
AllAreaStrsIndex = find(IsCellStrInds)-1;
AllParentAreaStrs = ParentRegionStrCell(AllAreaStrsIndex+1);

ChildRegStrCell = readcell(ParantAreaListFile,'Range','B:B',...
    'Sheet','Sheet1');
ChildRegUsedStrs = ChildRegStrCell(2:end);

NumParentAreas = length(AllParentAreaStrs);
NumChildAreas = length(ChildRegUsedStrs);
Child2ParentInds = zeros(NumChildAreas,1);
Child2ParentInds(AllAreaStrsIndex) = 1;
Child2ParentMapInds = cumsum(Child2ParentInds);

% used area strs will be: Child2ParentMapInds ChildRegUsedStrs
% AllParentAreaStrs

%%
AllBrainNames = AnovaData.BrainAreasStr;
NumBrainAreas = length(AllBrainNames);
Area2ParentMapDatas = cell(NumBrainAreas,6); % AreaStr, ParentIndex,StimEVars, ChoiceEVars,NonRevBTs,RevBTs
IsAreaUsed = false(NumBrainAreas,1);
for cStrInds = 1 : NumBrainAreas
    
    if (size(AnovaData.AreaPeakFactor_peakDatasAll{cStrInds,1},1) < 5 || size(AnovaData.AreaBT_AvgDatasAll{cStrInds,1},1) < 3) % if the unit number is to fewer
        continue;
    end
    cAreaStr = AnovaData.BrainAreasStr{cStrInds};
    
    TF = matches(ChildRegUsedStrs,cAreaStr,'IgnoreCase',true);
    if any(TF)
        AllenRegionInds = find(TF);
        if length(AllenRegionInds) > 1
            fprintf('Multiple fits exist for area <%s>.\n',cAreaStr);
            continue;
        end
        
        Area2ParentMapDatas(cStrInds,:) = {cAreaStr,Child2ParentMapInds(TF),...
            AnovaData.AreaPeakFactor_peakDatasAll{cStrInds,2},AnovaData.AreaPeakFactor_peakDatasAll{cStrInds,1},...
            AnovaData.AreaBT_AvgDatasAll{cStrInds,1},AnovaData.AreaBT_AvgDatasAll{cStrInds,2}};
        IsAreaUsed(cStrInds) = true;
    end
end
%%
FigSavePath = 'K:\Documents\me\projects\NP_reversaltask\summaryDatas\RegressionSummary\ParentAreaSummary';
% FigSavePath = 'E:\sycDatas\\Documents\me\projects\NP_reversaltask\summaryDatas\RegressionSummary\ParentAreaSummary';
saveDataname = fullfile(FigSavePath,'ParentAreaAnovaPeakData.mat');
save(saveDataname,'Area2ParentMapDatas','IsAreaUsed','Child2ParentMapInds',...
    'ChildRegUsedStrs','AllParentAreaStrs','AllBrainNames','-v7.3');

%% find existed Areas and then recalculate the values

FinalUsedArea2ParentCell = Area2ParentMapDatas(IsAreaUsed,:);
NumFinalUsedArea = size(FinalUsedArea2ParentCell,1);

AllAreaParentIndex = cat(1,FinalUsedArea2ParentCell{:,2});
[SortedPIIndex,sortInds] = sort(AllAreaParentIndex);
SortUsedArea2ParentCell = FinalUsedArea2ParentCell(sortInds,:);

StimOnsetBin = 149;
winGoesStep = 0.01;

UsedAreaDatasAll = cell(NumFinalUsedArea,2);
UsedAreaAvgDatas = cell(NumFinalUsedArea,2);
for cA = 1 : NumFinalUsedArea
%     cA = 1;
    cA_stimPeakData = SortUsedArea2ParentCell{cA,3};
    cA_stimInitPeakAmp = cellfun(@(x) x(1),cA_stimPeakData(:,1));
    cA_stimInitPeaktime = (cellfun(@(x) x(1),cA_stimPeakData(:,5))-StimOnsetBin)*winGoesStep; % half peak time
    cA_stimInitPeakwidth = cellfun(@(x) x(1),cA_stimPeakData(:,4))*winGoesStep; % half peak time
    
    cA_choicePeakData = SortUsedArea2ParentCell{cA,4};
    cA_choiceInitPeakAmp = cellfun(@(x) x(1),cA_choicePeakData(:,1));
    cA_choiceInitPeaktime = (cellfun(@(x) x(1),cA_choicePeakData(:,5))-StimOnsetBin)*winGoesStep; % half peak time
    cA_choiceInitPeakwidth = cellfun(@(x) x(1),cA_choicePeakData(:,4))*winGoesStep; % half peak time
    
    cA_StimANDChoiceData = {cA_stimInitPeakAmp,cA_stimInitPeaktime,cA_stimInitPeakwidth,...
        cA_choiceInitPeakAmp,cA_choiceInitPeaktime,cA_choiceInitPeakwidth};
    cA_StimANDChoiceAvgs = cellfun(@(x) dataSEMmean(x),cA_StimANDChoiceData,'un',0);
    cA_StimANDChoiceAvgMtx = cat(2,cA_StimANDChoiceAvgs{:});
    
    % Non-RevTrial BTs
    cA_NonRevBTs = SortUsedArea2ParentCell{cA,5};
    cA_NonRevBTAvgs = {cA_NonRevBTs(:,1),cA_NonRevBTs(:,3),cA_NonRevBTs(cA_NonRevBTs(:,1)>cA_NonRevBTs(:,2),1),...
        cA_NonRevBTs(cA_NonRevBTs(:,3)>cA_NonRevBTs(:,4),3)};
    
    % RevTrial BTs
    cA_RevTrBTs = SortUsedArea2ParentCell{cA,6};
    cA_RevTrBTAvgs = {cA_RevTrBTs(:,1),cA_RevTrBTs(:,3),(cA_RevTrBTs(cA_RevTrBTs(:,1)>cA_RevTrBTs(:,2),1)),...
        (cA_RevTrBTs(cA_RevTrBTs(:,3)>cA_RevTrBTs(:,4),3))};
    
    cA_BTDatasAll = [cA_NonRevBTAvgs,cA_RevTrBTAvgs];
    cA_BTDataAvgs = cellfun(@(x) dataSEMmean(x),cA_BTDatasAll,'un',0);
    cA_BTDataAvgMtx = cat(2,cA_BTDataAvgs{:});
    
    UsedAreaDatasAll(cA,:) = {cA_StimANDChoiceData, cA_BTDatasAll};
    UsedAreaAvgDatas(cA,:) = {cA_StimANDChoiceAvgMtx, cA_BTDataAvgMtx};
    
end

%% creating plots

% stim peak time and 
BoundIndex = find([1;diff(SortedPIIndex)]);
UsedBoundIndexAll = [BoundIndex;numel(SortedPIIndex)+1];
PIBoundCents = floor((UsedBoundIndexAll(1:end-1)+UsedBoundIndexAll(2:end))/2);

PITypes = unique(SortedPIIndex);
NumPIType = length(PITypes);
BarColors = linspecer(NumPIType,'qualitative');
PIAreaStrs = AllParentAreaStrs(PITypes);

UsedAreaPeakTimes = cellfun(@(x) x(1,2),UsedAreaAvgDatas(:,1));
UsedAreaPeakTimeSEM = cellfun(@(x) x(2,2),UsedAreaAvgDatas(:,1));
UsedAreaPeakAmps = cellfun(@(x) x(1,1),UsedAreaAvgDatas(:,1));
UsedAreaPeakAmpSEM = cellfun(@(x) x(2,1),UsedAreaAvgDatas(:,1));
UsedAreaPeakWidth = cellfun(@(x) x(1,3),UsedAreaAvgDatas(:,1));
UsedAreaPeakWidthSEM = cellfun(@(x) x(2,3),UsedAreaAvgDatas(:,1));

hf2 = figure('position',[100 100 800 380]);
axFrac = subplot(313); % for peak time
hold on;

axEvar = subplot(311); % for peak Amps
hold on;

axWidth = subplot(312); % for peak width
hold on;

for cPI = 1 : NumPIType
    cPIInds = UsedBoundIndexAll(cPI):UsedBoundIndexAll(cPI+1)-1;
%     cPI_CellFracs = UsedAreaPeakTimes(cPIInds);
    cPI_cType_Fracs = UsedAreaPeakTimes(cPIInds); %cellfun(@(x) x(cTypeInds),cPI_CellFracs)+1e-3;
    cPI_cType_FracSEM = UsedAreaPeakTimeSEM(cPIInds); 
    bar(axFrac,cPIInds,cPI_cType_Fracs,0.6,'FaceColor',BarColors(cPI,:),'EdgeColor','none');
    errorbar(axFrac,cPIInds,cPI_cType_Fracs,cPI_cType_FracSEM,'k.','Marker','none','linewidth',1.4);

%     cPI_CellEvars = UsedAreaPeakAmps(cPIInds);
    cPI_cType_EVars = UsedAreaPeakAmps(cPIInds); %cellfun(@(x) x(cTypeInds,1),cPI_CellEvars)+1e-3;
    cPI_cType_EVarSEM = UsedAreaPeakAmpSEM(cPIInds); 
    bar(axEvar,cPIInds,cPI_cType_EVars,0.6,'FaceColor',BarColors(cPI,:),'EdgeColor','k');
    errorbar(axEvar,cPIInds,cPI_cType_EVars,cPI_cType_EVarSEM,'k.','Marker','none','linewidth',1.4);
    
%     cPI_CellEvars = UsedAreaPeakWidth(cPIInds);
    cPI_cType_width = UsedAreaPeakWidth(cPIInds); %cellfun(@(x) x(cTypeInds,1),cPI_CellEvars)+1e-3;
    cPI_cType_widthSEM = UsedAreaPeakWidthSEM(cPIInds); 
    bar(axWidth,cPIInds,cPI_cType_width,0.6,'FaceColor',BarColors(cPI,:),'EdgeColor','k');
    errorbar(axWidth,cPIInds,cPI_cType_width,cPI_cType_widthSEM,'k.','Marker','none','linewidth',1.4);
end

% ytickGive = get(axFrac,'ytick');
% yscales = get(axFrac,'ylim');
% set(axFrac,'ytick',ytickGive+1e-3,'yticklabel',ytickGive,'ylim',yscales+[0,1e-3]);
ylabel(axFrac,'Time (s)');
ylabel(axEvar,'Explained Variance');
ylabel(axWidth,'Time (s)');

title(axFrac,'StimPeakTime');
title(axEvar,'StimPeakAmp');
title(axWidth,'StimPeakWidth');

set(axFrac,'xtick',PIBoundCents,'xticklabel',PIAreaStrs,'FontSize',8);
set(axWidth,'xtick',1:numel(SortedPIIndex),'xticklabel',SortUsedArea2ParentCell(:,1),'FontSize',8);
set(axEvar,'xtick',[],'FontSize',8);

%%
figSaveName2 = fullfile(FigSavePath,'ParentArea StimAnovaEvent summary plots');
saveas(hf2,figSaveName2);
print(hf2,figSaveName2,'-dpdf','-bestfit');
print(hf2,figSaveName2,'-dpng','-r350');
close(hf2);


%% choice info plots

UsedAreaPeakTimes = cellfun(@(x) x(1,5),UsedAreaAvgDatas(:,1));
UsedAreaPeakTimeSEM = cellfun(@(x) x(2,5),UsedAreaAvgDatas(:,1));
UsedAreaPeakAmps = cellfun(@(x) x(1,4),UsedAreaAvgDatas(:,1));
UsedAreaPeakAmpSEM = cellfun(@(x) x(2,4),UsedAreaAvgDatas(:,1));
UsedAreaPeakWidth = cellfun(@(x) x(1,6),UsedAreaAvgDatas(:,1));
UsedAreaPeakWidthSEM = cellfun(@(x) x(2,6),UsedAreaAvgDatas(:,1));

hf3 = figure('position',[100 100 800 380]);
axFrac = subplot(313); % for peak time
hold on;

axEvar = subplot(311); % for peak Amps
hold on;

axWidth = subplot(312); % for peak width
hold on;

for cPI = 1 : NumPIType
    cPIInds = UsedBoundIndexAll(cPI):UsedBoundIndexAll(cPI+1)-1;
%     cPI_CellFracs = UsedAreaPeakTimes(cPIInds);
    cPI_cType_Fracs = UsedAreaPeakTimes(cPIInds); %cellfun(@(x) x(cTypeInds),cPI_CellFracs)+1e-3;
    cPI_cType_FracSEM = UsedAreaPeakTimeSEM(cPIInds); 
    bar(axFrac,cPIInds,cPI_cType_Fracs,0.6,'FaceColor',BarColors(cPI,:),'EdgeColor','none');
    errorbar(axFrac,cPIInds,cPI_cType_Fracs,cPI_cType_FracSEM,'k.','Marker','none','linewidth',1.4);

%     cPI_CellEvars = UsedAreaPeakAmps(cPIInds);
    cPI_cType_EVars = UsedAreaPeakAmps(cPIInds); %cellfun(@(x) x(cTypeInds,1),cPI_CellEvars)+1e-3;
    cPI_cType_EVarSEM = UsedAreaPeakAmpSEM(cPIInds); 
    bar(axEvar,cPIInds,cPI_cType_EVars,0.6,'FaceColor',BarColors(cPI,:),'EdgeColor','k');
    errorbar(axEvar,cPIInds,cPI_cType_EVars,cPI_cType_EVarSEM,'k.','Marker','none','linewidth',1.4);
    
%     cPI_CellEvars = UsedAreaPeakWidth(cPIInds);
    cPI_cType_width = UsedAreaPeakWidth(cPIInds); %cellfun(@(x) x(cTypeInds,1),cPI_CellEvars)+1e-3;
    cPI_cType_widthSEM = UsedAreaPeakWidthSEM(cPIInds); 
    bar(axWidth,cPIInds,cPI_cType_width,0.6,'FaceColor',BarColors(cPI,:),'EdgeColor','k');
    errorbar(axWidth,cPIInds,cPI_cType_width,cPI_cType_widthSEM,'k.','Marker','none','linewidth',1.4);
end

% ytickGive = get(axFrac,'ytick');
% yscales = get(axFrac,'ylim');
% set(axFrac,'ytick',ytickGive+1e-3,'yticklabel',ytickGive,'ylim',yscales+[0,1e-3]);
ylabel(axFrac,'Time (s)');
ylabel(axEvar,'Explained Variance');
ylabel(axWidth,'Time (s)');

title(axFrac,'ChoicePeakTime');
title(axEvar,'ChoicePeakAmp');
title(axWidth,'ChoicePeakWidth');

set(axFrac,'xtick',PIBoundCents,'xticklabel',PIAreaStrs,'FontSize',8);
set(axWidth,'xtick',1:numel(SortedPIIndex),'xticklabel',SortUsedArea2ParentCell(:,1),'FontSize',8);
set(axEvar,'xtick',[],'FontSize',8);

%%
figSaveName3 = fullfile(FigSavePath,'ParentArea ChoiceAnovaEvent summary plots');
saveas(hf3,figSaveName3);
print(hf3,figSaveName3,'-dpdf','-bestfit');
print(hf3,figSaveName3,'-dpng','-r350');
close(hf3);

%% BT Evars calculation, because we can not find events for BT info

NonRevTr_BaselineBT = cellfun(@(x) (x(:,3))',UsedAreaAvgDatas(:,2),'un',0);
NonRevTr_BaselineBTMtx = cat(1,NonRevTr_BaselineBT{:});
NonRevTr_APBT = cellfun(@(x) (x(:,4))',UsedAreaAvgDatas(:,2),'un',0);
NonRevTr_APBTMtx = cat(1,NonRevTr_APBT{:});

RevTr_BaselineBT = cellfun(@(x) (x(:,7))',UsedAreaAvgDatas(:,2),'un',0);
RevTr_BaselineBTMtx = cat(1,RevTr_BaselineBT{:});
RevTr_APBT = cellfun(@(x) (x(:,8))',UsedAreaAvgDatas(:,2),'un',0);
RevTr_APBTMtx = cat(1,RevTr_APBT{:});

PlotDatas = {NonRevTr_BaselineBTMtx,NonRevTr_APBTMtx,RevTr_BaselineBTMtx,RevTr_APBTMtx};
TypeStrs = {'BaseNonRev','APNonRev','BaseRev','APRev'};

hf4 = figure('position',[100 100 980 400]);

for cType = 1 : 4
    cAx = subplot(4,1,cType);
    hold on
    
    cTypeData = PlotDatas{cType};
    cTypeData(isnan(cTypeData(:,2)),2) = 0;  % convert nan SEM datas into 0 variance
    cTypeData(isnan(cTypeData(:,3)),3) = 0;
    for cPI = 1 : NumPIType
        cPIInds = UsedBoundIndexAll(cPI):UsedBoundIndexAll(cPI+1)-1;
        cPI_cType_Fracs = cTypeData(cPIInds,1); %cellfun(@(x) x(cTypeInds),cPI_CellFracs)+1e-3;
        cPI_cType_FracSEM = cTypeData(cPIInds,2);
        cPI_cType_UnitNum = cTypeData(cPIInds,3);
        bar(cAx,cPIInds,cPI_cType_Fracs,0.6,'FaceColor',BarColors(cPI,:),'EdgeColor','none');
        errorbar(cAx,cPIInds,cPI_cType_Fracs,cPI_cType_FracSEM,'k.','Marker','none','linewidth',1.4);
        text(cAx,cPIInds,cPI_cType_Fracs+0.04,cellstr(num2str(cPI_cType_UnitNum(:),'%d')),'Color','m','FontSize',6,'Horizontalalignment','center');
    end
%     title(cAx, TypeStrs{cType});
    ylabel(cAx,{TypeStrs{cType};'EVars'});
    if cType == 4 % display parent areas in the last row
        set(cAx,'xtick',PIBoundCents,'xticklabel',PIAreaStrs,'FontSize',8);
    elseif cType == 3
        set(cAx,'xtick',1:numel(SortedPIIndex),'xticklabel',SortUsedArea2ParentCell(:,1),'FontSize',8);
    else
        set(cAx,'xtick',[],'FontSize',8);
    end
    
end

%%
figSaveName4 = fullfile(FigSavePath,'ParentArea Blocktype AnovaEVars summary plots');
saveas(hf4,figSaveName4);
print(hf4,figSaveName4,'-dpdf','-bestfit');
print(hf4,figSaveName4,'-dpng','-r350');
close(hf4);
