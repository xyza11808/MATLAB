function FunLosses = ParaSearchFun(Choice, Outcome, octaves, inds_low, md)

MDParas.BS_thres = md(1);% 0.5; % the threshold to switch internal boundary estimation
MDParas.BS_evid_Thres = md(2);% 0.6; % in octave, used for ocnstain the stimulus evidence used for boundary switch
MDParas.BS_LearRate = md(3);%0.9; % learn rate for boundary value update
MDParas.OctShiftStep = md(4);%0.5; % in octave, the scale range is [0.33, 0.66], according to real behavior design
MDParas.Q_learRate = md(5);%;

[Q_values, Bsvalues] = BoundQmodel(Choice, Outcome, octaves, MDParas);

ExpValues = exp(Q_values);
ChoiceType = unique(Choice);
% ProbValues = ExpValues ./ repmat(sum(ExpValues)
ChoiceInds = find(repmat(ChoiceType(:),1,numel(Choice)) == repmat((Choice(:))',...
    numel(ChoiceType),1));

LL_value = ExpValues(ChoiceInds) ./ (sum(ExpValues,2));

BoundContext = Bsvalues <  MDParas.BS_thres;

FunLosses = -sum(log(LL_value)) + sum(BoundContext(:) ~= inds_low(:));