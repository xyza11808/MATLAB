clear
clc
[fn,fp,fi] = uigetfile('*.txt','Please select the session path savage file');
if ~fi
    return;
end

%%
clearvars -except fn fp
fpath = fullfile(fp,fn);
fid = fopen(fpath);
tline = fgetl(fid);
nSess = 1;
SessBehavData = {};
SessLogData = {};
SessCommonData = {};

while ischar(tline)
    if isempty(strfind(tline,'NO_Correction\mode_f_change'))
        tline = fgetl(fid);
        continue;
    end
    %
    BehavBoundfile = load(fullfile(tline,'RandP_data_plots','boundary_result.mat'));
    StimOctave = log2(double(BehavBoundfile.boundary_result.StimType)/16000);
    StimCorrrate = BehavBoundfile.boundary_result.StimCorr;
    SessBehavData(nSess,:) = {StimOctave,StimCorrrate};
    logCorrValue = StimCorrrate;
    logCorrValue(StimOctave < 0) = 1 - logCorrValue(StimOctave < 0);
    SessLogData(nSess,:) = {StimOctave,logCorrValue};
    if length(StimOctave) > 6
        ExtraInds = abs(StimOctave) < 0.18;
        CommonOcts = StimOctave(~ExtraInds);
        CommonLogData = logCorrValue(~ExtraInds);
    else
        CommonOcts = StimOctave;
        CommonLogData = logCorrValue;
    end
    SessCommonData(nSess,:) = {CommonOcts,CommonLogData};
    
    tline = fgetl(fid);
    nSess = nSess + 1;
end

%%
BehavOctData = cell2mat(SessCommonData(:,1));
BehavLogData = cell2mat(SessCommonData(:,2));
MeanOctaves = mean(BehavOctData);
MeanLogData = mean(BehavLogData);
LogDataSEM = std(BehavLogData)/sqrt(size(BehavLogData,1));
UL = [0.5 0.5 max(MeanOctaves) 1000];
SP = [MeanLogData(1),(1-MeanLogData(1)-MeanLogData(end)),mean(MeanLogData),1];
LM = [0 0 min(MeanOctaves) 0];
ParaBoundLim = ([UL;SP;LM]);
fit_ReNew = FitPsycheCurveWH_nx(BehavOctData(:), BehavLogData(:), ParaBoundLim);
Fit_ci = predint(fit_ReNew.ffit,fit_ReNew.curve(:,1),0.95,'functional','on');
OctStrs = cellstr(num2str((2.^MeanOctaves(:))*16,'%.1f'));

%%
hhf = figure('position',[3000 200 450 350]);
plot(fit_ReNew.curve(:,1),fit_ReNew.curve(:,2),'k','Linewidth',2);
hold on
errorbar(MeanOctaves,MeanLogData,LogDataSEM,'bo','linewidth',1.8,'MarkerSize',4);%,'CapSize',0
plot(fit_ReNew.curve(:,1),Fit_ci(:,1),'Color',[.4 .4 .4],'linewidth',1.6,'linestyle','--');
plot(fit_ReNew.curve(:,1),Fit_ci(:,2),'Color',[.4 .4 .4],'linewidth',1.6,'linestyle','--');
% plot(BehavOctData(:), BehavLogData(:),'*','Color',[.7 .7 .7],'MarkerSize',8);
set(gca,'xtick',MeanOctaves,'xticklabel',OctStrs,'ytick',[0 0.5 1],'ylim',[0 1.1],'xlim',[-1.1,1.1]);
box off
xlabel('Frequency (kHz)');
ylabel('Right Prob.');
title(sprintf('n = %d',size(BehavLogData,1)));
set(gca,'FontSize',16);
% saveas(hhf,'MultiSess behavior psychometric curve plot');
% saveas(hhf,'MultiSess behavior psychometric curve plot','png');

%%
DisPowerCurve = diff(fit_ReNew.curve(:,2));
DisPowerCurve = [DisPowerCurve(1);DisPowerCurve];
NorDisPower = DisPowerCurve / max(DisPowerCurve);
[~,maxInds] = max(NorDisPower);
maxOctaveInds = fit_ReNew.curve(maxInds,1);
hhf = figure('position',[3000 200 450 350]);
hold on
plot(fit_ReNew.curve(:,1),NorDisPower,'k','linewidth',2);
% line([maxOctaveInds maxOctaveInds],[0 1],'Color',[0.1 0.7 0.1],'linewidth',2,'linestyle','--');
set(gca,'xtick',MeanOctaves,'xticklabel',OctStrs,'ytick',[0 0.5 1],'ylim',[0 1.1],'xlim',[-1.1,1.1]);
box off
xlabel('Frequency (kHz)');
ylabel({'Discrimination', 'power'});
set(gca,'FontSize',16)
saveas(hhf,'Psychometric curve Discrimination power plot Without');
saveas(hhf,'Psychometric curve Discrimination power plot Without','png');
