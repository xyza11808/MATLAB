cclr

p12EFDataStrc = load('p12fieldwiseData.mat');
p18EFDataStrc = load('p18fieldwiseData.mat');
m4EFDataStrc = load('M4fieldwiseData.mat');


%%

[p12WTSessEFData, p12WTEventBins, p12WTBinCenters] = ...
    EventFreq2Bins(p12EFDataStrc.WTSess_EventData_all,0.4);
[p12TgSessEFData, p12TgEventBins, p12TgBinCenters] = ...
    EventFreq2Bins(p12EFDataStrc.TgSess_EventData_all,0.4);

[p18WTSessEFData, p18WTEventBins, p18WTBinCenters] = ...
    EventFreq2Bins(p18EFDataStrc.WTSess_EventData_all,0.4);
[p18TgSessEFData, p18TgEventBins, p18TgBinCenters] = ...
    EventFreq2Bins(p18EFDataStrc.TgSess_EventData_all,0.4);

[M4WTSessEFData, m4WTEventBins, M4WTBinCenters] = ...
    EventFreq2Bins(m4EFDataStrc.WTSess_EventData_all,0.4);
[M4TgSessEFData, m4TgEventBins, M4TgBinCenters] = ...
    EventFreq2Bins(m4EFDataStrc.TgSess_EventData_all,0.4);


%%

hf = figure('position',[100 100 750 360]);

ax1 = subplot(121); % Neu data plot
hold on;
ax2 = subplot(122); % Ast plot
hold on;

TypeStrs = {'p12WT','p12Tg','p18WT','p18Tg','M4WT','M4Tg'};
TypeColors = {'k','r',[.3 .3 .3],[1 0.8 0.3],[.6 .6 .6],[0.7 0.4 0.1]};
hplots = [];
NeuBoxPlot = [];
AstBoxPlot = [];
SEMFact = 0.5;
for cData = 1 : length(TypeStrs)
    eval(sprintf('PlotData = %sSessEFData;',TypeStrs{cData}));
    eval(sprintf('Plotbins = %sBinCenters;',TypeStrs{cData}));
    
    NeuMtx = cell2mat(PlotData(:,3));
    NeuAvg = mean(NeuMtx);
    NeuSEM = std(NeuMtx) / sqrt(size(PlotData,1));
    
%     hl = errorbar(ax1,Plotbins,NeuAvg,NeuSEM,...
%         'Color',TypeColors{cData},'linewidth',1.4);
%     title(ax1,'Neu');
    Neu_px = [Plotbins,fliplr(Plotbins)];
    Neu_py = [NeuAvg - SEMFact*NeuSEM,fliplr(NeuAvg + SEMFact*NeuSEM)];
    patch(ax1,Neu_px,Neu_py,1,'FaceColor',[.8 .8 .8],'Edgecolor','none');
    hl = plot(ax1,Plotbins,NeuAvg,'linewidth',1.5,'Color',TypeColors{cData});
    hplots = [hplots,hl];
    
    AstMtx = cell2mat(PlotData(:,4));
    AstAvg = mean(AstMtx);
    AstSEM = std(AstMtx) / sqrt(size(PlotData,1));
    
%     errorbar(ax2,Plotbins,AstAvg,AstSEM,...
%         'Color',TypeColors{cData},'linewidth',1.4);
    Ast_px = [Plotbins,fliplr(Plotbins)];
    Ast_py = [AstAvg - AstSEM*SEMFact,fliplr(AstAvg + AstSEM*SEMFact)];
    patch(ax2,Ast_px,Ast_py,1,'FaceColor',[.8 .8 .8],'Edgecolor','none');
    plot(ax2,Plotbins,AstAvg,'linewidth',1.5,'Color',TypeColors{cData});
    title(ax2,['Ast',num2str(SEMFact,'SEMFac-%.2f')]);
    
    % field mean events frequency
    PlotAvgDatas = cell2mat(PlotData(:,6)); % Neu and Ast, two columns
    
    NeuBoxPlot = [NeuBoxPlot;[PlotAvgDatas(:,1),...
        ones(size(PlotAvgDatas,1),1)*cData]];
    
    AstBoxPlot = [AstBoxPlot;[PlotAvgDatas(:,2),...
        ones(size(PlotAvgDatas,1),1)*cData]];
    
end
legend(ax1,hplots,TypeStrs','box','off','location','Southeast');
xlabel(ax1,'Event/Min');
xlabel(ax2,'Event/Min');
ylabel(ax1,'Frac.');
ylabel(ax2,'Frac.');

hBoxf = figure('position',[100 500 750 360]);
ax1 = subplot(121);
boxplot(ax1,NeuBoxPlot(:,1),NeuBoxPlot(:,2),'labels',TypeStrs);
set(ax1,'box','off');
title('Neu')

ax2 = subplot(122);
boxplot(ax2,AstBoxPlot(:,1),AstBoxPlot(:,2),'labels',TypeStrs);
set(ax2,'box','off');
title('Ast')

%%
[Neupkw,~,NeuStats] = kruskalwallis(NeuBoxPlot(:,1),NeuBoxPlot(:,2),'off');
Neups = multcompare(NeuStats,'Display','off');
[Astpkw,~,AstStats] = kruskalwallis(AstBoxPlot(:,1),AstBoxPlot(:,2),'off');
Astps = multcompare(AstStats,'Display','off');

%%

CompareInds = [1,2;3,4;5,6;1,3;3,5;2,4;4,6;1,5;2,6];
ComNums = size(CompareInds,1);
NeuRanksumps = zeros(ComNums,3);
AstRanksumps = zeros(ComNums,3);
for cCom = 1 : ComNums
    cComInds = CompareInds(cCom,:);
    NeuRanksumps(cCom,1:2) = cComInds;
    NeuRanksumps(cCom,3) = ranksum(NeuBoxPlot(NeuBoxPlot(:,2) == cComInds(1),1),...
        NeuBoxPlot(NeuBoxPlot(:,2) == cComInds(2),1));
    
    AstRanksumps(cCom,1:2) = cComInds;
    AstRanksumps(cCom,3) = ranksum(AstBoxPlot(AstBoxPlot(:,2) == cComInds(1),1),...
        AstBoxPlot(AstBoxPlot(:,2) == cComInds(2),1));
end

% for cWTSess = 1 : p12WTSessNum
%     
%     % NeuData plot
%     plot(ax1,p12WTBinCenters,p12WTSessEFData{cWTSess,3},...
%         'Color',[.8 .8 .8],'linewidth',0.6);
%     
%     % AstData plot
%     plot(ax2,p12WTBinCenters,p12WTSessEFData{cWTSess,4},...
%         'Color',[.8 .8 .8],'linewidth',0.6);
%     
%     
% end
% 
% for cTgSess = 1 : p12TgSessNum
%       % NeuData plot
%     plot(ax1,p12TgBinCenters,p12TgSessEFData{cTgSess,3},...
%         'Color',[.8 .4 .4],'linewidth',0.6);
% 
%     plot(ax2,p12TgBinCenters,p12TgSessEFData{cTgSess,4},...
%         'Color',[.8 .4 .4],'linewidth',0.6);
% end

% % % % WT binned data averages 
% % % p12WTdataNeuMtx = cell2mat(p12WTSessEFData(:,3));
% % % p12WTdataNeuAvg = mean(p12WTdataNeuMtx);
% % % p12WTdataNeuSEM = std(p12WTdataNeuMtx) / sqrt(p12WTSessNum);
% % % 
% % % p12WTdataAstMtx = cell2mat(p12WTSessEFData(:,4));
% % % p12WTdataAstAvg = mean(p12WTdataAstMtx);
% % % p12WTdataAstSEM = std(p12WTdataAstMtx) / sqrt(p12WTSessNum);
% % % 
% % % % Tg binned data averages 
% % % p12TgdataNeuMtx = cell2mat(p12TgSessEFData(:,3));
% % % p12TgdataNeuAvg = mean(p12TgdataNeuMtx);
% % % p12TgdataNeuSEM = std(p12TgdataNeuMtx) / sqrt(p12TgSessNum);
% % % 
% % % p12TgdataAstMtx = cell2mat(p12TgSessEFData(:,4));
% % % p12TgdataAstAvg = mean(p12TgdataAstMtx);
% % % p12TgdataAstSEM = std(p12TgdataAstMtx) / sqrt(p12TgSessNum);
% % % 
% % % 
% % % errorbar(ax1,p12WTBinCenters,p12WTdataNeuAvg,p12WTdataNeuSEM,...
% % %     'Color','k','linewidth',1.8);
% % % errorbar(ax1,p12TgBinCenters,p12TgdataNeuAvg,p12TgdataNeuSEM,...
% % %     'Color','r','linewidth',1.8);
% % % title(ax1,'Neu');
% % % 
% % % errorbar(ax2,p12WTBinCenters,p12WTdataAstAvg,p12WTdataAstSEM,...
% % %     'Color','k','linewidth',1.8);
% % % errorbar(ax2,p12TgBinCenters,p12TgdataAstAvg,p12TgdataAstSEM,...
% % %     'Color','r','linewidth',1.8);
% % % title(ax2,'Ast');

%%
savename = sprintf('EventFreq fieldwise cumufrac shadow plot');
set(hf,'paperpositionmode','manual');
saveas(hf,savename);
saveas(hf,savename,'png');
print(hf,'-dpdf',savename,'-painters');

savename = sprintf('EventFreq fieldwise mean boxplot');
set(hBoxf,'paperpositionmode','manual');
saveas(hBoxf,savename);
saveas(hBoxf,savename,'png');
print(hBoxf,'-dpdf',savename,'-painters');

%%
p12WTNeuDisData = [p12WTdataNeuAvg(1),diff(p12WTdataNeuAvg)];
p12TgNeuDisData = [p12TgdataNeuAvg(1),diff(p12TgdataNeuAvg)];

[~,p12Neup,p12Neustats] = kstest2(p12WTdataNeuAvg,p12TgdataNeuAvg);

[~,p12Astp,p12Aststats] = kstest2(p12WTdataAstAvg,p12TgdataAstAvg);


%%
% 
% deltaCDF  =  abs(p12WTdataAstAvg - p12TgdataAstAvg);
% n      =  n1 * n2 /(n1 + n2);
% KSstatistic   =  max(deltaCDF);
% lambda =  max((sqrt(n) + 0.12 + 0.11/sqrt(n)) * KSstatistic , 0);
% j       =  (1:101)';
% pValue  =  2 * sum((-1).^(j-1).*exp(-2*lambda*lambda*j.^2));
% pValue  =  min(max(pValue, 0), 1)

