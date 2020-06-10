function CrossLoss = DFRL_call_fun(ActionChoice,Trial_type,md)
% call for the DFRL model calculation
MdParas = struct();
MdParas.Action_Choice = ActionChoice;
MdParas.Tr_Types = Trial_type;
MdParas.Pos_delta_value = md(1); %Pos_delta_value;
MdParas.Neg_delta_value = md(2); %Neg_delta_value;
MdParas.Chose_decay = md(3); %Chose_decay;
MdParas.UnChose_decay = md(4); %UnChose_decay;


[SoftChoiceProbs,TarChoiceProb,~] = DFRL_model_Cal(MdParas);

CrossLoss = sum(-log(TarChoiceProb(2:end)));

