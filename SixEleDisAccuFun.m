function cDisAccus = SixEleDisAccuFun(UsedMtx)

Dis1Vec = diag(UsedMtx,-1);
Dis1BetAccu = Dis1Vec(3);
Disw1inAccu = mean(Dis1Vec([1,2,4,5]));
Dis2Vec = diag(UsedMtx,-2);
Dis2BetAccu = mean(Dis2Vec([2,3]));
Dis2winAccu = mean(Dis2Vec([1,4]));
cDisAccus = [Dis1BetAccu,Disw1inAccu,Dis2BetAccu,Dis2winAccu];
