function CrossLoss = ddm_call_fun(TrialCohen,AnmChoice,Paras)
% Used for calculation
% ModelParas.cTr_Cohn = TrialCohen;% stimulus types
ModelParas.StimBias = Paras(1);% animal bias for stimulus
ModelParas.Stim_ratio = Paras(2);% ratio for stim evidence accumulation
ModelParas.Boundary = Paras(3);% calculation boundary
ModelParas.Stim_Varience = Paras(4);% % stim varience variance
ModelParas.Evidence_varience = Paras(5);% accumulation variance

%%
TrNums = numel(AnmChoice);
PredChoice = zeros(TrNums,1);
% hf = figure;
% hold on
for cTr = 1 : TrNums
    cTrCoheren = TrialCohen(cTr);
    ModelParas.cTr_Cohn = cTrCoheren;
    [~,StepData] = ddm_cal(ModelParas);
    if StepData(end) > 0
        PredChoice(cTr) = 1;
    else
        PredChoice(cTr) = 0;
    end
%     plot(StepData)
end
%%
CohenTypes = unique(TrialCohen);
nCohens = numel(CohenTypes);
CohenRProbs = zeros(nCohens,2);
for cCohen = 1 : nCohens
    cCohenTypeInds = TrialCohen == CohenTypes(cCohen);
    CohenRProbs(cCohen,1) = mean(AnmChoice(cCohenTypeInds));
    CohenRProbs(cCohen,2) = mean(PredChoice(cCohenTypeInds));
end

CrossLoss = sum((CohenRProbs(:,1) - CohenRProbs(:,2)).^2);
