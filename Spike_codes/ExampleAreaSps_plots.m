
% example session from:
% I:\ksOutput_backup\b107a08_ksoutput\A2021226_b107a08_NPSess02_g0_cat\catgt_A2021226_b107a08_NPSess02_g0\Cat_A2021226_b107a08_NPSess02_g0_imec1\ks2_5

load('Chnlocation.mat', 'AlignedAreaStrings')
load('NewClassHandle.mat')

%%

TaskTrigOnTimeAll = NewNPClusHandle.UsedTrigOnTime{1};
UsedTrigOnTime = TaskTrigOnTimeAll(100); % using 100 trials after task onset
MaxDispLength = 10; % seconds for display after selected onset time
UsedUnitIDs = NewNPClusHandle.UsedClus_IDs;
UsedUnitChannel = NewNPClusHandle.ChannelUseds_id;
ChnDepth = 3840 - (0:383)*10;
AllClusSPtimes = double(NewNPClusHandle.SpikeTimeSample)/30000;
NumUsedClus = length(UsedUnitIDs);
hf = figure('position',[100 100 480 840]);
subplot(1,5,2:5);
hold on
c_WithinInds = AllClusSPtimes >= UsedTrigOnTime & AllClusSPtimes < (UsedTrigOnTime+MaxDispLength);
c_WithinRangeSPs = AllClusSPtimes(c_WithinInds);
c_WithinRangeClus = NewNPClusHandle.SpikeClus(c_WithinInds);
for cU = 1 : NumUsedClus
    cU_ClusIDinds = c_WithinRangeClus == UsedUnitIDs(cU);
    cU_clusChn = UsedUnitChannel(cU);
    cU_ChnDepth = ChnDepth(cU_clusChn);
    cU_SPtimes = c_WithinRangeSPs(cU_ClusIDinds) - UsedTrigOnTime;
    if numel(cU_SPtimes) > 0
        plot(cU_SPtimes,cU_ChnDepth,'k.','MarkerSize',10);
    end
end

set(gca,'ylim',[0 3840],'yDir','Reverse','yColor','w');
%%
AllChnAreaStrs = AlignedAreaStrings{2};
AllChnAreaLayerRM = cell(384,1);
for cchn = 1 : 384
    cStr = AllChnAreaStrs{cchn};
    [Start,~] = regexp(cStr,'layer');
    cStr(Start:end) = [];
    AllChnAreaLayerRM{cchn} = cStr;
end
%%
[UniqueTypes, ~, UniqueLabels] = unique(AllChnAreaLayerRM);
AreaBounds = [1;find(abs(diff(UniqueLabels)) > 0);384];
AreaCenters = round((AreaBounds(1:end-1) + AreaBounds(2:end))/2);
AreaCenterStrs = UniqueTypes(UniqueLabels(AreaCenters));
subplot(1,5,1);
hold on
for cBound = 1 : numel(AreaBounds)
    line([0 2],AreaBounds(cBound)*[1 1],'Color','k','linewidth',2);
    if cBound < numel(AreaBounds)
        text(1,AreaCenters(cBound),AreaCenterStrs{cBound},'HorizontalAlignment','center',...
            'FontSize',8,'Color','m');
    end
end
line([0 0],[1 384],'Color','k','linewidth',2);
line([2 2],[1 384],'Color','k','linewidth',2);
set(gca,'ylim',[0 384],'yColor','w','xcolor','w','xlim',[0 2]);

%%
summarySaveFolder1 = 'K:\Documents\me\projects\NP_reversaltask\summaryDatas\ExamplePlots';
% summarySaveFolder1 = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\summaryDatas\ExamplePlots';

saveName = fullfile(summarySaveFolder1,'ExampleSPpositionPlot');
saveas(hf,saveName);
print(hf,saveName,'-dpng','-r300');
print(hf,saveName,'-dpdf','-bestfit','-painters');

%%




