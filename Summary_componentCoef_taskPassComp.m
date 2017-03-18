clear;
clc;

addchar = 'y';
DataPath = {};
DataSum = {};
TaskFirstCompCoefAll = [];
TaskSecondCompCofAll = [];
PassFirstCompCoefAll = [];
PassSecondCompCofAll = [];
m = 1;
%%
while ~strcmpi(addchar,'n')
    [fn,fp,fi] = uigetfile('CompCoefSavePassTask.mat','Please select your compared data set for Task and pass coef compare');
    if ~fi
        continue;
    else
        cDatapath = fullfile(fp,fn);
        DataPath{m} = cDatapath;
        xx = load(cDatapath);
        DataSum{m} = xx;
        
        if ~(isfield(xx,'FirstCROIcorr') && isfield(xx,'SecondCROIcorr'))
            FirstCMaskRaw = ones(size(xx.FirstCCoef));
            FirstCMask = logical(triu(FirstCMaskRaw,1));
            FirstCROIcorrVector = xx.FirstCCoef(FirstCMask);
            
            SecondCMaskRaw = ones(size(xx.SecondCCoef));
            SecondCMask = logical(triu(SecondCMaskRaw,1));
            SecondCROIcorrVector = xx.SecondCCoef(SecondCMask);
        else
            FirstCROIcorrVector = xx.FirstCROIcorr;
            SecondCROIcorrVector = xx.SecondCROIcorr;
        end
        
        PassFirstCCoef = xx.PassFirstCCoef;
        PassSecondCCoef = xx.PassSecondCCoef;
        
        TaskFirstCompCoefAll = [TaskFirstCompCoefAll;FirstCROIcorrVector];
        TaskSecondCompCofAll = [TaskSecondCompCofAll;SecondCROIcorrVector];
        PassFirstCompCoefAll = [PassFirstCompCoefAll;PassFirstCCoef];
        PassSecondCompCofAll = [PassSecondCompCofAll;PassSecondCCoef];
    end
    
    addchar = input('Would you like to add another session data?\n','s');
    m = m + 1;
end

%%
m = m - 1;
DatasaveDir = uigetdir(pwd,'Please select a path to save current summarized dataset');
cd(DatasaveDir);
fFormat = '%s;\r\n';
fid = fopen('PeakTime_coefCompare_Datapath.txt','w');
fprintf(fid,'Data path used for current summarized dataset:\r\n');
for nmnm = 1 : m
    fprintf(fid,fFormat,DataPath{nmnm});
end
fclose(fid);
save ComponentCoef_summarysave.mat DataSum TaskFirstCompCoefAll TaskSecondCompCofAll PassFirstCompCoefAll PassSecondCompCofAll -v7.3
%%
% plot two figure for first and second components seperately
% using the ranksum test instead of paired t-test

% plot the first component response data
hff = figure('position',[300 150 1300 800]);
subplot(1,2,1)
hist(TaskFirstCompCoefAll,40);
title(sprintf('Task Mean coef value = %.3f',mean(TaskFirstCompCoefAll)));

subplot(1,2,2)
hist(PassFirstCompCoefAll,40);
title(sprintf('Passive Mean coef value = %.3f',mean(PassFirstCompCoefAll)));

suptitle('First component');

saveas(hff,'First Component noise coef distribution');
saveas(hff,'First Component noise coef distribution','png');
close(hff);

% rand sum test
[p,h] = ranksum(TaskFirstCompCoefAll,PassFirstCompCoefAll);
[TaskFirstCCoefCum,TaskFirstx] = ecdf(TaskFirstCompCoefAll);
[PassFirstCCoefCum,PassFirstx] = ecdf(PassFirstCompCoefAll);
hFirstCum = figure;
hold on;
h1 = plot(TaskFirstx,TaskFirstCCoefCum,'k','LineWidth',1.6);
h2 = plot(PassFirstx,PassFirstCCoefCum,'r','LineWidth',1.6);
xlabel('NC value');
ylabel('Pair fraction');
title({'Task and passive noise comparation',sprintf('Ranksum p = %.3f',p)});
set(gca,'FontSize',18);
legend([h1,h2],{'Task FirstComponent','Pass FirstComponent'},'Location','northwest','FontSize',14);
saveas(hFirstCum,'Cumsum comparation plot first component');
saveas(hFirstCum,'Cumsum comparation plot first component','png');
close(hFirstCum);

% #################################################################################################
% plot the second component response data
hsf = figure('position',[300 150 1300 800]);
subplot(1,2,1)
hist(TaskSecondCompCofAll,40);
title(sprintf('Task Mean coef value = %.3f',mean(TaskSecondCompCofAll)));

subplot(1,2,2)
hist(PassSecondCompCofAll,40);
title(sprintf('Pass Mean coef value = %.3f',mean(PassSecondCompCofAll)));

suptitle('Second component');

saveas(hsf,'Second Component noise coef distribution');
saveas(hsf,'Second Component noise coef distribution','png');
close(hsf);

% rand sum test
[p,h] = ranksum(TaskSecondCompCofAll,PassSecondCompCofAll);
[TaskSecondCCoefCum,TaskFirstx] = ecdf(TaskSecondCompCofAll);
[PassSecondCCoefCum,PassFirstx] = ecdf(PassSecondCompCofAll);
hSecondCum = figure;
hold on;
h1 = plot(TaskFirstx,TaskSecondCCoefCum,'k','LineWidth',1.6);
h2 = plot(PassFirstx,PassSecondCCoefCum,'r','LineWidth',1.6);
xlabel('NC value');
ylabel('Pair fraction');
title({'Task and passive noise comparation',sprintf('Ranksum p = %.3f',p)});
set(gca,'FontSize',18);
legend([h1,h2],{'Task SecondComponent','Pass SecondComponent'},'Location','northwest','FontSize',14);
saveas(hSecondCum,'Cumsum comparation plot second component');
saveas(hSecondCum,'Cumsum comparation plot second component','png');
close(hSecondCum);
