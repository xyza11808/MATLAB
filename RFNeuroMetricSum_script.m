% this script is used for analysis of multisession rf classification result
% and summarized it together
add_char = 'y';
inputChoice = input('would like to added new session data into last summary result?\n','s');
if strcmpi(inputChoice,'y')
    [fnx,fpx,fix] = uigetfile('SessionDataSum.mat','Please load your last summary plot result');
    if fix
        load(fullfile(fpx,fnx));
        isOldLoad = 1;
    else
        isOldLoad = 0;
    end
else
    isOldLoad = 0;
end
if ~isOldLoad
    m = 1;
    datapath = {};
    DataSum = {};
    SumSessionOctave = {};
    SumSessionPerf = {};
    SumSessionMean = [];
    SumBehavFreq = {};
    SumBehavCorr = {};
    SumBehavCorrMean = [];
else
   m = length(DataSum) + 1;
end

while ~strcmpi(add_char,'n')
    [fn,fp,fi] = uigetfile('RFpcaResult.mat','Please select your ROI fraction based classification result save');
    if fi
        datapath{m} = fullfile(fp,fn);
        xx = load(fullfile(fp,fn));
        DataSum{m} = xx;
        LeftInds = xx.OctConsider < 0;
        RealCorrRate = xx.fityAll;
        RealCorrRate(LeftInds) = 1 - RealCorrRate(LeftInds); % convert the rightward fraction into correct rate
        NearBoundarySounds = abs(xx.OctConsider) < 1;
        NearBoundCorr = mean(RealCorrRate(NearBoundarySounds));
        SumSessionOctave{m} = xx.OctConsider(NearBoundarySounds);
        SumSessionPerf{m} = RealCorrRate(NearBoundarySounds);
        SumSessionMean(m) = NearBoundCorr;
        BehavOctWithinInds = abs(xx.BehavOctave) < 1;
        SumBehavFreq{m} = xx.BehavFreq(BehavOctWithinInds);
        SumBehavCorr{m} = xx.Corry(BehavOctWithinInds);
        SumBehavCorrMean(m) = mean(SumBehavCorr{m});
        
    end
    add_char = input('Do you want to add with more session data?\n','s');
    m = m + 1;
end
m = m - 1;
%%
fp = uigetdir(pwd,'Please select a session to save your current data');
cd(fp);
f = fopen('Session_resp_path.txt','w');
fprintf(f,'Sessions path for response summary plot:\r\n');
FormatStr = '%s;\r\n';
for nbnb = 1 : m
    fprintf(f,FormatStr,datapath{nbnb});
end
fclose(f);
save SessionDataSum.mat DataSum SumSessionOctave SumSessionPerf SumSessionMean SumBehavFreq SumBehavCorr SumBehavCorrMean -v7.3

%%
fprintf('Totally %d session data being summarized for analysis.\n',m);
BehavSumMean = mean(SumBehavCorrMean);
RFNeuroSunMean = mean(SumSessionMean);
PairedPoints = [SumBehavCorrMean;SumSessionMean];
h_RFAll = figure('position',[200 200 1200 800]);
hold on;
bar(1,BehavSumMean,0.2,'k');
bar(2,RFNeuroSunMean,0.2,'b');
plot(PairedPoints,'color',[.5 .5 .5],'LineWidth',4);
xlim([0 3]);
set(gca,'xtick',[1 2],'xticklabel',{'Behav','RF Neuro'});
set(gca,'ytick',[0 0.5 1]);
ylim([0 1.1]);
title('RF Neuron compare with behavior');
set(gca,'FontSize',20);
[h,p] = ttest(SumBehavCorrMean,SumSessionMean);
text(1.5,0.9,sprintf('p = %.4f',p),'HorizontalAlignment','center','FontSize',14);
saveas(h_RFAll,'RF and behavior compare plot2');
saveas(h_RFAll,'RF and behavior compare plot2','png');
% close(h_RFAll);
