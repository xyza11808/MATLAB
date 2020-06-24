function [QValues, BSvalues] = BoundQmodel(ActionChoice, rewards, TrTypes, Mdparas)
% used for boundary-switch q learning, with reward value related with
% realative-octave value
% the relative-octave value was calculated according to the real octave
% and estimated boundary values

NumTrials = numel(ActionChoice);
ChoiceTypes = unique(ActionChoice);
TrTypesAll = unique(TrTypes);

QValues = zeros(NumTrials, 2);
BSvalues = zeros(NumTrials, 1); % boundary switch values

QValues(1,:) = [0, 0];
BSvalues(1) = 0.5;

for cTrs = 2 : NumTrials
    cTr_Action = ActionChoice(cTrs);
    ActChoiceInds = cTr_Action == ChoiceTypes;
    if abs(TrTypes(cTrs)) > Mdparas.BS_evid_Thres % do not update the outlier frequencyes to the reward value
        QValues(cTrs,:) = QValues(cTrs-1,:);
        continue;
    end
    
    % non-choosed action
    QValues(cTrs, ~ActChoiceInds) = QValues(cTrs-1, ~ActChoiceInds);
    
    % choosed action
    EstimateBound_toOct = TrTypes(cTrs) - Mdparas.OctShiftStep * sign(BSvalues(cTrs-1) - Mdparas.BS_thres);
    BSvalues(cTrs) = BSvalues(cTrs - 1) - Mdparas.BS_LearRate * EstimateBound_toOct * rewards(cTrs);
    
    QValues(cTrs, ActChoiceInds) = QValues(cTrs-1,ActChoiceInds) + Mdparas.Q_learRate * (...
        rewards(cTrs) * EstimateBound_toOct - QValues(cTrs-1,ActChoiceInds));
    
end

