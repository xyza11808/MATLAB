
function [varargout]=wave_analysis(mx,f_signal,time,FileName,varargin)
%%wave analysis function
%contains original signal plot, fft analysis plot and spectrom plot
%XIN yu
%within this function, the f_signal means the sample rate also, otherwise we need to resample from the original signal, which is not supported in this function
%need full three input elements
%the order should be the data vector, data aqusition frequence, the total
%time length of the signal data
if nargin<4 || isempty(FileName)
    FileName='Wave_component_analysis.png';
end

if nargin>4
    userDefineScale=1;
    FrequencyScale=varargin{1};
else
    userDefineScale=0;
end

fs = 1*f_signal; %calculate the sampling rate for signal mx, whose signal rate is f
t=1/fs : 1/fs : time;
% fs=2*fs;
N=length(t);%减1使N为偶数
%频率分辨率F=1/t=fs/N
p=mx;
%1.3*sin(0.48*2*pi*t)+2.1*sin(0.52*2*pi*t)+1.1*sin(0.53*2*pi*t)...
%+0.5*sin(1.8*2*pi*t)+0.9*sin(2.2*2*pi*t);
%上面模拟对信号进行采样，得到采样数据p，下面对p进行频谱分析

figure(1);
subplot(311);
% length(t)
% length(p)
plot(t,p);

grid on
title('原始信号 p(t)');
xlabel('t')
ylabel('V')

Y=fft(p);
magY=abs(Y(1:1:floor(N/2)+1))*2/N;
f=((1:N/2+1)-1)'*fs/N;  %using the sample rate for calculation here
% figure(2)
subplot(312);
%plot(f,magY);
% disp('the length of fft result vector is:');
% length(Y)
% disp('the length of fft vector amplitude is: ');
% length(magY)
% length(f)
h=stem(f,magY,'fill','--');
% set(gca,'xlim',[0,100]);
set(h,'MarkerEdgeColor','red','Marker','*')
grid on
%title('频谱图 （理想值：[0.48Hz,1.3]、[0.52Hz,2.1]、[0.53Hz,1.1]、[1.8Hz,0.5]、[2.2Hz,0.9]） ');
xlabel('f (Hz)')
ylabel('Power Amp.')
if userDefineScale
    xlim(FrequencyScale);
end

%n=length(t(1:10:end));
subplot(313);
window = t(1:10:end);
% figure(3)
[S,F,T] = spectrogram(p,window,[],[],fs);  %also fs means sample rate here, not the signal rate
pcolor(T,F,1000*abs(S));
shading interp;
% set(gca,'ylim',[0,100]);
xlabel('Time (s)');
ylabel('Freq(cycles/s)');
ylim([0 100]);
if userDefineScale
    ylim(FrequencyScale);
end
% filename=datestr(now,30); 
%,'\',datestr(now,30)
%the filename named after system time
% filename='D:\testt';
% cd(FileName);
saveas(h,FileName,'png');
% length(Y)
% length(magY)
% length(S)
% length(F)
% length(T)

% xlswrite(filename,Y,1);
%xlswrite(filename,[S;F;T],2);

close;


% figure;
% magY_raw=(Y(1:1:N/2))*2/N;
% subplot(211);
% h=stem(f,magY_raw,'fill','--');
% set(h,'MarkerEdgeColor','blue','Marker','diamond')
% title('raw data of fft result');
% xlabel('f (Hz)')
% ylabel('幅值')
% grid on

% subplot(212);
% magY_pow=power(abs(Y(1:1:N/2))*2/N,2);
% h=stem(f,magY_pow,'fill','--');
% set(h,'MarkerEdgeColor','blue','Marker','square')
% title('power of the result');
% xlabel('f (Hz)')
% ylabel('幅值')
% grid on

if nargout==1
    varargout{1}={{Y},{magY},{f}};
elseif nargout==3
    varargout{1}=Y;
    varargout{2}=magY;
    varargout{3}=f;
end

end


