% for single session data processing
% collect single session data and then plot the scatter compasison plot
[fn,fp,fi] = uigetfile('OptoContAUCSave.mat','Please select the AUC savage file for single session');
%
if ~fi
    return;
else
    cd(fp);
    fpath = fullfile(fp,fn);
    DataStrc = load(fpath);
    ContAUCABS = DataStrc.ContAUCData.ROCareaABS;
    ShufAUCAll = DataStrc.ContAUCData.ROCshuffle;
    ContPopuThres = mean(ShufAUCAll);
    OptoAUCABS = DataStrc.OptoAUCData.ROCareaABS;
    axesScales = [min([ContAUCABS;OptoAUCABS]),max([ContAUCABS;OptoAUCABS])] + [-0.05,0.05];
    axesScales(2) = 1;
%     if min(axesScales) < 0.5
%         xtickss = [axesScales(1),0.5,0.75,1];
%     else
%         xtickss = [0.5,0.75,1];
%     end
    AboveThresInds = ContAUCABS > ContPopuThres;
    hf = figure;
    hold on;
    scatter(ContAUCABS(AboveThresInds),OptoAUCABS(AboveThresInds),40,'o','LineWidth',1.5,...
        'MarkerEdgeColor',[.7 .7 .7],'MarkerFaceColor','k'); % sig ROI scatter plot
    scatter(ContAUCABS(~AboveThresInds),OptoAUCABS(~AboveThresInds),40,'ko','LineWidth',1.5,...
        'MarkerEdgeColor',[.8 .8 .8],'MarkerFaceColor',[.6 .6 .6]); % sig ROI scatter plot
    set(gca,'xlim',axesScales,'ylim',axesScales);
    line([ContPopuThres ContPopuThres],axesScales,'Color',[.7 .7 .7],'LineWidth',1.5,'LineStyle','--');
    line(axesScales,axesScales,'Color',[.7 .7 .7],'LineWidth',1.5,'LineStyle','--');
    [~,p_test] = ttest(ContAUCABS(AboveThresInds),OptoAUCABS(AboveThresInds));
    xlabel('Control AUC');
    ylabel('Opto AUC');
    title(sprintf('p = %.3e',p_test));
    set(gca,'xtick',[0.5,0.75,1]);
    set(gca,'FontSize',18);
    saveas(hf,'Session AUC opto control compare plot');
    saveas(hf,'Session AUC opto control compare plot','pdf');
    saveas(hf,'Session AUC opto control compare plot','png');
    close(hf);
    
    save SessionDataSave.mat ContAUCABS OptoAUCABS ContPopuThres ShufAUCAll -v7.3
end

%%
% summary scripts across multiple sessions
addchar = 'y';
dataSum = {};
dataPath = {};
DataContAUCall = [];
DataOptoAUCall = [];
DataShufAll = [];
m = 1;

while ~strcmpi(addchar,'n')
    [fn,fp,fi] = uigetfile('SessionDataSave.mat','Please select your Session AUC analysis data');
    if ~fi
        addchar = input('Would you like to add another session data?\n','s');
        continue;
    else
        fpath = fullfile(fp,fn);
        dataPath{m} = fpath;
        cdataStrc = load(fpath);
        dataSum{m} = cdataStrc;
        DataContAUCall = [DataContAUCall;cdataStrc.ContAUCABS(:)];
        DataOptoAUCall = [DataOptoAUCall;cdataStrc.OptoAUCABS(:)];
        DataShufAll = [DataShufAll;cdataStrc.ShufAUCAll];
       
        addchar = input('Would you like to add another session data?\n','s');
        m = m + 1;
    end
end
%%
SavePath = uigetdir(pwd,'Please select the summarized data save path');
cd(SavePath);

save AUCSumData.mat dataPath dataSum DataContAUCall DataOptoAUCall DataShufAll -v7.3

ContAUCABS = DataContAUCall;
OptoAUCABS = DataOptoAUCall;
SumThres = mean(DataShufAll);
AboveThresInds = ContAUCABS > SumThres;

h_sum = figure;
hold on;
scatter(ContAUCABS(AboveThresInds),OptoAUCABS(AboveThresInds),40,'o','LineWidth',1.5,...
    'MarkerEdgeColor',[.7 .7 .7],'MarkerFaceColor','k'); % sig ROI scatter plot
scatter(ContAUCABS(~AboveThresInds),OptoAUCABS(~AboveThresInds),40,'ko','LineWidth',1.5,...
    'MarkerEdgeColor',[.8 .8 .8],'MarkerFaceColor',[.6 .6 .6]); % sig ROI scatter plot
set(gca,'xlim',axesScales,'ylim',axesScales);
line([ContPopuThres ContPopuThres],axesScales,'Color',[.7 .7 .7],'LineWidth',1.5,'LineStyle','--');
line(axesScales,axesScales,'Color',[.7 .7 .7],'LineWidth',1.5,'LineStyle','--');
[~,p_test] = ttest(ContAUCABS(AboveThresInds),OptoAUCABS(AboveThresInds));
xlabel('Control AUC');
ylabel('Opto AUC');
title(sprintf('p = %.3e',p_test));
set(gca,'xtick',[0.5,0.75,1]);
set(gca,'FontSize',18);
saveas(h_sum,'Summarized AUC opto control compare plot');
saveas(h_sum,'Summarized AUC opto control compare plot','pdf');
saveas(h_sum,'Summarized AUC opto control compare plot','png');
close(h_sum);