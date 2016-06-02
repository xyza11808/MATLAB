function Amptitude_modulation
% MATLAB Script for Amplitude Modulation
% Although it is possible to modulate any signal over a sinusoid, however I
% will use a low frequency sinusoid to modulate a high frequency sinusoid
% without the loss of generality. Please feel free to contact me if you
% have problems modulation other signals over a sinusoid.
% Contact me at shah_gul_khan@hotmail.com

format long;

% Clear all previuosly used variables and close all figures
clear all;
close all;

% Amplitude, Frequency and Phase Shift for Modulating Signal
A1 = 2; f1 = 5; p1 = 0;

% Amplitude, Frequency and Phase Shift for Carrier Signal
A2 = 4; f2 = 20000; p2 = 0;

% Sample Rate - This will define the resolution
fs = 100000;

% Time Line. Longer the signal, better will be the fft
t = 0: 1/fs : 1;

% Generate the message signal
s1 = A1*sin(2*pi*f1*t + p1);

% Plot the message signal
figure(1);
plot(t,s1);
xlabel('Time (sec)');
ylabel('Amplitude');
title(['Message Signal with frequency = ',num2str(f1),' Hz']);
grid on;

% Generate the Carrier wave
s2 = A2*sin(2*pi*f2*t + p2);

% Plot the carrier wave
figure(2);
plot(t,s2);
xlabel('Time (sec)');
ylabel('Amplitude');
title(['Carrier Signal with frequency = ',num2str(f2),' Hz']);
grid on;

% Finally the Modulation
% Ref. Modern Analogue and Digital Communication Systems - B. P. Lathi

% Amplitude Modulation with Suppressed Carrier
% Double Sideband with Suppressed Carrier (DSB-SC)
s3 = s1.*s2;

% Generate the Envelope
s3_01 = A1*A2*(sin(2*pi*f1*t));
s3_02 = -A1*A2*(sin(2*pi*f1*t));

% Amplitude Modulation with Large Carrier 
% Double Sideband with Large Carrier (DSB - LC)
s4 = (A2 + s1).*sin(2*pi*f2*t);

% Generate the Envelope
s4_01 = A2 + s1;
s4_02 = -A2 - s1;

% ----------------------------------------------------------
% Let's Check out the frequency content of the two Modulations

% Number of FFT points. N should be greater than Carrier Frequency
% Larger the better
N = 2^nextpow2(length(t));
f = fs * (0 : N/2) / N; 

% Find FFT
s3_f = (2/N)*abs(fft(s3,N));
s4_f = (2/N)*abs(fft(s4,N));

%-------------------------------------------------------------
% Plot the two Modulations
% Plot the DSB-SC Signal
figure(3);
subplot(2,1,1);
plot(t,s3);
hold on;
plot(t,s3_01,'r');
hold on;
plot(t,s3_02,'g');
xlabel('Time (sec)');
ylabel('Amplitude');
title('Double Sideband with Suppressed Carrier');
grid on;

subplot(2,1,2);
plot(f(1:100),s3_f(1:100));
xlabel('Frequency (Hz)');
ylabel('| Amplitude |');
title('Spectral Anaalysis (Single Sided PSD)');
grid on;

% Plot the DSB-LC Signal
figure(4);
subplot(2,1,1);
plot(t,s4);
hold on;
plot(t,s4_01,'r');
hold on;
plot(t,s4_02,'g');
xlabel('Time (sec)');
ylabel('Amplitude');
title('Double Sideband with Large Carrier');
grid on;
subplot(2,1,2);
plot(f(1:100),s4_f(1:100));
xlabel('Frequency (Hz)');
ylabel('| Amplitude |');
title('Spectral Anaalysis (Single Sided PSD)');
grid on;