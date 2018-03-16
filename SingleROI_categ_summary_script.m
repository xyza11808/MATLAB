
clear
clc
cd('E:\DataToGo\data_for_xu\Tuning_curve_plot');
[fn,fp,~] = uigetfile('*.txt','Please select the text file contains the path of all task sessions');
% [Passfn,Passfp,~] = uigetfile('*.txt','Please select the text file contains the path of all passive sessions');
load('E:\DataToGo\data_for_xu\SingleCell_RespType_summary\NewMethod\SessROItypeData.mat');
cd('E:\DataToGo\data_for_xu\CategDataSummary');
%%
fpath = fullfile(fp,fn);
% PassFid = fopen(fullfile(Passfp,Passfn));

ff = fopen(fpath);
tline = fgetl(ff);
% PassLine = fgetl(PassFid);
cSess = 1;
CategDataSumAlls = {}; 
BnoundTunROIs = {};
CategDataPassAll = {};
%
while ischar(tline)
    if isempty(strfind(tline,'NO_Correction\mode_f_change'))
       tline = fgetl(ff);
%        PassLine = fgetl(PassFid);
        continue;
    end
%     cd(tline);

    cBehavDataP = fullfile(tline,'RandP_data_plots','boundary_result.mat');
    CellTypeDataStrc = load(fullfile(tline,'Tunning_fun_plot_New1s','Curve fitting plots','NewCurveFitsave.mat'));
    load(fullfile(tline,'Tunning_fun_plot_New1s','TunningDataSave.mat'));
    cBehavDataStrc = load(cBehavDataP);
    BehavStims = cBehavDataStrc.boundary_result.StimType;
    BehavRProb = cBehavDataStrc.boundary_result.StimCorr;
    StimOcts = log2(BehavStims/16000);
    ReverInds = BehavStims < 16000; % inds that need to be reversed
    BehavRProb(ReverInds) = 1 - BehavRProb(ReverInds);
    %
    CategROIinds = CellTypeDataStrc.IsCategROI;
    CategROIIndex = find(CategROIinds);
    nCategs = sum(CategROIinds);
    CategNorData = cell(1,nCategs);
    FitDataAll = cell(1,nCategs);
    ROIPreferSide = zeros(1,nCategs);
    
    
    OutIndexInds = abs(PassFreqOctave) < 1.02;
    UsedPassOcts = PassFreqOctave(OutIndexInds);
    UsedPassData = PassTunningfun(OutIndexInds,:);
    disp(UsedPassOcts');
    UsedIndsTr = input('Please select Used inds:\n','s');
    UsedInds = str2num(UsedIndsTr);
    UsedPassOcts = UsedPassOcts(UsedInds);
    UsedPassData = UsedPassData(UsedInds,:);
    if ~isempty(UsedPassOcts)
        CategROIPassData =cell(1,nCategs);
        CategROIPassNorData =cell(1,nCategs);
    end
    %
    for cR = 1 : nCategs
        %
        cRData = CorrTunningFun(:,CategROIIndex(cR));
        cRNorData = (max(BehavRProb) - min(BehavRProb))*((cRData - min(cRData))./(max(cRData) - min(cRData))) + min(BehavRProb);
        
        CategNorData{cR} = cRNorData;
        if ~isempty(UsedPassOcts)
            cRPassData = UsedPassData(:,CategROIIndex(cR));
            cRPassNorData = (max(BehavRProb) - min(BehavRProb))*((cRPassData - min(cRPassData))./...
            (max(cRPassData) - min(cRPassData))) + min(BehavRProb);
            CategROIPassData{cR} = cRPassNorData;
            CategROIPassRawData{cR} = cRPassData;
        end
        
%         plot(cRNorData,'b')
       
        if mean(cRNorData(ReverInds)) < mean(cRNorData(~ReverInds))
            FitResult = FitPsycheCurveWH_nx(StimOcts(:),cRNorData(:));
            ROIPreferSide(cR) = 1;
        else
            cREvertData = flipud(cRNorData(:));
            FitResult = FitPsycheCurveWH_nx(StimOcts(:),cREvertData);
        end
        FitDataAll{cR} = FitResult;
%         pause(0.5);
        %
    end
    %
    CategDataSumAlls{cSess,1} = CategNorData;
    CategDataSumAlls{cSess,2} = FitDataAll;
    CategDataSumAlls{cSess,3} = ROIPreferSide;
    
    BoundTunROIs = BoundTunROIindex{cSess,1};
    BoundTunDatas = CorrTunningFun(:,BoundTunROIs);
    BnoundTunROIs{cSess,1} = BoundTunDatas;
    BnoundTunROIs{cSess,2} = cBehavDataStrc.boundary_result;
    
    if ~isempty(UsedPassOcts)
        CategDataPassAll{cSess,1} = CategROIPassData;
        CategDataPassAll{cSess,2} = UsedPassOcts;
        CategDataPassAll{cSess,3} = CategROIPassRawData;
    end
    
    tline = fgetl(ff);
    cSess = cSess + 1;
end
nSess = cSess - 1;
%% Plot all ROIs together
SessCategDataAll = [];
SessCategPrefer = [];
for cS = 1 : nSess
    SessCategDataAll = [SessCategDataAll,CategDataSumAlls{cS,2}];
    SessCategPrefer = [SessCategPrefer,CategDataSumAlls{cS,3}];
end
LeftPreferDatas = SessCategDataAll(SessCategPrefer == 0);
RightCategDatas = SessCategDataAll(SessCategPrefer == 1);

%%
LeftDataMtx = zeros(1000,length(LeftPreferDatas));
hf = figure;
hold on
for cLroi = 1 : length(LeftPreferDatas)
    plot(LeftPreferDatas{cLroi}.curve(:,1),flipud(LeftPreferDatas{cLroi}.curve(:,2)),'b','linewidth',1.2);
    LeftDataMtx(:,cLroi) = flipud(LeftPreferDatas{cLroi}.curve(:,2));
end
%%
RightDataMtx = zeros(1000,length(RightCategDatas));
hf = figure;
hold on
for cLroi = 1 : length(RightCategDatas)
    plot(RightCategDatas{cLroi}.curve(:,1),RightCategDatas{cLroi}.curve(:,2),'r','linewidth',1.2);
    RightDataMtx(:,cLroi) = RightCategDatas{cLroi}.curve(:,2);
end
%% behavior data summary
OctsAll = [];
BehavDataAll = [];
for cS = 1 : nSess
    cSessStims = BnoundTunROIs{cS,2}.StimType;
    cSessOcts = log2(cSessStims(:)/16000);
    OctsAll = [OctsAll;cSessOcts];
    BehavCorr = BnoundTunROIs{cS,2}.StimCorr;
    RevertInds = cSessOcts < 0;
    BehavCorr(RevertInds) = 1 - BehavCorr(RevertInds);
    BehavDataAll = [BehavDataAll;BehavCorr(:)];
end
BehavFitRes = FitPsycheCurveWH_nx(OctsAll,BehavDataAll);

%%
OctRange = RightCategDatas{1}.curve(:,1);
PopuCategDiff = mean(RightDataMtx,2) - mean(LeftDataMtx,2);
% plot(OctRange,PopuCategDiff,'m','linewidth',1.5);
NorPopuDiffFit = FitPsycheCurveWH_nx(OctRange,NorPopuDiff);

NorPopuDiff = (max(BehavFitRes.curve(:,2)) - min(BehavFitRes.curve(:,2)))*...
    ((PopuCategDiff - min(PopuCategDiff))./(max(PopuCategDiff) - min(PopuCategDiff))) + min(BehavFitRes.curve(:,2));

hf = figure;
hold on
plot(OctRange,NorPopuDiff,'c','linewidth',1.4);
plot(BehavFitRes.curve(:,1),BehavFitRes.curve(:,2),'m');
plot(NorPopuDiffFit.curve(:,1),NorPopuDiffFit.curve(:,2),'Color',[1 0.7 0.2])
set(gca,'xlim',[-1.1 1.1],'xtick',[-1 -0.5 0 0.5 1],'ylim',[0 1],'ytick',[0 0.5 1]);
xlabel('Octave');
ylabel('RProb');
set(gca,'FontSize',14);
% saveas(hf,'CategROI All population fit curve');
% saveas(hf,'CategROI All population fit curve','pdf');
%% passive data summary
LPassDataAll = [];
LPassOctAll = [];
RPassDataAll = [];
RPassOctAll = [];

LTaskDataAll = [];
LTaskOctAll = [];
RTaskDataAll = [];
RTaskOctAll = [];

for cSS = 1 : nSess
    cSessPass = CategDataPassAll{cSS,1};
    cSessPassOct = CategDataPassAll{cSS,2};
    cSessTask = CategDataSumAlls{cSS,1};
    cSessTaskOcts = log2(BnoundTunROIs{cSS,2}.StimType(:)/16000);
    if isempty(cSessPass)
        continue;
    end
    cSessROIRever = CategDataSumAlls{cSS,3};
    for cR = 1 : length(cSessROIRever)
        if cSessROIRever(cR)
            RPassDataAll = [RPassDataAll;cSessPass{cR}];
            RPassOctAll = [RPassOctAll;cSessPassOct];
            RTaskDataAll = [RTaskDataAll;cSessTask{cR}];
            RTaskOctAll = [RTaskOctAll;cSessTaskOcts(:)];
        else
            LPassDataAll = [LPassDataAll;flipud(cSessPass{cR})];
            LPassOctAll = [LPassOctAll;cSessPassOct];
            LTaskDataAll = [LTaskDataAll;flipud(cSessTask{cR})];
            LTaskOctAll = [LTaskOctAll;cSessTaskOcts(:)];
        end
    end
    
end

%%
hf = figure;
hold on
plot(LTaskOctAll,LTaskDataAll,'bo')
plot(LPassOctAll,LPassDataAll,'co')
plot(RTaskOctAll,RTaskDataAll,'ro')
plot(RPassOctAll,RPassDataAll,'mo')

%% fit all results
LTaskFit = FitPsycheCurveWH_nx(LTaskOctAll,LTaskDataAll);
LPassFit = FitPsycheCurveWH_nx(LPassOctAll,LPassDataAll);
RTaskFit = FitPsycheCurveWH_nx(RTaskOctAll,RTaskDataAll);
RPassFit = FitPsycheCurveWH_nx(RPassOctAll,RPassDataAll);
%%
LTaskFitDataNor = (max(BehavFitRes.curve(:,2)) - min(BehavFitRes.curve(:,2)))*...
    ((LTaskFit.curve(:,2) - min(LTaskFit.curve(:,2)))./(max(LTaskFit.curve(:,2)) - min(LTaskFit.curve(:,2)))) + min(BehavFitRes.curve(:,2));
LPassFitDataNor = (max(BehavFitRes.curve(:,2)) - min(BehavFitRes.curve(:,2)))*...
    ((LPassFit.curve(:,2) - min(LPassFit.curve(:,2)))./(max(LPassFit.curve(:,2)) - min(LPassFit.curve(:,2)))) + min(BehavFitRes.curve(:,2));
RTaskFitDataNor = (max(BehavFitRes.curve(:,2)) - min(BehavFitRes.curve(:,2)))*...
    ((RTaskFit.curve(:,2) - min(RTaskFit.curve(:,2)))./(max(RTaskFit.curve(:,2)) - min(RTaskFit.curve(:,2)))) + min(BehavFitRes.curve(:,2));
RPassFitDataNor = (max(BehavFitRes.curve(:,2)) - min(BehavFitRes.curve(:,2)))*...
    ((RPassFit.curve(:,2) - min(RPassFit.curve(:,2)))./(max(RPassFit.curve(:,2)) - min(RPassFit.curve(:,2)))) + min(BehavFitRes.curve(:,2));

hTaskf = figure('position',[100 100 380 320]);
hold on
plot(LTaskFit.curve(:,1),flipud(LTaskFitDataNor),'b','linewidth',1.5);
plot(RTaskFit.curve(:,1),RTaskFitDataNor,'r','linewidth',1.5);
set(gca,'xlim',[-1.1 1.1],'ylim',[0 1]);
title('Task');
xlabel('Octaves');
ylabel('Activity (Nor.)');
set(gca,'FontSize',14);

hPassf = figure('position',[500 100 380 320]);
hold on
plot(RPassFit.curve(:,1),RPassFitDataNor,'g','linewidth',1.5);
plot(LPassFit.curve(:,1),flipud(LPassFitDataNor),'c','linewidth',1.5);
set(gca,'xlim',[-1.1 1.1],'ylim',[0 1]);
title('Passive');
xlabel('Octaves');
ylabel('Activity (Nor.)');
set(gca,'FontSize',14);
%%
saveas(hTaskf,'Task popu activities plot save');
saveas(hTaskf,'Task popu activities plot save','pdf');

saveas(hPassf,'Pass popu activities plot save');
saveas(hPassf,'Pass popu activities plot save','pdf');


%% Task Passive Diff
OctRange = RPassFit.curve(:,1);
PassLRDiff = RPassFit.curve(:,2) - flipud(LPassFit.curve(:,2));
TaskLRDiff = RTaskFit.curve(:,2) - flipud(LTaskFit.curve(:,2));

TaskNorPopuDiff = (max(BehavFitRes.curve(:,2)) - min(BehavFitRes.curve(:,2)))*...
    ((TaskLRDiff - min(TaskLRDiff))./(max(TaskLRDiff) - min(TaskLRDiff))) + min(BehavFitRes.curve(:,2));
PassNorPopuDiff = (max(BehavFitRes.curve(:,2)) - min(BehavFitRes.curve(:,2)))*...
    ((PassLRDiff - min(PassLRDiff))./(max(PassLRDiff) - min(PassLRDiff))) + min(BehavFitRes.curve(:,2));

TaskDiffFit = FitPsycheCurveWH_nx(OctRange,TaskNorPopuDiff);
PassDiffFit = FitPsycheCurveWH_nx(OctRange,PassNorPopuDiff);

hDiff = figure;
yyaxis left
hold on
plot(OctRange,TaskNorPopuDiff,'Color',[1 0.7 0.2],'linewidth',1.5); 
plot(OctRange,PassNorPopuDiff,'Color','k','linewidth',1.5);
set(gca,'xlim',[-1.1 1.1],'ylim',[0 1])


yyaxis right
AmpFactorData = (TaskNorPopuDiff-0.5)./(PassNorPopuDiff-0.5);
plot(OctRange,AmpFactorData,'Color','m','linewidth',1.5);

%%
BARange = linspace(-1,1,1000);
TaskCalRange = BARange + TaskDiffFit.ffit.u;
PassCalRange = BARange + PassDiffFit.ffit.u;
TaskAlignData = feval(TaskDiffFit.ffit,TaskCalRange(:));
PassAlignData = feval(PassDiffFit.ffit,PassCalRange(:));

hDiff = figure;
% yyaxis left
hold on
plot(BARange,TaskAlignData,'Color',[1 0.7 0.2],'linewidth',1.5);
plot(BARange,PassAlignData,'Color','k','linewidth',1.5);
plot(BehavFitRes.curve(:,1),BehavFitRes.curve(:,2),'r','linewidth',1.5);
set(gca,'xlim',[-1.1 1.1],'ylim',[0 1])

% 
% yyaxis right 
% AmpFactorData = diff(TaskAlignData)./diff(PassAlignData);
% plot(BARange(2:end),AmpFactorData,'Color','m','linewidth',1.5);
%%
saveas(hDiff,'Popu Difference plot taskPass comp plot withTunFun');
saveas(hDiff,'Popu Difference plot taskPass comp plot withTunFun','pdf');

%%
OctStep = BARange(2) - BARange(1);
hSlope = figure('position',[100 100 380 300]);
hold on
% hll1 = plot(BARange(2:end),diff(TaskAlignData)/OctStep,'Color',[0.9 0.3 0.1],'linewidth',1.5);
% hll2 = plot(BARange(2:end),diff(PassAlignData)/OctStep,'Color',[.5 .5 .5],'linewidth',1.5);
hll3 = plot(BARange(2:end),AmpFactorData,'Color','g','linewidth',1.5);
set(gca,'xlim',[-1.1 1.1],'ylim',[-0.2 3]);
% legend([hll1,hll2,hll3],{'Task','Pass','AmpFunction'},'box','off')

saveas(hSlope,'Slope Amplification plot save');
saveas(hSlope,'Slope Amplification plot save','pdf');

