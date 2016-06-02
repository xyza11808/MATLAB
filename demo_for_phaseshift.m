function demo_for_phaseshift
sr=10000; 
dt=1/sr;
len=0.01; 
t=0:dt:(len-dt); 
f=500; 
N = length(t); 

%generate signal 
sig=sin(2*pi*f*t); 

%Define a phase shift in rads
p=-pi/4; 
num_samp = round((sr/f)*(p/(2*pi))); 

%Get the FFT of the signal 
z=fft(sig); 

%Delay each fft component 
for  k=1:length(z) 
    w = 2*pi/N*(k-1); 
    spec(k)=z(k)*exp(-1i*w*num_samp); 
end

%Get the new signal
newsig=(ifft(spec)); 

%plot the signals 
figure;
plot(t,sig);
hold on; 
plot(t,newsig,'g');

