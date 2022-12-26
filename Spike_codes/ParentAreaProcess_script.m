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

% NonRevTr_BaselineBT = cellfun(@(x) (x(:,3))',UsedAreaAvgDatas(:,2),'un',0);
NonRevTr_BaselineBT = cellfun(@(x) (x(:,1))',UsedAreaAvgDatas(:,2),'un',0);
NonRevTr_BaselineBTMtx = cat(1,NonRevTr_BaselineBT{:});
% NonRevTr_APBT = cellfun(@(x) (x(:,4))',UsedAreaAvgDatas(:,2),'un',0);
NonRevTr_APBT = cellfun(@(x) (x(:,2))',UsedAreaAvgDatas(:,2),'un',0);
NonRevTr_APBTMtx = cat(1,NonRevTr_APBT{:});

% RevTr_BaselineBT = cellfun(@(x) (x(:,7))',UsedAreaAvgDatas(:,2),'un',0);
RevTr_BaselineBT = cellfun(@(x) (x(:,5))',UsedAreaAvgDatas(:,2),'un',0);
RevTr_BaselineBTMtx = cat(1,RevTr_BaselineBT{:});
% RevTr_APBT = cellfun(@(x) (x(:,8))',UsedAreaAvgDatas(:,2),'un',0);
RevTr_APBT = cellfun(@(x) (x(:,6))',UsedAreaAvgDatas(:,2),'un',0);
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


%% #########################################################################
% parent area response explained variance compare plot

cclr
% load anova peak analysis data
EVarDataSumDataPath = 'K:\Documents\me\projects\NP_reversaltask\summaryDatas\RegressionSummary\UnitEVscatterPlot\NoStim_frac';
% AnovaDataSumDataPath = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\summaryDatas\RegressionSummary\UnitEVscatterPlot\NoStim_frac';
saveFilePath = fullfile(EVarDataSumDataPath,'AllFracData_EVarcompareDatas.mat');
EVarData = load(saveFilePath,'AreaFracDatas','BrainAreasStr','AllLabelStr');

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
AllBrainNames = EVarData.BrainAreasStr;
NumBrainAreas = length(AllBrainNames);
Area2ParentMapDatas = cell(NumBrainAreas,5);  % AreaStr, ParentIndex,StimEVars, ChoiceEVars,NonRevBTs,RevBTs
IsAreaUsed = false(NumBrainAreas,1);
for cStrInds = 1 : NumBrainAreas
    
    cAreaStr = EVarData.BrainAreasStr{cStrInds};
    if isempty(EVarData.AreaFracDatas{cStrInds,1})
        continue;
    end
    TF = matches(ChildRegUsedStrs,cAreaStr,'IgnoreCase',true);
    if any(TF)
        AllenRegionInds = find(TF);
        if length(AllenRegionInds) > 1
            fprintf('Multiple fits exist for area <%s>.\n',cAreaStr);
            continue;
        end
        
        Area2ParentMapDatas(cStrInds,:) = {cAreaStr,Child2ParentMapInds(TF),...
            EVarData.AreaFracDatas{cStrInds,1},EVarData.AreaFracDatas{cStrInds,2},...
            EVarData.AreaFracDatas{cStrInds,3}};
        IsAreaUsed(cStrInds) = true;
    end
end

UsedAreaDatas = Area2ParentMapDatas(IsAreaUsed,:);
%%
FigSavePath = 'K:\Documents\me\projects\NP_reversaltask\summaryDatas\RegressionSummary\ParentAreaSummary\ExplainedVarsPlot';
% FigSavePath = 'E:\sycDatas\\Documents\me\projects\NP_reversaltask\summaryDatas\RegressionSummary\ParentAreaSummary\ExplainedVarsPlot';


%%

FracTypeStr = {'BT&Stim','BT&Choice','Stim&Choice','All'};
AllTypeStr = {'Block','Stimulus','Choice'};
AllLabelStr = [AllTypeStr, FracTypeStr];


UsedAreaParentAreInds = cat(1,UsedAreaDatas{:,2});
[SortedAreaInds,SortInds] = sort(UsedAreaParentAreInds);
SortAreaDatas = UsedAreaDatas(SortInds,:);
[AreaIndsTypes,~,SortAreaIndexSeq] = unique(SortedAreaInds);
NumAreaTypes = length(AreaIndsTypes);
ParentAreaFracDatas = cell(NumAreaTypes, 2);
for cParentAreaInds = 1:NumAreaTypes
    cParentArea_Index = AreaIndsTypes(cParentAreaInds);
    cAreaDatas = SortAreaDatas(SortedAreaInds == cParentArea_Index,:);

    cA_AllUnitEV = cat(1,cAreaDatas{:,3});
    cA_AllUnitIsResp = cat(1,cAreaDatas{:,4});
    TotalUnitNum = size(cA_AllUnitEV, 1);

    BT_AllUnitEVAlls = cA_AllUnitEV(:,1);
    Stim_AllUnitEVAlls = cA_AllUnitEV(:,2);
    Choice_AllUnitEVAlls = cA_AllUnitEV(:,3);
    ParentAreaFracDatas(cParentAreaInds,1:2) = {cA_AllUnitEV, cA_AllUnitIsResp};

    h5f = figure('position',[100 100 800 220]);
    StimANDBTsigInds = cA_AllUnitIsResp(:,1) | cA_AllUnitIsResp(:,2);
    StimAx = subplot(131);
    hold on
    plot(StimAx, BT_AllUnitEVAlls(~StimANDBTsigInds),Stim_AllUnitEVAlls(~StimANDBTsigInds),'o','MarkerSize',6,...
        'MarkerFaceColor',[.7 .7 .7],'MarkeredgeColor','none');
    plot(StimAx, BT_AllUnitEVAlls(StimANDBTsigInds),Stim_AllUnitEVAlls(StimANDBTsigInds),'o','MarkerSize',6,...
        'MarkerFaceColor',[0.8 0.2 0.2],'MarkeredgeColor','none');
    if cParentArea_Index == 1
        xscale = [min(BT_AllUnitEVAlls)-0.01,0.1]; % to exclude one abnormally high values
    else
        xscale = [min(BT_AllUnitEVAlls)-0.01,max(BT_AllUnitEVAlls)+0.06];
    end
    yscale = [min(Stim_AllUnitEVAlls)-0.01,max(Stim_AllUnitEVAlls)+0.04];
    CommonScale = [min(xscale(1),yscale(1)),max(xscale(2),yscale(2))];

    line(CommonScale,CommonScale,'Color','k','linewidth',1,'linestyle','--');
    text(xscale(2)*0.2,yscale(2)*0.7,sprintf('n = %d',TotalUnitNum),'Color','m','FontSize',10);
    set(StimAx,'xlim',xscale,'ylim',yscale);
    xlabel('BlockType Explained Variance','FontSize',10);
    ylabel('Stimulus Explained Variance','FontSize',10);

    ChoiceAx = subplot(132);
    hold on
    ChoiceANDBTsigInds = cA_AllUnitIsResp(:,1) | cA_AllUnitIsResp(:,3);
    plot(ChoiceAx, BT_AllUnitEVAlls(~ChoiceANDBTsigInds),Choice_AllUnitEVAlls(~ChoiceANDBTsigInds),'o','MarkerSize',6,...
        'MarkerFaceColor',[.7 .7 .7],'MarkeredgeColor','none');
    plot(ChoiceAx, BT_AllUnitEVAlls(ChoiceANDBTsigInds),Choice_AllUnitEVAlls(ChoiceANDBTsigInds),'bo','MarkerSize',6,...
        'MarkerFaceColor',[0.2 0.2 0.8],'MarkeredgeColor','none');

    yscale = [min(Choice_AllUnitEVAlls)-0.01,max(Choice_AllUnitEVAlls)+0.04];
    CommonScale = [min(xscale(1),yscale(1)),max(xscale(2),yscale(2))];

    line(CommonScale,CommonScale,'Color','k','linewidth',1,'linestyle','--');
    set(ChoiceAx,'xlim',xscale,'ylim',yscale);
    xlabel('BlockType Explained Variance','FontSize',10);
    ylabel('Choice Explained Variance','FontSize',10);

    cAreaStr = AllParentAreaStrs{cParentArea_Index};
    annotation('textbox',[0.8 0.1 0.1 0.05],'String',cAreaStr,'FitBoxToText','on','Color','r');
    
    FracNums = [sum(cA_AllUnitIsResp(:,1) & cA_AllUnitIsResp(:,2)),sum(cA_AllUnitIsResp(:,1) & cA_AllUnitIsResp(:,3)),...
            sum(cA_AllUnitIsResp(:,3) & cA_AllUnitIsResp(:,2)),sum(cA_AllUnitIsResp(:,1) & cA_AllUnitIsResp(:,2) & cA_AllUnitIsResp(:,3))];
    IndiTypeFracs = mean(cA_AllUnitIsResp);
    OverlapFracs = FracNums/TotalUnitNum;
    AllFracs = [IndiTypeFracs,OverlapFracs];
    try
        FracAx = subplot(133);
        hold on
        InfividualTypeFrac = mean(cA_AllUnitIsResp);
        EachTypeNum = sum(cA_AllUnitIsResp);
        if all(EachTypeNum > 0) 
            FracNums = [sum(cA_AllUnitIsResp(:,1) & cA_AllUnitIsResp(:,2)),sum(cA_AllUnitIsResp(:,1) & cA_AllUnitIsResp(:,3)),...
                sum(cA_AllUnitIsResp(:,3) & cA_AllUnitIsResp(:,2)),sum(cA_AllUnitIsResp(:,1) & cA_AllUnitIsResp(:,2) & cA_AllUnitIsResp(:,3))];
            OverlapFracs = FracNums/TotalUnitNum;
%             if any(FracNums == 0)
%                 EachTypeNum = EachTypeNum*10+10;
%                 FracNums = FracNums*10 + [2 0 0 1]; % only for midbrain areas, should remove this values if new data is added
%             end
            [H, S] = venn(EachTypeNum,...
                FracNums,'FaceAlpha', 0.4,'edgeColor','none', 'ErrMinMode', 'ChowRodgers');
            for i = 1:3
                text(S.ZoneCentroid(i,1), S.ZoneCentroid(i,2), AllLabelStr{i},'HorizontalAlignment','center');
            end
            set(FracAx,'xtick',[],'ytick',[],'xColor','none','yColor','none');
            hlg = legend(H,cellstr(num2str(InfividualTypeFrac(:)*100,'%.2f%%')),'Box','off','location','northEast');
            axPos = get(FracAx,'position');
            set(FracAx,'position',axPos.*[1 1 0.8 0.8]+[-0.05 0.15 0.01 0]);
            lgPos = get(hlg,'position');
            set(hlg,'position',lgPos+[0.15 0.05 0 0]);
            axis(FracAx,'square');

            annotation('textbox',[lgPos(1)+0.13,0.14,0.06 0.4],'String',{sprintf('BT&S = %.2f%%',OverlapFracs(1)*100);...
                sprintf('BT&C = %.2f%%',OverlapFracs(2)*100);sprintf('S&C = %.2f%%',OverlapFracs(3)*100);...
                sprintf('All = %.2f%%',OverlapFracs(4)*100)},'FitBoxToText','on','Color','m','FontSize',8);

        end
    catch ME
%         cla(FracAx);
%             
%         for cType = 1 : 7
%             text(FracAx,1,10-cType,sprintf('%s = %.2f%%',AllLabelStr{cType},AllFracs(cType)*100));
%         end
%         set(FracAx,'xtick',[],'ytick',[],'xColor','none','yColor','none','xlim',[0.5 3],'ylim',[2 11]);
%         
    end
    figSavePath = fullfile(FigSavePath,sprintf('%s EVar compare plot',cAreaStr));
    saveas(h5f,figSavePath);
    print(h5f,figSavePath,'-dpng','-r350');
    print(h5f,figSavePath,'-dpdf','-bestfit');
    close(h5f);
    
end

%% 
summaryDatasavefile = fullfile(FigSavePath,'EVarParentsummaryData.mat');
save(summaryDatasavefile,'ParentAreaFracDatas','UsedAreaDatas','AllParentAreaStrs','Area2ParentMapDatas','-v7.3')

%%
cclr

savePathfolder2 = 'K:\Documents\me\projects\NP_reversaltask\summaryDatas\RegressionSummary\UnitEVscatterPlot\NoStim_frac\WithinThres';
% savePathfolder2 = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\summaryDatas\RegressionSummary\UnitEVscatterPlot\NoStim_frac\WithinThres';

% savePathfolder2 = 'K:\Documents\me\projects\NP_reversaltask\summaryDatas\RegressionSummary\UnitEVscatterPlot\WithStim\WithinThres';
% % savePathfolder2 = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\summaryDatas\RegressionSummary\UnitEVscatterPlot\WithStim\WithinThres';

DataSavefile2 = fullfile(savePathfolder2,'WithinThresDataEVarFrac.mat');
ThresAvgDataStrc = load(DataSavefile2,'ThresedAvgDatas','BrainAreasStr');

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

%% resort the parent index swquence
ResortParentAreas = {{'Auditory','Motor','InterBrain','MidBrain','Hypothalamus'},...
    {'Amygdalar','Hippocampus','Striatum','Association'},{'Pallidum','Thalamus'}};
ResortParentStrAll = (cat(2,ResortParentAreas{:}))';
Child2ParentMapIndsNew = zeros(numel(Child2ParentMapInds),1);

for cPI = 1 : NumParentAreas
    cPIStr = strrep(AllParentAreaStrs{cPI},' Areas','');
    cStrInResort = find(contains(ResortParentStrAll,cPIStr));
    Child2ParentMapIndsNew(Child2ParentMapInds == cPI) = cStrInResort;
    
end
%%
UsedAreaInds = ~cellfun(@isempty,ThresAvgDataStrc.ThresedAvgDatas(:,1));
UsedAreaAvgDatas = ThresAvgDataStrc.ThresedAvgDatas(UsedAreaInds,1);
NEBrainStrs = ThresAvgDataStrc.BrainAreasStr(UsedAreaInds);

AllAreaFracStr = {'BlockType','Stimlulus','Choice'};
AllAreaFracCell = cellfun(@(x) x(:,5),UsedAreaAvgDatas,'un',0);
AllAreaFracs = cat(2,AllAreaFracCell{:})';

AllAreaEVarCell = cellfun(@(x) x(:,3),UsedAreaAvgDatas,'un',0);
AllAreaEvars = cat(2,AllAreaEVarCell{:})';

%%
AllBrainNames = NEBrainStrs;
NumBrainAreas = length(AllBrainNames);
Area2ParentMapDatas = cell(NumBrainAreas,4);  % AreaStr, ParentIndex, TypeFracs, TypeAllUnitAvg EVars
IsAreaUsed = false(NumBrainAreas,1);
for cStrInds = 1 : NumBrainAreas
    
    cAreaStr = AllBrainNames{cStrInds};
    
    TF = matches(ChildRegUsedStrs,cAreaStr,'IgnoreCase',true);
    if any(TF)
        AllenRegionInds = find(TF);
        if length(AllenRegionInds) > 1
            fprintf('Multiple fits exist for area <%s>.\n',cAreaStr);
            continue;
        end
        
        Area2ParentMapDatas(cStrInds,:) = {cAreaStr,Child2ParentMapIndsNew(TF),...
            AllAreaFracs(cStrInds,:),AllAreaEvars(cStrInds,:)};
        IsAreaUsed(cStrInds) = true;
    end
end

UsedAreaDatas = Area2ParentMapDatas(IsAreaUsed,:);

%%
ParentAreaIndexes = cat(1,UsedAreaDatas{:,2});
[PASortedIndex, SortInds] = sort(ParentAreaIndexes);
SortedAreaDatas = UsedAreaDatas(SortInds,:);
SortedAreaFracs = cat(1,SortedAreaDatas{:,3});
SortedAreaEVars = cat(1,SortedAreaDatas{:,4});

SortedAreaFracs_zs = zscore(SortedAreaFracs);
SortedAreaEVars_zs = zscore(SortedAreaEVars);
ColorScale = [-0.5 1.5];

% SortedAreaFracs_zs = (SortedAreaFracs)./repmat(max(SortedAreaFracs),size(SortedAreaFracs,1),1);
% SortedAreaEVars_zs = (SortedAreaEVars)./repmat(max(SortedAreaEVars),size(SortedAreaEVars,1),1);
% ColorScale = [0 1];

% SortedAreaFracs_zs = (SortedAreaFracs);
% SortedAreaEVars_zs = (SortedAreaEVars);
% ColorScale = [0 0.2];

SortedAreaStrs = SortedAreaDatas(:,1);

PAIndexAll = unique(PASortedIndex);
% PAIndexStrs = AllParentAreaStrs(PAIndexAll);
PAIndexStrs = ResortParentStrAll(PAIndexAll);
PAIndexStrShort = cellfun(@(x) strrep(x,' Areas',''),PAIndexStrs,'un',0);

PACounts = accumarray(PASortedIndex, 1);
PACounts(PACounts == 0) = [];
CountsCum = cumsum(PACounts)+0.5;
PACountEdges = [1;CountsCum-0.5];
PACountCents = (PACountEdges(1:end-1)+PACountEdges(2:end))/2+0.5;

UsedAreaNums = size(SortedAreaFracs_zs,1);
%
h6f = figure('position',[100 100 420 680]);
FracAxs = subplot(121);
hold on
imagesc(SortedAreaFracs_zs,ColorScale);
for cCount = 1 : length(CountsCum)-1
    line([0.5 3.5],CountsCum(cCount)*[1 1],'Color','m','linewidth',1.5,'linestyle','--');
end
set(FracAxs,'xlim',[0.5 3.5],'ylim',[0.5 UsedAreaNums+0.5],'xtick',1:3,...
    'xticklabel',{'Block','Stimulus','Choice'},'ytick',PACountCents,'yticklabel',PAIndexStrShort);

title('Fraction');
set(FracAxs,'FontSize',10);

EVarAxs = subplot(122);
hold on
imagesc(SortedAreaEVars_zs,ColorScale);
for cCount = 1 : length(CountsCum)-1
    line([0.5 3.5],CountsCum(cCount)*[1 1],'Color','m','linewidth',1.5,'linestyle','--');
end
set(EVarAxs,'xlim',[0.5 3.5],'ylim',[0.5 UsedAreaNums+0.5],'xtick',1:3,...
    'xticklabel',{'Block','Stimulus','Choice'},'ytick',1:UsedAreaNums,'yticklabel',SortedAreaStrs); %
title('Explained Variance');
set(EVarAxs,'FontSize',10);


%%

figSavePathn = fullfile(savePathfolder2,'Area zscored fraction and Variance colorplot');
saveas(h6f,figSavePathn);
print(h6f,figSavePathn,'-dpng','-r350');
print(h6f,figSavePathn,'-dpdf','-bestfit');

%% 2d denoise plot
[U,S,V] = svd(SortedAreaFracs_zs); %SortedAreaFracs_zs, SortedAreaEVars_zs
EigValues = diag(S);
EigValuesSqr = EigValues.^2;
ExplainedVariance = EigValuesSqr/sum(EigValuesSqr);
TwoExplainVar = sum(ExplainedVariance(1:2));

% SortedAreaEVars_zs
DenoiseData = U(:,1:2) * S(1:2,1:2) * V(1:2,:);
% DenoiseData = SortedAreaFracs_zs;
% DenoiseData = U(:,1:2) * S(1:2,1:2);
Group1Inds = 1:5;
Group2Inds = 6:9;
Group3Inds = 10:11;

Group1AreaInds = ismember(PASortedIndex, Group1Inds);
Group2AreaInds = ismember(PASortedIndex, Group2Inds);
Group3AreaInds = ismember(PASortedIndex, Group3Inds);

h7f = figure('position',[100 100 640 240]);
subplot(121)
hold on
plot(DenoiseData(Group1AreaInds,1),DenoiseData(Group1AreaInds,2),'o','MarkerFaceColor','r','MarkerSize',10);
plot(DenoiseData(Group2AreaInds,1),DenoiseData(Group2AreaInds,2),'o','MarkerFaceColor','g','MarkerSize',10);
plot(DenoiseData(Group3AreaInds,1),DenoiseData(Group3AreaInds,2),'o','MarkerFaceColor','b','MarkerSize',10);
title(sprintf('Fracs VarExp = %.2f%%',TwoExplainVar*100));
% legend([hp1,hp2,hp3],{'SensMotorMB','HPAssociation','Thalamus'},'location','northeastoutside','box','off','autoupdate','off');
xlabel('D1');
ylabel('D2');


[U2,S2,V2] = svd(SortedAreaEVars_zs); %SortedAreaFracs_zs, SortedAreaEVars_zs
EigValues2 = diag(S2);
EigValuesSqr2 = EigValues2.^2;
ExplainedVariance2 = EigValuesSqr2/sum(EigValuesSqr2);
TwoExplainVar2 = sum(ExplainedVariance2(1:2));
DenoiseData2 = U2(:,1:2) * S2(1:2,1:2) * V2(1:2,:);

subplot(122)
hold on
hp1 = plot(DenoiseData2(Group1AreaInds,1),DenoiseData2(Group1AreaInds,2),'o','MarkerFaceColor','r','MarkerSize',10);
hp2 = plot(DenoiseData2(Group2AreaInds,1),DenoiseData2(Group2AreaInds,2),'o','MarkerFaceColor','g','MarkerSize',10);
hp3 = plot(DenoiseData2(Group3AreaInds,1),DenoiseData2(Group3AreaInds,2),'o','MarkerFaceColor','b','MarkerSize',10);
title(sprintf('GLMEVar VarExp = %.2f%%',TwoExplainVar2*100));
legend([hp1,hp2,hp3],{'SensMotorMB','HPAssociation','Thalamus'},'location','northeast','box','on','autoupdate','off');
xlabel('D1');
ylabel('D2');

%%

figSavePathn = fullfile(savePathfolder2,'Area zscored fracEVar reductedDimension scatter');
saveas(h7f,figSavePathn);
print(h7f,figSavePathn,'-dpng','-r350');
print(h7f,figSavePathn,'-dpdf','-bestfit');



%%
DenoiseData = SortedAreaFracs_zs;

Group1Inds = 1:5;
Group2Inds = 6:9;
Group3Inds = 10:11;

Group1AreaInds = ismember(PASortedIndex, Group1Inds);
Group2AreaInds = ismember(PASortedIndex, Group2Inds);
Group3AreaInds = ismember(PASortedIndex, Group3Inds);

figure;
hold on
plot3(DenoiseData(Group1AreaInds,1),DenoiseData(Group1AreaInds,2),DenoiseData(Group1AreaInds,3),...
    'o','MarkerFaceColor','r','MarkerSize',10);
plot3(DenoiseData(Group2AreaInds,1),DenoiseData(Group2AreaInds,2),DenoiseData(Group2AreaInds,3),...
    'o','MarkerFaceColor','g','MarkerSize',10);
plot3(DenoiseData(Group3AreaInds,1),DenoiseData(Group3AreaInds,2),DenoiseData(Group3AreaInds,3),...
    'o','MarkerFaceColor','b','MarkerSize',10);


%% save folders 4
cclr

% % savePathfolder4 = 'K:\Documents\me\projects\NP_reversaltask\summaryDatas\ChoiceScoreSummary\plsChoiceScoreSum';
% savePathfolder4 = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\summaryDatas\ChoiceScoreSummary\plsChoiceScoreSum';
% 
% DataSavefile4 = fullfile(savePathfolder4,'plsChoiceInfo_CompData.mat');
% ThresAvgDataStrc = load(DataSavefile4,'AreaDataInfos','BrainAreasStr','AllDataDespStr');

% savePathfolder4 = 'K:\Documents\me\projects\NP_reversaltask\summaryDatas\ChoiceScoreSummary\plsChoiceScoreSum_zsed';
savePathfolder4 = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\summaryDatas\ChoiceScoreSummary\plsChoiceScoreSum_zsed';

DataSavefile4 = fullfile(savePathfolder4,'plsChoiceInfo_CompData_zsed.mat');
ThresAvgDataStrc = load(DataSavefile4,'AreaDataInfos','BrainAreasStr','AllDataDespStr');

% load parent str datas
% ParantAreaListFile = fullfile('K:\Documents\me\projects\NP_reversaltask\Parent_areas_list.xlsx');
ParantAreaListFile = fullfile('E:\sycDatas\Documents\me\projects\NP_reversaltask\Parent_areas_list.xlsx');

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

%%
UsedAreaInds = ~cellfun(@isempty,ThresAvgDataStrc.AreaDataInfos(:,1,1));
UsedAreaAvgDatas = squeeze(ThresAvgDataStrc.AreaDataInfos(UsedAreaInds,5,:));
NEBrainStrs = ThresAvgDataStrc.BrainAreasStr(UsedAreaInds);
%
AllAreaAvgRatio = cellfun(@mean,UsedAreaAvgDatas);
AllAreaRatioSEM = cellfun(@(x) std(x)/sqrt(numel(x)),UsedAreaAvgDatas);

UsedAreaAvgAllDatas = squeeze(ThresAvgDataStrc.AreaDataInfos(UsedAreaInds,:,:));
UsedAreaAllDataInfoAvgs = cellfun(@mean,UsedAreaAvgAllDatas);
UsedAreaAllDataInfoSEMs = cellfun(@(x) std(x)/sqrt(numel(x)),UsedAreaAvgAllDatas);
%%
AllBrainNames = NEBrainStrs;
NumBrainAreas = length(AllBrainNames);
Area2ParentMapDatas = cell(NumBrainAreas,7);  % AreaStr, ParentIndex, 
IsAreaUsed = false(NumBrainAreas,1);
for cStrInds = 1 : NumBrainAreas
    
    cAreaStr = AllBrainNames{cStrInds};
    
    TF = matches(ChildRegUsedStrs,cAreaStr,'IgnoreCase',true);
    if any(TF)
        AllenRegionInds = find(TF);
        if length(AllenRegionInds) > 1
            fprintf('Multiple fits exist for area <%s>.\n',cAreaStr);
            continue;
        end
        
        Area2ParentMapDatas(cStrInds,:) = {cAreaStr,Child2ParentMapInds(TF),...
            AllAreaAvgRatio(cStrInds,:),AllAreaRatioSEM(cStrInds,:),UsedAreaAvgDatas(cStrInds,:),...
            UsedAreaAllDataInfoAvgs(cStrInds,:,:),UsedAreaAllDataInfoSEMs(cStrInds,:,:)};
        IsAreaUsed(cStrInds) = true;
    end
end

UsedAreaDatas = Area2ParentMapDatas(IsAreaUsed,:);

%%

AllAreaIndex = cat(1,UsedAreaDatas{:,2});
[SortedPIIndex, SortIds] = sort(AllAreaIndex);

UsedAreaStrs = UsedAreaDatas(SortIds,1);
UsedAreaRatioAvg = cat(1,UsedAreaDatas{SortIds, 3});
UsedAreaRatioSEM = cat(1,UsedAreaDatas{SortIds, 4});
UsedAreaAllRatios = cat(1, UsedAreaDatas{SortIds, 5});
SortAreaAllDataInfoAvgs = cat(1,UsedAreaDatas{SortIds, 6});
SortAreaAllDataInfoSEM = cat(1,UsedAreaDatas{SortIds, 7});
% stim peak time and 
BoundIndex = find([1;diff(SortedPIIndex)]);
UsedBoundIndexAll = [BoundIndex;numel(SortedPIIndex)+1];
PIBoundCents = floor((UsedBoundIndexAll(1:end-1)+UsedBoundIndexAll(2:end))/2);

PITypes = unique(SortedPIIndex);
NumPIType = length(PITypes);
BarColors = linspecer(NumPIType,'qualitative');
PIAreaStrs = AllParentAreaStrs(PITypes);
%%
NumUsedAreas = size(UsedAreaRatioAvg,1);

hf4 = figure('position',[100 100 780 320]);

ax1 = subplot(211);
hold on;

ax2 = subplot(212);
hold on;

for cAI = 1 : NumUsedAreas
    cA_datas = UsedAreaAllRatios{cAI,1};
    cA_Color = BarColors(SortedPIIndex(cAI)==PITypes,:);
    plot(ax1, cAI, cA_datas, 'o', 'linewidth', 1, 'MarkerEdgeColor',cA_Color,'MarkerSize',6);
    [~, p] = ttest(cA_datas, 1);
    if p < 0.05
        text(ax1, cAI, max(cA_datas)+1, '*','FontSize',16,'HorizontalAlignment','center');
    end
end
set(ax1,'xtick',1:NumUsedAreas,'xticklabel',UsedAreaStrs,'xlim',[0 NumUsedAreas+2]);
line(ax1, [0.5 NumUsedAreas+0.5],[1 1],'Color','c','linewidth',1,'linestyle','--');
ylabel(ax1,sprintf('%s Info Ratio',ThresAvgDataStrc.AllDataDespStr{1}));

for cPI = 1 : NumPIType
    cPIInds = UsedBoundIndexAll(cPI):UsedBoundIndexAll(cPI+1)-1;
    cPI_cType_Ratios = UsedAreaRatioAvg(cPIInds,1); %cellfun(@(x) x(cTypeInds),cPI_CellFracs)+1e-3;
    cPI_cType_RatioSEM = UsedAreaRatioSEM(cPIInds,1); 
    bar(ax2, cPIInds,cPI_cType_Ratios,0.6,'FaceColor',BarColors(cPI,:),'EdgeColor','none');
    errorbar(ax2, cPIInds,cPI_cType_Ratios,cPI_cType_RatioSEM,'k.','Marker','none','linewidth',1.4);
end
set(ax2,'xtick',PIBoundCents,'xticklabel',PIAreaStrs,'xlim',[0 NumUsedAreas+2]);
line(ax2, [0.5 NumUsedAreas+0.5],[1 1],'Color','m','linewidth',1,'linestyle','--');
ylabel(ax2,sprintf('%s Info Ratio',ThresAvgDataStrc.AllDataDespStr{1}));

%%
% % savePathfolder4 = 'K:\Documents\me\projects\NP_reversaltask\summaryDatas\ChoiceScoreSummary\plsChoiceScoreSum';
% savePathfolder4 = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\summaryDatas\ChoiceScoreSummary\plsChoiceScoreSum';

% savePathfolder4 = 'K:\Documents\me\projects\NP_reversaltask\summaryDatas\ChoiceScoreSummary\plsChoiceScoreSum_zsed';
savePathfolder4 = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\summaryDatas\ChoiceScoreSummary\plsChoiceScoreSum_zsed';

ParentAreaSaveName = fullfile(savePathfolder4, 'Parent area zsedData ChoiceAfinfo ratio summary plot');
saveas(hf4, ParentAreaSaveName);
print(hf4, ParentAreaSaveName, '-dpng','-r350');
print(hf4, ParentAreaSaveName, '-dpdf','-bestfit');

%%

hf4_2 = figure('position',[100 100 780 320]);

ax1 = subplot(211);
hold on;

ax2 = subplot(212);
hold on;

for cAI = 1 : NumUsedAreas
    cA_datas = UsedAreaAllRatios{cAI,3};
    cA_Color = BarColors(SortedPIIndex(cAI)==PITypes,:);
    plot(ax1, cAI, cA_datas, 'o', 'linewidth', 1, 'MarkerEdgeColor',cA_Color,'MarkerSize',6);
    [~, p] = ttest(cA_datas, 1);
    if p < 0.05
        text(ax1, cAI, max(cA_datas)+1, '*','FontSize',16,'HorizontalAlignment','center');
    end
end
set(ax1,'xtick',1:NumUsedAreas,'xticklabel',UsedAreaStrs,'xlim',[0 NumUsedAreas+2]);
line(ax1, [0.5 NumUsedAreas+0.5],[1 1],'Color','c','linewidth',1,'linestyle','--');
ylabel(ax1,sprintf('%s Info Ratio',ThresAvgDataStrc.AllDataDespStr{3}));

for cPI = 1 : NumPIType
    cPIInds = UsedBoundIndexAll(cPI):UsedBoundIndexAll(cPI+1)-1;
    cPI_cType_Ratios = UsedAreaRatioAvg(cPIInds,3); %cellfun(@(x) x(cTypeInds),cPI_CellFracs)+1e-3;
    cPI_cType_RatioSEM = UsedAreaRatioSEM(cPIInds,3); 
    bar(ax2, cPIInds,cPI_cType_Ratios,0.6,'FaceColor',BarColors(cPI,:),'EdgeColor','none');
    errorbar(ax2, cPIInds,cPI_cType_Ratios,cPI_cType_RatioSEM,'k.','Marker','none','linewidth',1.4);
end
set(ax2,'xtick',PIBoundCents,'xticklabel',PIAreaStrs,'xlim',[0 NumUsedAreas+2]);
line(ax2, [0.5 NumUsedAreas+0.5],[1 1],'Color','m','linewidth',1,'linestyle','--');
ylabel(ax2,sprintf('%s Info ratio',ThresAvgDataStrc.AllDataDespStr{3}));

%%
% % savePathfolder4 = 'K:\Documents\me\projects\NP_reversaltask\summaryDatas\ChoiceScoreSummary\plsChoiceScoreSum';
% savePathfolder4 = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\summaryDatas\ChoiceScoreSummary\plsChoiceScoreSum';

ParentAreaSaveName2 = fullfile(savePathfolder4, 'Parent area zsed BTAfinfo ratio summary plot');
saveas(hf4_2, ParentAreaSaveName2);
print(hf4_2, ParentAreaSaveName2, '-dpng','-r350');
print(hf4_2, ParentAreaSaveName2, '-dpdf','-bestfit');

%% plot the real info size
ChoiceAfDataAll = SortAreaAllDataInfoAvgs(:,:,1);
BTAfDataAll = SortAreaAllDataInfoAvgs(:,:,3);
ChoiceAfDataAllSEM = SortAreaAllDataInfoSEM(:,:,1);
BTAfDataAllSEM = SortAreaAllDataInfoSEM(:,:,3);

hf4_3 = figure('position',[100 100 540 220]);
ChoiceAx = subplot(121);
hold on

BTAx = subplot(122);
hold on

% choice plot
for cPI = 1 : NumPIType
    cPIInds = UsedBoundIndexAll(cPI):UsedBoundIndexAll(cPI+1)-1;
    cPI_RawInfo_Avgs = ChoiceAfDataAll(cPIInds,1); %cellfun(@(x) x(cTypeInds),cPI_CellFracs)+1e-3;
    cPI_RawInfo_SEM = ChoiceAfDataAllSEM(cPIInds,1)*0.2;
    
    cPI_SubInfo_Avgs = ChoiceAfDataAll(cPIInds,2); %cellfun(@(x) x(cTypeInds),cPI_CellFracs)+1e-3;
    cPI_SubInfo_SEM = ChoiceAfDataAllSEM(cPIInds,2)*0.2;
    
    plot(ChoiceAx, cPI_RawInfo_Avgs,cPI_SubInfo_Avgs,'o','MarkerEdgeColor',BarColors(cPI,:),...
        'MarkerFaceColor',BarColors(cPI,:),'linewidth',0.8);
%     errorbar(ChoiceAx, cPI_RawInfo_Avgs,cPI_SubInfo_Avgs,cPI_SubInfo_SEM,cPI_SubInfo_SEM,...
%         cPI_RawInfo_SEM,cPI_RawInfo_SEM,'ko','linewidth',0.6);
end
Comscale = uniAxesAdj(ChoiceAx);
tb1 = fitlm(ChoiceAfDataAll(:,1),ChoiceAfDataAll(:,2));
% fprintf('Model fit result.\n');
% disp(tb1.Coefficients);
% disp(tb1);
InterValue = tb1.Coefficients.Estimate(1);
CoefValue = tb1.Coefficients.Estimate(2);
Rsqr = tb1.Rsquared.Adjusted;
PredValue = predict(tb1,Comscale(:));
line(ChoiceAx, Comscale, PredValue, 'Color','m','linewidth',0.6,'linestyle','--');
text(ChoiceAx,Comscale(1)+1,Comscale(2)-5,{sprintf('Slope = %.4f',CoefValue);sprintf('Rsqr = %.4f',Rsqr)},...
    'fontSize',8);
xlabel(ChoiceAx, 'RawData');
ylabel(ChoiceAx, 'Baseline subtracted');
title(ChoiceAx, 'Choice Info');
set(gca,'FontSize',10)

% BT plot
for cPI = 1 : NumPIType
    cPIInds = UsedBoundIndexAll(cPI):UsedBoundIndexAll(cPI+1)-1;
    cPI_RawInfo_Avgs = BTAfDataAll(cPIInds,1); %cellfun(@(x) x(cTypeInds),cPI_CellFracs)+1e-3;
    cPI_RawInfo_SEM = BTAfDataAllSEM(cPIInds,1)*0.2;
    
    cPI_SubInfo_Avgs = BTAfDataAll(cPIInds,2); %cellfun(@(x) x(cTypeInds),cPI_CellFracs)+1e-3;
    cPI_SubInfo_SEM = BTAfDataAllSEM(cPIInds,2)*0.2;
    
    plot(BTAx, cPI_RawInfo_Avgs,cPI_SubInfo_Avgs,'o','MarkerEdgeColor',BarColors(cPI,:),...
        'MarkerFaceColor',BarColors(cPI,:),'linewidth',0.8);
%     errorbar(ChoiceAx, cPI_RawInfo_Avgs,cPI_SubInfo_Avgs,cPI_SubInfo_SEM,cPI_SubInfo_SEM,...
%         cPI_RawInfo_SEM,cPI_RawInfo_SEM,'ko','linewidth',0.6);
end
Comscale2 = uniAxesAdj(BTAx);
tb12 = fitlm(BTAfDataAll(:,1),BTAfDataAll(:,2));
% fprintf('Model fit result.\n');
% disp(tb1.Coefficients);
% disp(tb1);
InterValue = tb12.Coefficients.Estimate(1);
CoefValue = tb12.Coefficients.Estimate(2);
Rsqr = tb12.Rsquared.Adjusted;
PredValue = predict(tb12,Comscale2(:));
line(BTAx, Comscale2, PredValue, 'Color','m','linewidth',0.6,'linestyle','--');
text(BTAx,Comscale2(1)+1,Comscale2(2)-5,{sprintf('Slope = %.4f',CoefValue);sprintf('Rsqr = %.4f',Rsqr)},...
    'fontSize',8);
xlabel(BTAx, 'RawData');
ylabel(BTAx, 'Baseline subtracted');
title(BTAx,'BT Info');
set(gca,'FontSize',10)

%% shuf threshold data plot
hf4_4 = figure('position',[100 100 540 220]);
ChoiceAx = subplot(121);
hold on

BTAx = subplot(122);
hold on

% choice plot
for cPI = 1 : NumPIType
    cPIInds = UsedBoundIndexAll(cPI):UsedBoundIndexAll(cPI+1)-1;
    cPI_RawInfo_Avgs = ChoiceAfDataAll(cPIInds,3); %cellfun(@(x) x(cTypeInds),cPI_CellFracs)+1e-3;
    cPI_RawInfo_SEM = ChoiceAfDataAllSEM(cPIInds,1)*0.2;
    
    cPI_SubInfo_Avgs = ChoiceAfDataAll(cPIInds,4); %cellfun(@(x) x(cTypeInds),cPI_CellFracs)+1e-3;
    cPI_SubInfo_SEM = ChoiceAfDataAllSEM(cPIInds,2)*0.2;
    
    plot(ChoiceAx, cPI_RawInfo_Avgs,cPI_SubInfo_Avgs,'o','MarkerEdgeColor',BarColors(cPI,:),...
        'MarkerFaceColor',BarColors(cPI,:),'linewidth',0.8);
%     errorbar(ChoiceAx, cPI_RawInfo_Avgs,cPI_SubInfo_Avgs,cPI_SubInfo_SEM,cPI_SubInfo_SEM,...
%         cPI_RawInfo_SEM,cPI_RawInfo_SEM,'ko','linewidth',0.6);
end
Comscale = uniAxesAdj(ChoiceAx);
tb1 = fitlm(ChoiceAfDataAll(:,3),ChoiceAfDataAll(:,4));
% fprintf('Model fit result.\n');
% disp(tb1.Coefficients);
% disp(tb1);
InterValue = tb1.Coefficients.Estimate(1);
CoefValue = tb1.Coefficients.Estimate(2);
Rsqr = tb1.Rsquared.Adjusted;
PredValue = predict(tb1,Comscale(:));
line(ChoiceAx, Comscale, PredValue, 'Color','m','linewidth',0.6,'linestyle','--');
text(ChoiceAx,Comscale(1)+0.01,Comscale(2)-0.02,{sprintf('Slope = %.4f',CoefValue);sprintf('Rsqr = %.4f',Rsqr)},...
    'fontSize',8);
xlabel(ChoiceAx, 'RawData');
ylabel(ChoiceAx, 'Baseline subtracted');
title(ChoiceAx, 'Choice Info threshold');
set(gca,'FontSize',10)

% BT plot
for cPI = 1 : NumPIType
    cPIInds = UsedBoundIndexAll(cPI):UsedBoundIndexAll(cPI+1)-1;
    cPI_RawInfo_Avgs = BTAfDataAll(cPIInds,3); %cellfun(@(x) x(cTypeInds),cPI_CellFracs)+1e-3;
    cPI_RawInfo_SEM = BTAfDataAllSEM(cPIInds,1)*0.2;
    
    cPI_SubInfo_Avgs = BTAfDataAll(cPIInds,4); %cellfun(@(x) x(cTypeInds),cPI_CellFracs)+1e-3;
    cPI_SubInfo_SEM = BTAfDataAllSEM(cPIInds,2)*0.2;
    
    plot(BTAx, cPI_RawInfo_Avgs,cPI_SubInfo_Avgs,'o','MarkerEdgeColor',BarColors(cPI,:),...
        'MarkerFaceColor',BarColors(cPI,:),'linewidth',0.8);
%     errorbar(ChoiceAx, cPI_RawInfo_Avgs,cPI_SubInfo_Avgs,cPI_SubInfo_SEM,cPI_SubInfo_SEM,...
%         cPI_RawInfo_SEM,cPI_RawInfo_SEM,'ko','linewidth',0.6);
end
Comscale2 = uniAxesAdj(BTAx);
tb12 = fitlm(BTAfDataAll(:,3),BTAfDataAll(:,4));
% fprintf('Model fit result.\n');
% disp(tb1.Coefficients);
% disp(tb1);
InterValue = tb12.Coefficients.Estimate(1);
CoefValue = tb12.Coefficients.Estimate(2);
Rsqr = tb12.Rsquared.Adjusted;
PredValue = predict(tb12,Comscale2(:));
line(BTAx, Comscale2, PredValue, 'Color','m','linewidth',0.6,'linestyle','--');
text(BTAx,Comscale2(1)+0.01,Comscale2(2)-0.02,{sprintf('Slope = %.4f',CoefValue);sprintf('Rsqr = %.4f',Rsqr)},...
    'fontSize',8);
xlabel(BTAx, 'RawData');
ylabel(BTAx, 'Baseline subtracted');
title(BTAx,'BT Info threshold');
set(gca,'FontSize',10)


%%

ParentAreaSaveName3 = fullfile(savePathfolder4, 'Parent area Info Compared summary plot');
saveas(hf4_3, ParentAreaSaveName3);
print(hf4_3, ParentAreaSaveName3, '-dpng','-r350');
print(hf4_3, ParentAreaSaveName3, '-dpdf','-bestfit');


ParentAreaSaveName4 = fullfile(savePathfolder4, 'Parent area InfoThreshold Compared summary plot');
saveas(hf4_4, ParentAreaSaveName4);
print(hf4_4, ParentAreaSaveName4, '-dpng','-r350');
print(hf4_4, ParentAreaSaveName4, '-dpdf','-bestfit');




