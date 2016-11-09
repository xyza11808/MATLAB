
%loading 2afc index
[fn2afc,fp2afc,fi2] = uigetfile('FreqMeanData.mat','Please select your 2afc analysis index value');
if fi2
    xx = load(fullfile(fp2afc,fn2afc));
    TuDIndex2afc = xx.TDindex;
    ClIndex2afc = xx.CIindex;
end

%%
% loading rf index
[fnrf,fprf,firf] = uigetfile('FreqMeanData.mat','Please select your rf analysis index value');
if firf
    xx = load(fullfile(fprf,fnrf));
    TuDIndexrf = xx.TDindex;
    ClIndexrf = xx.CIindex;
end

%%
% comparing the value between two different conditions
if length(TuDIndex2afc) ~= length(TuDIndexrf)
    fprintf('2afc ROI number %d is different from rf ROI number %d,\n',length(TuDIndex2afc),length(TuDIndexrf));
    ChoiceChar = input('Continue analysis?\n','s');
    if strcmpi(ChoiceChar,'n')
        return;
    else
        TargetIndx = min(length(TuDIndex2afc),length(TuDIndexrf));
        TuDIndex2afcP = TuDIndex2afc(1:TargetIndx);
        ClIndex2afcP = ClIndex2afc(1:TargetIndx);
        TuDIndexrfP = TuDIndexrf(1:TargetIndx);
        ClIndexrfP = ClIndexrf(1:TargetIndx);
    end
else
    TargetIndx = length(TuDIndex2afc);
    TuDIndex2afcP = TuDIndex2afc(1:TargetIndx);
    ClIndex2afcP = ClIndex2afc(1:TargetIndx);
    TuDIndexrfP = TuDIndexrf(1:TargetIndx);
    ClIndexrfP = ClIndexrf(1:TargetIndx);
end
%%
% scatter plot of two index
h_tdindex = figure('position',[300,120,1000,850]);
scatter(TuDIndex2afcP, TuDIndexrfP,40,'r*');
set(gca,'xlim',[0 1],'ylim',[0 1]);
line([0 1],[0 1],'color',[.8 .8 .8],'LineWidth',1.5);
xlabel('2afc Index');
ylabel('rf Index');
set(gca,'FontSize',20);
title('Tuning depth plot');
saveas(h_tdindex,'Tuning depth plot for comparation');
saveas(h_tdindex,'Tuning depth plot for comparation','png');

h_CIindex = figure('position',[300,120,1000,850]);
scatter(ClIndex2afcP,ClIndexrfP,40,'r*');
set(gca,'xlim',[0 1],'ylim',[0 1]);
line([0 1],[0 1],'color',[.8 .8 .8],'LineWidth',1.5);
xlabel('2afc Index');
ylabel('rf Index');
set(gca,'FontSize',20);
title('Classification index plot');
saveas(h_CIindex,'Classification index plot for comparation');
saveas(h_CIindex,'Classification index plot for comparation','png');


%%
close(h_CIindex);
close(h_tdindex);