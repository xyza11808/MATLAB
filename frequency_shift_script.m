% 
% clc;
% 
% f_raw=fs;
% fs=5*f_raw;
% t=1/fs:1/fs:1;
% sig_raw=sin(2*pi*f_raw*t);
% N=length(sig_raw);
% 
% Y=fft(sig_raw);
% magY=abs(Y(1:1:N/2+1))*2/N;
% f=((1:N/2+1)-1)'*fs/N;
% figure;
% h=stem(f,magY,'fill','--');
% set(h,'MarkerEdgeColor','red','Marker','*')
% grid on
% 
% %just shift the value, and set the rest of the values into 0, then do the
% %ifft tranform

function [varargout]=freq_shift_full(raw_sample,varargin)
%this function will be used for signal frequency shift and maybe other
%usage
%raw_data indicates the orignal sample signal
% freq_shift_full(raw_sample,method,options)
    %name gives the value description,in this case indicates the methods
    %that will be used for further analysis
    %the variable value have several options, following as:
    % 'low' means the frequency power range will be shifted to lower frequency range
    % 'high' means the frequency power range will be shifted to higher frequency range
    % 'band' means a bandpass filter for given signal
%freq_shift_full(raw_sample,method,options,soundplay,options)
    % gives options whether play the sound or not
    % 1 means playing the sound after processing
    % 0 means not, but only plot the after processing 