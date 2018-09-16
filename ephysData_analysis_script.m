
[Data,TempData,info] = load_open_ephys_data('104_ADC1.continuous');
RealTimeData = TempData - TempData(1);
figure;
plot(RealTimeData,Data)

%%
[NewData,NewTempData,Newinfo] = load_open_ephys_data('104_CH2.continuous');
yyaxis right
plot(RealTimeData,NewData)

%%
NewFittedSignal = bandpass(NewData,[300 8000],info.header.sampleRate);
figure;
plot(RealTimeData,NewFittedSignal)