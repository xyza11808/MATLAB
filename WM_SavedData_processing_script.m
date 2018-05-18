
Datfolder = uigetdir(pwd,'Please select your data saved path');
cd(Datfolder);
datafileAll = dir('*.mat');
nfs = length(datafileAll);

VarNames = {'ROINum','xDataNum','GauCategPara','SlopeValueB','SlopeValueA','IsRandWid','WidTypes','WidFracs','fnName'};
VarTypes = {'double','double','cell','double','double','double','cell','cell','string'};
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
figure;
plot(ROINum,SlopeChangeInds,'ko');

%%
% Width change results
cDataInds = DataAlls.xDataNum == sDataBase & DataAlls.ROINum == ROINumBase & DataAlls.IsRandWid == IsRandWidBase;
cDataTable = DataAlls(cDataInds,:);
SlopeChangeInds = cDataTable.SlopeValueA ./ cDataTable.SlopeValueB;
GauWids = GauWidsAll(cDataInds);
figure;
plot(GauWids,SlopeChangeInds,'ko');

%%
% rand Inds
cDataInds = DataAlls.xDataNum == sDataBase & GauWidsAll == TunWIdthBase & DataAlls.IsRandWid == (1 - IsRandWidBase) & DataAlls.ROINum == ROINumBase;
cDataTable = DataAlls(cDataInds,:);
SlopeChangeInds = cDataTable.SlopeValueA ./ cDataTable.SlopeValueB;
% ROINum = cDataTable.ROINum;
figure;
hist(SlopeChangeInds);

%%
cDataTable = DataAlls(73:end,:);
SlopeChangeInds1 = cDataTable.SlopeValueA ./ cDataTable.SlopeValueB;
% ROINum = cDataTable.ROINum;
figure;
hist(SlopeChangeInds1);
%%
cDataTable = DataAlls(38:end,:);
SlopeChangeInds2 = cDataTable.SlopeValueA ./ cDataTable.SlopeValueB;
% ROINum = cDataTable.ROINum;
figure;
hist(SlopeChangeInds2);

