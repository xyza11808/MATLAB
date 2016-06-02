N=128;
k=0:N-1;
 
dr = 60;
sigma = 0.4;
w = exp(-0.5*( (k-(N-1)/2)/(sigma*(N-1)/2) ).^2);
 
B = N*sum(w.^2)/sum(w)^2 ;   % noise bandwidth (bins)
 
H = abs(fft([w zeros(1,7*N)]));
H = fftshift(H);
H = H/max(H);
H = 20*log10(H);
H = max(0,dr+H);
 
figure
area(k,w,'FaceColor', [0 .4 .6])
xlim([0 N-1])
set(gca,'XTick', [0 : 1/8 : 1]*(N-1))
set(gca,'XTickLabel','0| | | | | | | |N-1')
grid on
ylabel('amplitude')
xlabel('samples')
title('Window function (Gauss, \sigma = 0.4)')
 
figure
stem(([1:(8*N)]-1-4*N)/8,H,'-');
set(findobj('Type','line'),'Marker','none','Color',[.871 .49 0])
xlim([-4*N 4*N]/8)
ylim([0 dr])
set(gca,'YTickLabel','-60|-50|-40|-30|-20|-10|0')
grid on
ylabel('decibels')
xlabel('DFT bins')
title('Frequency response (Gauss, \sigma = 0.4)')