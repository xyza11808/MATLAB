[fn1,fp1,~] = uigetfile('*.mat','Please select your first part session results');
sess1Strc = load(fullfile(fp1,fn1));
cd(fp1);

[fn2,fp2,~] = uigetfile('*.mat','Please select your first part session results');
sess2Strc = load(fullfile(fp2,fn2));
fnfixed = fn1(1:end-8);

%%
sess1BoundRest = rand_plot(sess1Strc.behavResults,3,fn1);
sess2BoundRest = rand_plot(sess2Strc.behavResults,3,fn2);

%%
sess1StimsAll = double(sess1BoundRest.StimType);
sess1PerfAll = sess1BoundRest.StimCorr;
sess2StimsAll = double(sess2BoundRest.StimType);
sess2PerfAll = sess2BoundRest.StimCorr;
sess1bound = min(sess1StimsAll)*2^(sess1BoundRest.Boundary);
sess2bound = min(sess2StimsAll)*2^(sess2BoundRest.Boundary);
sess1RightProb = sess1PerfAll;
sess1RightProb(1:floor(length(sess1RightProb)/2)) = 1 - sess1RightProb(1:floor(length(sess1RightProb)/2));
sess2RightProb = sess2PerfAll;
sess2RightProb(1:floor(length(sess1RightProb)/2)) = 1 - sess2RightProb(1:floor(length(sess1RightProb)/2));


MinStimUsed = min([sess1StimsAll,sess2StimsAll]);
sess1Octave = log2(sess1StimsAll/MinStimUsed);
sess2Octave = log2(sess2StimsAll/MinStimUsed);
sess1BoundOcta = log2(sess1bound/MinStimUsed);
sess2BoundOcta = log2(sess2bound/MinStimUsed);
 modelfun = @(p1,t)(p1(2)./(1 + exp(-p1(3).*(t-p1(1)))));
 
[~,sess1b]=fit_logistic(sess1Octave,sess1RightProb);
[~,sess2b]=fit_logistic(sess2Octave,sess2RightProb);
sess1fitx = linspace(min(sess1Octave),max(sess1Octave),500);
sess2fitx = linspace(min(sess2Octave),max(sess2Octave),500);
sess1fity = modelfun(sess1b,sess1fitx);
sess2fity = modelfun(sess2b,sess2fitx);

%%
h_sum = figure;
hold on;
plot(sess1Octave,sess1RightProb,'ro','Markersize',14);
plot(sess2Octave,sess2RightProb,'ko','Markersize',14);
plot(sess1fitx,sess1fity,'r','linewidth',1.8);
plot(sess2fitx,sess2fity,'k','linewidth',1.8);
ylim([0 1]);
line([sess1BoundOcta,sess1BoundOcta],[0 1],'color',[0.7 0 0],'linewidth',1.6,'linestyle','--');
line([sess2BoundOcta,sess2BoundOcta],[0 1],'color',[0.7 0.7 0.7],'linewidth',1.6,'linestyle','--');
text([sess1BoundOcta,sess2BoundOcta],[0.9,0.8],{num2str(sess1BoundOcta,'%.3f'),...
    num2str(sess2BoundOcta,'%.3f')},'FontSize',12);
set(gca,'ytick',[0 0.5 1],'FontSize',16);
title('Session boundary shifting');
%%
if ~isdir('./Bound_shift_plots/')
    mkdir('./Bound_shift_plots/');
end
cd('./Bound_shift_plots/');

saveas(h_sum,sprintf('%s session boundary shift plot',fnfixed));
saveas(h_sum,sprintf('%s session boundary shift plot',fnfixed),'png');
saveas(h_sum,sprintf('%s session boundary shift plot',fnfixed),'pdf');
close(h_sum);

cd ..;