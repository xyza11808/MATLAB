function [SoftChoiceProbs,TargetSoftProb,Q_SWP_Context_Values] = ...
    RL_Confidence_model_Cal(ModelParas)
% reference: "Orbitofrontal Circuits Control Multiple Reinforcement-Learning
% Processes"

% following parameters is needed for calculation
% 
% ModelParas.Choice_Type = [0,1]; % left or right
% ModelParas.Action_Choice;
% ModelParas.Tr_Types;
% ModelParas.TrNum = 100;
% ModelParas.QValues = zeros(NumChoiceTypes,TrNum);
% ModelParas.Pos_delta_value = 3;
% ModelParas.Neg_delta_value = 0;
% ModelParas.Chose_decay = 0.6;
% ModelParas.UnChose_decay = 0.5;
% ModelParas.Step_Delta = 0.5; % used for boundary position shiftment
% ModelParas.Context_indices = 0.5; % -1 or 1, used for block type indication
% ModelParas.SwitchProb_Thres = 0.5;
% ModelParas.SwitchProb_decay = 0.5;
% ModelParas.SwitchProb_delta = 0.5;

% ModelParas.
if length(unique(ModelParas.Tr_Types)) == 2
    BinaryTrTypes = ModelParas.Tr_Types;
    UsedFrameScale = ones(numel(BinaryTrTypes),1);
elseif length(unique(ModelParas.Tr_Types)) > 2
    BinaryTrTypes = double(ModelParas.Tr_Types >= 0);
    % normalize stim data into [-1,1] scales
    if max(abs(ModelParas.Tr_Types)) > 1.02
        warning('The maxium stimulus info is larger than expectation.\n');
        UsedFrameScale = abs(2 * (ModelParas.Tr_Types - min(ModelParas.Tr_Types)) / ...
            (max(ModelParas.Tr_Types) - min(ModelParas.Tr_Types)) - 1);
    else
        UsedFrameScale = abs(ModelParas.Tr_Types);
    end
else
    error('Not enough input trial types.');
end

if ~isfield(ModelParas,'Choice_Type')
    ModelParas.Choice_Type = unique(BinaryTrTypes);
end
ChoiceType = ModelParas.Choice_Type; % left or right
NumChoiceTypes = numel(ChoiceType);
TrNum = numel(ModelParas.Action_Choice);

if ~isfield(ModelParas,'Q_Values')
    QValues = zeros(NumChoiceTypes,TrNum);
else
    QValues = ModelParas.Q_Values;
end

if ~isfield(ModelParas,'Switch_prob')
    Switch_Probs = zeros(1,TrNum);
else
    Switch_Probs = ModelParas.Switch_prob;
end

SoftChoiceProbs = zeros(size(QValues));
TargetSoftProb = zeros(1,TrNum);

Pos_delta_value = ModelParas.Pos_delta_value;
Neg_delta_value = ModelParas.Neg_delta_value;
Chose_decay = ModelParas.Chose_decay;
UnChose_decay = ModelParas.UnChose_decay;
[SoftMaxFun,~] = ActFunCheck('SoftMax');

% calculation
Assumed_TrType = BinaryTrTypes(:);
Action_Type = ModelParas.Action_Choice(:);
if numel(Action_Type) ~= numel(Assumed_TrType)
    error('Error number of trial type and choice numbers');
end
TrOutcome = double(Action_Type == Assumed_TrType);
Tr_Used_Decay = [Neg_delta_value,Pos_delta_value];
SwitchProb_UsedOutcome = TrOutcome;
SwitchProb_UsedOutcome(TrOutcome == 0) = -1;

if numel(ModelParas.Context_indices) ~= TrNum
    % if only the initial value was given
    InitialContextOnly = 1;
    Tr_Context = zeros(1,TrNum);
    Tr_Context(1) = ModelParas.Context_indices;
else
    Tr_Context = ModelParas.Context_indices; % low bound is -1 and high-bound is 1
    InitialContextOnly = 0;
end

for cTr = 2 : TrNum
    cActIndex = double(ChoiceType == Action_Type(cTr)); 
    cTrOutcome = TrOutcome(cTr);
    if InitialContextOnly
        HyperStims = UsedFrameScale(cTr) - ModelParas.Step_Delta * ModelParas.Context_indices;
    else
        HyperStims = UsedFrameScale(cTr) - ModelParas.Step_Delta * Tr_Context(cTr);
    end
    HyperStims = min(1,abs(HyperStims)) * sign(HyperStims);
    
    for cN_choice = 1 : NumChoiceTypes
        if cActIndex(cN_choice) % update same action side Q values
            QValues(cN_choice,cTr) = Chose_decay * QValues(cN_choice,cTr-1) + ...
                Tr_Used_Decay(cTrOutcome + 1)*HyperStims;
        else % update different action side Q values
            QValues(cN_choice,cTr) = UnChose_decay * QValues(cN_choice,cTr-1);
        end
    end
    
    if InitialContextOnly
       Switch_Probs(cTr) = exp(Switch_Probs(cTr - 1)*ModelParas.SwitchProb_decay + ...
            SwitchProb_UsedOutcome(cTr) * HyperStims * ModelParas.SwitchProb_delta); 
        if Switch_Probs(cTr) > ModelParas.SwitchProb_Thres
            Switch_Probs(cTr) = 0;
            ModelParas.Context_indices = ModelParas.Context_indices * -1;
        end
        Tr_Context(cTr) = ModelParas.Context_indices;
    end
    
    SoftChoiceProbs(:,cTr) = SoftMaxFun(QValues(:,cTr));
    TargetSoftProb(cTr) = SoftChoiceProbs(logical(cActIndex),cTr);
end

Q_SWP_Context_Values = {QValues, Switch_Probs, Tr_Context};

