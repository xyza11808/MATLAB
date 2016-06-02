function main
clc
close all
Ts = 0.001;
Fs = 1/Ts;
%% ԭʼ�ź�
t = 0:Ts:pi/2;
yt = sin(2*pi*5*t) + sin(2*pi*10*t) + sin(2*pi*15*t);
[Yf, f] = Spectrum_Calc(yt, Fs);
figure
subplot(211)
plot(t, yt)
xlabel('t')
ylabel('y')
title('ԭʼ�ź�')
subplot(212)
plot(f, Yf)
xlabel('f')
ylabel('|Yf|')
xlim([0 100])
ylim([0 1])
title('ԭʼ�ź�Ƶ��')
%% �Ӵ��ź�
win = hann(length(t));
yt1 = yt.*win';
[Yf1, f1] = Spectrum_Calc(yt1, Fs);
figure
subplot(211)
plot(t, yt1)
xlabel('t')
ylabel('y')
title('�Ӵ��ź�')
subplot(212)
plot(f1, 2*Yf1) % 2��ʾ����ϵ��
xlabel('f')
ylabel('|Yf|')
xlim([0 100])
ylim([0 1])
title('�Ӵ��ź�Ƶ��')
end
%% ��ȡƵ��
function [Yf, f] = Spectrum_Calc(yt, Fs)
L = length(yt);
NFFT = 2^nextpow2(L);
Yf = fft(yt,NFFT)/L;
Yf = 2*abs(Yf(1:NFFT/2+1));
f = Fs/2*linspace(0,1,NFFT/2+1);
end