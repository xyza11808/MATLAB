clearvars -except NormSessPathTask NormSessPathPass

nSession = length(NormSessPathTask);

HardPredChoiceAll = cell(nSession,1);
HardBehavChoiceAll = cell(nSession,1);
AllStimPredANDBehavChoice = cell(nSession,3);
PredCI = cell(nSession,1);
AllSessTrCI = cell(nSession,1);
for cSess = 1 : nSession
    %
    tline = NormSessPathTask{cSess};
    
    cTbyTPath = fullfile(tline,'Test_anmChoice_predNewCROIs');

%     PredChoiceStrc = load(fullfile(cTbyTPath,'ModelPredictionSave.mat'),'IterPredChoice');
    SessStimStrc = load(fullfile(cTbyTPath,'AnmChoicePredSaveNew.mat'),'Stimlulus','RealStimPerf','UsingAnmChoice','StimInds','IterPredChoice');
    [~,WorstPerfInds] = min(SessStimStrc.RealStimPerf);
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
    
    cTbyTPath = fullfile(tline,'Test_anmChoice_predNewCROIs');

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


