function CrossLoss = RLConfid_call_fun(ActionChoice,Trial_type,InitialContext,md)
% call for the DFRL model calculation
MdParas = struct();
MdParas.Action_Choice = ActionChoice;
MdParas.Tr_Types = Trial_type;
MdParas.Pos_delta_value = md(1); %Pos_delta_value;
MdParas.Neg_delta_value = md(2); %Neg_delta_value;
MdParas.Chose_decay = md(3); %Chose_decay;
MdParas.UnChose_decay = md(4); %UnChose_decay;
MdParas.SwitchProb_decay = md(5); %switch prob decay;
MdParas.SwitchProb_delta = md(6); %switch prob delta;
MdParas.SwitchProb_Thres = md(7); %switch prob threshold;
MdParas.Step_Delta = md(8);
MdParas.Context_indices = InitialContext; % initial block context indication

[SoftChoiceProbs,TarChoiceProb,~] = RL_Confidence_model_Cal(MdParas);

CrossLoss = sum(-log(TarChoiceProb(2:end)));