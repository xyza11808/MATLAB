% this script is used for mat file have "behavResults" and "behavSetting"
% two variables within mat file
clear;
% clc;
[fn,fp,fi] = uigetfile('*.mat','Please select your human psychometic curve data saved mat file');
if ~fi
    return;
else
    cPath = fullfile(fp,fn);
end
load(cPath);
cd(fp);
%

AllTrFreq = behavResults.TrialType;
TrialOutc = behavResults.TrialCorrect;
StimOnT = behavResults.StimOnset;
AnswerT = behavResults.AnswerTime;
RespTime = AnswerT - StimOnT;

%
FreqTypes = unique(AllTrFreq);
%%
FreqNum = length(FreqTypes);
TrialOutCell = cell(FreqNum,1);
TrialRespTCell = cell(FreqNum,1);
for nf = 1 : FreqNum
    cFreq = FreqTypes(nf);
    cFreqInds = AllTrFreq == cFreq;
    TrialOutCell{nf} = TrialOutc(cFreqInds);
    TrialRespTCell{nf} = RespTime(cFreqInds);
end

%%
FreqOctave = log2(FreqTypes/FreqTypes(1));
OctCorr = cellfun(@mean,TrialOutCell);
OctRightwProb = OctCorr;
if mod(FreqNum,2)
    OctRightwProb(1:floor(FreqNum/2)) = 1 - OctRightwProb(1:floor(FreqNum/2));
else
    OctRightwProb(1:(FreqNum/2)) = 1 - OctRightwProb(1:(FreqNum/2));
end
[~,b] = fit_logistic(FreqOctave,OctRightwProb);
modelfun = @(p1,t)(p1(2)./(1 + exp(-p1(3).*(t-p1(1)))));

modelfun2 = @(bnlf,x) (bnlf(1)+ bnlf(2)./(1+exp(-(x - bnlf(3))./bnlf(4))));
b0 = [min(x); max(x); mean([min(x),max(x)]); 0.1];
opts = statset('nlinfit');
opts.RobustWgtFun = 'bisquare';
[bfit,R,J,CovB,MSE,ErrorModelInfo] = nlinfit(FreqOctave,OctRightwProb,modelfun2,b0,opts);

Cur_linex = linspace(min(FreqOctave),max(FreqOctave),500);
Cur_liney = modelfun(b,Cur_linex);

hff = figure;
hold on
plot(FreqOctave,OctRightwProb,'bo','MarkerSize',10);
plot(Cur_linex,Cur_liney,'k','LineWidth',1.6);
set(gca,'xtick',FreqOctave,'xticklabel',cellstr(num2str(FreqOctave(:),'%.2f')));
xlabel('Stimulus (octave)');
ylabel('Rightward Rpob');
set(gca,'FontSize',18);
saveas(hff,sprintf('%slogisfit',fn(1:end-18)));
saveas(hff,sprintf('%slogisfit',fn(1:end-18)),'pdf');
saveas(hff,sprintf('%slogisfit',fn(1:end-18)),'png');
% save(sprintf('%sPcmDataS.mat',fn(1:end-4)),'FreqTypes', 'OctRightwProb', 'TrialOutCell', 'TrialRespTCell', 'RespTime', '-v7.3');

%% summarize all session data results
DataPath = uigetdir(pwd,'Please select the data save path');
cd(DataPath);
Dfiles = dir('*PcmDataS.mat');
nfiles = length(Dfiles);
RProbDataAll = zeros(nfiles,6);
FreqTypeAll = zeros(nfiles,6);
for nfs = 1 : nfiles
    cfname = Dfiles(nfs).name;
    cDataStrc = load(cfname);
    cDataFreqTypes = cDataStrc.FreqTypes;
    cDataOctRProb = cDataStrc.OctRightwProb;
    RProbDataAll(nfs,:) = cDataOctRProb;
    FreqTypeAll(nfs,:) = cDataFreqTypes;
end

%%
fUsedFreq = FreqTypeAll(1,:);
fUsedOct = log2(fUsedFreq/fUsedFreq(1));
fFreqRProbmean = mean(RProbDataAll);
fFreqRProbstd = std(RProbDataAll)/sqrt(size(RProbDataAll,1));
[~,b] = fit_logistic(fUsedOct,fFreqRProbmean);
modelfun = @(p1,t)(p1(2)./(1 + exp(-p1(3).*(t-p1(1)))));
Cur_linex = linspace(min(fUsedOct),max(fUsedOct),500);
Cur_liney = modelfun(b,Cur_linex);


hf = figure;
hold on
errorbar(fUsedOct,fFreqRProbmean,fFreqRProbstd,'ko','MarkerSize',10,'LineWidth',1.6);
plot(Cur_linex,Cur_liney,'b','LineWidth',1.5);
xlabel('Octave');
ylabel('Rightward prob');
title(sprintf('n = %d',size(RProbDataAll,1)));
set(gca,'FontSize',16);
saveas(hf,'MultiSession summary human psychometric curve');
saveas(hf,'MultiSession summary human psychometric curve','png');
saveas(hf,'MultiSession summary human psychometric curve','epsc');
close(hf);