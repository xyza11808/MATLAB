function [SoftChoiceProbs,TargetSoftProb,HiddenValues] = ...
    RL_model_CalAll(ModelType, ModelParas)
% reference: "Orbitofrontal Circuits Control Multiple Reinforcement-Learning
% Processes"

% following parameters is needed for calculation
% Different model will use different parameter for calculation

% ModelParas.Choice_Type = [0,1]; % left or right
% ModelParas.Action_Choice;
% ModelParas.Trial_Types;
% ModelParas.TrNum = 100;
% ModelParas.QValues = zeros(NumChoiceTypes,TrNum);
% ModelParas.Pos_delta_value = 3;
% ModelParas.Neg_delta_value = 0;
% ModelParas.Chose_decay = 0.6;
% ModelParas.UnChose_decay = 0.5;

if ~ischar(ModelType)
    error('The input "ModelType" must be a string');
end

switch ModelType
    case "DFRL"  % Differential forgetting RL model
        FieldName = {'Trial_Types', 'Action_Choice', 'Pos_delta_value',...
            'Neg_delta_value', 'Neg_delta_value', 'Chose_decay', 'UnChose_decay'};
        ContainFs = isfield(ModelParas, FieldName);
        if mean(ContainFs) ~= 1
            error('The input DFRL model parameter is not sufficient for calculation.');
        end
    case "FRL" % Forgetting RL model
        FieldName = {'Trial_Types', 'Action_Choice', 'Pos_delta_value',...
            'Neg_delta_value', 'Common_decay'};
        ContainFs = isfield(ModelParas, FieldName);
        if mean(ContainFs) ~= 1
            error('The input FRL model parameter is not sufficient for calculation.');
        end
    case "QL"
        FieldName = {'Trial_Types', 'Action_Choice', 'LearningRate'};
        ContainFs = isfield(ModelParas, FieldName);
        if mean(ContainFs) ~= 1
            error('The input QL model parameter is not sufficient for calculation.');
        end
    case "FQL" % Forgetting Q-plearning model
        FieldName = {'Trial_Types', 'Action_Choice', 'LearningRate',...
            'Common_decay'};
        ContainFs = isfield(ModelParas, FieldName);
        if mean(ContainFs) ~= 1
            error('The input FQL model parameter is not sufficient for calculation.');
        end
    case "DFQL" % Differential forgetting Q-learning model
        FieldName = {'Trial_Types', 'Action_Choice', 'LearningRate', ...
             'Chose_decay', 'UnChose_decay'};
        ContainFs = isfield(ModelParas, FieldName);
        if mean(ContainFs) ~= 1
            error('The input DFQL model parameter is not sufficient for calculation.');
        end
        
    case 'PH' % pearce-Hall reinforcement learning models.
        
        
        
    otherwise
        error('Unsupported learning model for now');
end

% check the consistance of trial length
if length(unique(ModelParas.Trial_Types)) == 2
    BinaryTrTypes = ModelParas.Trial_Types;
    UsedFrameScale = ones(numel(BinaryTrTypes),1);
elseif length(unique(ModelParas.Trial_Types)) > 2
    BinaryTrTypes = double(ModelParas.Trial_Types >= 0);
    % normalize stim data into [-1,1] scales
    if max(abs(ModelParas.Trial_Types)) > 1.02
        warning('The maxium stimulus info is larger than expectation.\n');
        UsedFrameScale = abs(2 * (ModelParas.Trial_Types - min(ModelParas.Trial_Types)) / ...
            (max(ModelParas.Trial_Types) - min(ModelParas.Trial_Types)) - 1);
    else
        UsedFrameScale = abs(ModelParas.Trial_Types);
    end
else
    error('Not enough input trial types.');
end

ModelParas.Choice_Type = unique(BinaryTrTypes); % unique trial types

ChoiceType = ModelParas.Choice_Type; % left or right
NumChoiceTypes = numel(ChoiceType);
TrNum = numel(ModelParas.Action_Choice);

if ~isfield(ModelParas,'Q_Values')
    QValues = zeros(NumChoiceTypes,TrNum);
else
    QValues = ModelParas.Q_Values;
end
SoftChoiceProbs = zeros(size(QValues));
TargetSoftProb = zeros(1,TrNum);
% calculation
Assumed_TrType = BinaryTrTypes(:);
Action_Type = ModelParas.Action_Choice(:);
if numel(Action_Type) ~= numel(Assumed_TrType)
    error('Error number of trial type and choice numbers');
end
TrOutcome = double(Action_Type == Assumed_TrType);
if strfind(ModelType, 'QL') %#ok<STRIFCND>
    TrOutcome(TrOutcome == 0) = -1;
end
[SoftMaxFun,~] = ActFunCheck('SoftMax');

% perform calculation according to the given model
switch ModelType
    case "DFRL"  % Differential forgetting RL model
        Pos_delta_value = ModelParas.Pos_delta_value;
        Neg_delta_value = ModelParas.Neg_delta_value;
        Chose_decay = ModelParas.Chose_decay;
        UnChose_decay = ModelParas.UnChose_decay;

        Tr_Used_Decay = [Neg_delta_value,Pos_delta_value];

        for cTr = 2 : TrNum
            cActIndex = double(ChoiceType == Action_Type(cTr)); 
            cTrOutcome = TrOutcome(cTr);
            for cN_choice = 1 : NumChoiceTypes
                if cActIndex(cN_choice) % update same action side Q values
                    QValues(cN_choice,cTr) = Chose_decay * QValues(cN_choice,cTr-1) + ...
                        Tr_Used_Decay(cTrOutcome + 1)*UsedFrameScale(cN_choice);
                else % update different action side Q values
                    QValues(cN_choice,cTr) = UnChose_decay * QValues(cN_choice,cTr-1);
                end
            end
            SoftChoiceProbs(:,cTr) = SoftMaxFun(QValues(:,cTr));
            TargetSoftProb(cTr) = SoftChoiceProbs(logical(cActIndex),cTr);
        end
    case "FRL" % Forgetting RL model
        CommonDecay = ModelParas.Common_decay;
        Pos_delta_value = ModelParas.Pos_delta_value;
        Neg_delta_value = ModelParas.Neg_delta_value; % update the delta value according to the outcome
        
        Tr_Used_Decay = [Neg_delta_value,Pos_delta_value];
        for cTr = 2 : TrNum
            cActIndex = double(ChoiceType == Action_Type(cTr)); 
            cTrOutcome = TrOutcome(cTr);
            for cN_choice = 1 : NumChoiceTypes
                if cActIndex(cN_choice) % update same action side Q values
                    QValues(cN_choice,cTr) = CommonDecay * QValues(cN_choice,cTr-1) + ...
                        Tr_Used_Decay(cTrOutcome + 1)*UsedFrameScale(cN_choice);
                else % update different action side Q values
                    QValues(cN_choice,cTr) = CommonDecay * QValues(cN_choice,cTr-1);
                end
            end
            SoftChoiceProbs(:,cTr) = SoftMaxFun(QValues(:,cTr));
            TargetSoftProb(cTr) = SoftChoiceProbs(logical(cActIndex),cTr);
        end
        
    case "QL"
        LearnRate = ModelParas.LearningRate;
        for cTr = 2 : TrNum
            cActIndex = double(ChoiceType == Action_Type(cTr)); 
            cTrOutcome = TrOutcome(cTr);
            for cN_choice = 1 : NumChoiceTypes
                if cActIndex(cN_choice) % update same action side Q values
                    QValues(cN_choice,cTr) = QValues(cN_choice,cTr-1) * (1 - LearnRate)+ ...
                        LearnRate * (cTrOutcome - QValues(cN_choice,cTr-1));
                else % update different action side Q values
                    QValues(cN_choice,cTr) = QValues(cN_choice,cTr-1);
                end
            end
            SoftChoiceProbs(:,cTr) = SoftMaxFun(QValues(:,cTr));
            TargetSoftProb(cTr) = SoftChoiceProbs(logical(cActIndex),cTr);
        end
        
    case "FQL"
        LearnRate = ModelParas.LearningRate;
        CommonDecay = ModelParas.Common_decay;
        
        for cTr = 2 : TrNum
            cActIndex = double(ChoiceType == Action_Type(cTr)); 
            cTrOutcome = TrOutcome(cTr);
            for cN_choice = 1 : NumChoiceTypes
                if cActIndex(cN_choice) % update same action side Q values
                    QValues(cN_choice,cTr) = CommonDecay * QValues(cN_choice,cTr-1) + ...
                        LearnRate * (cTrOutcome - QValues(cN_choice,cTr-1));
                else % update different action side Q values
                    QValues(cN_choice,cTr) = CommonDecay * QValues(cN_choice,cTr-1);
                end
            end
            SoftChoiceProbs(:,cTr) = SoftMaxFun(QValues(:,cTr));
            TargetSoftProb(cTr) = SoftChoiceProbs(logical(cActIndex),cTr);
        end
        
    case "DFQL"
        LearnRate = ModelParas.LearningRate;
        Chose_decay = ModelParas.Chose_decay;
        UnChose_decay = ModelParas.UnChose_decay;
        
        for cTr = 2 : TrNum
            cActIndex = double(ChoiceType == Action_Type(cTr)); 
            cTrOutcome = TrOutcome(cTr);
            for cN_choice = 1 : NumChoiceTypes
                if cActIndex(cN_choice) % update same action side Q values
                    QValues(cN_choice,cTr) = Chose_decay * QValues(cN_choice,cTr-1) + ...
                        LearnRate * (cTrOutcome - QValues(cN_choice,cTr-1));
                else % update different action side Q values
                    QValues(cN_choice,cTr) = UnChose_decay * QValues(cN_choice,cTr-1);
                end
            end
            SoftChoiceProbs(:,cTr) = SoftMaxFun(QValues(:,cTr));
            TargetSoftProb(cTr) = SoftChoiceProbs(logical(cActIndex),cTr);
        end
    otherwise
        fprintf('Unsupproted model type, please check your input string.\n');
end

HiddenValues = QValues;
        