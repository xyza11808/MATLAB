%% HH model
TimeLen = 100; %ms      时间长度要合适，这样可以看到多个spike
TimeStep = 1e-4; %ms
StimOnset = 1; %ms
StimDur = 8; %ms

TimeStepNum = ceil(TimeLen/TimeStep);

%{
I_e = 0.1*[zeros(1,ceil(StimOnset/TimeStep)),...
    ones(1,ceil(StimDur/TimeStep))*1,...
    zeros(1,TimeStepNum - ceil(StimOnset/TimeStep) - ceil(StimDur/TimeStep))];
%}
%外加电流不能�?

I_e=0.1*ones(1,TimeStepNum);    %外加电流大小要合�?

Factor_a = 1;
gK = 0.36*Factor_a;
gNa = 1.2*Factor_a;
gL = 0.003*Factor_a;
E_L = -54.387;
E_K = -77;
E_Na = 50;
Cm = 0.01;

V = zeros(TimeStepNum,1);
n = zeros(TimeStepNum,1);
m = zeros(TimeStepNum,1);
h = zeros(TimeStepNum,1);
V(1) = -70;
% h(1) = 1;
%
for cStep = 2 : TimeStepNum
    %
%     cStep = 8;
    FormStepV = V(cStep - 1);
    % update n,m,h for current step
    Alpha_n = 0.01*(FormStepV + 55)/(1 - exp(-0.1*(FormStepV + 55)));
    Beta_n = 0.125*exp(-0.0125*(FormStepV + 65));
%     if cStep == 2
%         n(1) = Alpha_n/(Alpha_n + Beta_n);
%     end
    dn_dt = Alpha_n*(1 - n(cStep-1)) - Beta_n * n(cStep-1);
    n(cStep) = n(cStep-1) + dn_dt*TimeStep;
    
    Alpha_m = 0.1*(FormStepV+40)/(1 - exp(-0.1*(FormStepV+40)));
    Beta_m = 4*exp(-0.0556*(FormStepV+65));
%     if cStep == 2
%         m(1) = Alpha_m/(Alpha_m + Beta_m);
%     end
    dm_dt = Alpha_m*(1 - m(cStep-1)) - Beta_m*m(cStep-1);
    m(cStep) = m(cStep-1) + dm_dt*TimeStep;
    
    Alpha_h = 0.07*exp(-0.05*(FormStepV+65));
    Beta_h = 1/(1 + exp(-0.1*(FormStepV+35)));
%     if cStep == 2
%         h(1) = Alpha_h/(Alpha_h + Beta_h);
%     end
    dh_dt = Alpha_h*(1 - h(cStep-1)) - Beta_h*h(cStep-1);
    h(cStep) = h(cStep - 1) + dh_dt*TimeStep;
    
    dV_dt = (-gK*(n(cStep-1)^4)*(FormStepV - E_K) - ...
        gNa*(m(cStep-1)^3)*h(cStep-1)*(FormStepV - E_Na) - ...
        gL*(FormStepV - E_L) + I_e(cStep-1))/Cm;   %
    V(cStep) = V(cStep - 1) + dV_dt*TimeStep;
    %
end

figure;
plot(V)
