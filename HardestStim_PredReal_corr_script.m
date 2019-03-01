%% given data path in a txt file for imaging
clear
clc

[fn,fp,fi] = uigetfile('*.txt','Please select the used data path saved file');
if ~fi
    return;
end
fPath = fullfile(fp,fn);
fids = fopen(fPath);
tline = fgetl(fids);
NormSessPathTask = {};
NormSessPathPass = {};
m = 1;

while ischar(tline)
    if isempty(strfind(tline,'NO_Correction\mode_f_change'))
        tline = fgetl(fids);
        continue;
    end
    
    NormSessPathTask{m} = tline;
    
    [~,EndInds] = regexp(tline,'test\d{2,3}');
    cPassDataUpperPath = fullfile(sprintf('%srf',tline(1:EndInds)),'im_data_reg_cpu','result_save');
    
    [~,InfoDataEndInds] = regexp(tline,'result_save');
    PassPathline = fullfile(sprintf('%srf%s',tline(1:EndInds),tline(EndInds+1:InfoDataEndInds)),'plot_save','NO_Correction');
    NormSessPathPass{m} = PassPathline;
    
    tline = fgetl(fids);
    m = m + 1;
end
fclose(fids);
%%

clearvars -except NormSessPathTask NormSessPathPass

nSession = length(NormSessPathTask);

HardPredChoiceAll = cell(nSession,1);
HardBehavChoiceAll = cell(nSession,1);
AllStimPredANDBehavChoice = cell(nSession,3);
PredCI = cell(nSession,1);
AllSessTrCI = cell(nSession,1);
WorstPerfAll = zeros(nSession,1);
for cSess = 1 : nSession
    %
    tline = NormSessPathTask{cSess};
    
    cTbyTPath = fullfile(tline,'Test_anmChoice_predCROIs');

%     PredChoiceStrc = load(fullfile(cTbyTPath,'ModelPredictionSave.mat'),'IterPredChoice');
    SessStimStrc = load(fullfile(cTbyTPath,'AnmChoicePredSaveNew.mat'),'Stimlulus','RealStimPerf','UsingAnmChoice','StimInds','IterPredChoice');
    [cWorstPerf,WorstPerfInds] = min(SessStimStrc.RealStimPerf);
    WorstPerfAll(cSess) = cWorstPerf;
    WorstStimInds = SessStimStrc.StimInds{WorstPerfInds};
    %
    HardChoiceData = SessStimStrc.IterPredChoice(:,WorstStimInds);
    [NRepeat,HardStimTrNum] = size(HardChoiceData);
    %
    ProbAndCI = zeros(HardStimTrNum,3);
    for cr = 1 : HardStimTrNum
        crRepeats = HardChoiceData(:,cr);
        [pHat,pci] = binofit(sum(crRepeats),NRepeat);
        ProbAndCI(cr,:) = [pHat,pci];
    end
    %
    cSessPredChoice = (mean(SessStimStrc.IterPredChoice))'; % averaged across all repeats
    
%     cSessSEM = std(SessStimStrc.IterPredChoice)/sqrt(size(SessStimStrc.IterPredChoice,1));
%     ts = tinv([0.025 0.975],size(SessStimStrc.IterPredChoice,1)-1);
%     CIs = repmat(cSessPredChoice',2,1) + ts'.* cSessSEM;
    PredCI{cSess} = ProbAndCI;
    
    WorstStimPredChoice = cSessPredChoice(WorstStimInds);
    WorstStimBehavChoice = SessStimStrc.UsingAnmChoice(WorstStimInds);
    
    AllStimPredANDBehavChoice{cSess,1} = cSessPredChoice;
    AllStimPredANDBehavChoice{cSess,2} = SessStimStrc.UsingAnmChoice;
%     AllTrCI = zeros(numel(SessStimStrc.UsingAnmChoice),3);
    TrRepeatsAll = sum(SessStimStrc.IterPredChoice);
    [AllpHat,Allpci] = binofit(TrRepeatsAll,NRepeat);
    AllTrCI = [AllpHat(:),Allpci];
    AllSessTrCI{cSess} = AllTrCI;
    %
    HardPredChoiceAll{cSess} = WorstStimPredChoice;
    HardBehavChoiceAll{cSess} = WorstStimBehavChoice;
end

%%
HardPredChoiceVec = cell2mat(HardPredChoiceAll);
hardBehavChoiceVec = cell2mat(HardBehavChoiceAll);
PredCIAll = cell2mat(PredCI);

SMHardPredChoiceVec = smooth(PredCIAll(:,1),15);
SMhardBehavChoiceVec = smooth(hardBehavChoiceVec,15);
Patchx = ([1:numel(SMHardPredChoiceVec),fliplr(1:numel(SMHardPredChoiceVec))])';
Patchy = [smooth(PredCIAll(:,2),15);flipud(smooth(PredCIAll(:,3),15))];
%%
[r,p] = corrcoef(PredCIAll(:,1),hardBehavChoiceVec);
hCoeff = figure('position',[20 100 650 320]);
hold on
patch(Patchx,Patchy,1,'facecolor',[0.8 0.1 0.1],'edgecolor','none','facealpha',0.5)
hl1 = plot(SMHardPredChoiceVec,'Color',[0.8 0.4 0.1],'linewidth',1.5);
hl2 = plot(SMhardBehavChoiceVec,'Color',[.2 .2 .7],'linewidth',1.5);
set(gca,'xlim',[0 numel(SMhardBehavChoiceVec)],'ylim',[-0.05 1.05],'ytick',[0,1],'yTicklabel',{'Left','Right'});
xlabel('Trials');
ylabel('Choice');
set(gca,'FontSize',12);
text(50,1,sprintf('Coef = %.3f, p = %.3e',r(1,2),p(1,2)),'Color','m','FontSize',12);
title('Prediction of the hardest trials');
legend([hl1,hl2],{'Prediction','Behavior'},'Location','southwest','FontSize',12,'Box','off')
text(550,0.1,sprintf('nTrs = %d',numel(SMHardPredChoiceVec)));

saveas(hCoeff,'Hardest trial prediction coef plots');
saveas(hCoeff,'Hardest trial prediction coef plots','png');
saveas(hCoeff,'Hardest trial prediction coef plots','pdf');
close(hCoeff);

%%  summarize neurometric and psychometric curve together

nSession = length(NormSessPathTask);

cSessDataAll = cell(nSession,4);
for cSess = 1 : nSession
    
    tline = NormSessPathTask{cSess};
    
    cTbyTPath = fullfile(tline,'Test_anmChoice_predCROIs');

%     PredChoiceStrc = load(fullfile(cTbyTPath,'ModelPredictionSave.mat'),'IterPredChoice');
    SessStimStrc = load(fullfile(cTbyTPath,'NeuroCurveVSBehav.mat'));
    
    SessOcts = SessStimStrc.StimOctaveTypes(:);
    SessBehavs = SessStimStrc.StimRProb;
    SessTestScore = SessStimStrc.AvgUsedTestRPRob;
    SessPredPerfs = SessStimStrc.PredRightwardPerfMean;
    
    cSessDataAll{cSess,1} = SessOcts;
    cSessDataAll{cSess,2} = SessBehavs;
    cSessDataAll{cSess,3} = SessTestScore;
    cSessDataAll{cSess,4} = SessPredPerfs; 
end

OctBinEdges = [-1.1,-0.7,-0.4,-0.18,0,0.18,0.4,0.7,1.1];
OctCents = [-1,-0.6,-0.2,-0.1,0.1,0.2,0.6,1];
OctsAll = cell2mat(cSessDataAll(:,1));
BehavRProbAll = cell2mat(cSessDataAll(:,2));
TestScoreAll = cell2mat(cSessDataAll(:,3));
TestPredPerfAll = cell2mat(cSessDataAll(:,4));
%%
BehavRProbFit = FitPsycheCurveWH_nx(OctsAll,BehavRProbAll);
TestScoreRProbFit = FitPsycheCurveWH_nx(OctsAll,TestScoreAll);
TestPredPerfRProbFit = FitPsycheCurveWH_nx(OctsAll,TestPredPerfAll);

RProbsAvgWithCent = zeros(3,length(OctCents));
RProbsSemWithCent = zeros(3,length(OctCents));
for cOct = 1 : length(OctCents)
    cOctInds = OctsAll >= OctBinEdges(cOct) & OctsAll < OctBinEdges(cOct+1);
    cOctBehavs = BehavRProbAll(cOctInds);
    RProbsAvgWithCent(1,cOct) = mean(cOctBehavs);
    RProbsSemWithCent(1,cOct) = std(cOctBehavs)/sqrt(numel(cOctBehavs));
    
    cOctTestScore = TestScoreAll(cOctInds);
    RProbsAvgWithCent(2,cOct) = mean(cOctTestScore);
    RProbsSemWithCent(2,cOct) = std(cOctTestScore)/sqrt(numel(cOctTestScore));
    
    cOctPredPerf = TestPredPerfAll(cOctInds);
    RProbsAvgWithCent(3,cOct) = mean(cOctPredPerf);
    RProbsSemWithCent(3,cOct) = std(cOctPredPerf)/sqrt(numel(cOctPredPerf));    
end

%%
hihf = figure('position',[100 100 380 300]);
hold on
hl1 = plot(BehavRProbFit.curve(:,1),BehavRProbFit.curve(:,2),'Color','k','linewidth',1.6);
hl2 = plot(TestScoreRProbFit.curve(:,1),TestScoreRProbFit.curve(:,2),'Color','r','linewidth',1.6);
hl3 = plot(TestPredPerfRProbFit.curve(:,1),TestPredPerfRProbFit.curve(:,2),'Color','m','linewidth',1.6);
errorbar(OctCents,RProbsAvgWithCent(1,:),RProbsSemWithCent(1,:),'ko','linewidth',0.4);
errorbar(OctCents,RProbsAvgWithCent(2,:),RProbsSemWithCent(2,:),'ro','linewidth',0.4);
errorbar(OctCents,RProbsAvgWithCent(3,:),RProbsSemWithCent(3,:),'mo','linewidth',0.4);
set(gca,'xtick',-1:1,'xticklabel',[8 16 32],'ytick',[0 0.5 1],'xlim',[-1.05,1.05]);
xlabel('Frequency (kHz)');
ylabel('Rightchoice Prob.');
set(gca,'FontSize',12);
legend([hl1,hl2,hl3],{'Behav','TestScore','PredPerf'},'Box','off','location','Northwest','FontSize',8);
%%
saveas(hihf,'TrbyTr psychometric and neurometric curve plots');
saveas(hihf,'TrbyTr psychometric and neurometric curve plots','png');
saveas(hihf,'TrbyTr psychometric and neurometric curve plots','pdf');

%% pred all trial choice and behav choice

AllPredChoiceVec = cell2mat(AllStimPredANDBehavChoice(:,1));
AllAllBehavChoiceVec = cell2mat(AllStimPredANDBehavChoice(:,2));
PredCIAllTrs = cell2mat(AllSessTrCI);

SMAllPredChoiceVec = smooth(PredCIAllTrs(:,1),15);
SMhardBehavChoiceVec = smooth(AllAllBehavChoiceVec,15);
Patchx = ([1:numel(SMAllPredChoiceVec),fliplr(1:numel(SMAllPredChoiceVec))])';
Patchy = [smooth(PredCIAllTrs(:,2),15);flipud(smooth(PredCIAllTrs(:,3),15))];
%
[r,p] = corrcoef(PredCIAllTrs(:,1),AllAllBehavChoiceVec);
hCoeff = figure('position',[20 100 650 320]);
hold on
patch(Patchx,Patchy,1,'facecolor',[0.8 0.1 0.1],'edgecolor','none','facealpha',0.5)
hl1 = plot(SMAllPredChoiceVec,'Color',[0.8 0.4 0.1],'linewidth',1.5);
hl2 = plot(SMhardBehavChoiceVec,'Color',[.2 .2 .7],'linewidth',1.5);
set(gca,'xlim',[0 numel(SMhardBehavChoiceVec)],'ylim',[-0.05 1.05],'ytick',[0,1],'yTicklabel',{'Left','Right'});
xlabel('Trials');
ylabel('Choice');
set(gca,'FontSize',12);
text(50,1,sprintf('Coef = %.3f, p = %.3e',r(1,2),p(1,2)),'Color','m','FontSize',12);
title('Prediction of the all trials');
legend([hl1,hl2],{'Prediction','Behavior'},'Location','southwest','FontSize',12,'Box','off')

%% plots the correlation between predicted choice RProb and behav choice
CusMap = blue2red_2(32,0.8);
tbl = fitlm(TestPredPerfAll,BehavRProbAll);
MdRsqure = tbl.Rsquared.Adjusted;
xRange = (linspace(0,1,500))';
LineyValues = predict(tbl,xRange);
MdCoefCI = coefCI(tbl,0.05);
MdCoefData = [MdCoefCI(1,1)+MdCoefCI(2,1)*xRange,MdCoefCI(1,2)+MdCoefCI(2,2)*xRange];
Patchx = [xRange;flipud(xRange)];
Patchy = [MdCoefData(:,1);flipud(MdCoefData(:,2))];

hCoeff = figure('position',[100 100 390 300]);
hold on
patch(Patchx,Patchy,1,'FaceColor',[.7 .7 .7],'edgeColor','none','facealpha',0.5);
scatter(TestPredPerfAll,BehavRProbAll,30,OctsAll(:)+1,'o','filled');
plot(xRange,LineyValues,'k','linewidth',1.6);
set(gca,'xtick',0:0.5:1,'ytick',0:0.5:1,'xlim',[-0.05 1.05],'ylim',[-0.05 1.05]);
xlabel('PredChoice');
ylabel('BehavChoice');
set(gca,'FontSize',12);
text(0.05,0.9,sprintf('R squre = %.3f',MdRsqure));
colormap(CusMap);
hBar = colorbar;
BarPos = get(hBar,'position');
set(hBar,'position',BarPos.*[1 1 0.5 0.3]+[0.08 0.1 0 0]);
set(hBar,'ytick',0:2,'yticklabel',[8 16 32]);
ylabel(hBar,'Frequency (kHz)');
colormap(CusMap);
%%
saveas(hCoeff,'PredChoice and behavChoice coef plots');
saveas(hCoeff,'PredChoice and behavChoice coef plots','png');
saveas(hCoeff,'PredChoice and behavChoice coef plots','pdf');

%% summarize decoding boundary for task and passive condition
clearvars -except NormSessPathTask NormSessPathPass

nSession = length(NormSessPathTask);
NeuroFitBound = zeros(nSession,5);
NeuroFitSTD = zeros(nSession,5);
NeuroFitLOO = cell(nSession,5);
ErrorSess = [];
for cSess = 1 : nSession
    %
    tline = NormSessPathTask{cSess};
    Passline = NormSessPathPass{cSess};
    
    clearvars BehavBoundStrc TaskFitData PassFitData
    BehavBoundStrc = load(fullfile(tline,'RandP_data_plots','boundary_result.mat'));
    try
        BehavBound = BehavBoundStrc.boundary_result.FitValue.ffit.u;
        BehavSTD = BehavBoundStrc.boundary_result.FitValue.ffit.v;
    catch
        BehavBound = BehavBoundStrc.boundary_result.FitValue.u;
        BehavSTD = BehavBoundStrc.boundary_result.FitValue.v;
    end
    
    
    try
        TaskTbyTPath = fullfile(tline,'Test_anmChoice_predCROIs','NeuroCurveVSBehav.mat');
        PassTbyTPath = fullfile(Passline,'Test_anmChoice_predCROIs','NeuroCurveVSBehav.mat');
        
        TaskFitData = load(TaskTbyTPath,'CurTestScorFit','PerfFit');
        PassFitData = load(PassTbyTPath,'CurTestScorFit','PerfFit');

        NeuroFitBound(cSess,:) = [TaskFitData.CurTestScorFit.ffit.u,TaskFitData.PerfFit.ffit.u,...
            PassFitData.CurTestScorFit.ffit.u,PassFitData.PerfFit.ffit.u,BehavBound-1];
        NeuroFitSTD(cSess,:) = [TaskFitData.CurTestScorFit.ffit.v,TaskFitData.PerfFit.ffit.v,...
            PassFitData.CurTestScorFit.ffit.v,PassFitData.PerfFit.ffit.v,BehavSTD];

    catch ME
        fprintf('Error for session %d.\n',cSess);
        ErrorSess = [ErrorSess,cSess];
        disp(ME);
    end
    TaskLOODataPath = fullfile(tline,'Test_anmChoice_LOO','LOOPred_NeuroCurve.mat');
    TaskLOOData = load(TaskLOODataPath);
    NeuroFitLOO(cSess,:) = {TaskLOOData.MdSelfPerf,TaskLOOData.BehavFit.ffit.u,TaskLOOData.BehavFit.ffit.v,...
            TaskLOOData.PredPerfFits.ffit.u,TaskLOOData.PredPerfFits.ffit.v};
end
NeuroFitBound(ErrorSess,:) = [];
NeuroFitSTD(ErrorSess,:) = [];
%% boundary correlation plots 1
[TR,TP] = corrcoef(NeuroFitBound(:,5),NeuroFitBound(:,1));
TaskCorrANDp = [TR(1,2),TP(1,2)];
[PR,PP] = corrcoef(NeuroFitBound(:,5),NeuroFitBound(:,3));
PassCorrANDp = [PR(1,2),PP(1,2)];
hf = figure('position',[2000 100 380 320]);
hold on
plot(NeuroFitBound(:,5),NeuroFitBound(:,1),'o','Color',[1 0.6 0.1],'linewidth',1.2);
plot(NeuroFitBound(:,5),NeuroFitBound(:,3),'o','Color','k','linewidth',1.2);
cScales = UniAxesScale(gca);
line(cScales,cScales,'Color',[.7 .7 .7],'linewidth',1,'linestyle','--');
line([0 0],cScales,'Color',[.7 .7 .7],'linewidth',1,'linestyle','--');
line(cScales,[0 0],'Color',[.7 .7 .7],'linewidth',1,'linestyle','--');
tt = text([0 0],[-0.4,-0.5],{sprintf('Coef %.3f,%.3e',TR(1,2),TP(1,2)),sprintf('Coef %.3f,%.3e',PR(1,2),PP(1,2))});
tt(1).Color = [1 0.6 0.1];
tt(2).Color = 'k';
xlabel('Behavior');
ylabel('Neurometric');
%%
saveas(hf,'TestScore neurometric boundary plots');
saveas(hf,'TestScore neurometric boundary plots','png');
saveas(hf,'TestScore neurometric boundary plots','pdf');

%% boundary correlation plots 2

[TR,TP] = corrcoef(NeuroFitBound(:,5),NeuroFitBound(:,2));
TaskCorrANDp = [TR(1,2),TP(1,2)];
[PR,PP] = corrcoef(NeuroFitBound(:,5),NeuroFitBound(:,4));
PassCorrANDp = [PR(1,2),PP(1,2)];
hf = figure('position',[2400 100 380 320]);
hold on
plot(NeuroFitBound(:,5),NeuroFitBound(:,2),'o','Color',[1 0.6 0.1],'linewidth',1.2);
plot(NeuroFitBound(:,5),NeuroFitBound(:,4),'o','Color','k','linewidth',1.2);
cScales = UniAxesScale(gca);
line(cScales,cScales,'Color',[.7 .7 .7],'linewidth',1,'linestyle','--');
line([0 0],cScales,'Color',[.7 .7 .7],'linewidth',1,'linestyle','--');
line(cScales,[0 0],'Color',[.7 .7 .7],'linewidth',1,'linestyle','--');
tt = text([-0.6 -0.6],[0.2,0.3],{sprintf('C%.3f,%.3e',TR(1,2),TP(1,2)),sprintf('C%.3f,%.3e',PR(1,2),PP(1,2))});
tt(1).Color = [1 0.6 0.1];
tt(2).Color = 'k';
xlabel('Behavior');
ylabel('Neurometric');
%%
saveas(hf,'TestPerf neurometric boundary plots');
saveas(hf,'TestPerf neurometric boundary plots','png');
saveas(hf,'TestPerf neurometric boundary plots','pdf');

%%
% slope correlation plots 1
[TR,TP] = corrcoef(NeuroFitSTD(:,5),NeuroFitSTD(:,1));
TaskScoreCorrANDp = [TR(1,2),TP(1,2)];
[PR,PP] = corrcoef(NeuroFitSTD(:,5),NeuroFitSTD(:,3));
PassScoreCorrANDp = [PR(1,2),PP(1,2)];
hf = figure('position',[2000 100 380 320]);
hold on
plot(NeuroFitSTD(:,5),NeuroFitSTD(:,1),'o','Color',[1 0.6 0.1],'linewidth',1.2);
plot(NeuroFitSTD(:,5),NeuroFitSTD(:,3),'o','Color','k','linewidth',1.2);
cScales = UniAxesScale(gca);
line(cScales,cScales,'Color',[.7 .7 .7],'linewidth',1,'linestyle','--');
% line([0 0],cScales,'Color',[.7 .7 .7],'linewidth',1,'linestyle','--');
% line(cScales,[0 0],'Color',[.7 .7 .7],'linewidth',1,'linestyle','--');
tt = text([0.6 0.6],[.6 .7],{sprintf('C %.3f,%.3e',TaskScoreCorrANDp(1),TaskScoreCorrANDp(2)),...
    sprintf('C %.3f,%.3e',PassScoreCorrANDp(1),PassScoreCorrANDp(2))});
tt(1).Color = [1 0.6 0.1];
tt(2).Color = 'k';
xlabel('Behavior');
ylabel('Neurometric');

saveas(hf,'TestScore neurometric threshold plots');
saveas(hf,'TestScore neurometric threshold plots','png');
saveas(hf,'TestScore neurometric threshold plots','pdf');

%% slope correlation plots 2

[TR,TP] = corrcoef(NeuroFitSTD(:,5),NeuroFitSTD(:,2));
TaskPerfCorrANDp = [TR(1,2),TP(1,2)];
[PR,PP] = corrcoef(NeuroFitSTD(:,5),NeuroFitSTD(:,4));
PassPerfCorrANDp = [PR(1,2),PP(1,2)];
hf = figure('position',[2400 100 380 320]);
hold on
plot(NeuroFitSTD(:,5),NeuroFitSTD(:,2),'o','Color',[1 0.6 0.1],'linewidth',1.2);
plot(NeuroFitSTD(:,5),NeuroFitSTD(:,4),'o','Color','k','linewidth',1.2);
cScales = UniAxesScale(gca);
line(cScales,cScales,'Color',[.7 .7 .7],'linewidth',1,'linestyle','--');
% line([0 0],cScales,'Color',[.7 .7 .7],'linewidth',1,'linestyle','--');
% line(cScales,[0 0],'Color',[.7 .7 .7],'linewidth',1,'linestyle','--');
tt = text([.7 .7],[0.5 0.6],{sprintf('C %.3f,%.3e',TaskPerfCorrANDp(1),TaskPerfCorrANDp(2)),...
    sprintf('C %.3f,%.3e',PassPerfCorrANDp(1),PassPerfCorrANDp(2))});
tt(1).Color = [1 0.6 0.1];
tt(2).Color = 'k';
xlabel('Behavior');
ylabel('Neurometric');

saveas(hf,'TestPerf neurometric threshold plots');
saveas(hf,'TestPerf neurometric threshold plots','png');
saveas(hf,'TestPerf neurometric threshold plots','pdf');

%% boundary correlation plots for LOO method
% cd('E:\DataToGo\NewDataForXU\OldBatchData_SingleTrChoicePred');
MDperf = cellfun(@mean,NeuroFitLOO(:,1));
BehavBounds = cell2mat(NeuroFitLOO(:,2));
TaskLOOBound = cell2mat(NeuroFitLOO(:,4));
BehavThreshold = cell2mat(NeuroFitLOO(:,3));
TaskLOOThreshold = cell2mat(NeuroFitLOO(:,5));
[TR,TP] = corrcoef(BehavBounds,TaskLOOBound);
TaskCorrANDp = [TR(1,2),TP(1,2)];
[TThresR,TThresP] = corrcoef(BehavThreshold,TaskLOOThreshold);
ThresCorrANDp = [TThresR(1,2),TThresP(1,2)];

hf = figure('position',[2200 100 650 260]);
subplot(121)
plot(BehavBounds,TaskLOOBound,'o','Color',[1 0.6 0.1],'linewidth',1.2);
cScales = UniAxesScale(gca);
line(cScales,cScales,'Color',[.7 .7 .7],'linewidth',1,'linestyle','--');
line([0 0],cScales,'Color',[.7 .7 .7],'linewidth',1,'linestyle','--');
line(cScales,[0 0],'Color',[.7 .7 .7],'linewidth',1,'linestyle','--');
tt = text(-0.6,0.2,sprintf('C%.3f,%.3e',TR(1,2),TP(1,2)));
tt(1).Color = [1 0.6 0.1];
title('Boundary')
xlabel('Behavior');
ylabel('Neurometric');
set(gca,'box','off');

subplot(122)
plot(BehavThreshold,TaskLOOThreshold,'o','Color',[1 0.6 0.1],'linewidth',1.2);
cScales = UniAxesScale(gca);
line(cScales,cScales,'Color',[.7 .7 .7],'linewidth',1,'linestyle','--');
t2 = text(1,0.4,sprintf('C%.3f,%.3e',TThresR(1,2),TThresP(1,2)));
xlabel('Behavior');
ylabel('Neurometric');
title('Threshold')
set(gca,'box','off');
%%
saveas(hf,'LOO method based boundary and threshold correlation');
saveas(hf,'LOO method based boundary and threshold correlation','png');
saveas(hf,'LOO method based boundary and threshold correlation','pdf');
% ##########################################################################################################################
%% passive session neurometric curve plot
%%  summarize neurometric and psychometric curve together

nSession = length(NormSessPathPass);

cSessDataAll = cell(nSession,4);
for cSess = 1 : nSession
    
    tline = NormSessPathPass{cSess};
    
    cTbyTPath = fullfile(tline,'Test_anmChoice_predCROIs');

%     PredChoiceStrc = load(fullfile(cTbyTPath,'ModelPredictionSave.mat'),'IterPredChoice');
   try  
        SessStimStrc = load(fullfile(cTbyTPath,'NeuroCurveVSBehav.mat'));

        SessOcts = SessStimStrc.StimOctaveTypes(:);
        SessBehavs = SessStimStrc.StimRProb;
        SessTestScore = SessStimStrc.AvgUsedTestRPRob;
        SessPredPerfs = SessStimStrc.PredRightwardPerfMean;
        if numel(SessBehavs) > numel(SessOcts)
            SessBehavs(ceil(numel(SessBehavs)/2)) = [];
        end
        cSessDataAll{cSess,1} = SessOcts;
        cSessDataAll{cSess,2} = SessBehavs(:);
        cSessDataAll{cSess,3} = SessTestScore;
        cSessDataAll{cSess,4} = SessPredPerfs; 
        
    catch
        fprintf('Error for session %d.\n',cSess);
    end
end

OctBinEdges = [-1.1,-0.7,-0.4,-0.18,0,0.18,0.4,0.7,1.1];
OctCents = [-1,-0.6,-0.2,-0.1,0.1,0.2,0.6,1];
PassOctsAll = cell2mat(cSessDataAll(:,1));
PassBehavRProbAll = cell2mat(cSessDataAll(:,2));
PassTestScoreAll = cell2mat(cSessDataAll(:,3));
PassTestPredPerfAll = cell2mat(cSessDataAll(:,4));
%%
BehavRProbFitPass = FitPsycheCurveWH_nx(PassOctsAll,PassBehavRProbAll);
TestScoreRProbFitPass = FitPsycheCurveWH_nx(PassOctsAll,PassTestScoreAll);
TestPredPerfRProbFitPass = FitPsycheCurveWH_nx(PassOctsAll,PassTestPredPerfAll);

RProbsAvgWithCentPass = zeros(3,length(OctCents));
RProbsSemWithCentPass = zeros(3,length(OctCents));
for cOct = 1 : length(OctCents)
    cOctInds = PassOctsAll >= OctBinEdges(cOct) & PassOctsAll < OctBinEdges(cOct+1);
    cOctBehavs = PassBehavRProbAll(cOctInds);
    RProbsAvgWithCentPass(1,cOct) = mean(cOctBehavs);
    RProbsSemWithCentPass(1,cOct) = std(cOctBehavs)/sqrt(numel(cOctBehavs));
    
    cOctTestScore = PassTestScoreAll(cOctInds);
    RProbsAvgWithCentPass(2,cOct) = mean(cOctTestScore);
    RProbsSemWithCentPass(2,cOct) = std(cOctTestScore)/sqrt(numel(cOctTestScore));
    
    cOctPredPerf = PassTestPredPerfAll(cOctInds);
    RProbsAvgWithCentPass(3,cOct) = mean(cOctPredPerf);
    RProbsSemWithCentPass(3,cOct) = std(cOctPredPerf)/sqrt(numel(cOctPredPerf));    
end

%%
hihf = figure('position',[100 100 380 300]);
hold on
hl1 = plot(BehavRProbFitPass.curve(:,1),BehavRProbFitPass.curve(:,2),'Color','k','linewidth',1.6);
hl2 = plot(TestScoreRProbFitPass.curve(:,1),TestScoreRProbFitPass.curve(:,2),'Color','r','linewidth',1.6);
hl3 = plot(TestPredPerfRProbFitPass.curve(:,1),TestPredPerfRProbFitPass.curve(:,2),'Color','m','linewidth',1.6);
errorbar(OctCents,RProbsAvgWithCentPass(1,:),RProbsSemWithCentPass(1,:),'ko','linewidth',0.4);
errorbar(OctCents,RProbsAvgWithCentPass(2,:),RProbsSemWithCentPass(2,:),'ro','linewidth',0.4);
errorbar(OctCents,RProbsAvgWithCentPass(3,:),RProbsSemWithCentPass(3,:),'mo','linewidth',0.4);
set(gca,'xtick',-1:1,'xticklabel',[8 16 32],'ytick',[0 0.5 1],'xlim',[-1.05,1.05]);
xlabel('Frequency (kHz)');
ylabel('Rightchoice Prob.');
set(gca,'FontSize',12);
legend([hl1,hl2,hl3],{'Behav','TestScore','PredPerf'},'Box','off','location','Northwest','FontSize',8);


%%
% combine task and passive curve plots together
hComf = figure('position',[100 100 380 300]);
hold on
hComp1 = plot(BehavRProbFit.curve(:,1),BehavRProbFit.curve(:,2),'Color','k','linewidth',1.6);
hlCompTask = plot(TestScoreRProbFit.curve(:,1),TestScoreRProbFit.curve(:,2),'Color',[1 0.8 0.4],'linewidth',1.6);
hlCompPass = plot(TestScoreRProbFitPass.curve(:,1),TestScoreRProbFitPass.curve(:,2),'Color',[.7 .7 .7],'linewidth',1.6);

errorbar(OctCents,RProbsAvgWithCent(1,:),RProbsSemWithCent(1,:),'ko','linewidth',0.4);
errorbar(OctCents,RProbsAvgWithCent(2,:),RProbsSemWithCent(2,:),'o','linewidth',0.4,'Color',[1 0.8 0.2]);
errorbar(OctCents,RProbsAvgWithCentPass(2,:),RProbsSemWithCentPass(2,:),'o','linewidth',0.4,'Color',[.7 .7 .7]);
set(gca,'xtick',-1:1,'xticklabel',[8 16 32],'ytick',[0 0.5 1],'xlim',[-1.05,1.05]);
xlabel('Frequency (kHz)');
ylabel('Rightchoice Prob.');
set(gca,'FontSize',12);
legend([hl1,hl2,hl3],{'Behav','TaskNeuro','PassNeuro'},'Box','off','location','Northwest','FontSize',8);

saveas(hComf,'TrbyTr psychometric and TPneurometric curve plots');
saveas(hComf,'TrbyTr psychometric and TPneurometric curve plots','png');
saveas(hComf,'TrbyTr psychometric and TPneurometric curve plots','pdf');
%% combine foe same population two different range tests
cclr
[fn,fp,fi] = uigetfile('*.txt','Please select the compasison session path file'); 
if ~fi
    return; 
end 
fPath = fullfile(fp,fn); 
%%
fid = fopen(fPath);
tline = fgetl(fid);
SessType = 0;
SessPathAll = {};
m = 1;
while ischar(tline)
    if ~isempty(strfind(tline,'######')) % new section flag
        SessType = SessType + 1;
        tline = fgetl(fid);
        continue;
    end
    if ~isempty(strfind(tline,'NO_Correction\mode_f_change'))
        SessPathAll{m,1} = tline;
        SessPathAll{m,2} = SessType;
        
        [~,EndInds] = regexp(tline,'test\d{2,3}');
        cPassDataUpperPath = fullfile(sprintf('%srf',tline(1:EndInds)),'im_data_reg_cpu','result_save');

        [~,InfoDataEndInds] = regexp(tline,'result_save');
        PassPathline = fullfile(sprintf('%srf%s',tline(1:EndInds),tline(EndInds+1:InfoDataEndInds)),'plot_save','NO_Correction');
        SessPathAll{m,3} = PassPathline;
        
        m = m + 1;
    end
    tline = fgetl(fid);
end
SessIndexAll = cell2mat(SessPathAll(:,2));
%%
Is832Sess = 1;
Sess8_32_Inds = SessIndexAll == 1;
Sess8_32PathAll = SessPathAll(Sess8_32_Inds,1);
Sess8_32PassPath = SessPathAll(Sess8_32_Inds,3);

Sess4_16_Part1_Inds = SessIndexAll == 2;
Sess4_16_Part1_PathAll = SessPathAll(Sess4_16_Part1_Inds,1);
Sess4_16PassPath = SessPathAll(Sess4_16_Part1_Inds,3);

if length(Sess4_16_Part1_PathAll) ~= length(Sess8_32PathAll)
    warning('The session path number is different, please check your input data.\n');
    return;
end
%%
NumPaths = length(Sess4_16_Part1_PathAll);
c832NeuroFitLOO = cell(NumPaths,5);
c416NeuroFitLOO = cell(NumPaths,5);
for cPath = 1 : NumPaths
    c832Path = Sess8_32PathAll{cPath};
    c832PassPath = Sess8_32PassPath{cPath};
    c416Path = Sess4_16_Part1_PathAll{cPath};
    c416PassPath = Sess4_16PassPath{cPath};
    
    clearvars BehavBoundStrc
    BehavBoundStrc = load(fullfile(c832Path,'RandP_data_plots','boundary_result.mat'));
    ToneStimsBase = log2(min(BehavBoundStrc.boundary_result.StimType)/4000);
    
    if Is832Sess
        c832TaskLOODataPath = fullfile(c832Path,'Test_anmChoice_LOO832','LOOPred_NeuroCurve.mat'); 
    else
        c832TaskLOODataPath = fullfile(c832Path,'Test_anmChoice_LOO','LOOPred_NeuroCurve.mat');
    end
    c832TaskLOOData = load(c832TaskLOODataPath);
    c832NeuroFitLOO(cPath,:) = {c832TaskLOOData.MdSelfPerf,c832TaskLOOData.BehavFit.ffit.u+ToneStimsBase+1,...
        c832TaskLOOData.BehavFit.ffit.v,...
            c832TaskLOOData.PredPerfFits.ffit.u+ToneStimsBase+1,c832TaskLOOData.PredPerfFits.ffit.v};
    
    % loading 416 session data 
    clearvars BehavBoundStrc416
%     BehavBoundStrc416 = load(fullfile(c416Path,'RandP_data_plots','boundary_result.mat'));
    
    if Is832Sess
        c416TaskLOODataPath = fullfile(c416Path,'Test_anmChoice_LOO832','LOOPred_NeuroCurve.mat'); 
    else
        c416TaskLOODataPath = fullfile(c416Path,'Test_anmChoice_LOO','LOOPred_NeuroCurve.mat'); 
    end
    c416TaskLOOData = load(c416TaskLOODataPath);
    c416NeuroFitLOO(cPath,:) = {c416TaskLOOData.MdSelfPerf,c416TaskLOOData.BehavFit.ffit.u+1,c416TaskLOOData.BehavFit.ffit.v,...
            c416TaskLOOData.PredPerfFits.ffit.u+1,c416TaskLOOData.PredPerfFits.ffit.v};
    
end

%%
MDperf = cellfun(@mean,c832NeuroFitLOO(:,1));
BehavBounds = cell2mat(c832NeuroFitLOO(:,2));
TaskLOOBound = cell2mat(c832NeuroFitLOO(:,4));
BehavThreshold = cell2mat(c832NeuroFitLOO(:,3));
TaskLOOThreshold = cell2mat(c832NeuroFitLOO(:,5));

MDperf416 = cellfun(@mean,c416NeuroFitLOO(:,1));
BehavBounds416 = cell2mat(c416NeuroFitLOO(:,2));
TaskLOOBound416 = cell2mat(c416NeuroFitLOO(:,4));
BehavThreshold416 = cell2mat(c416NeuroFitLOO(:,3));
TaskLOOThreshold416 = cell2mat(c416NeuroFitLOO(:,5));

[TR,TP] = corrcoef(BehavBounds,TaskLOOBound);
TaskCorrANDp = [TR(1,2),TP(1,2)];
[TThresR,TThresP] = corrcoef(BehavThreshold,TaskLOOThreshold);
ThresCorrANDp = [TThresR(1,2),TThresP(1,2)];

[TR416,TP416] = corrcoef(BehavBounds416,TaskLOOBound416);
TaskCorrANDp416 = [TR416(1,2),TP416(1,2)];
[TThresR416,TThresP416] = corrcoef(BehavThreshold416,TaskLOOThreshold416);
ThresCorrANDp416 = [TThresR416(1,2),TThresP416(1,2)];
%%
h816f = figure('position',[2200 100 650 260]);
subplot(121)
hold on
plot(BehavBounds,TaskLOOBound,'o','Color','r','linewidth',1.2);
plot(BehavBounds416,TaskLOOBound416,'o','Color','b','linewidth',1.2);
% cScales = UniAxesScale(gca);
cScales = [-0.1 3.1];
set(gca,'xlim',cScales,'ylim',cScales);
line(cScales,cScales,'Color',[.7 .7 .7],'linewidth',1,'linestyle','--');
line([0 0],cScales,'Color',[.7 .7 .7],'linewidth',1,'linestyle','--');
line(cScales,[0 0],'Color',[.7 .7 .7],'linewidth',1,'linestyle','--');
tt = text(1.5,0.4,sprintf('C%.3f,%.3e',TR(1,2),TP(1,2)));
tt2 = text(1.5,0.8,sprintf('C%.3f,%.3e',TR416(1,2),TP416(1,2)));
tt(1).Color = 'r';
tt2(1).Color = 'b';
title('Boundary')
xlabel('Behavior');
ylabel('Neurometric');
set(gca,'box','off');

subplot(122)
hold on
plot(BehavThreshold,TaskLOOThreshold,'o','Color','r','linewidth',1.2);
plot(BehavThreshold416,TaskLOOThreshold416,'o','Color','b','linewidth',1.2);
cScales = UniAxesScale(gca);
line(cScales,cScales,'Color',[.7 .7 .7],'linewidth',1,'linestyle','--');
t2 = text(0.6,0.4,sprintf('C%.3f,%.3e',TThresR(1,2),TThresP(1,2)),'Color','r');
t22 = text(0.6,0.5,sprintf('C%.3f,%.3e',TThresR416(1,2),TThresP416(1,2)),'Color','b');
xlabel('Behavior');
ylabel('Neurometric');
title('Threshold')
set(gca,'box','off');

%%
cd('S:\BatchData\batch55\summarization\TbyTLOO_MethodCorrelation');
saveas(h816f,'Sess716 NeuroANDBehav Bound and thres corr');
saveas(h816f,'Sess716 NeuroANDBehav Bound and thres corr','png');
saveas(h816f,'Sess716 NeuroANDBehav Bound and thres corr','pdf');

%% merging two session data together
CMergBehavBounds = [BehavBounds;BehavBounds416];
CMergeLOOBounds = [TaskLOOBound;TaskLOOBound416];
CMergBehavThres = [BehavThreshold;TaskLOOThreshold];
CMergLOOThres = [BehavThreshold416;TaskLOOThreshold416];

[TRMerge,TPMerge] = corrcoef(CMergBehavBounds,CMergeLOOBounds);
TaskCorrANDpMerg = [TRMerge(1,2),TPMerge(1,2)];
[TThresRMerge,TThresPMerge] = corrcoef(CMergBehavThres,CMergLOOThres);
ThresCorrANDpMerg = [TThresRMerge(1,2),TThresPMerge(1,2)];
%%
hf = figure('position',[2200 100 650 260]);
subplot(121)
plot(CMergBehavBounds,CMergeLOOBounds,'o','Color',[1 0.6 0.1],'linewidth',1.2);
cScales = UniAxesScale(gca);
line(cScales,cScales,'Color',[.7 .7 .7],'linewidth',1,'linestyle','--');
line([0 0],cScales,'Color',[.7 .7 .7],'linewidth',1,'linestyle','--');
line(cScales,[0 0],'Color',[.7 .7 .7],'linewidth',1,'linestyle','--');
tt = text(1.5,0.3,sprintf('C%.3f,%.3e',TRMerge(1,2),TPMerge(1,2)));
tt(1).Color = [1 0.6 0.1];
title('Boundary')
xlabel('Behavior');
ylabel('Neurometric');
set(gca,'box','off');

subplot(122)
plot(CMergBehavThres,CMergLOOThres,'o','Color',[1 0.6 0.1],'linewidth',1.2);
cScales = UniAxesScale(gca);
line(cScales,cScales,'Color',[.7 .7 .7],'linewidth',1,'linestyle','--');
t2 = text(1,0.4,sprintf('C%.3f,%.3e',TThresRMerge(1,2),TThresPMerge(1,2)));
xlabel('Behavior');
ylabel('Neurometric');
title('Threshold')
set(gca,'box','off');

%% loading old method neurometric curve
Is816Sess = 1;
Sess8_32_Inds = SessIndexAll == 1;
Sess8_32PathAll = SessPathAll(Sess8_32_Inds,1);
Sess8_32PassPath = SessPathAll(Sess8_32_Inds,3);

Sess4_16_Part1_Inds = SessIndexAll == 2;
Sess4_16_Part1_PathAll = SessPathAll(Sess4_16_Part1_Inds,1);
Sess4_16PassPath = SessPathAll(Sess4_16_Part1_Inds,3);

if length(Sess4_16_Part1_PathAll) ~= length(Sess8_32PathAll)
    warning('The session path number is different, please check your input data.\n');
    return;
end
%
NumPaths = length(Sess4_16_Part1_PathAll);
c832NeuroFitSummary = zeros(NumPaths,6);
c416NeuroFitSummary = zeros(NumPaths,6);
for cPath = 1 : NumPaths
    c832Path = Sess8_32PathAll{cPath};
    c832PassPath = Sess8_32PassPath{cPath};
    c416Path = Sess4_16_Part1_PathAll{cPath};
    c416PassPath = Sess4_16PassPath{cPath};
    
    clearvars BehavBoundStrc
    BehavBoundStrc = load(fullfile(c832Path,'RandP_data_plots','boundary_result.mat'));
    try
        BehavBound = BehavBoundStrc.boundary_result.FitValue.ffit.u;
        BehavSTD = BehavBoundStrc.boundary_result.FitValue.ffit.v;
    catch
        BehavBound = BehavBoundStrc.boundary_result.FitValue.u;
        BehavSTD = BehavBoundStrc.boundary_result.FitValue.v;
    end
    if Is816Sess
        c832TaskDataPath = fullfile(c832Path,'Test_anmChoice_predCROIs832','NeuroCurveVSBehav.mat'); 
    else
        c832TaskDataPath = fullfile(c832Path,'Test_anmChoice_predCROIs','NeuroCurveVSBehav.mat'); 
    end
    c832TaskDataStrc = load(c832TaskDataPath,'CurTestScorFit','PerfFit');
    c832NeuroFitSummary(cPath,:) = [c832TaskDataStrc.CurTestScorFit.ffit.u,c832TaskDataStrc.PerfFit.ffit.u,...
        BehavBound-1,c832TaskDataStrc.CurTestScorFit.ffit.v,c832TaskDataStrc.PerfFit.ffit.v,BehavSTD];
    
    % loading 416 session data 
    clearvars BehavBoundStrc416
    BehavBoundStrc416 = load(fullfile(c416Path,'RandP_data_plots','boundary_result.mat'));
    try
        BehavBound416 = BehavBoundStrc416.boundary_result.FitValue.ffit.u;
        BehavSTD416 = BehavBoundStrc416.boundary_result.FitValue.ffit.v;
    catch
        BehavBound416 = BehavBoundStrc416.boundary_result.FitValue.u;
        BehavSTD416 = BehavBoundStrc416.boundary_result.FitValue.v;
    end
    if Is816Sess
        c416TaskDataPath = fullfile(c416Path,'Test_anmChoice_predCROIs832','NeuroCurveVSBehav.mat'); 
    else
        c416TaskDataPath = fullfile(c416Path,'Test_anmChoice_predCROIs','NeuroCurveVSBehav.mat'); 
    end
    c416TaskDataStrc = load(c416TaskDataPath,'CurTestScorFit','PerfFit');
    c416NeuroFitSummary(cPath,:) = [c416TaskDataStrc.CurTestScorFit.ffit.u,c416TaskDataStrc.PerfFit.ffit.u,...
        BehavBound416-1,c416TaskDataStrc.CurTestScorFit.ffit.v,c416TaskDataStrc.PerfFit.ffit.v,BehavSTD416];
    
end

%%
figure;
hold on
plot(c416NeuroFitSummary(:,6),c416NeuroFitSummary(:,4),'ro');
plot(c416NeuroFitSummary(:,6),c416NeuroFitSummary(:,5),'ko');
figure;
hold on
plot(c416NeuroFitSummary(:,3),c416NeuroFitSummary(:,1),'ro');
plot(c416NeuroFitSummary(:,3),c416NeuroFitSummary(:,2),'ko');

%% generate a random choice correlation for comparison
nTrials = 726;
nRepeat = 1000;
RandR = zeros(nRepeat,1);
for cRe = 1 : nRepeat
    RandData = rand(2,nTrials);
    RandBinaryData = double(RandData > 0.5);
    [cR,cP] = corrcoef(RandBinaryData(1,:),RandBinaryData(2,:));
    RandR(cRe) = cR(1,2);
end
    
    
