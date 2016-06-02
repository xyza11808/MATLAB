function test_wave_gene

x=1:5000;
z=0:0.0001:1;
f0=5000;
%fs=20;
sig=400;
a=length(x)/2;

%generate modulated amplitude function
%Amp=abs(sin((2*pi/fs).*x));
Amp=(1/sqrt(1*pi*sig))*exp(-((x-a).^2)/(2*(sig.^2)));
plot(x,Amp);
figure;
%y=Amp.*sin((2*pi/f0).*x);
y=sin((2*pi*f0)*z);
plot(z,y);


end