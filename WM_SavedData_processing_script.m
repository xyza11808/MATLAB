
Datfolder = uigetdir(pwd,'Please select your data saved path');
cd(Datfolder);
datafileAll = dir('*.mat');
nfs = length(datafileAll);

VarNames = {'ROINum','xDataNum','GauCategPara','SlopeValueB','SlopeValueA','IsRandWid','WidTypes','WidFracs','fnName','ModuSlopePeak'};
VarTypes = {'double','double','cell','double','double','double','cell','cell','string','double'};
DataAlls = table('Size',[nfs,length(VarNames)],'VariableTypes',VarTypes,'VariableNames',VarNames);
for cf = 1 : nfs
    cData = load(datafileAll(cf).name);
    DataAlls.ROINum(cf) = cData.WorkModelPara.CategROINum;
    DataAlls.xDataNum(cf) = cData.WorkModelPara.xDataNumUsed;
    DataAlls.GauCategPara(cf) = {cData.WorkModelPara.gausCategParaDef};
    DataAlls.SlopeValueB(cf) = cData.WorkModelPara.SlopeV(1);
    DataAlls.SlopeValueA(cf) = cData.WorkModelPara.SlopeV(2);
    DataAlls.IsRandWid(cf) = cData.WorkModelPara.IsRandWid;
    DataAlls.WidTypes{cf} = cData.WorkModelPara.WidTypes;
    DataAlls.WidFracs{cf} = cData.WorkModelPara.WidTypeFrac;
    DataAlls.ModuSlopePeak(cf) = max(cData.WorkModelPara.UncertainFunCurve);
    DataAlls.fnName(cf) = datafileAll(cf).name;
end

%%
GauWidsAll = cellfun(@(x) x(2),DataAlls.GauCategPara);
ROINumBase = 11;
sDataBase = 500;
TunWIdthBase = 0.2;
IsRandWidBase = 0;

%%
% xDataChange Results
DataInds = DataAlls.ROINum == ROINumBase & GauWidsAll == TunWIdthBase & DataAlls.IsRandWid == IsRandWidBase;
cDataTable = DataAlls(DataInds,:);
SlopeChangeInds = cDataTable.SlopeValueA ./ cDataTable.SlopeValueB;
xDataNums = cDataTable.xDataNum;
figure;
plot(xDataNums,SlopeChangeInds,'ko')

%%
% ROI number Results 
cDataInds = DataAlls.xDataNum == sDataBase & GauWidsAll == TunWIdthBase & DataAlls.IsRandWid == IsRandWidBase;
cDataTable = DataAlls(cDataInds,:);
SlopeChangeInds = cDataTable.SlopeValueA ./ cDataTable.SlopeValueB;
ROINum = cDataTable.ROINum;
hff = figure('position',[100 100 360 300]);
plot(ROINum,SlopeChangeInds,'ko','MarkerSize',8,'linewidth',2);
xlabel('Number of neurons');
ylabel('Slope changes (times)');
set(gca,'FontSize',14,'box','off');

saveas(hff,'ROI number change slope change');
saveas(hff,'ROI number change slope change','png');
saveas(hff,'ROI number change slope change','pdf');

%%
% Width change results
cDataInds = DataAlls.xDataNum == sDataBase & DataAlls.ROINum == ROINumBase & DataAlls.IsRandWid == IsRandWidBase;
cDataTable = DataAlls(cDataInds,:);
SlopeChangeInds = cDataTable.SlopeValueA ./ cDataTable.SlopeValueB;
GauWids = GauWidsAll(cDataInds);
hhf = figure('position',[100 100 360 300]);
plot(GauWids,SlopeChangeInds,'ko','MarkerSize',8,'linewidth',2);
xlabel('Single neuron \sigma');
ylabel('Slope changes (times)');
set(gca,'FontSize',14,'box','off','ylim',[2 4]);

saveas(hhf,'GauROI width change slope change');
saveas(hhf,'GauROI width change slope change','png');
saveas(hhf,'GauROI width change slope change','pdf');


%%
% rand Inds
cDataInds = DataAlls.xDataNum == sDataBase & GauWidsAll == TunWIdthBase & DataAlls.IsRandWid == (1 - IsRandWidBase) & DataAlls.ROINum == ROINumBase;
cDataTable = DataAlls(cDataInds,:);
SlopeChangeInds = cDataTable.SlopeValueA ./ cDataTable.SlopeValueB;
% ROINum = cDataTable.ROINum;
[Datas,Figs] = lmFunCalPlot(cDataTable.SlopeValueB , cDataTable.SlopeValueA);
xlabel('Before modulation slope');
ylabel('After modulation slope');
set(Figs,'position',[100 100 360 300]);
cAxes = figaxesScaleUni(gca);
set(cAxes,'FontSize',14);
AxesScales = get(cAxes,'xlim');
line(AxesScales,AxesScales,'linewidth',1.2,'Color',[.7 .7 .7],'Linestyle','--');
set(cAxes,'xlim',[1 AxesScales(2)],'ylim',[1 AxesScales(2)]);
%%

saveas(Figs,'Random width and fraction slope change');
saveas(Figs,'Random width and fraction slope change','png');
saveas(Figs,'Random width and fraction slope change','pdf');

%%
% cDataTable = DataAlls(73:end,:);
% SlopeChangeInds1 = cDataTable.SlopeValueA ./ cDataTable.SlopeValueB;
% ROINum = cDataTable.ROINum;
figure;
hist(SlopeChangeInds);
%%
cDataTable = DataAlls(38:end,:);
SlopeChangeInds2 = cDataTable.SlopeValueA ./ cDataTable.SlopeValueB;
% ROINum = cDataTable.ROINum;
figure;
hist(SlopeChangeInds2);

%% calculating slope peak value change affects final results
SlopeChangesAll = DataAlls.SlopeValueA ./ DataAlls.SlopeValueB;
ModuPeaksAll = DataAlls.ModuSlopePeak;
huf = figure('position',[100 100 360 300]);
plot(ModuPeaksAll,SlopeChangesAll,'ko','MarkerSize',8,'linewidth',2);
xlabel('ModuCurve Peak');
ylabel('Slope changes (times)');
set(gca,'FontSize',14,'Box','off');

saveas(huf,'ModuPeak Slope Change plots')
saveas(huf,'ModuPeak Slope Change plots','pdf')
saveas(huf,'ModuPeak Slope Change plots','png')

