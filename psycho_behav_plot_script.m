[fn,fp,~] = uigetfile('*.mat','Select the mat file for behavior plot');
load(fullfile(fp,fn));

TrialType = cellfun(@(x) x.Trial_Type,SessionResults);
ActionChoice = cellfun(@(x) x.Action_choice,SessionResults);
IsprobleTrial = cellfun(@(x) x.Trial_isProbeTrial,SessionResults);
TimeReward = cellfun(@(x) x.Time_reward,SessionResults);
CorrectInds = TimeReward~=0;
% trial type is not corresponded with frequency value, so can not using
% TrialOutcome = double(TrialType == ActionChoice); expression
%%
TrialTone = zeros(length(SessionResults),1);
for nnn = 1 : length(SessionResults)
    if isfield(SessionResults{nnn},'Stim_toneFreq')
        TrialTone(nnn) = SessionResults{nnn}.Stim_toneFreq;
    else
        TrialTone(nnn) = SessionResults{nnn}.Stim_Probe_pureTone_freq;
    end
end

TrialOutcome = double(TrialType == ActionChoice);
MissTrialInds = ActionChoice == 2;

%%

FreqType = unique(TrialTone);
FreqOutcome = zeros(length(FreqType),1);
FreqNum = zeros(length(FreqType),1);
for nn = 1 : length(FreqType)
    cfreq = FreqType(nn);
    cFreqData = ActionChoice(TrialTone == cfreq);
    FreqOutcome(nn) = mean(cFreqData == 1);
    FreqNum(nn) = length(cFreqData);
end
% LeftInds = FreqType < 16000;
% CurvePoints = FreqOutcome;
% CurvePoints(LeftInds) = 1 - CurvePoints(LeftInds);
OctFreq = log2(FreqType/min(FreqType));

h_psycho=figure;
scatter(OctFreq,FreqOutcome,40);
hold on;

%%
% currently excluded
%miss exclude
TrialToneBU = TrialTone;
TrialToneBU(MissTrialInds) = []; 
TrialOutcomeBU = ActionChoice;
TrialOutcomeBU(MissTrialInds) = []; 
FreqType = unique(TrialToneBU);
FreqOutcome = zeros(length(FreqType),1);
for nn = 1 : length(FreqType)
    cfreq = FreqType(nn);
    cFreqData = TrialOutcomeBU(TrialToneBU == cfreq);
    FreqOutcome(nn) = mean(cFreqData == 1);
end
% LeftInds = FreqType < 16000;
% CurvePoints = FreqOutcome;
% CurvePoints(LeftInds) = 1 - CurvePoints(LeftInds);
OctFreq = log2(FreqType/min(FreqType));

h_psycho=figure;
scatter(OctFreq,FreqOutcome,40);
hold on;
%%
modelfun = @(p1,t)(p1(2)./(1 + exp(-p1(3).*(t-p1(1)))));
[~,bfit]=fit_logistic(OctFreq,FreqOutcome);
Curvex = linspace(min(OctFreq),max(OctFreq),500);
CurveY = modelfun(bfit,Curvex);
plot(Curvex,CurveY,'k','LineWidth',1.5);

%%
hhh = figure('position',[950 300 850 750],'PaperPositionMode','auto');
m = 64;
cmap = zeros(64, 3);
g = zeros(m, 1); 
b = linspace(.8,0,m)';
r = linspace(0,1,m)';

cmap = [r g b];

colormap(cmap)

% freq_oct = linspace(0,2,8);
clf
haxis = plot(Curvex, CurveY, '-', 'linewidth',2,'color','k');
hold on;
scatter(OctFreq, FreqOutcome, 200, OctFreq,'filled')
hcolor = colorbar;

% h = get(gcf,'children');
set(hcolor,'fontsize',30, 'box','off',...
    'ytick',[0 2],'yticklabel',8*2.^[0 2]);
set(get(hcolor, 'ylabel'),'String','Tone Freq (kHz)')

set(hcolor,'Location','southoutside')

set(gca,'fontsize',20, 'xtick',[0 1 2],...
    'xticklabel',8*2.^[0 1 2], 'box','off','linewidth',2)
xlabel('Tone Freq (kHz)')
ylabel('Right choice (%)')

saveas(hhh,sprintf('%s%sXY',fp,fn(1:end-4)),'fig');
saveas(hhh,sprintf('%s%sXY',fp,fn(1:end-4)),'png');
