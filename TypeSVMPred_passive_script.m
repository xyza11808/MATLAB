TrType = double(StimAll >= 16000);
%% Stimulus based labeling
nTrs = length(TrType);
StimsAll = double(CorrTrialStim);
StimTypes = unique(StimsAll);
nStims = length(StimTypes);
RealLoss = zeros(nTrs,1);

    TrainMdl = fitcsvm(ConsideringData,TrType);
    c = crossval(TrainMdl,'leaveOut','on');
    CVTrInds = zeros(nTrs,1);
    for cTrs = 1 : nTrs
        CVTrInds(cTrs) = find(c.Partition.test(cTrs));
    end
    L = kfoldLoss(c,'mode','individual');
    RealLoss(CVTrInds) = L;
    %
    
    StimRProb = zeros(nStims,1);
    StimDataAvg = zeros(nStims,size(ConsideringData,2));
    for cStimInds = 1 : nStims
        cStim = StimTypes(cStimInds);
        cStimTrs = StimsAll == cStim;
        cStimRProb = mean(RealLoss(cStimTrs));
        if cStim <= 16000
            StimRProb(cStimInds) = cStimRProb;
        else
            StimRProb(cStimInds) = 1 - cStimRProb;
        end
        cStimData = ConsideringData(cStimTrs,:);
        StimDataAvg(cStimInds,:) = mean(cStimData);
    end
StimBasedRProb = StimRProb;
StimOcts = log2(StimTypes/16000);
StimStrs = cellstr(num2str(StimTypes(:)/1000,'%.1f'));

BehavRProb = boundary_result.StimCorr;
StimRevert = boundary_result.StimType < 16000;
TaskStimOcts = log2(boundary_result.StimType/16000);
TaskStimStrs = cellstr(num2str(boundary_result.StimType(:)/1000,'%.1f'));
BehavRProb(StimRevert) = 1 - BehavRProb(StimRevert);

[~,PredScore] = predict(TrainMdl,StimDataAvg);
TypeNorSc = (max(BehavRProb) - min(BehavRProb)) * (PredScore(:,2) - min(PredScore(:,2)))/...
    (max(PredScore(:,2)) - min(PredScore(:,2))) + min(BehavRProb);
StimScoreAll = {BehavRProb,PredScore,TypeNorSc};
StimNorScore = TypeNorSc;

hf = figure('position',[100 100 600 240]);
subplot(121)
plot(StimOcts,StimBasedRProb,'r-o','linewidth',1.6);
set(gca,'xtick',StimOcts,'xticklabel',StimStrs,'ylim',[0 1],'ytick',[0 0.5 1]);
title('StimBase')
xlabel('Freqs (kHz)');
ylabel('Accuracy');
set(gca,'FontSize',14);

subplot(122)
%%
hold on
hl1 = plot(TaskStimOcts,BehavRProb,'k-o','linewidth',1.6);
hl2 = plot(StimOcts,StimNorScore,'g-o','linewidth',1.6);
set(gca,'xtick',TaskStimOcts,'xticklabel',TaskStimStrs,'ylim',[0 1],'ytick',[0 0.5 1]);
title('StimBase')
xlabel('Freqs (kHz)');
ylabel('NorRProb');
legend([hl1,hl2],{'Behav','NorScore'},'Box','off','location','Northwest');
%%

saveas(hf,'NoBound Popu Passive StimBased SVM plots');
saveas(hf,'NoBound Popu Passive StimBased SVM plots','png');
close(hf);

save NoBoundPassSVMSave.mat StimBasedRProb StimTypes StimScoreAll StimNorScore -v7.3
