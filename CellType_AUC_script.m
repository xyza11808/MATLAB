% since unequal number of ROIs exist for some session
AUCDataStrc = load('E:\DataToGo\data_for_xu\Task_Pass_AUCComp\New_singleAUC\ROIAUCSaveAll.mat');
load('E:\DataToGo\data_for_xu\SingleCell_RespType_summary\NewMethod\SessROItypeData.mat');
nSessions = size(AUCDataStrc.SessAUCDataAll,1);
UsedROInum = cell(nSessions,1);
for cSess = 1 : nSessions
    UsedROInum{cSess} = length(AUCDataStrc.SessAUCDataAll{cSess,2}.ROCareaReal);
end

TaskSess1s_sum = cellfun(@(x,y) x.ROCareaReal(1:y),AUCDataStrc.SessAUCDataAll(:,2),UsedROInum,'Uniformoutput',false);
PassSess1s_sum = cellfun(@(x,y) x.ROCareaReal(1:y),AUCDataStrc.SessAUCDataAll(:,4),UsedROInum,'Uniformoutput',false);
TaskSess1s_isRevert = cellfun(@(x,y) x.IsRevert(1:y),AUCDataStrc.SessAUCDataAll(:,2),UsedROInum,'Uniformoutput',false);
PassSess1s_isRevert = cellfun(@(x,y) x.IsRevert(1:y),AUCDataStrc.SessAUCDataAll(:,4),UsedROInum,'Uniformoutput',false);

%% plot the AUC values according to cell response type
nSessNum = size(BoundTunROIindex,1);
TaskTypeAUCStrc = struct('CategAUC',{cell(nSessNum,1)},'BoundTunAUC',{cell(nSessNum,1)},'OtherTunAUC',...
    {cell(nSessNum,1)},'RestROIAUC',{cell(nSessNum,1)});
PassTypeAUCStrc = struct('CategAUC',{cell(nSessNum,1)},'BoundTunAUC',{cell(nSessNum,1)},'OtherTunAUC',...
    {cell(nSessNum,1)},'RestROIAUC',{cell(nSessNum,1)});
for cSess = 1 : nSessNum
    cSessTaskAUCData = TaskSess1s_sum{cSess};
%     cSessTaskAUCData(logical(TaskSess1s_isRevert{cSess})) = 1 - cSessTaskAUCData(logical(TaskSess1s_isRevert{cSess}));
    cSessPassAUCData = PassSess1s_sum{cSess};
%     cSessPassAUCData(logical(PassSess1s_isRevert{cSess})) = 1 - cSessPassAUCData(logical(PassSess1s_isRevert{cSess}));
    
    CategInds = BoundTunROIindex{cSess,6};
    TuningInds = BoundTunROIindex{cSess,7};
    TuningIndex = find(TuningInds);
    BoundTunROIIndex = BoundTunROIindex{cSess,1};
    OtherTunROIIndex = TuningIndex(~(BoundTunROIindex{cSess,2}));
    RestROIs = ~(CategInds | TuningInds);
    
    TaskTypeAUCStrc.CategAUC{cSess} = (cSessTaskAUCData(CategInds))';
    TaskTypeAUCStrc.BoundTunAUC{cSess} = (cSessTaskAUCData(BoundTunROIIndex))';
    TaskTypeAUCStrc.OtherTunAUC{cSess} = (cSessTaskAUCData(OtherTunROIIndex))';
    TaskTypeAUCStrc.RestROIAUC{cSess} = (cSessTaskAUCData(RestROIs))';
    
    PassTypeAUCStrc.CategAUC{cSess} = (cSessPassAUCData(CategInds))';
    PassTypeAUCStrc.BoundTunAUC{cSess} = (cSessPassAUCData(BoundTunROIIndex))';
    PassTypeAUCStrc.OtherTunAUC{cSess} = (cSessPassAUCData(OtherTunROIIndex))';
    PassTypeAUCStrc.RestROIAUC{cSess} = (cSessPassAUCData(RestROIs))';
end
% save TypeAUCDataSave.mat PassTypeAUCStrc TaskTypeAUCStrc -v7.3
%% plot data
TaskCategAUC = cell2mat(TaskTypeAUCStrc.CategAUC);
PassCategAUC = cell2mat(PassTypeAUCStrc.CategAUC);
BoundTunTaskAUC = cell2mat(TaskTypeAUCStrc.BoundTunAUC);
BoundTunPassAUC = cell2mat(PassTypeAUCStrc.BoundTunAUC);
OtherTunTaskAUC = cell2mat(TaskTypeAUCStrc.OtherTunAUC);
OtherTunPassAUC = cell2mat(PassTypeAUCStrc.OtherTunAUC);
TaskRestAUC = cell2mat(TaskTypeAUCStrc.RestROIAUC);
PassRestAUC = cell2mat(PassTypeAUCStrc.RestROIAUC);
Colors = cool(4);   % parula
cd('E:\DataToGo\data_for_xu\Task_Pass_AUCComp\New_singleAUC');
%% plot data separately
[~,p1] = ttest(TaskRestAUC,PassRestAUC);
[~,p1Sig] = ttest(TaskRestAUC,0.6,'Tail','right');
hf = figure('position',[1950 100 350 300]);
hold on
scatter(TaskRestAUC,PassRestAUC,14,'o','MarkerFaceColor',Colors(4,:),'MarkerEdgeColor','none');
figaxesScaleUni(gca);
xscales = get(gca,'xlim');
line(xscales,xscales,'Color',[.7 .7 .7],'linewidth',2,'linestyle','--');
xlabel('Task (NoSelective)');
ylabel('Passive');
title({sprintf('Task = %.3f, Pass = %.3f',mean(TaskRestAUC),mean(PassRestAUC)),sprintf('CompP = %.2e,SigP = %.2e',p1,p1Sig)});
set(gca,'FontSize',14,'xtick',[0.3 0.5 1],'ytick',[0.3 0.5 1],'xlim',[0.2 1.1],'ylim',[0.2 1.1]);
saveas(hf,'NoSelective ROIs AUC compare plot');
saveas(hf,'NoSelective ROIs AUC compare plot','pdf');

%% categorical ROI AUC dis
[~,p2] = ttest(TaskCategAUC,PassCategAUC);
[~,p2Sig] = ttest(TaskCategAUC,0.6,'Tail','right');
hf = figure('position',[1950 100 350 300]);
hold on
scatter(TaskCategAUC,PassCategAUC,14,'o','MarkerFaceColor',Colors(1,:),'MarkerEdgeColor','none');
figaxesScaleUni(gca);
xscales = get(gca,'xlim');
line(xscales,xscales,'Color',[.7 .7 .7],'linewidth',2,'linestyle','--');
xlabel('Task  (Categorical)');
ylabel('Passive');
title({sprintf('Task = %.3f, Pass = %.3f',mean(TaskCategAUC),mean(PassCategAUC)),sprintf('CompP = %.2e,SigP = %.2e',p2,p2Sig)});
set(gca,'FontSize',14,'xtick',[0.3 0.5 1],'ytick',[0.3 0.5 1],'xlim',[0.2 1.1],'ylim',[0.2 1.1]);
saveas(hf,'categorical ROIs AUC compare plot');
saveas(hf,'categorical ROIs AUC compare plot','pdf');

%% boundary tuning ROI AUC Dis
[~,p3] = ttest(BoundTunTaskAUC,BoundTunPassAUC);
[~,p3Sig] = ttest(BoundTunTaskAUC,0.6,'Tail','right');
hf = figure('position',[1950 100 350 300]);
hold on
scatter(BoundTunTaskAUC,BoundTunPassAUC,14,'o','MarkerFaceColor',Colors(2,:),'MarkerEdgeColor','none');
figaxesScaleUni(gca);
xscales = get(gca,'xlim');
line(xscales,xscales,'Color',[.7 .7 .7],'linewidth',2,'linestyle','--');
xlabel('Task (Boundary Tun)');
ylabel('Passive');
title({sprintf('Task = %.3f, Pass = %.3f',mean(BoundTunTaskAUC),mean(BoundTunPassAUC)),sprintf('CompP = %.2e,SigP = %.2e',p3,p3Sig)});
set(gca,'FontSize',14,'xtick',[0.3 0.5 1],'ytick',[0.3 0.5 1],'xlim',[0.2 1.1],'ylim',[0.2 1.1]);
saveas(hf,'BoundTun ROIs AUC compare plot');
saveas(hf,'BoundTun ROIs AUC compare plot','pdf');

%% OtherTun ROI AUC Dis
[~,p4] = ttest(OtherTunTaskAUC,OtherTunPassAUC);
[~,p4Sig] = ttest(OtherTunTaskAUC,0.6,'Tail','right');
hf = figure('position',[1950 100 350 300]);
hold on
scatter(OtherTunTaskAUC,OtherTunPassAUC,14,'o','MarkerFaceColor',Colors(3,:),'MarkerEdgeColor','none');
figaxesScaleUni(gca);
xscales = get(gca,'xlim');
line(xscales,xscales,'Color',[.7 .7 .7],'linewidth',2,'linestyle','--');
xlabel('Task (Sensory Tun)');
ylabel('Passive');
title({sprintf('Task = %.3f, Pass = %.3f',mean(OtherTunTaskAUC),mean(OtherTunPassAUC)),sprintf('CompP = %.2e,SigP = %.2e',p4,p4Sig)});
set(gca,'FontSize',14,'xtick',[0.3 0.5 1],'ytick',[0.3 0.5 1],'xlim',[0.2 1.1],'ylim',[0.2 1.1]);
saveas(hf,'OtherTun ROIs AUC compare plot');
saveas(hf,'OtherTun ROIs AUC compare plot','pdf');

