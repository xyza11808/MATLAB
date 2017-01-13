% scripts for summarized paired auc analysis

addchar = 'y';
DataSum = {};
DataPath = {};
BetGrAUCAll = [];
WhnGrAUCAll = [];
MatrixAUCSave = {};
m = 1;

while ~strcmpi(addchar,'n')
    [fn,fp,fi] = uigetfile('DiffMeanAUC.mat','Please select your Session response modulation saving result');
    if fi
        DataPath{m} = fullfile(fp,fn);
        xx = load(DataPath{m});
        DataSum{m} = xx;
        cBetGeAUC = mean(xx.SumBetGrAUC,2);
        cWhnGrAUC = mean(xx.SumWhnGrAUC,2);
        try 
            BetGrAUCAll = [BetGrAUCAll,cBetGeAUC];
            WhnGrAUCAll = [WhnGrAUCAll,cWhnGrAUC];
            MatrixAUCSave{m} = xx.MatrixWiseAUCSelect;
            m = m + 1;
        catch
            fprintf('Current session stimulus length is different from old sessions, skipped current dataset.\n');
        end
    end  
     addchar = input('Would you like to add another session dataset?\n','s');
     
end
m = m - 1;

%%
SavePath = uigetdir('Please select a folder to save current summarized dataset');
cd(SavePath);
fid = fopen('Session_Data_path_save.txt','w');
fprintf(fid,'Data path used for current dataset:\r\n');
fformat = '%s;\r\n';
for nmnm = 1 : m
    fprintf(fid,fformat,DataPath{nmnm});
end
fclose(fid);
save cDataSetSave.mat DataPath DataSum BetGrAUCAll WhnGrAUCAll MatrixAUCSave -v7.3

%%
h_sumPlot = figure('position',[100 100 800 700]);
[h1,hp1,hl1] = MeanSemPlot(BetGrAUCAll',[],h_sumPlot,'color','k','LineWidth',2);
[h2,hp2,hl2] = MeanSemPlot(WhnGrAUCAll',[],h1,'color','k','LineWidth',2,'LineStyle','--');
set(gca,'xtick',1:5);
xlabel('Stimulus diff');
ylabel('Mean AUC');
title('Stimulus paired AUC');
set(gca,'FontSize',18);
legend([hl1,hl2],{'BetGrAUC','WinGrAUC'},'FontSize',10);
saveas(h2,'Summarized_DisTance_wised_auc');
saveas(h2,'Summarized_DisTance_wised_auc','png');
% close(h2);

%%
[SumROIdisAUC,SumROIdisAUCMean] = cellfun(@(x) Matrix2DifBasedAUC(x),MatrixAUCSave,'UniformOutput',false);
SessionMean = cellfun(@(x) mean(x),SumROIdisAUCMean,'UniformOutput',false);
MatrixSessionMean = cell2mat(SessionMean');
h_DisPlot = figure('position',[100 100 800 700]);
[h_f,~,hl] = MeanSemPlot(MatrixSessionMean,[],h_DisPlot,'color','k','LineWidth',2);
set(gca,'xtick',1:5);
xlabel('Stimulus diff');
ylabel('Mean AUC');
title('Stimulus paired AUC');
set(gca,'FontSize',18);
% legend(hl,'Task MeanAUC','FontSize',10);
saveas(h_f,'DisTance_based_auc_Mean_plot');
saveas(h_f,'DisTance_based_auc_Mean_plot','png');
close(h_f);

%%
% for task session
SessionStim = cellfun(@(x) (x.cSessionStim),DataSum,'UniformOutput',false);
SessionStimArray = cell2mat(SessionStim');
OctBase = 8000;
StimOctave = log2(SessionStimArray./OctBase);
save cDataSetSaveNew.mat DataPath DataSum BetGrAUCAll WhnGrAUCAll SessionStimArray OctBase StimOctave SumROIdisAUCMean SumROIdisAUC -v7.3

%%
% for passive session
SessionStim = cellfun(@(x) (x.cSessionStim),DataSum,'UniformOutput',false);
SessionStimArray = (cell2mat(SessionStim))';
OctBase = 8000;
StimOctave = log2(SessionStimArray./OctBase);
save cDataSetSaveNew.mat DataPath DataSum BetGrAUCAll WhnGrAUCAll SessionStimArray OctBase StimOctave SumROIdisAUCMean SumROIdisAUC -v7.3 