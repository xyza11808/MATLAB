

% used parameters
Cohen = -5; % Used coherence
Coh2mu_factor = 0.1; % factor describe linear relationship between cohn and evidence mean
mu = Coh2mu_factor * Cohen;
Vars = 1;
dt = 2; % in ms
AcumulatorNoiseVar = 2;

decisionTime = 500; % in ms
BoundDisTotal = 2;
BoundDis_ratio_z = 0.5; % 0<Value<1

EvidenceAccuFactor = 0.1;

RightBound = (1 - BoundDis_ratio_z) * BoundDisTotal; % positive value
LeftBound = -BoundDis_ratio_z*BoundDisTotal; % negtive value

TimeSteps = decisionTime / dt;
DV_t = zeros(TimeSteps,1);
Evidence = mu + sqrt(Vars) * (rand(size(DV_t))-0.5)*2;  % stimulus evidence
AccuNoise = sqrt(AcumulatorNoiseVar) * 2 * (rand(size(DV_t))-0.5);
%
xx = zeros(TimeSteps,1);
for ct = 2 : TimeSteps
    dx_dt = EvidenceAccuFactor * Evidence(ct) + AccuNoise(ct);
    xx(ct) = xx(ct-1) + dx_dt;
end

figure;
plot(xx)


