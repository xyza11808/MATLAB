
%%
 [h,p]=ttest(ResultStrc.AUCPrefer,ResultStrc.ModuAUCPrefer)
 
 MeanDiff=mean(ResultStrc.ModuAUCPrefer)-mean(ResultStrc.AUCPrefer)
 
 %%
 %SingleFreq Test
 ControlAUCMatrix = ResultStrc.AUCvalueAll;
 ModuAUCMatrix = ResultStrc.ModuAUCvalueAll;
 
 MeanComp=mean(ControlAUCMatrix) < mean(ModuAUCMatrix);
 
 h_all=zeros(1,size(ControlAUCMatrix,2));
 p_all=zeros(1,size(ControlAUCMatrix,2));
 
 
 for nn=1:size(ControlAUCMatrix,2)
     [h_c,p_c]=ttest(ControlAUCMatrix(:,nn),ModuAUCMatrix(:,nn));
     h_all(nn)=h_c;
     p_all(nn)=p_c;
 end
 
 %%
 
 ROINum=size(ControlAUCMatrix,1);
 
 hf=figure('position',[100,100,1000,900],'PaperPositionMode','auto');
 hold on;
 
 for mm=1:size(ControlAUCMatrix,2)
     plot((mm*2-0.5)*ones(ROINum,1),ControlAUCMatrix(:,mm),'o','color','k','LineWidth',1.2);
     plot((mm*2+0.5)*ones(ROINum,1),ModuAUCMatrix(:,mm),'*','color','r','LineWidth',1.2);
     errorbar((mm*2-0.7),mean(ControlAUCMatrix(:,mm)),std(ControlAUCMatrix(:,mm))/sqrt(ROINum),'d','color','k','LineWidth',1.5,'MarkerSize',10);
     errorbar((mm*2+0.7),mean(ModuAUCMatrix(:,mm)),std(ModuAUCMatrix(:,mm))/sqrt(ROINum),'d','color','r','LineWidth',1.5,'MarkerSize',10);
     if p_all(mm) < 0.05 && p_all(mm) >= 0.01
         text(mm*2,0.7,'*','FontSize',20,'color','b','LineWidth',1.2,'HorizontalAlignment','center');
     elseif p_all(mm) < 0.01 && p_all(mm) >= 0.001
         text(mm*2,0.7,'**','FontSize',20,'color','b','LineWidth',1.2,'HorizontalAlignment','center');
     elseif p_all(mm) < 0.001
         text(mm*2,0.7,'***','FontSize',20,'color','b','LineWidth',1.2,'HorizontalAlignment','center');
     end
 end
 ylim([0.4 1]);
 xTickl=(1:size(ControlAUCMatrix,2))*2;
 set(gca,'xtick',xTickl,'xticklabel',{'Freq1','Freq2','Freq3','Freq4','Freq5','Freq6'});
 xlabel('Frequency')
 ylabel('AUC value')
 
 %%
saveas(hf,'Popu AUC plot.png');
saveas(hf,'Popu AUC plot.fig');
     