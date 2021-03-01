%calcium event simulation codes
t0 = 1;
t_step = 0.05;
TimeLength = 5;
TimePointsAll = 0:t_step:TimeLength;
tau_on = 0.5;
tau_1 = 1;
tau_2 = 1;
A1 = 1;
A2 = 2;

% calculate the function values
AboveThresTimesInds = TimePointsAll > t0;
AboveThresTimes = TimePointsAll(AboveThresTimesInds);

Func = @(x,Ft0,Ftau_on,Ftau_1,Ftau_2,FA1,FA2) (1 - exp(-(x - Ft0)/Ftau_on)).*(...
    FA1.*exp(-(x - Ft0)/Ftau_1) + FA2 .* exp(-(x - Ft0)/Ftau_2));

Cal_Fun = CalciumEventKernal(TimePointsAll,0,t0,tau_on,tau_1,tau_2,A1,A2);

figure;
plot(TimePointsAll,Cal_Fun)

%%
SpikeOnTime = 21;
kernalLength = length(Cal_Fun);

TotalLength = 10000;
SamplespikeNum = 100;
SampleSPTime = randsample(TotalLength,SamplespikeNum);

SampleSPTime(SampleSPTime < SpikeOnTime) = SampleSPTime(SampleSPTime < SpikeOnTime) + 100;
SampleSPTime(SampleSPTime >= (TotalLength - kernalLength)) = ...
    SampleSPTime(SampleSPTime >= (TotalLength - kernalLength)) - kernalLength - 1;

%%
KernalDrivedData = rand(TotalLength,1)*0.02;
for ct = 1 : length(SampleSPTime)
    st = SampleSPTime(ct);
    ct_kernalData = CalciumEventKernal(TimePointsAll,0,t0,tau_on,tau_1,tau_2,A1,A2);
    KernalDataInds = (st - SpikeOnTime+1):(st+kernalLength-SpikeOnTime);
    KernalDrivedData(KernalDataInds) = KernalDrivedData(KernalDataInds) + ct_kernalData;
    
end

figure;plot(KernalDrivedData,'k')

%% calculate kernal values






