
[cellFrac,cellAUC] = ecdf(ROCSortABS);
CellFracPerf = mean(CellFracClassPerfAll,2);
CellFracs = 0.1:0.05:1;
ROCpercent = prctile(ROCSortABS,CellFracs*100);
%%
for nnf = 0.2:0.2:1
    hf = figure;
    hold on
    scatter(cellFrac,cellAUC,40,'ro','LineWidth',1.4);
    plot(CellFracs,1-CellFracPerf,'k-o','linewidth',1.5);
    xlabel('Cell Fraction');
    ylabel({'AUC';'Population decoding accuracy'});
    set(gca,'xtick',0:0.2:1,'ytick',0.4:0.1:1);

    line([nnf nnf],[0.4,1],'color',[.7 .7 .7],'linestyle','--','linewidth',1.6);
    saveas(hf,sprintf('Figure%d example plot save',round(nnf/0.2)));
    saveas(hf,sprintf('Figure%d example plot save',round(nnf/0.2)),'png');
    saveas(hf,sprintf('Figure%d example plot save',round(nnf/0.2)),'pdf');
    close(hf);
end