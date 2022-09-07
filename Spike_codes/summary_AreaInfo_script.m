
Choice_disScore = AreainfosAll(:,1,1);
BT_disScore = AreainfosAll(:,2,1);
Choice_DisAccuracy = AreainfosAll(:,1,2);
BT_DisAccuracy = AreainfosAll(:,2,2);

AreaNums = length(NewAdd_ExistAreaNames);
AreaTrainScore_Accu = zeros(AreaNums,4);
AreaTestScore_Accu = zeros(AreaNums,4);
for cA = 1 : AreaNums
    cA_Choice_Score_train = mean(Choice_disScore{cA}(:,1));
    cA_Choice_Score_test = mean(Choice_disScore{cA}(:,2));
    cA_Choice_accu_train =  mean(Choice_DisAccuracy{cA}(:,1));
    cA_Choice_accu_test =  mean(Choice_DisAccuracy{cA}(:,2));
    
    cA_BT_Score_train = mean(BT_disScore{cA}(:,1));
    cA_BT_Score_test = mean(BT_disScore{cA}(:,2));
    cA_BT_Accu_train = mean(BT_DisAccuracy{cA}(:,1));
    cA_BT_Accu_test = mean(BT_DisAccuracy{cA}(:,2));
    
    AreaTrainScore_Accu(cA,:) = [cA_Choice_Score_train,cA_Choice_accu_train,...
        cA_BT_Score_train,cA_BT_Accu_train];
    AreaTestScore_Accu(cA,:) = [cA_Choice_Score_test,cA_Choice_accu_test,...
        cA_BT_Score_test,cA_BT_Accu_test];
end

AreaTrainScore_Accu = [AreaTrainScore_Accu,AreaUnitNumbers];
AreaTestScore_Accu = [AreaTestScore_Accu,AreaUnitNumbers];


