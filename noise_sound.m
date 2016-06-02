function noise_sound(target_fq,SNR,time_stim,Fs)
%this function is used for generate noise sound with certain input options
%Fs indicates the sample rate of speaker
%Apr. 14, 2015

if nargin<2
    SNR=3;
    time_stim=300; %ms
    Fs=8192;
elseif nargin==2
    time_stim=300; %ms
    Fs=8192;
elseif nargin==3
    Fs=8192;
end

sample_step=1/(5*target_fq);  
sample_length=ceil((time_stim/1000)*target_fq);
x=-2*pi:sample_step:2*pi;
y=sin(2*target_fq*pi*x);

if length(x)<sample_length
    warning('Not enough sample wave generate, using gived time length.\n');
    x=0:sample_step:(2*sample_step*sample_length);
    y=sin(2*target_fq*pi*x);
end

noise_signal=awgn(y,SNR,'measured');  %awgn is used to add noise to an exist signal, wgn is used to generate a sequence of white noise
N=length(y);
Y=fft(noise_signal);
mag_Y=abs(Y(1:1:N/2+1))*2/N;
f=((1:N/2+1)-1)'*target_fq*5/N;
h=stem(f,mag_Y,'fill','--');
title(['SNR=',num2str(SNR)]);
set(h,'MarkerEdgeColor','red','Marker','*')
grid on;

disp(['Playing sound at frequency ' num2str(target_fq) 'with SNR=' num2str(SNR) '.\n']);
sound(y,Fs);
pause(double(time_stim)/1000);
disp('End of sound playing.\n');
