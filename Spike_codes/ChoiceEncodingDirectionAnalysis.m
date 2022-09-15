
figure;
hold on
[type1_train_N, type1_train_Edge] = histcounts(TrainScores(C1DataInds),50);
type1_train_Centers = (type1_train_Edge(1:end-1)+type1_train_Edge(2:end))/2;
[type2_train_N, type2_train_Edge] = histcounts(TrainScores(C2DataInds),50);
type2_train_Centers = (type2_train_Edge(1:end-1)+type2_train_Edge(2:end))/2;

plot(type1_train_Centers, type1_train_N/sum(type1_train_N),'b','linewidth',1);
plot(type2_train_Centers, type2_train_N/sum(type2_train_N),'r','linewidth',1);
yscales = get(gca,'ylim');
line([ClassBoundScore,ClassBoundScore],yscales,'Color','c','linestyle','--','linewidth',1.4);
line(median(TrainScores(C1DataInds))*[1 1],yscales,'Color','c','linestyle','--','linewidth',1.4)

