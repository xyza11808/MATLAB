
TrFreqs = double(behavResults.Stim_toneFreq);
MissInds = trial_outcome == 2;
NMtrFactorData = cLRIndexSum(~MissInds,:);
NMStimTone = TrFreqs(~MissInds);
NMoutcome = trial_outcome(~MissInds);
TypeFreqs = unique(NMStimTone);
nFreqs = length(TypeFreqs);

FrameScale = [start_frame+1,start_frame+frame_rate]; % within 1s time window
FreqMaxIndex = zeros(nFreqs,1);
FreqMaxIndexAll = cell(nFreqs,1);

for cFreq = 1 : nFreqs
    cTone = TypeFreqs(cFreq);
    cToneInds = NMStimTone == cTone;
    cToneData = NMtrFactorData(cToneInds,:);
    MeanTrace = mean(cToneData);
    AbsTrace = abs(MeanTrace);
    [~,MaxInds] = max(AbsTrace(FrameScale(1):FrameScale(2)));
    FreqMaxIndex(cFreq) = MeanTrace(start_frame+MaxInds);
    FreqMaxIndexAll{cFreq} = cToneData(:,start_frame+MaxInds);
end
%%
BoundTone = 16000;
FreqOctave = log2(TypeFreqs/BoundTone);
Frestr = cellstr(num2str(TypeFreqs(:)/1000,'%.1f'));
NorFreqIndex = (FreqMaxIndex - min(FreqMaxIndex))/(max(FreqMaxIndex) - min(FreqMaxIndex));
IsBoundToneExist = 0;
if mod(length(FreqOctave),2)
    fprintf('Not using Boundary frequency.\n');
    BoundTone = FreqOctave(ceil(length(FreqOctave)/2));
    BoundNorFA = NorFreqIndex(ceil(length(FreqOctave)/2));
    FreqOctave(ceil(length(FreqOctave)/2)) = [];
    NorFreqIndex(ceil(length(FreqOctave)/2)) = [];
    IsBoundToneExist = 1;
end
% figure;
% plot(FreqOctave,FreqMaxIndex,'k-o','Markersize',12,'linewidth',2);
% set(gca,'xtick',FreqOctave,'xticklabel',Frestr);
% xlabel('Freq (kHz)');
% ylabel('Mean Selection index');
% set(gca,'FontSize',20);

%%

% figure;
% plot(FreqOctave,NorFreqIndex,'r-o','Markersize',12,'linewidth',2);
% set(gca,'xtick',FreqOctave,'xticklabel',Frestr);
% xlabel('Freq (kHz)');
% ylabel('Mean Selection index');
% set(gca,'FontSize',20);

%%
% [fn,fp,fi] = uigetfile('boundary_result.mat','Please select the PsC fitting result');
% if ~fi
%     return;
% end
% load(fullfile(fp,fn));
BehavRes = boundary_result.StimCorr;
BehavRes(1:floor(length(BehavRes)/2)) = 1 - BehavRes(1:floor(length(BehavRes)/2));
octave_dist = FreqOctave;
reward_type = BehavRes;
SP_FA = [NorFreqIndex(1),1 - NorFreqIndex(end)-NorFreqIndex(1), mean(octave_dist), 1];
%%
UL = [0.5, 0.5, max(octave_dist), 100];
SP = [reward_type(1),1 - reward_type(end)-reward_type(1), mean(octave_dist), 1];
LM = [0, 0, min(octave_dist), 0];
ParaBoundLim = ([UL;SP;LM]);
ParaBoundLimFA = ([UL;SP_FA;LM]);
fit_ReNew = FitPsycheCurveWH_nx(octave_dist, reward_type, ParaBoundLim);
fit_ReNew_FA = FitPsycheCurveWH_nx(octave_dist, NorFreqIndex, ParaBoundLim);
hf = figure('position',[560 500 500 400]);
hold on
plot(octave_dist,reward_type,'ro','MarkerSize',12,'linewidth',1.8);
plot(fit_ReNew.curve(:,1),fit_ReNew.curve(:,2),'Color','r','linewidth',2);
plot(octave_dist,NorFreqIndex,'ko','MarkerSize',12,'linewidth',1.8);
plot(fit_ReNew_FA.curve(:,1),fit_ReNew_FA.curve(:,2),'Color','k','linewidth',2);
if IsBoundToneExist
    plot(BoundTone,BoundNorFA,'bo','MarkerSize',10,'linewidth',1.5);
end
% legend(plot(0,0,'r-o','visible','off'),'Behav');
legend([plot(0,0,'r-o','visible','off'),plot(0,0,'k-o','visible','off')],{'Behav','FAPeak'},'Location','NorthWest','FontSize',12);
set(gca,'xtick',FreqOctave,'xticklabel',Frestr);
xlabel('Freq (kHz)');
set(gca,'FontSize',20);
saveas(hf,'Factor and behavior compare plot');
saveas(hf,'Factor and behavior compare plot','png');
close(hf);
%