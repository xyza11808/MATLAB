
SinROIdata = squeeze(data_aligned(:,1,:));
SinROIvector = reshape(SinROIdata',[],1);
figure;
plot(SinROIvector);

%%
figure;
f_signal = 55;
fs = f_signal; %calculate the sampling rate for signal mx, whose signal rate is f
time = length(SinROIvector)/fs;

t=1/fs : 1/fs : time;
% fs=2*fs;
N=length(t);%减1使N为偶数
%频率分辨率F=1/t=fs/N
p=SinROIvector;
Y=fft(p);
magY=abs(Y(1:floor(N/2)+1))*2/N;
f=((1:N/2+1)-1)'*fs/N; 
h=stem(f,magY,'fill','--');
% set(gca,'xlim',[0,100]);
set(h,'MarkerEdgeColor','red','Marker','*')
grid on
%title('频谱图 （理想值：[0.48Hz,1.3]、[0.52Hz,2.1]、[0.53Hz,1.1]、[1.8Hz,0.5]、[2.2Hz,0.9]） ');
xlabel('f (Hz)')
ylabel('Power Amp.')

%%
h_spect = figure;
window = t(1:10:end);
% figure(3)
[S,F,T] = spectrogram(p,window,[],[],fs);  %also fs means sample rate here, not the signal rate
pcolor(T,F,1000*abs(S));
shading interp;
% set(gca,'ylim',[0,100]);
xlabel('Time (s)');
ylabel('Freq(cycles/s)');
ylim([0 30]);

%%
% please select the DC component that will not be processed
fprintf('Please select the DC component excluded inds.\n');
[DCx,DCy] = ginput(1);

% select the frequency component that need to be excluded from analysis
hf = gcf;
nNumbers = length(p); % signal length
yscale = get(gca,'ylim');
xFreqValue = (f(:))';
hold on;
nFreqComp = 1;
CompIndsX = [];
FreqIndsAll = false(length(Y),1);
IsAddComponent = 'y';
while ~strcmpi(IsAddComponent,'n')
    [Compx,Compy] = ginput(2);
    Compx = sort(Compx);
%     CompIndsX(2,nFreqComp) = Compx;
    patch([Compx(1) Compx(1) Compx(2) Compx(2)],[yscale(1) yscale(2) yscale(2) yscale(1)],1,...
        'FaceColor','c','EdgeColor','none','FaceAlpha',0.4);
    aInds = find(xFreqValue >= Compx(1),1,'first');
    bInds = find(xFreqValue <= Compx(2),1,'last');
    FreqIndsAll(aInds:bInds) = true;
    FreqIndsAll((2*nNumbers - aInds + 1):(2*nNumbers - bInds + 1)) = true;
    
    nFreqComp = nFreqComp + 1;
    IsAddComponent = input('Would you like to add another component to be excluded?\n','s');
end
BeforeDCInds = find(xFreqValue > DCx,1,'first');
WithoutDCInds = FreqIndsAll;
WithoutDCInds(1:BeforeDCInds) = true;

% use random assignment methods
BaselineDataAll = Y(~WithoutDCInds);
BaseShufDataAll = Vshuffle(BaselineDataAll);

% MeanBaseFreqBase = mean(Y(~FreqIndsAll));
% StdBaseFreqBase = std(Y(~FreqIndsAll));
%%
FreqRemoveY = Y;
ExcludeIndsY = length(Y(FreqIndsAll));
SampleDataY = Y(~FreqIndsAll);
try
    SampleDataNewY = BaseShufDataAll(randsample(length(BaseShufDataAll),ExcludeIndsY));
catch
    SampleDataNewY = BaseShufDataAll(randsample(length(BaseShufDataAll),length(SampleDataY),true));
end
FreqRemoveY(FreqIndsAll) = SampleDataNewY;
RemoveFreqData = abs(ifft(FreqRemoveY));

%%
% plot the frequency bandpass fft result
figure;
f_signal = 55;
fs = f_signal; %calculate the sampling rate for signal mx, whose signal rate is f
time = length(RemoveFreqData)/fs;

t=1/fs : 1/fs : time;
% fs=2*fs;
N=length(t);%减1使N为偶数
%频率分辨率F=1/t=fs/N
p=RemoveFreqData;
Y=fft(p);
magY=abs(Y(1:floor(N/2)+1))*2/N;
f=((1:N/2+1)-1)'*fs/N; 
h=stem(f(2:end),magY(2:end),'fill','--');
% set(gca,'xlim',[0,100]);
set(h,'MarkerEdgeColor','red','Marker','*')
grid on
%title('频谱图 （理想值：[0.48Hz,1.3]、[0.52Hz,2.1]、[0.53Hz,1.1]、[1.8Hz,0.5]、[2.2Hz,0.9]） ');
xlabel('f (Hz)')
ylabel('Power Amp.')


%%
RawData = (reshape(SinROIvector(:),size(SinROIdata,1),size(SinROIdata,2)))';
AfterData = (reshape(RemoveFreqData(:),size(SinROIdata,1),size(SinROIdata,2)))';
figure;imagesc(RawData,[0 300])
figure;imagesc(AfterData,[0 300])
figure;plot(mean(RawData))
figure;plot(mean(AfterData))