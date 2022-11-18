
ParantAreaListFile = fullfile('K:\Documents\me\projects\NP_reversaltask\Parent_areas_list.xlsx');

ParentRegionStrCell = readcell(ParantAreaListFile,'Range','A:A',...
    'Sheet','Sheet1');
IsCellStrInds = cellfun(@(x) ischar(x),ParentRegionStrCell);
IsCellStrInds(1) = false;
AllAreaStrsIndex = find(IsCellStrInds)-1;
AllParentAreaStrs = ParentRegionStrCell(AllAreaStrsIndex+1);

ChildRegStrCell = readcell(ParantAreaListFile,'Range','B:B',...
    'Sheet','Sheet1');
ChildRegUsedStrs = ChildRegStrCell(2:end);

NumParentAreas = length(AllAreaStrs);
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
saveDataname = fullfile(FigSavePath,'ParentAreaSumData.mat');
save(saveDataname,'UsedArea2ParentMap','IsAreaUsed','AreaSelectEVStrc','Child2ParentMapInds',...
    'ChildRegUsedStrs','AllParentAreaStrs','FinalAreaDatas','-v7.3');

%% fraction bar plots
TypeStrs = {'Blocktype','Stim','Choice'};
BoundIndex = find([1;diff(SortedPIIndex)]);
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

