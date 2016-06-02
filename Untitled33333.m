clc
fs=200000;
t=[0:1/(fs-1):5];
N=length(t)-1;%减1使N为偶数
%频率分辨率F=1/t=fs/N
p=mx2;
%1.3*sin(0.48*2*pi*t)+2.1*sin(0.52*2*pi*t)+1.1*sin(0.53*2*pi*t)...
%+0.5*sin(1.8*2*pi*t)+0.9*sin(2.2*2*pi*t);
%上面模拟对信号进行采样，得到采样数据p，下面对p进行频谱分析

figure(1)
plot(t,p);
grid on
title('原始信号 p(t)');
xlabel('t')
ylabel('p')

Y=fft(p);
magY=abs(Y(1:1:N/2))*2/N;
f=(0:N/2-1)'*fs/N;
figure(2)
%plot(f,magY);
h=stem(f,magY,'fill','--');
set(h,'MarkerEdgeColor','red','Marker','*')
grid on
%title('频谱图 （理想值：[0.48Hz,1.3]、[0.52Hz,2.1]、[0.53Hz,1.1]、[1.8Hz,0.5]、[2.2Hz,0.9]） ');
xlabel('f (Hz)')
ylabel('幅值')


 window = t(1:10:end);
 figure(3)
 [S,F,T] = spectrogram(Y,window);
 pcolor(T,F,abs(S));shading interp;
 xlabel('Time (s)');
 ylabel('Frequency (cycles/second)');