function [k,StepData] = ddm_cal(ModelParas)
% used parameters
% ModelParas.cTr_Cohn % stimulus types
% ModelParas.StimBias % animal bias for stimulus
% ModelParas.Stim_ratio % ratio for stim evidence accumulation
% ModelParas.Boundary % calculation boundary
% ModelParas.Stim_Varience % % stim varience variance
% ModelParas.Evidence_varience % accumulation variance
% ModelParas.StartPos = 0;
if ~isfield(ModelParas,'StartPos')
    ModelParas.StartPos = 0;
end

StimEvidence = ModelParas.Stim_ratio * (ModelParas.cTr_Cohn + ModelParas.StimBias ...
    + randn(1)*sqrt(ModelParas.Stim_Varience));
k = 1;
StepData = ModelParas.StartPos;
while abs(StepData) < abs(ModelParas.Boundary)
    k = k + 1;
    StepData(k) = StepData(k - 1) + ModelParas.Stim_ratio * StimEvidence + randn(1)*sqrt(ModelParas.Evidence_varience);
end


