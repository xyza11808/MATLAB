function CrossLoss = RL_MdAll_call_fun(ActionChoice,Trial_type,MDType, md)
% call for the model calculation according to input type
% supported model types are: 
%     "DFRL"  % Differential forgetting RL model
%     "FRL" % Forgetting RL model
%     "QL" % Q-learning model
%     "FQL" % Forgetting Q-plearning model
%     "DFQL" % Differential forgetting Q-learning model
% 
% Ref.: Groman et al., 2019, Neuron 103, 734¨C746 
% Orbitofrontal Circuits Control Multiple Reinforcement-Learning Processes
if ~ischar(MDType)
    return;
end
MdParas = struct();
MdParas.Action_Choice = ActionChoice;
MdParas.Trial_Types = Trial_type;

switch MDType
    case "DFRL"
        MdParas.Pos_delta_value = md(1); %Pos_delta_value;
        MdParas.Neg_delta_value = md(2); %Neg_delta_value;
        MdParas.Chose_decay = md(3); %Chose_decay;
        MdParas.UnChose_decay = md(4); %UnChose_decay;
        
    case "FRL"
        MdParas.Common_decay = md(1);
        MdParas.Pos_delta_value = md(2);
        MdParas.Neg_delta_value = md(3);
    case "QL" 
        MdParas.LearningRate = md(1);
    case "FQL"
        MdParas.LearningRate = md(1);
        MdParas.Common_decay = md(2);
    case "DFQL"
        MdParas.LearningRate = md(1);
        MdParas.Chose_decay = md(2);
        MdParas.UnChose_decay = md(3);
    otherwise 
        error('Unkown model calculation type.');
end
        
[SoftChoiceProbs,TarChoiceProb,~] = RL_model_CalAll(MDType, MdParas);
CrossLoss = sum(-log(TarChoiceProb(2:end)));

% ActionChoiceMtx = ([1 - ActionChoice(2:end), ActionChoice(2:end)])';
% % Calculate AIC from the second estimation
% SoftMaxOutputs = SoftChoiceProbs(:,2:end);
% PosInds = ActionChoiceMtx == 1;
% NegInds = ActionChoiceMtx == 0;
% 
% Likelihood_sum = (sum(log(SoftMaxOutputs(PosInds))) + sum(log(1 - SoftMaxOutputs(NegInds))));
% AIC = 2*length(md) - 2*Likelihood_sum;
% CrossLoss = AIC;