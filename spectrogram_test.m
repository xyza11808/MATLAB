function [f,freqpowers] = spectrogram_test(trace, Fs, varargin)

% Fs = 40;% sampling frequency
% x = 0:(1/Fs):4;% time domain
x = (1/Fs):(1/Fs):(numel(trace)/Fs);% time domain
% y = [sin(2 * pi * 5 * x(x <= 2)), sin(2 * pi * 10 * x(x > 2))];% signal
y = trace;

    N = length(x);                     % Length of signal

    NFFT = 2^nextpow2(N); % Next power of 2 from length of y
    Y = fft(y,NFFT)/N;
    f = Fs/2*linspace(0,1,NFFT/2+1);

    % Generate the plot, title and labels.
    fh = figure;
    % set(fh,'color','white','visible','off');
    subplot(311);
    plot(x,y,'k');
    xlabel('Time (s)','FontName','Times New Roman','fontsize',10);
    ylabel('Amplitude','FontName','Times New Roman','fontsize',10);
    set(gca,'FontName','Times New Roman','fontsize',10);

    % # Frequency domain plots
    subplot(312);
    freqpowers = 2*abs(Y(1:NFFT/2+1));
    plot(f,freqpowers) 
    xlabel('Frequency (cycles/second)','FontName','Times New Roman','fontsize',10);
    ylabel('Amplitude','FontName','Times New Roman','fontsize',10);
    set(gca,'FontName','Times New Roman','fontsize',10);

    subplot(313);
    window = x(1:10:end);
    [S,F,T] = spectrogram(y,window,[],[],Fs);
    pcolor(T,F,abs(S));shading interp;
    xlabel('Time (s)');
    ylabel('Frequency (cycles/second)');