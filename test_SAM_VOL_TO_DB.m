function test_SAM_VOL_TO_DB

clear;
clc;
%mag2db() function can be used to change amp balue into DB value, converted
%by equaltion  ydb = 20 log10(y).

%%
A0=1;
L0=150;
Lp=20;
modu_freq=20;
sig_freq=500;
fs=4000;
time=0:1/fs:1;

%%
L=Lp*sin(2*pi*modu_freq*time)-Lp;
L_modu=L+L0;
sig_wave=A0*sin(2*pi*sig_freq*time);

Amp_modu=A0./(power(10,((L0-L_modu)/20)));

modu_wave_vol=L_modu.*sig_wave;
modu_wave_DB=Amp_modu.*sig_wave;

%%
figure;
plot(time,L_modu);
title('sound intensity modulation');

%%
figure;
plot(time,Amp_modu);
title('wave amp modulation');

%%
figure;
plot(time,modu_wave_vol);
title('volume modulation');

%%
figure;
plot(time,modu_wave_DB);
title('intensity modulation');

% %%
% clear;
% clc;
% 
% %%
% A0=1;
% Am=0.5;
% L0=150;
% Lp=40;
% modu_freq=5;
% sig_freq=500;
% fs=4000;
% time=0:1/fs:1;
% 
% %%
% sig_wave=A0*sin(2*pi*sig_freq*time);
% modu_amp=Am*sin(2*pi*modu_freq*time)-Am;
% 
% modu_wave=modu_amp.*sig_wave+Am;
% 
% figure;
% plot(time,modu_wave);
% title('Amp modulation of signal wave');
% 

