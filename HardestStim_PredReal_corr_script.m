clearvars -except NormSessPathTask NormSessPathPass

nSession = length(NormSessPathTask);

HardPredChoiceAll = cell(nSession,1);
HardBehavChoiceAll = cell(nSession,1);
PredCI = cell(nSession,1);
for cSess = 1 : nSession
    
    tline = NormSessPathTask{cSess};
    
    cTbyTPath = fullfile(tline,'Test_anmChoice_predNew');

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
hl1 = plot(SMHardPredChoiceVec,'Color',[0.7 0.5 0.2],'linewidth',1.5);
hl2 = plot(SMhardBehavChoiceVec,'Color',[.4 .4 .7],'linewidth',1.5);
set(gca,'xlim',[0 numel(SMhardBehavChoiceVec)],'ylim',[-0.05 1.05],'ytick',[0,1],'yTicklabel',{'Left','Right'});
xlabel('Trials');
ylabel('Choice');
set(gca,'FontSize',12);
text(50,1,sprintf('Coef = %.3f, p = %.3e',r(1,2),p(1,2)),'Color','m','FontSize',12);
title('Prediction of the hardest trials');
legend([hl1,hl2],{'Prediction','Behavior'},'Location','southwest','FontSize',12,'Box','off')

saveas(hCoeff,'Hardest trial prediction coef plots');
saveas(hCoeff,'Hardest trial prediction coef plots','png');
close(hCoeff);

