define ff-test;
clc;
clear;
Adc=2; %ֱ����������
A1=3;   %Ƶ��F1�źŵķ���
A2=1.5; %Ƶ��F2�źŵķ���
F1=50; %�ź�1Ƶ��(Hz)
F2=75; %�ź�2Ƶ��(Hz)
Fs=256; %����Ƶ��(Hz)
P1=-30; %�ź�1��λ(��)
P2=90; %�ź���λ(��)
N=256; %��������
t=[0:1/Fs:N/Fs]; %����ʱ��

%�ź�
S=Adc+A1*cos(2*pi*F1*t+pi*P1/180)+A2*cos(2*pi*F2*t+pi*P2/180);
%��ʾԭʼ�ź�
subplot(411);plot(S);
title('ԭʼ�ź�');


Y = fft(S,N); %��FFT�任
Ayy = (abs(Y)); %ȡģ
subplot(412);stem(Ayy(1:N)); %��ʾԭʼ��FFTģֵ���
title('FFT ģֵ');

Ayy=Ayy/(N/2);   %�����ʵ�ʵķ���
Ayy(1)=Ayy(1)/2;
F=([1:N]-1)*Fs/N; %�����ʵ�ʵ�Ƶ��ֵ��Fn=(n-1)*Fs/N
subplot(413);stem(F(1:N/2),Ayy(1:N/2));   %��ʾ������FFTģֵ���
title('����-Ƶ������ͼ');

Pyy=[1:N/2];
for i=1:N/2
Pyy(i)=angle(Y(i)); %������λ
Pyy(i)=Pyy(i)*180/pi; %����Ϊ�Ƕ�
end;
subplot(414);stem(F(1:N/2),Pyy(1:N/2));   %��ʾ��λͼ
title('��λ-Ƶ������ͼ');