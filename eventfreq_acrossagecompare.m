% event frequency compare plots
% cd('~~/invivo_imaging_data_xnn_20191224_update20201110/threeagemerged/respFrac_compare');
p12dataStrc = load('p12ActiveEFDatas.mat');
p18dataStrc = load('p18ActiveEFDatas.mat');
M4dataStrc = load('M4ActiveEFDatas.mat');

Datafieldnames = {'TgNeu_EventFreq_Min','TgAst_EventFreq_Min',...
    'WTNeu_EventFreq_Min','WTAst_EventFreq_Min'};
Numoffields = length(Datafieldnames);

hf = figure('position',[100,100,670,521]);
barColors = {[0.7,0.4,0.1],[1,0.6,0.2],[0.2,0.8,0.3]};
TypeStrs = {'p12','p18','M4'};
VAluesANDpSave = cell(Numoffields,3);
for cf = 1 : Numoffields
    ax = subplot(2,2,cf);
    hold on;
    cfield = Datafieldnames{cf};
    
    p12_cData = p12dataStrc.(cfield);
    p18_cData = p18dataStrc.(cfield);
    M4_cData = M4dataStrc.(cfield);
    
    [p12_Avgs,p12_SEM] = AvgSEMCalcu_Fun(p12_cData);
    [p18_Avgs,p18_SEM] = AvgSEMCalcu_Fun(p18_cData);
    [M4_Avgs,M4_SEM] = AvgSEMCalcu_Fun(M4_cData);
    
%     p12_p18_p = ranksum(p18_cData, p12_cData);
%     p12_M4_p = ranksum(M4_cData, p12_cData);
%     p18_M4_p = ranksum(M4_cData, p18_cData);
    [~,p12_p18_p] = ttest2(p18_cData, p12_cData);
    [~,p12_M4_p] = ttest2(M4_cData, p12_cData);
    [~,p18_M4_p] = ttest2(M4_cData, p18_cData);
    
    Numstrs = {numel(p12_cData);numel(p18_cData);numel(M4_cData)};
    
    bar(1, p12_Avgs,0.6,'EdgeColor','none','FaceColor',barColors{1});
    bar(2, p18_Avgs,0.6,'EdgeColor','none','FaceColor',barColors{2});
    bar(3, M4_Avgs,0.6,'EdgeColor','none','FaceColor',barColors{3});
    errorbar(1:3,[p12_Avgs,p18_Avgs,M4_Avgs],[p12_SEM,p18_SEM,M4_SEM],...
        'k.','linewidth',1.4,'Marker','none');
    text(1:3,[p12_Avgs,p18_Avgs,M4_Avgs]*0.8,Numstrs,'HorizontalAlignment','center',...
        'Color','k');
    set(ax,'xtick',1:3,'xticklabel',TypeStrs','box','off','FontSize',8);
    title(strrep(cfield,'_','\_'));
    ylabel(ax,'Number/Min');
    GroupSigIndication([1,2],[p12_Avgs,p18_Avgs],p12_p18_p,ax,1.1,[],6);
    GroupSigIndication([2,3],[p18_Avgs,M4_Avgs],p18_M4_p,ax,1.3,[],6);
    GroupSigIndication([1,3],[p12_Avgs,M4_Avgs],p12_M4_p,ax,2,[],6);
    VAluesANDpSave(cf,:) = {cfield,[p12_Avgs,p18_Avgs,M4_Avgs],...
        [p12_p18_p,p12_M4_p,p18_M4_p]};
end

%%
saveas(hf,'Eventfreq across age compare plot ttest');
saveas(hf,'Eventfreq across age compare plot ttest','pdf');
saveas(hf,'Eventfreq across age compare plot ttest','png');

save MeanANDpdatas.mat VAluesANDpSavettest -v7.3

%% #####################################################################
% event amplitude cmpare plots
% cd('~~/invivo_imaging_data_xnn_20191224_update20201110/threeagemerged/respAmp_compare')
cclr
p12dataStrc = load('p12EventAmpCellwise.mat');
p18dataStrc = load('p18EventAmpCellwise.mat');
M4dataStrc = load('M4EventAmpCellwise.mat');

Datafieldnames = {'WTNeu_EventAmp_Min','TgNeu_EventAmp_Min',...
    'WTAst_EventAmp_Min','TgAst_EventAmp_Min'};
Numoffields = length(Datafieldnames);

h2f = figure('position',[100,100,670,521]);
barColors = {[0.7,0.4,0.1],[1,0.6,0.2],[0.2,0.8,0.3]};
TypeStrs = {'p12','p18','M4'};
VAluesANDpSave = cell(Numoffields,3);
for cf = 1 : Numoffields
    ax = subplot(2,2,cf);
    hold on;
    cfield = Datafieldnames{cf};
    
    p12_cData = p12dataStrc.(cfield);
    p18_cData = p18dataStrc.(cfield);
    M4_cData = M4dataStrc.(cfield);
    
    [p12_Avgs,p12_SEM] = AvgSEMCalcu_Fun(p12_cData);
    [p18_Avgs,p18_SEM] = AvgSEMCalcu_Fun(p18_cData);
    [M4_Avgs,M4_SEM] = AvgSEMCalcu_Fun(M4_cData);
    
    p12_p18_p = ranksum(p18_cData, p12_cData);
    p12_M4_p = ranksum(M4_cData, p12_cData);
    p18_M4_p = ranksum(M4_cData, p18_cData);
%     [~,p12_p18_p] = ttest2(p18_cData, p12_cData);
%     [~,p12_M4_p] = ttest2(M4_cData, p12_cData);
%     [~,p18_M4_p] = ttest2(M4_cData, p18_cData);
    
    Numstrs = {numel(p12_cData);numel(p18_cData);numel(M4_cData)};
    
    bar(1, p12_Avgs,0.6,'EdgeColor','none','FaceColor',barColors{1});
    bar(2, p18_Avgs,0.6,'EdgeColor','none','FaceColor',barColors{2});
    bar(3, M4_Avgs,0.6,'EdgeColor','none','FaceColor',barColors{3});
    errorbar(1:3,[p12_Avgs,p18_Avgs,M4_Avgs],[p12_SEM,p18_SEM,M4_SEM],...
        'k.','linewidth',1.4,'Marker','none');
    text(1:3,[p12_Avgs,p18_Avgs,M4_Avgs]*0.8,Numstrs,'HorizontalAlignment','center',...
        'Color','k');
    set(ax,'xtick',1:3,'xticklabel',TypeStrs','box','off','FontSize',8);
    title(strrep(cfield,'_','\_'));
    ylabel(ax,'dff');
    GroupSigIndication([1,2],[p12_Avgs,p18_Avgs],p12_p18_p,ax,1.1,[],6);
    GroupSigIndication([2,3],[p18_Avgs,M4_Avgs],p18_M4_p,ax,1.3,[],6);
    GroupSigIndication([1,3],[p12_Avgs,M4_Avgs],p12_M4_p,ax,1.7,[],6);
    VAluesANDpSave(cf,:) = {cfield,[p12_Avgs,p18_Avgs,M4_Avgs],...
        [p12_p18_p,p12_M4_p,p18_M4_p]};
end

%%
saveas(h2f,'Event Amplitude across age compare plot ranksum');
saveas(h2f,'Event Amplitude across age compare plot ranksum','pdf');
saveas(h2f,'Event Amplitude across age compare plot ranksum','png');

save MeanANDpdatasRank.mat VAluesANDpSave -v7.3

%% #####################################################################
% resp fraction cmpare plots
% cd('~~/invivo_imaging_data_xnn_20191224_update20201110/threeagemerged/respFrac_compare')
cclr
p12dataStrc = load('p12Activefrac.mat');
p18dataStrc = load('p18Activefrac.mat');
M4dataStrc = load('M4Activefrac.mat');

Datafieldnames = {'WTNeu_active_Index','TgNeu_active_Index',...
    'WTAst_active_Index','TgAst_active_Index'};
Numoffields = length(Datafieldnames);

h3f = figure('position',[100,100,820,580]);
% barColors = {[0.7,0.4,0.1],[1,0.6,0.2],[0.2,0.8,0.3]};
TypeStrs = {'p12','p18','M4'};
VAluesANDpSave = cell(Numoffields,3);
for cf = 1 : Numoffields
    ax = subplot(2,2,cf);
    hold on;
    cfield = Datafieldnames{cf};
    
    p12_cData = p12dataStrc.(cfield);
    p18_cData = p18dataStrc.(cfield);
    M4_cData = M4dataStrc.(cfield);
    
    p12_p18_p = ChiSqureProbTest(p18_cData, p12_cData);
    p12_M4_p = ChiSqureProbTest(M4_cData, p12_cData);
    p18_M4_p = ChiSqureProbTest(M4_cData, p18_cData);
    
    cActive_frac = [mean(p12_cData),1 - mean(p12_cData);...
        mean(p18_cData),1 - mean(p18_cData);...
        mean(M4_cData),1 - mean(M4_cData)];
    
    ActNumStrs = {num2str([sum(p12_cData),numel(p12_cData)],'%d/%d');...
        num2str([sum(p18_cData),numel(p18_cData)],'%d/%d');...
        num2str([sum(M4_cData),numel(M4_cData)],'%d/%d')};
    
    hb = bar(1:3,cActive_frac,0.5,'stacked');
    text(1:3,0.8*ones(3,1),ActNumStrs,'HorizontalAlignment','center','Color','k',...
        'Fontsize',12);
    set(gca,'xlim',[0.5 3.5],'ylim',[0 2],'ytick',[0 0.5 1],'xtick',1:3,...
        'xticklabel',TypeStrs');
    ylabel('Fraction')
    title(strrep(cfield,'_','\_'));
    legend(hb,{'Active','Inactive'},'box','off','Location','Northeastoutside','AutoUpdate','off')
    GroupSigIndication([1,2],[1,1],p12_p18_p,ax,1.1,[],6);
    GroupSigIndication([2,3],[1,1],p18_M4_p,ax,1.3,[],6);
    GroupSigIndication([1,3],[1,1],p12_M4_p,ax,1.6,[],6);
    VAluesANDpSave(cf,:) = {cfield,[mean(p12_cData),mean(p18_cData),mean(M4_cData)],...
        [p12_p18_p,p12_M4_p,p18_M4_p]};
    
end

%%
saveas(h3f,'Active fraction across age compare plot chisquare');
saveas(h3f,'Active fraction across age compare plot chisquare','pdf');
saveas(h3f,'Active fraction across age compare plot chisquare','png');

save MeanANDpdatas.mat VAluesANDpSave -v7.3

%%

cclr
p12dataStrc = load('p12fieldwiseData.mat');
p18dataStrc = load('p18fieldwiseData.mat');
M4dataStrc = load('M4fieldwiseData.mat');
%%
[p12_WT_Sess_fieldwise_neuAvgs, p12_WT_Sess_fieldwise_astAvgs,p12_WT_Sess_fracs] = ...
    cellfun(@(x,y,z) fieldwisecalculationFun(x,y,z,1),p12dataStrc.WTSess_EventData_all(:,1),...
    p12dataStrc.WTSess_EventData_all(:,2),p12dataStrc.WTSess_EventData_all(:,3),...
    'UniformOutput',false);
[p12_Tg_Sess_fieldwise_neuAvgs, p12_Tg_Sess_fieldwise_astAvgs,p12_Tg_Sess_fracs] = ...
    cellfun(@(x,y,z) fieldwisecalculationFun(x,y,z,1),p12dataStrc.TgSess_EventData_all(:,1),...
    p12dataStrc.TgSess_EventData_all(:,2),p12dataStrc.TgSess_EventData_all(:,3),...
    'UniformOutput',false);
[p18_WT_Sess_fieldwise_neuAvgs, p18_WT_Sess_fieldwise_astAvgs,p18_WT_Sess_fracs] = ...
    cellfun(@(x,y,z) fieldwisecalculationFun(x,y,z,1),p18dataStrc.WTSess_EventData_all(:,1),...
    p18dataStrc.WTSess_EventData_all(:,2),p18dataStrc.WTSess_EventData_all(:,3),...
    'UniformOutput',false);
[p18_Tg_Sess_fieldwise_neuAvgs, p18_Tg_Sess_fieldwise_astAvgs,p18_Tg_Sess_fracs] = ...
    cellfun(@(x,y,z) fieldwisecalculationFun(x,y,z,1),p18dataStrc.TgSess_EventData_all(:,1),...
    p18dataStrc.TgSess_EventData_all(:,2),p18dataStrc.TgSess_EventData_all(:,3),...
    'UniformOutput',false);
[M4_WT_Sess_fieldwise_neuAvgs, M4_WT_Sess_fieldwise_astAvgs,M4_WT_Sess_fracs] = ...
    cellfun(@(x,y,z) fieldwisecalculationFun(x,y,z,1),M4dataStrc.WTSess_EventData_all(:,1),...
    M4dataStrc.WTSess_EventData_all(:,2),M4dataStrc.WTSess_EventData_all(:,3),...
    'UniformOutput',false);
[M4_Tg_Sess_fieldwise_neuAvgs, M4_Tg_Sess_fieldwise_astAvgs,M4_Tg_Sess_fracs] = ...
    cellfun(@(x,y,z) fieldwisecalculationFun(x,y,z,1),M4dataStrc.TgSess_EventData_all(:,1),...
    M4dataStrc.TgSess_EventData_all(:,2),M4dataStrc.TgSess_EventData_all(:,3),...
    'UniformOutput',false);

%% fieldwise frequency plots
p12_WT_NeuAvgs = cell2mat(p12_WT_Sess_fieldwise_neuAvgs);
p12_WT_AstAvgs = cell2mat(p12_WT_Sess_fieldwise_astAvgs);
p12_Tg_NeuAvgs = cell2mat(p12_Tg_Sess_fieldwise_neuAvgs);
p12_Tg_AstAvgs = cell2mat(p12_Tg_Sess_fieldwise_astAvgs);

p18_WT_NeuAvgs = cell2mat(p18_WT_Sess_fieldwise_neuAvgs);
p18_WT_AstAvgs = cell2mat(p18_WT_Sess_fieldwise_astAvgs);
p18_Tg_NeuAvgs = cell2mat(p18_Tg_Sess_fieldwise_neuAvgs);
p18_Tg_AstAvgs = cell2mat(p18_Tg_Sess_fieldwise_astAvgs);

M4_WT_NeuAvgs = cell2mat(M4_WT_Sess_fieldwise_neuAvgs);
M4_WT_AstAvgs = cell2mat(M4_WT_Sess_fieldwise_astAvgs);
M4_Tg_NeuAvgs = cell2mat(M4_Tg_Sess_fieldwise_neuAvgs);
M4_Tg_AstAvgs = cell2mat(M4_Tg_Sess_fieldwise_astAvgs);

%%
% bet genotype compare plots
PlotStrs = {'p12','p18','M4'};
NumPlots = length(PlotStrs);
colors = {[0.2 0.2 0.2],[0.9 0.1 0.1],[0.6 0.6 0.6],[0.6 0.2 0.2]};
hff = figure('position',[100 200 1040 340]);
for cp = 1 : NumPlots
    ax = subplot(1,3,cp);
    hold on
    eval(['WT_NEU_Das = ',PlotStrs{cp},'_WT_NeuAvgs;']);
    eval(['WT_AST_Das = ',PlotStrs{cp},'_WT_AstAvgs;']);
    eval(['Tg_NEU_Das = ',PlotStrs{cp},'_Tg_NeuAvgs;']);
    eval(['Tg_AST_Das = ',PlotStrs{cp},'_Tg_AstAvgs;']);
    
    WT_NEU_Das(isnan(WT_NEU_Das(:,1)),:) = [];
    WT_AST_Das(isnan(WT_AST_Das(:,1)),:) = [];
    Tg_NEU_Das(isnan(Tg_NEU_Das(:,1)),:) = [];
    Tg_AST_Das(isnan(Tg_AST_Das(:,1)),:) = [];
    
    PlotAvgs = [mean(WT_NEU_Das(:,1)),mean(Tg_NEU_Das(:,1)),...
        mean(WT_AST_Das(:,1)),mean(Tg_AST_Das(:,1))];
    Plotfieldnums = [size(WT_NEU_Das,1),size(Tg_NEU_Das,1),...
        size(WT_AST_Das,1),size(Tg_AST_Das,1)];
    
    PlotSEMs = [std(WT_NEU_Das(:,1))/sqrt(Plotfieldnums(1)),...
        std(Tg_NEU_Das(:,1))/sqrt(Plotfieldnums(2)),...
        std(WT_AST_Das(:,1))/sqrt(Plotfieldnums(3)),...
        std(Tg_AST_Das(:,1))/sqrt(Plotfieldnums(4))];
    AllDatas = {WT_NEU_Das(:,1),Tg_NEU_Das(:,1),WT_AST_Das(:,1),Tg_AST_Das(:,1)};
    
%     [~,Neu_p] = ttest2(WT_NEU_Das(:,1),Tg_NEU_Das(:,1));
%     [~,Ast_p] = ttest2(WT_AST_Das(:,1),Tg_AST_Das(:,1));
    Neu_p = ranksum(WT_NEU_Das(:,1),Tg_NEU_Das(:,1));
    Ast_p = ranksum(WT_AST_Das(:,1),Tg_AST_Das(:,1));
    
    for ccp = 1 : 4
        bar(ccp,PlotAvgs(ccp),0.6,'edgecolor','none','Facecolor',colors{ccp});
        plot((rand(Plotfieldnums(ccp),1)-0.5)*0.2+ccp,AllDatas{ccp},'ko','MarkerSize',4);
    end
    errorbar(1:4,PlotAvgs,PlotSEMs,'k.','Marker','none','linewidth',1.2);
    
    text(1:4,PlotAvgs*0.8,cellstr(num2str(Plotfieldnums(:),'%d')),...
        'HorizontalAlignment','center','Fontsize',8,'color','c');
    
    GroupSigIndication([1,2],PlotAvgs(1:2),Neu_p,ax,1.3,[],6);
    GroupSigIndication([3,4],PlotAvgs(3:4),Ast_p,ax,1.3,[],6);
    
    set(ax,'xtick',1:4,'xticklabel',{'WTN','TgN','WTA','TgA'},'xlim',[0 5]);
    ylabel('Freq per min');
    title(PlotStrs{cp});
    
end

%%
saveas(hff,'Same age bet type compare plot fieldwise');
saveas(hff,'Same age bet type compare plot fieldwise','png');
saveas(hff,'Same age bet type compare plot fieldwise','pdf');

%% 
% bet age compare plots
Usedstrs = {'WT_Neu','WT_Ast','Tg_Neu','Tg_Ast'};
NPlots = length(Usedstrs);
barColors = {[0.7,0.4,0.1],[1,0.6,0.2],[0.2,0.8,0.3]};
hcf = figure('position',[100 200 750 620]);
for csub = 1 : NPlots
    cax = subplot(2,2,csub);
    hold on
    
    eval(['P12_Das = ','p12_',Usedstrs{csub},'Avgs;']);
    eval(['P18_Das = ','p18_',Usedstrs{csub},'Avgs;']);
    eval(['M4_Das = ','M4_',Usedstrs{csub},'Avgs;']);
    
    P12_Das(isnan(P12_Das(:,1)),:) = [];
    P18_Das(isnan(P18_Das(:,1)),:) = [];
    M4_Das(isnan(M4_Das(:,1)),:) = [];
    
    PlotAvgs = [mean(P12_Das(:,1)),mean(P18_Das(:,1)),...
        mean(M4_Das(:,1))];
    Plotfieldnums = [size(P12_Das,1),size(P18_Das,1),...
        size(M4_Das,1)];
    
    PlotSEMs = [std(P12_Das(:,1))/sqrt(Plotfieldnums(1)),...
        std(P18_Das(:,1))/sqrt(Plotfieldnums(2)),...
        std(M4_Das(:,1))/sqrt(Plotfieldnums(3))];
    
    [~,p12_18_p] = ttest2(P12_Das(:,1),P18_Das(:,1));
    [~,p12_m4_p] = ttest2(P12_Das(:,1),M4_Das(:,1));
    [~,p18_m4_p] = ttest2(P18_Das(:,1),M4_Das(:,1));
    for cplot = 1 : 3
        bar(cplot, PlotAvgs(cplot),0.6,'EdgeColor','none','FaceColor',barColors{cplot});
    end
    
    errorbar(1:3,PlotAvgs,PlotSEMs,'k.','linewidth',1.4,'Marker','none');
    text(1:3,PlotAvgs*0.7,cellstr(num2str(Plotfieldnums(:),'%d')),...
        'HorizontalAlignment','center','Color','k');
    set(cax,'xtick',1:3,'xticklabel',{'p12';'p18';'M4'},'box','off','FontSize',8,'xlim',[0 4]);
    title(cax,strrep(Usedstrs{csub},'_','\_'));
    ylabel(cax,'Freq per min');
    GroupSigIndication([1,2],PlotAvgs([1,2]),p12_18_p,cax,1.1,[],6);
    GroupSigIndication([2,3],PlotAvgs([2,3]),p18_m4_p,cax,1.3,[],6);
    GroupSigIndication([1,3],PlotAvgs([1,3]),p12_m4_p,cax,1.5,[],6);
    
end

%%
saveas(hcf,'Same type across age compare plot fieldwise');
saveas(hcf,'Same type across age compare plot fieldwise','png');
saveas(hcf,'Same type across age compare plot fieldwise','pdf');

%% ####################################################
% fraction plot using fieldwise plot
p12_WT_NeuANDAst_fracs = cell2mat(p12_WT_Sess_fracs);
p12_WT_NeuActiveFracs = p12_WT_NeuANDAst_fracs(:,1);
p12_WT_AstActiveFracs = p12_WT_NeuANDAst_fracs(:,2);
p12_Tg_NeuANDAst_fracs = cell2mat(p12_Tg_Sess_fracs);
p12_Tg_NeuActiveFracs = p12_Tg_NeuANDAst_fracs(:,1);
p12_Tg_AstActiveFracs = p12_Tg_NeuANDAst_fracs(:,2);

p18_WT_NeuANDAst_fracs = cell2mat(p18_WT_Sess_fracs);
p18_WT_NeuActiveFracs = p18_WT_NeuANDAst_fracs(:,1);
p18_WT_AstActiveFracs = p18_WT_NeuANDAst_fracs(:,2);
p18_Tg_NeuANDAst_fracs = cell2mat(p18_Tg_Sess_fracs);
p18_Tg_NeuActiveFracs = p18_Tg_NeuANDAst_fracs(:,1);
p18_Tg_AstActiveFracs = p18_Tg_NeuANDAst_fracs(:,2);

M4_WT_NeuANDAst_fracs = cell2mat(M4_WT_Sess_fracs);
M4_WT_NeuActiveFracs = M4_WT_NeuANDAst_fracs(:,1);
M4_WT_AstActiveFracs = M4_WT_NeuANDAst_fracs(:,2);
M4_Tg_NeuANDAst_fracs = cell2mat(M4_Tg_Sess_fracs);
M4_Tg_NeuActiveFracs = M4_Tg_NeuANDAst_fracs(:,1);
M4_Tg_AstActiveFracs = M4_Tg_NeuANDAst_fracs(:,2);

%% bet genotype compare plot

PlotStrs = {'p12','p18','M4'};
NumPlots = length(PlotStrs);
colors = {[0.2 0.2 0.2],[0.9 0.1 0.1],[0.6 0.6 0.6],[0.6 0.2 0.2]};
hfracf = figure('position',[100 200 1040 340]);
for cp = 1 : NumPlots
    ax = subplot(1,3,cp);
    hold on
    eval(['WT_NEU_Das = ',PlotStrs{cp},'_WT_NeuActiveFracs;']);
    eval(['WT_AST_Das = ',PlotStrs{cp},'_WT_AstActiveFracs;']);
    eval(['Tg_NEU_Das = ',PlotStrs{cp},'_Tg_NeuActiveFracs;']);
    eval(['Tg_AST_Das = ',PlotStrs{cp},'_Tg_AstActiveFracs;']);
    
%     WT_NEU_Das(isnan(WT_NEU_Das(:,1)),:) = [];
%     WT_AST_Das(isnan(WT_AST_Das(:,1)),:) = [];
%     Tg_NEU_Das(isnan(Tg_NEU_Das(:,1)),:) = [];
%     Tg_AST_Das(isnan(Tg_AST_Das(:,1)),:) = [];
    
    PlotAvgs = [mean(WT_NEU_Das),mean(Tg_NEU_Das),...
        mean(WT_AST_Das),mean(Tg_AST_Das)];
    Plotfieldnums = [numel(WT_NEU_Das),numel(Tg_NEU_Das),...
        numel(WT_AST_Das),numel(Tg_AST_Das)];
    
    PlotSEMs = [std(WT_NEU_Das)/sqrt(Plotfieldnums(1)),...
        std(Tg_NEU_Das)/sqrt(Plotfieldnums(2)),...
        std(WT_AST_Das)/sqrt(Plotfieldnums(3)),...
        std(Tg_AST_Das)/sqrt(Plotfieldnums(4))];
    
    
    [~,Neu_p] = ttest2(WT_NEU_Das,Tg_NEU_Das,'Vartype','unequal');
    [~,Ast_p] = ttest2(WT_AST_Das,Tg_AST_Das,'Vartype','unequal');
    
    for ccp = 1 : 4
        bar(ccp,PlotAvgs(ccp),0.6,'edgecolor','none','Facecolor',colors{ccp});
    end
    errorbar(1:4,PlotAvgs,PlotSEMs,'k.','Marker','none','linewidth',1.2);
    
    text(1:4,PlotAvgs*0.8,cellstr(num2str(Plotfieldnums(:),'%d')),...
        'HorizontalAlignment','center','Fontsize',8,'color','c');
    
    GroupSigIndication([1,2],PlotAvgs(1:2),Neu_p,ax,1.2,[],6);
    GroupSigIndication([3,4],PlotAvgs(3:4),Ast_p,ax,1.2,[],6);
    
    set(ax,'xtick',1:4,'xticklabel',{'WTN','TgN','WTA','TgA'},'xlim',[0 5]);
    ylabel('Active frac.');
    title(PlotStrs{cp});
    
end

%%
saveas(hfracf,'Same age bet genotype frac compare fieldwise');
saveas(hfracf,'Same age bet genotype frac compare fieldwise','png');
saveas(hfracf,'Same age bet genotype frac compare fieldwise','pdf');

%%
% save genotype bet age compare plot

Usedstrs = {'WT_Neu','WT_Ast','Tg_Neu','Tg_Ast'};
NPlots = length(Usedstrs);
barColors = {[0.7,0.4,0.1],[1,0.6,0.2],[0.2,0.8,0.3]};
hcf = figure('position',[100 200 750 620]);
for csub = 1 : NPlots
    cax = subplot(2,2,csub);
    hold on
    
    eval(['P12_Das = ','p12_',Usedstrs{csub},'ActiveFracs;']);
    eval(['P18_Das = ','p18_',Usedstrs{csub},'ActiveFracs;']);
    eval(['M4_Das = ','M4_',Usedstrs{csub},'ActiveFracs;']);
    
%     P12_Das(isnan(P12_Das(:,1)),:) = [];
%     P18_Das(isnan(P18_Das(:,1)),:) = [];
%     M4_Das(isnan(M4_Das(:,1)),:) = [];
    
    PlotAvgs = [mean(P12_Das),mean(P18_Das),...
        mean(M4_Das)];
    Plotfieldnums = [numel(P12_Das),numel(P18_Das),...
        numel(M4_Das)];
    
    PlotSEMs = [std(P12_Das)/sqrt(Plotfieldnums(1)),...
        std(P18_Das)/sqrt(Plotfieldnums(2)),...
        std(M4_Das)/sqrt(Plotfieldnums(3))];
    
    [~,p12_18_p] = ttest2(P12_Das,P18_Das);
    [~,p12_m4_p] = ttest2(P12_Das,M4_Das);
    [~,p18_m4_p] = ttest2(P18_Das,M4_Das);
    for cplot = 1 : 3
        bar(cplot, PlotAvgs(cplot),0.6,'EdgeColor','none','FaceColor',barColors{cplot});
    end
    
    errorbar(1:3,PlotAvgs,PlotSEMs,'k.','linewidth',1.4,'Marker','none');
    text(1:3,PlotAvgs*0.7,cellstr(num2str(Plotfieldnums(:),'%d')),...
        'HorizontalAlignment','center','Color','k');
    set(cax,'xtick',1:3,'xticklabel',{'p12';'p18';'M4'},'box','off','FontSize',8,'xlim',[0 4]);
    title(cax,strrep(Usedstrs{csub},'_','\_'));
    ylabel(cax,'Active frac.');
    GroupSigIndication([1,2],PlotAvgs([1,2]),p12_18_p,cax,1.1,[],6);
    GroupSigIndication([2,3],PlotAvgs([2,3]),p18_m4_p,cax,1.3,[],6);
    GroupSigIndication([1,3],PlotAvgs([1,3]),p12_m4_p,cax,1.5,[],6);
    
end

%%

saveas(hcf,'Same genotype bet age frac compare fieldwise');
saveas(hcf,'Same genotype bet age frac compare fieldwise','png');
saveas(hcf,'Same genotype bet age frac compare fieldwise','pdf');

%% #########################################################################
% amplitude field wise compare plots

cclr
p12dataStrc = load('p12fieldwiseAmpData.mat');
p18dataStrc = load('p18fieldwiseAmpData.mat');
M4dataStrc = load('M4fieldwiseAmpData.mat');

%%
% wt datas
[p12_wt_Neu_Ampdats,p12_wt_Ast_Ampdats,p12_wt_NeuAllAmp,p12_wt_AstAllAmp] ...
    = cellfun(@(x,y) fieldwiseAmpCalFun(x,y),...
    p12dataStrc.WT_EventPeak_Alls,...
    p12dataStrc.WTSess_EventData_all(:,2),'UniformOutput',false);
[p18_wt_Neu_Ampdats,p18_wt_Ast_Ampdats,p18_wt_NeuAllAmp,p18_wt_AstAllAmp] ...
    = cellfun(@(x,y) fieldwiseAmpCalFun(x,y),...
    p18dataStrc.WT_EventPeak_Alls,...
    p18dataStrc.WTSess_EventData_all(:,2),'UniformOutput',false);
[M4_wt_Neu_Ampdats,M4_wt_Ast_Ampdats,M4_wt_NeuAllAmp,M4_wt_AstAllAmp] ...
    = cellfun(@(x,y) fieldwiseAmpCalFun(x,y),...
    M4dataStrc.WT_EventPeak_Alls,...
    M4dataStrc.WTSess_EventData_all(:,2),'UniformOutput',false);
% tg datas
[p12_tg_Neu_Ampdats,p12_tg_Ast_Ampdats,p12_tg_NeuAllAmp,p12_tg_AstAllAmp] ...
    = cellfun(@(x,y) fieldwiseAmpCalFun(x,y),...
    p12dataStrc.Tg_EventPeak_Alls,...
    p12dataStrc.TgSess_EventData_all(:,2),'UniformOutput',false);
[p18_tg_Neu_Ampdats,p18_tg_Ast_Ampdats,p18_tg_NeuAllAmp,p18_tg_AstAllAmp] ...
    = cellfun(@(x,y) fieldwiseAmpCalFun(x,y),...
    p18dataStrc.Tg_EventPeak_Alls,...
    p18dataStrc.TgSess_EventData_all(:,2),'UniformOutput',false);
[M4_tg_Neu_Ampdats,M4_tg_Ast_Ampdats,M4_tg_NeuAllAmp,M4_tg_AstAllAmp] ...
    = cellfun(@(x,y) fieldwiseAmpCalFun(x,y),...
    M4dataStrc.Tg_EventPeak_Alls,...
    M4dataStrc.TgSess_EventData_all(:,2),'UniformOutput',false);

p12_wt_Neu_AmpMtx = cell2mat(p12_wt_Neu_Ampdats);
p12_wt_Ast_AmpMtx = cell2mat(p12_wt_Ast_Ampdats);
p18_wt_Neu_AmpMtx = cell2mat(p18_wt_Neu_Ampdats);
p18_wt_Ast_AmpMtx = cell2mat(p18_wt_Ast_Ampdats);
M4_wt_Neu_AmpMtx = cell2mat(M4_wt_Neu_Ampdats);
M4_wt_Ast_AmpMtx = cell2mat(M4_wt_Ast_Ampdats);

p12_tg_Neu_AmpMtx = cell2mat(p12_tg_Neu_Ampdats);
p12_tg_Ast_AmpMtx = cell2mat(p12_tg_Ast_Ampdats);
p18_tg_Neu_AmpMtx = cell2mat(p18_tg_Neu_Ampdats);
p18_tg_Ast_AmpMtx = cell2mat(p18_tg_Ast_Ampdats);
M4_tg_Neu_AmpMtx = cell2mat(M4_tg_Neu_Ampdats);
M4_tg_Ast_AmpMtx = cell2mat(M4_tg_Ast_Ampdats);

%%

% bet genotype compare plots
PlotStrs = {'p12','p18','M4'};
NumPlots = length(PlotStrs);
colors = {[0.2 0.2 0.2],[0.9 0.1 0.1],[0.6 0.6 0.6],[0.6 0.2 0.2]};
hff = figure('position',[100 200 1040 340]);
for cp = 1 : NumPlots
    ax = subplot(1,3,cp);
    hold on
    eval(['WT_NEU_Das = ',PlotStrs{cp},'_wt_Neu_AmpMtx;']);
    eval(['WT_AST_Das = ',PlotStrs{cp},'_wt_Ast_AmpMtx;']);
    eval(['Tg_NEU_Das = ',PlotStrs{cp},'_tg_Neu_AmpMtx;']);
    eval(['Tg_AST_Das = ',PlotStrs{cp},'_tg_Ast_AmpMtx;']);
    
    WT_NEU_Das(isnan(WT_NEU_Das(:,1)),:) = [];
    WT_AST_Das(isnan(WT_AST_Das(:,1)),:) = [];
    Tg_NEU_Das(isnan(Tg_NEU_Das(:,1)),:) = [];
    Tg_AST_Das(isnan(Tg_AST_Das(:,1)),:) = [];
    
    PlotAvgs = [mean(WT_NEU_Das(:,1)),mean(Tg_NEU_Das(:,1)),...
        mean(WT_AST_Das(:,1)),mean(Tg_AST_Das(:,1))];
    Plotfieldnums = [size(WT_NEU_Das,1),size(Tg_NEU_Das,1),...
        size(WT_AST_Das,1),size(Tg_AST_Das,1)];
    
    PlotSEMs = [std(WT_NEU_Das(:,1))/sqrt(Plotfieldnums(1)),...
        std(Tg_NEU_Das(:,1))/sqrt(Plotfieldnums(2)),...
        std(WT_AST_Das(:,1))/sqrt(Plotfieldnums(3)),...
        std(Tg_AST_Das(:,1))/sqrt(Plotfieldnums(4))];
    
    
    [~,Neu_p] = ttest2(WT_NEU_Das(:,1),Tg_NEU_Das(:,1));
    [~,Ast_p] = ttest2(WT_AST_Das(:,1),Tg_AST_Das(:,1));
    
    for ccp = 1 : 4
        bar(ccp,PlotAvgs(ccp),0.6,'edgecolor','none','Facecolor',colors{ccp});
    end
    errorbar(1:4,PlotAvgs,PlotSEMs,'k.','Marker','none','linewidth',1.2);
    
    text(1:4,PlotAvgs*0.8,cellstr(num2str(Plotfieldnums(:),'%d')),...
        'HorizontalAlignment','center','Fontsize',8,'color','c');
    
    GroupSigIndication([1,2],PlotAvgs(1:2),Neu_p,ax,1.2,[],6);
    GroupSigIndication([3,4],PlotAvgs(3:4),Ast_p,ax,1.2,[],6);
    
    set(ax,'xtick',1:4,'xticklabel',{'WTN','TgN','WTA','TgA'},'xlim',[0 5]);
    ylabel('Amplitude(dff)');
    title(PlotStrs{cp});
    
end

%% 
saveas(hff,'Same age bet genotype amplitude fieldwise');
saveas(hff,'Same age bet genotype amplitude fieldwise','png');
saveas(hff,'Same age bet genotype amplitude fieldwise','pdf');

%% same genotype compare between ages
% bet age compare plots
Usedstrs = {'wt_Neu','wt_Ast','tg_Neu','tg_Ast'};
NPlots = length(Usedstrs);
barColors = {[0.7,0.4,0.1],[1,0.6,0.2],[0.2,0.8,0.3]};
hcf = figure('position',[100 200 750 620]);
for csub = 1 : NPlots
    cax = subplot(2,2,csub);
    hold on
    
    eval(['P12_Das = ','p12_',Usedstrs{csub},'_AmpMtx;']);
    eval(['P18_Das = ','p18_',Usedstrs{csub},'_AmpMtx;']);
    eval(['M4_Das = ','M4_',Usedstrs{csub},'_AmpMtx;']);
    
    P12_Das(isnan(P12_Das(:,1)),:) = [];
    P18_Das(isnan(P18_Das(:,1)),:) = [];
    M4_Das(isnan(M4_Das(:,1)),:) = [];
    
    PlotAvgs = [mean(P12_Das(:,1)),mean(P18_Das(:,1)),...
        mean(M4_Das(:,1))];
    Plotfieldnums = [size(P12_Das,1),size(P18_Das,1),...
        size(M4_Das,1)];
    
    PlotSEMs = [std(P12_Das(:,1))/sqrt(Plotfieldnums(1)),...
        std(P18_Das(:,1))/sqrt(Plotfieldnums(2)),...
        std(M4_Das(:,1))/sqrt(Plotfieldnums(3))];
    
    [~,p12_18_p] = ttest2(P12_Das(:,1),P18_Das(:,1));
    [~,p12_m4_p] = ttest2(P12_Das(:,1),M4_Das(:,1));
    [~,p18_m4_p] = ttest2(P18_Das(:,1),M4_Das(:,1));
    for cplot = 1 : 3
        bar(cplot, PlotAvgs(cplot),0.6,'EdgeColor','none','FaceColor',barColors{cplot});
    end
    
    errorbar(1:3,PlotAvgs,PlotSEMs,'k.','linewidth',1.4,'Marker','none');
    text(1:3,PlotAvgs*0.7,cellstr(num2str(Plotfieldnums(:),'%d')),...
        'HorizontalAlignment','center','Color','k');
    set(cax,'xtick',1:3,'xticklabel',{'p12';'p18';'M4'},'box','off','FontSize',8,'xlim',[0 4]);
    title(cax,strrep(Usedstrs{csub},'_','\_'));
    ylabel(cax,'Amplitude(dff)');
    GroupSigIndication([1,2],PlotAvgs([1,2]),p12_18_p,cax,1.1,[],6);
    GroupSigIndication([2,3],PlotAvgs([2,3]),p18_m4_p,cax,1.3,[],6);
    GroupSigIndication([1,3],PlotAvgs([1,3]),p12_m4_p,cax,1.5,[],6);
    
end

%%
saveas(hcf,'Same type across age amplitude compare fieldwise');
saveas(hcf,'Same type across age amplitude compare fieldwise','png');
saveas(hcf,'Same type across age amplitude compare fieldwise','pdf');

%% same genotype compare between ages box plot
% bet age compare plots
% ######
% AstUsedStrs = {'p12_wt_Ast','p18_wt_Ast','M4_wt_Ast','p12_tg_Ast','p18_tg_Ast','M4_tg_Ast'};
% NeuUsedStrs = {'p12_wt_Neu','p18_wt_Neu','M4_wt_Neu','p12_tg_Neu','p18_tg_Neu','M4_tg_Neu'};
% NPlots = length(NeuUsedStrs);
% TypeColors = {'k',[.3 .3 .3],[.6 .6 .6],'r',[1 0.8 0.3],[0.7 0.4 0.1]};
% ######
AstUsedStrs = {'p12_wt_Ast','p12_tg_Ast','p18_wt_Ast','p18_tg_Ast','M4_wt_Ast','M4_tg_Ast'};
NeuUsedStrs = {'p12_wt_Neu','p12_tg_Neu','p18_wt_Neu','p18_tg_Neu','M4_wt_Neu','M4_tg_Neu'};
NPlots = length(NeuUsedStrs);
TypeColors = {'k','r',[.3 .3 .3],[1 0.8 0.3],[.6 .6 .6],[0.7 0.4 0.1]};


hls = [];
NeuDataANDInds = [];
AstDataANDInds = [];
hcf = figure('position',[100 100 780 320]);
ax1 = subplot(121);
hold on;
ax2 = subplot(122);
hold on;
for csub = 1 : NPlots
    
    
    eval(['Neu_Das = ',NeuUsedStrs{csub},'AllAmp;']);% All ROI amp datas
    eval(['Ast_Das = ',AstUsedStrs{csub},'AllAmp;']);
    
    eval(['NeuAvg_Das = ',NeuUsedStrs{csub},'_AmpMtx;']);% field averaged amp datas
    eval(['AstAvg_Das = ',AstUsedStrs{csub},'_AmpMtx;']);
    
    [NeuAmpData, NeuAmpBins, NeuAmpBinCenters] = ...
        AmpValue2Bins(Neu_Das,0.2,3);
    [AstAmpData, AstAmpBins, AstAmpBinCenters] = ...
        AmpValue2Bins(Ast_Das,0.2,3);
    
    NeuAmpDataMtx = cell2mat(NeuAmpData(:,1));
    NeuAmpAvg = mean(NeuAmpDataMtx,'omitnan');
    NeuAmpSEM = std(NeuAmpDataMtx,'omitnan')./sqrt(sum(~isnan(NeuAmpDataMtx)));
    Neupatch_x = [NeuAmpBinCenters,fliplr(NeuAmpBinCenters)];
    Neupatch_y = [NeuAmpAvg - NeuAmpSEM*0.4,fliplr(NeuAmpAvg + NeuAmpSEM*0.4)];
    
    AstAmpDataMtx = cell2mat(AstAmpData(:,1));
    AstAmpAvg = mean(AstAmpDataMtx,'omitnan');
    AstAmpSEM = std(AstAmpDataMtx,'omitnan')./sqrt(sum(~isnan(AstAmpDataMtx)));
    Astpatch_x = [AstAmpBinCenters,fliplr(AstAmpBinCenters)];
    Astpatch_y = [AstAmpAvg - AstAmpSEM*0.4,fliplr(AstAmpAvg + AstAmpSEM*0.4)];
    
    patch(ax1,Neupatch_x,Neupatch_y,1,'EdgeColor','none','FaceColor',[.8 .8 .8],'facealpha',0.4);
    patch(ax2,Astpatch_x,Astpatch_y,1,'EdgeColor','none','FaceColor',[.8 .8 .8],'facealpha',0.4);
    
    
%     Neu_DataVec = cell2mat(Neu_Das);
%     Ast_DataVec = cell2mat(Ast_Das);
%     [Neu_y,Neu_x] = ecdf(Neu_DataVec);
%     [Ast_y,Ast_x] = ecdf(Ast_DataVec);
    
    hl = plot(ax1,NeuAmpBinCenters,NeuAmpAvg,'Color',TypeColors{csub},'linewidth',1.4);
    plot(ax2,AstAmpBinCenters,AstAmpAvg,'Color',TypeColors{csub},'linewidth',1.4);
    hls = [hls,hl];
%     hl = plot(ax1,Neu_x,Neu_y,'Color',TypeColors{csub},'linewidth',1.4);
%     plot(ax2,Ast_x,Ast_y,'Color',TypeColors{csub},'linewidth',1.4);
%     hls = [hls,hl];
    
    NeuFieldNums = size(NeuAvg_Das,1);
    AstFieldNums = size(AstAvg_Das,1);
    NeuDataANDInds = [NeuDataANDInds;[NeuAvg_Das(:,1),ones(NeuFieldNums,1)+csub]];
    AstDataANDInds = [AstDataANDInds;[AstAvg_Das(:,1),ones(AstFieldNums,1)+csub]];
end
xlabel(ax1,'Amplitude/dff');
xlabel(ax2,'Amplitude/dff');
ylabel(ax1,'Cumu. frac.');
ylabel(ax2,'Cumu. frac.');
title(ax1,'Neu');
title(ax2,'Ast');
legend(ax1,hls,strrep(NeuUsedStrs,'_','-'),'location','Southeast','box','off');
%%
huuf = figure('position',[100 500 980 320]);
ax1 = subplot(121);
boxplot(ax1,NeuDataANDInds(:,1),NeuDataANDInds(:,2),'labels',...
    strrep(NeuUsedStrs,'_',''));
title('Neus');
ylabel('dff');

ax2 = subplot(122);
boxplot(ax2,AstDataANDInds(:,1),AstDataANDInds(:,2),'labels',...
    strrep(AstUsedStrs,'_',''));
title('Asts');
ylabel('dff');

Neups = zeros(15,3);
Astps = zeros(15,3);
k = 1;
for cData = 1 : 6
    for ccomdata = (cData+1) : 6
        eval(['NeuData1 = ',NeuUsedStrs{cData},'_AmpMtx;']);
        eval(['NeuData2 = ',NeuUsedStrs{ccomdata},'_AmpMtx;']);
        Neups(k,:) = [cData,ccomdata,AssumpTest(NeuData1(:,1),NeuData2(:,1))];
        
        eval(['AstData1 = ',AstUsedStrs{cData},'_AmpMtx;']);
        eval(['AstData2 = ',AstUsedStrs{ccomdata},'_AmpMtx;']);
        Astps(k,:) = [cData,ccomdata,AssumpTest(AstData1(:,1),AstData2(:,1))];
        k = k + 1;
    end
end
%%
save ampcompareps.mat Neups Astps NeuUsedStrs AstUsedStrs -v7.3

%%

savename = sprintf('Threeage amplitude boxplot fieldwise');
set(huuf,'paperpositionmode','manual');
saveas(huuf,savename);
saveas(huuf,savename,'png');
print(huuf,'-dpdf',savename,'-painters');

savename = sprintf('Threeage amplitude ROI fieldwise cumulative plots');
set(hcf,'paperpositionmode','manual');
saveas(hcf,savename);
saveas(hcf,savename,'png');
print(hcf,'-dpdf',savename,'-painters');


