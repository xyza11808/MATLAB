% scripts for passive data trial-by-Trial trial choice decoding
Boundary = 16000;
PassSounds = unique(SelectSArray);
presumedTrialTypes = SelectSArray > Boundary;

%%
TimeScale = 1.5;
if length(TimeScale) == 1
    FrameScale = sort([(start_frame+1),(start_frame + round(TimeScale*frame_rate))]);
elseif length(TimeScale) == 2
    FrameScale = sort([(start_frame + round(TimeScale(1)*frame_rate)),(start_frame + round(TimeScale(2)*frame_rate))]);
end
RespData = max(SelectData(:,:,FrameScale(1):FrameScale(2)),[],3);

%%
[nTrs,nROI] = size(RespData);
FoldsRange = 10:25;
foldLen = length(foldsRange);
IterPredChoice = zeros(foldLen,nTrs);
for nIter = 1 : foldLen
    cflods = FoldsRange(nIter);
    cp = cvpartition(nTrs,'k',cflods);
    PredChoice = zeros(nTrs,1);
    for nn = 1 : cflods
        TrIdx = cp.training(nn);
        TeIdx = cp.test(nn);
        
        TrainingDataSet = RespData(TrIdx,:);
        TrainingClassLabel = presumedTrialTypes(TrIdx);
        mdl = fitcsvm(TrainingDataSet,TrainingClassLabel(:));
        
        TestData = RespData(TeIdx,:);
        PredC = predict(mdl,TestData);
        
        PredChoice(TeIdx) = PredC;
    end
    IterPredChoice(nIter,:) = PredChoice;
end

%%
if ~isdir('./Pass_pesudoChoice_pred/')
    mkdir('./Pass_pesudoChoice_pred/');
end
cd('./Pass_pesudoChoice_pred/');

TrialTypeMatrix = repmat((TrialTypes(:))',foldLen,1);
PredOutcomes = IterPredChoice == TrialTypeMatrix;
PredStimPerf = zeros(length(PassSounds),foldLen);
for nmnm = 1 : length(PassSounds)
    cStim = PassSounds(nmnm);
    cStimInds = SelectSArray == cStim;
    PredStimPerf(nmnm,:) = mean(PredOutcomes(:,cStimInds),2);
end
StimOct = log2(PassSounds/Boundary);
Colormaps = cool(foldLen);
h = figure;
hold on;
% plot(StimOct,RealStimPerf,'k-o','LineWidth',2);
for nxnx = 1 : foldLen
    plot(StimOct,PredStimPerf(:,nxnx),'-o','LineWidth',2,'Color',Colormaps(nxnx,:));
end
xlabel('Octave');
ylabel('Pesudo Correct rate');
ylim([0 1.1]);
title({'Passive neuron prediction','With Error Trials'});
set(gca,'fontSize',20)
saveas(h,'TbyT Pred pesudo choice correct rate');
saveas(h,'TbyT Pred pesudo choice correct rate','png');
close(h);

save PassPredSave.mat SelectSArray Boundary IterPredChoice StimOct PredStimPerf FoldsRange -v7.3

%%
PredStimPerfMean = mean(PredStimPerf,2);
LeftInds = (PassSounds > Boundary);
RightWardChoice = PredStimPerfMean;
RightWardChoice(LeftInds) = 1 - RightWardChoice(LeftInds);
[~,bPass] = fit_logistic(StimOct,RightWardChoice);
modelfun = @(p1,t)(p1(2)./(1 + exp(-p1(3).*(t-p1(1)))));
curvex = linspace(min(StimOct),max(StimOct),500);
curve_fity = modelfun(bPass,curvex);

hplot = figure('position',[200 200 1000 800]);
hold on;
plot(curvex,curve_fity,'r','LineWidth',2);
scatter(StimOct,RightWardChoice,'r','o','LineWidth',2);
text(StimOct(2),0.8,sprintf('nROI = %d',nROI),'FontSize',15);
set(gca,'xtick',StimOct,'FontSize',20);
xlabel('Octave Diff');
ylabel('Rightward probability');
saveas(hplot,'TBYT pesudo choice decoding result compare plot');
saveas(hplot,'TBYT pesudo choice decoding result compare plot','png');

cd ..;