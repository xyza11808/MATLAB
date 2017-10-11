load('FactorAnaDataSave.mat')
load('LRIndexsumSave.mat')
%%
if ~isdir('./New_Sum_Plot_corrONLY/')
    mkdir('./New_Sum_Plot_corrONLY/');
end
cd('./New_Sum_Plot_corrONLY/');
%% cSess = 1;
for cSess = 1 : length(TaskTime)
    cActionChoice = ActionChoice{cSess};
    cLRIndex = LRIndexSum{cSess};
    cAlignF = TaskAlignF(cSess);
    cTaskFactorData = TaskFactorData{cSess};
    cTaskFrate = TaskFrate(cSess);
    cTaskOutcome = TaskOutcomes{cSess};
    cTaskTime = TaskTime{cSess};
    cTaskTones = TaskTones{cSess};

    % ColorMap = [r g b]
    %
    NMtrInds = cTaskOutcome ~= 2;
    NMLRIndex = cTaskTime.cLRIndexSumNor(NMtrInds,:);
    NMTones = cTaskTones(NMtrInds);
    NMOutcomes = cTaskOutcome(NMtrInds);
    FreqTypes = unique(NMTones);
    nFreqs = length(FreqTypes);
    cstimes = cTaskTime.xTimes;
    Opt.t_eventOn = cAlignF/cTaskFrate;
    Opt.eventDur = 0.3;
    eventOff = Opt.t_eventOn + Opt.eventDur;
    CMap = [(linspace(0,1,nFreqs))',zeros(nFreqs,1)+0.1,(linspace(1,0,nFreqs))'];
    %
    Opt.isPatchPlot = 0;
    lineMemoStrs = cellstr(num2str(FreqTypes/1000,'%.1fKHz'));
    lineobj = [];
    hhf = figure('position',[500 300 1050 750]);
    hold on
    for nf = 1 : nFreqs
        cFreqs = FreqTypes(nf);
        cFreqData = NMLRIndex(NMTones==cFreqs,:);  % correct trials,  & NMOutcomes == 1
        H = plot_meanCaTrace(mean(cFreqData),std(cFreqData)/sqrt(size(cFreqData,1)),cstimes,hhf,Opt);
        set(H.meanPlot,'color',CMap(nf,:));
        set(H.ep,'facecolor',CMap(nf,:),'facealpha',0.4);
    %     if nf == 1
    %         Opt.isPatchPlot = 0;
    %         set(H.eventPatch,'facecolor',[.8 .8 .8]);
    %     end
        lineobj = [lineobj,H.meanPlot];

%         cFreqDataE = NMLRIndex(NMTones==cFreqs & NMOutcomes == 0,:);  % error trials
%         if ~isempty(cFreqDataE)
%             if size(cFreqDataE,1) < 3
%                 plot(cstimes,mean(cFreqDataE),'linewidth',1.5,'Color',CMap(nf,:),'linestyle','--');
%             else
%                 HE = plot_meanCaTrace(mean(cFreqDataE),std(cFreqDataE)/sqrt(size(cFreqDataE,1)),cstimes,hhf,Opt);
%                 set(HE.meanPlot,'color',CMap(nf,:),'linestyle','--'); 
%                 set(HE.ep,'facecolor',CMap(nf,:),'facealpha',0.2);
%             end
%         end
    end
    %
    yscales = get(gca,'ylim');
    patch([Opt.t_eventOn Opt.t_eventOn eventOff eventOff],[yscales(1) yscales(2) yscales(2) yscales(1)],1,...
        'Edgecolor','none','facecolor',[.8 .8 .8] ,'facealpha',0.6);
    legend(lineobj,lineMemoStrs,'FontSize',12)
    legend('boxoff')
    title(sprintf('Sess #%d',cSess))
    xlabel('Time (s)');
    ylabel('Nor. selction index');
    set(gca,'FontSize',16);
    %
    saveas(hhf,sprintf('Sess%d Normalized Sindex sumPlot',cSess));
    saveas(hhf,sprintf('Sess%d Normalized Sindex sumPlot',cSess),'png');
    close(hhf);
end
cd ..;