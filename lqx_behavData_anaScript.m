cclr;
[fn,fp,fi] = uigetfile('*.mat','Please select session analized mat file');
if ~fi
    return;
end
cd(fp);

load(fullfile(fp,fn));
%%
DateStart = regexp(fn,'2021\d{4}');
[GroupInds, GrendInds] = regexp(fn,'group\d{1-2}');
[AnmStart, AnmendInds] = regexp(fn,'anim\d{1-2}');
DateAndanmStr = [fn(DateStart:DateStart+7),...
    '\_Gr',fn(GrendInds-1:GrendInds),...
    '\_Anm',fn(AnmendInds-1:AnmendInds)];

TrTypes = double(behavResults.Trial_Type(:));
TrActionChoice = double(behavResults.Action_choice(:));
TrFreqUseds = double(behavResults.Stim_toneFreq(:));
TrStimOnsets = double(behavResults.Time_stimOnset(:));
TrTimeAnswer = double(behavResults.Time_answer(:));
TrTimeReward = double(behavResults.Time_reward(:));
TrManWaters = double(behavResults.ManWater_choice(:));
TrIstrainOptos = double(behavResults.Trial_isOptoTraingTrial(:));
TrAnmPerfsAll = TrActionChoice == TrTypes;

cNMInds = TrActionChoice ~= 2; % without miss trial
IsWithMiss = 0;

% cNMInds = TrActionChoice <= 2; % with miss trial
% IsWithMiss = 1;

cTrFreqsNM = TrFreqUseds(cNMInds);
cTrChoiceNM = TrActionChoice(cNMInds);
cTrStimOnset = TrStimOnsets(cNMInds);
cTrStimAnswer = TrTimeAnswer(cNMInds);
cTrTimeReward = TrTimeReward(cNMInds);
cTrTrainOptos = TrIstrainOptos(cNMInds);
TrPerfsNM = TrAnmPerfsAll(cNMInds);
%
SessFreqTypes = unique(cTrFreqsNM);
NumFreqs = length(SessFreqTypes);
FreqChoiceANDperfs_ctrl = zeros(NumFreqs,3);
FreqChoiceANDperfs_opto = zeros(NumFreqs,3);
for cf = 1 : NumFreqs
  cfcBInds_ctrl = cTrFreqsNM == SessFreqTypes(cf) & cTrTrainOptos == 0;
  cfcBChoices = cTrChoiceNM(cfcBInds_ctrl);
  cfcBPerfs = mean(TrPerfsNM(cfcBInds_ctrl));

  FreqChoiceANDperfs_ctrl(cf,:) = [mean(cfcBChoices),cfcBPerfs,numel(cfcBChoices)]; 
  
  % opto trials
  cfcBInds_opto = cTrFreqsNM == SessFreqTypes(cf) & cTrTrainOptos == 1;
  cfcBChoices_opto = cTrChoiceNM(cfcBInds_opto);
  cfcBPerfs_opto = mean(TrPerfsNM(cfcBInds_opto));

  FreqChoiceANDperfs_opto(cf,:) = [mean(cfcBChoices_opto),cfcBPerfs_opto,numel(cfcBChoices_opto)]; 
end

SessFreqOcts = log2(SessFreqTypes/min(SessFreqTypes));
% fit for control trials
ChoiceProbs = FreqChoiceANDperfs_ctrl(:,1);
UL = [0.5, 0.5, max(SessFreqOcts), 100];
SP = [min(ChoiceProbs),1 - max(ChoiceProbs)-min(ChoiceProbs), mean(SessFreqOcts), 1];
LM = [0, 0, min(SessFreqOcts), 0];
ParaBoundLim = ([UL;SP;LM]);
ctrl_TrFreqsNM = cTrFreqsNM(cTrTrainOptos == 0);
ctrl_TrChoiceNM = cTrChoiceNM(cTrTrainOptos == 0);
TrFreqOcts_ctrl = log2(ctrl_TrFreqsNM/min(SessFreqTypes));
fit_curve_ctrl = FitPsycheCurveWH_nx(TrFreqOcts_ctrl,ctrl_TrChoiceNM,ParaBoundLim);

% fit for opto trials
ChoiceProbs_opto = FreqChoiceANDperfs_opto(:,1);
UL = [0.5, 0.5, max(SessFreqOcts), 100];
SP = [min(ChoiceProbs_opto),1 - max(ChoiceProbs_opto)-min(ChoiceProbs_opto), mean(SessFreqOcts), 1];
LM = [0, 0, min(SessFreqOcts), 0];
ParaBoundLim_opto = ([UL;SP;LM]);
opto_TrFreqsNM = cTrFreqsNM(cTrTrainOptos == 1);
opto_TrChoiceNM = cTrChoiceNM(cTrTrainOptos == 1);
TrFreqOcts_opto = log2(opto_TrFreqsNM/min(SessFreqTypes));
fit_curve_opto = FitPsycheCurveWH_nx(TrFreqOcts_opto,opto_TrChoiceNM,ParaBoundLim_opto);
%
hcf = figure('position',[100 100 340 260]);
hold on
plot(fit_curve_ctrl.curve(:,1),fit_curve_ctrl.curve(:,2),'color','k','LineWidth',1.6);
plot(SessFreqOcts,ChoiceProbs,'ko','MarkerSize',5,'linewidth',1.2);

plot(fit_curve_opto.curve(:,1),fit_curve_opto.curve(:,2),'color','r','LineWidth',1.6);
plot(SessFreqOcts,ChoiceProbs_opto,'ro','MarkerSize',5,'linewidth',1.2);
if IsWithMiss
    TitleStr = [DateAndanmStr,'\_WM'];
    savename = fullfile(fp,[fn(1:end-4),'_Curveplot_withMiss']);
else
    TitleStr = [DateAndanmStr,'\_NM'];
    savename = fullfile(fp,[fn(1:end-4),'_Curveplot_NoMiss']);
end
set(gca,'box','off','xtick',SessFreqOcts,'xticklabel',cellstr(num2str(SessFreqTypes(:)/1000,'%.2f')),...
    'ytick',[0 0.5 1],'ylim',[-0.05 1.05]);
title(TitleStr);


saveas(hcf,savename);
saveas(hcf,savename,'png');
% close(hcf);

