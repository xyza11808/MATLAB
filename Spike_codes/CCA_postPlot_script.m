% close
clearvars PairCCADatasAllCell TypeAreaPairInfo TypeRespCalAvgs OutDataStrc AllTimeWin 

load(fullfile(ksfolder,'jeccAnA','CCA_TypeSubCal.mat'),'TypeAreaPairInfo',...
    'TypeRespCalAvgs','AllTimeWin','OutDataStrc');

figSaveFolder = fullfile(ksfolder,'jeccAnA','ComponentCorrplot');
if ~isfolder(figSaveFolder)
    mkdir(figSaveFolder);
end


NumPairs = size(TypeRespCalAvgs,1);
PairCCADatasAllCell = cell(NumPairs,2);

for cPair = 1:NumPairs
    cPairInfos = TypeAreaPairInfo(cPair,:);
    cPairThresCell = cellfun(@(x) x{5},TypeRespCalAvgs(cPair,:),'un',0);
    cPairAllThres = cat(2,cPairThresCell{:});
    cPairUsedThres = max(cPairAllThres,[],2);

    hf = figure('position',[100 300 860 240]);

    ax1 = subplot(131); %  CCA component correlation plots
    hold on
    % baseline corr
    [~,~,hl1] = MeanSemPlot(TypeRespCalAvgs{cPair,1}(2),[],ax1,10,[.7 .7 .7],...
        'Color','k','linewidth',1.5);% with block variation subtraction
    [~,~,hl2] = MeanSemPlot(TypeRespCalAvgs{cPair,3}(2),[],ax1,10,[.8 .4 .4],...
        'Color','r','linewidth',1.5);% without block variation subtraction
    % After response corr
    [~,~,hl11] = MeanSemPlot(TypeRespCalAvgs{cPair,2}(2),[],ax1,10,[.7 .7 .7],...
        'Color','k','linewidth',1.5,'linestyle','--');% with block variation subtraction
    [~,~,hl22] = MeanSemPlot(TypeRespCalAvgs{cPair,4}(2),[],ax1,10,[.8 .4 .4],...
        'Color','r','linewidth',1.5,'linestyle','--');% without block variation subtraction
    plot(cPairUsedThres,'Color',[.7 .7 .7],'linewidth',1.5);
    xlabel(ax1,'CCA component');
    ylabel(ax1,'Coefficient');
    OldAxPos = get(ax1,'position');
    set(ax1,'position',OldAxPos.*[1 1 0.9 0.8]+[-0.07 0.07 0 0]);
    title(sprintf('%s(%d)-%s(%d)',cPairInfos{1},cPairInfos{3}(1),cPairInfos{2},cPairInfos{3}(2)));
    set(ax1,'FontSize',8);
    hlg = legend([hl1,hl2,hl11,hl22],{'BaseBVar','BaseTrVar','AfBVar','AfTrVar'},'position',[0.20 0.65 0.04 0.06],...%'northeast',...
        'box','off','AutoUpdate','off','FontSize',6);
    CCA_ComponetDatas = {cat(3,TypeRespCalAvgs{cPair,1}{1:2}),cat(3,TypeRespCalAvgs{cPair,2}{1:2}),...
        cat(3,TypeRespCalAvgs{cPair,3}{1:2}),cat(3,TypeRespCalAvgs{cPair,4}{1:2}),cPairUsedThres,...
        {'BaseBVar','AfBVar','BaseTrVar','AfTrVar'}};

    %
    OnsetBin = AllTimeWin{4};
    BinCentTimeAll = OutDataStrc.BinCenters;
    BaseValidWin = (OnsetBin+AllTimeWin{1}(1)):(OnsetBin+AllTimeWin{1}(2)+AllTimeWin{3}-1);
    BaseValidWinTime = BinCentTimeAll(BaseValidWin);
    AfterValidWin = (OnsetBin+AllTimeWin{2}(1)-AllTimeWin{3}):(OnsetBin+AllTimeWin{2}(2)-1);
    AfterValidWinTime = BinCentTimeAll(AfterValidWin);

    BaseValidData_BVar = TypeRespCalAvgs{cPair,1}{3}; %NumComponent by Numtimes
    BaseValidDataSTD_BVar = TypeRespCalAvgs{cPair,1}{4}; %NumComponent by Numtimes
    AfterValidData_BVar = TypeRespCalAvgs{cPair,2}{3};
    AfterValidDataSTD_BVar = TypeRespCalAvgs{cPair,2}{4};
    BaseValidData_TrVar = TypeRespCalAvgs{cPair,3}{3};
    BaseValidDataSTD_TrVar = TypeRespCalAvgs{cPair,3}{4};
    AfterValidData_TrVar = TypeRespCalAvgs{cPair,4}{3};
    AfterValidDataSTD_TrVar = TypeRespCalAvgs{cPair,4}{4};

    AllValidDatas = {cat(3,BaseValidData_BVar,BaseValidDataSTD_BVar),...
        cat(3,AfterValidData_BVar,AfterValidDataSTD_BVar),...
        cat(3,BaseValidData_TrVar,BaseValidDataSTD_TrVar),...
        cat(3,AfterValidData_TrVar,AfterValidDataSTD_TrVar),...
        {'BaseValidBVar','AfValidBVar','BaseValidTrVar','AfValidTrVar'}};

    ax2 = subplot(132); %  CCA component correlation plots
    hold on

    [~,~,hl3] = MeanSemPlot({BaseValidData_BVar(1,:),BaseValidDataSTD_BVar(1,:)},BaseValidWinTime,ax2,[],[.7 .7 .7],...
        'Color','k','linewidth',1.5);% with block variation subtraction
    [~,~,hl32] = MeanSemPlot({BaseValidData_TrVar(1,:),BaseValidDataSTD_TrVar(1,:)},BaseValidWinTime,ax2,[],[.7 .7 .7],...
        'Color',[0.1 0.1 0.3],'linewidth',1.5,'linestyle','--');% without block variation subtraction
    [~,~,hl3_2] = MeanSemPlot({BaseValidData_BVar(2,:),BaseValidDataSTD_BVar(2,:)},BaseValidWinTime,ax2,[],[.7 .7 .7],...
        'Color','b','linewidth',1.5);% with block variation subtraction
    [~,~,hl32_2] = MeanSemPlot({BaseValidData_TrVar(2,:),BaseValidDataSTD_TrVar(2,:)},BaseValidWinTime,ax2,[],[.7 .7 .7],...
        'Color',[0.3 0.3 0.8],'linewidth',1.5,'linestyle','--');% without block variation subtraction
    yscales = get(ax2,'ylim');
    line(ax2,[0 0],yscales,'Color','c','linewidth',1.2,'linestyle','--');
    xlabel(ax2,'Time (s)');
    ylabel(ax2,'Coefficient');
    OldAxPos = get(ax2,'position');
    NewPos2 = OldAxPos.*[1 1 0.8 0.8]+[-0.05 0.07 0 0];
    set(ax2,'position',NewPos2);
    title(ax2,'Baseline mode');
    set(ax2,'FontSize',8);
    hlg2 = legend([hl3,hl32,hl3_2,hl32_2],{'BaseBVarM1','BaseTrVarM1','BaseBVarM2','BaseTrVarM2'},...
        'position',[NewPos2(1)+NewPos2(3)+0.04 0.75 0.04 0.06],...%'northeast',...
        'box','off','AutoUpdate','off','FontSize',6);


    ax3 = subplot(133); %  CCA component correlation plots
    hold on

    [~,~,hl4] = MeanSemPlot({AfterValidData_BVar(1,:),AfterValidDataSTD_BVar(1,:)},AfterValidWinTime,ax3,[],[.8 .4 .4],...
        'Color','r','linewidth',1.5);% without
    [~,~,hl42] = MeanSemPlot({AfterValidData_TrVar(1,:),AfterValidDataSTD_TrVar(1,:)},AfterValidWinTime,ax3,[],[.8 .4 .4],...
        'Color',[0.5 0.1 0.1],'linewidth',1.5,'linestyle','--');% without
    [~,~,hl4_2] = MeanSemPlot({AfterValidData_BVar(2,:),AfterValidDataSTD_BVar(2,:)},AfterValidWinTime,ax3,[],[.8 .4 .4],...
        'Color','m','linewidth',1.5);% without
    [~,~,hl42_2] = MeanSemPlot({AfterValidData_TrVar(2,:),AfterValidDataSTD_TrVar(2,:)},AfterValidWinTime,ax3,[],[.8 .4 .4],...
        'Color',[0.8 0.6 0.2],'linewidth',1.5,'linestyle','--');% without
    yscales = get(ax3,'ylim');
    line(ax3,[0 0],yscales,'Color','c','linewidth',1.2,'linestyle','--');
    title(ax3,'AfterResp Mode');
    xlabel(ax3,'Time (s)');
    ylabel(ax3,'Coefficient');
    OldAxPos = get(ax3,'position');
    NewPos3 = OldAxPos.*[1 1 0.8 0.8]+[0 0.07 0 0];
    set(ax3,'position',NewPos3);
    set(ax3,'FontSize',8);
    hlg3 = legend([hl4,hl42,hl4_2,hl42_2],{'AfBVarM1','AfTrVarM1','AfBVarM2','AfTrVarM2'},...
        'position',[NewPos3(1)+NewPos3(3)+0.04 0.75 0.04 0.06],...%'northeast',...
        'box','off','AutoUpdate','off','FontSize',6);
    
    
    PairCCADatasAllCell(cPair,:) = {CCA_ComponetDatas, AllValidDatas};
    
    figSavefile = fullfile(figSaveFolder,sprintf('Area %s-%s component correlation plot',cPairInfos{1},cPairInfos{2}));
    saveas(hf, figSavefile);
    print(hf, figSavefile,'-dpng','-r350');
    print(hf, figSavefile,'-dpdf','-bestfit');
    close(hf);
    
end

dataSaveFile = fullfile(figSaveFolder,'PairCCADatas.mat');
save(dataSaveFile,'TypeAreaPairInfo','PairCCADatasAllCell','AllTimeWin','-v7.3');

