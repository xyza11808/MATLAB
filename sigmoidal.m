function sigmoidal;
Rmax=100;
s_half=10;
s_inter=0.8;
s_end=20;

%S plot
s=0:0.1:s_end;
f_s=Rmax./(1+exp((s_half-s)/s_inter));
plot(s,f_s);
grid on
set(gca,'XTick', [0:s_inter*2:s_end]);
set(gca,'XTickLabel','0| | | | | | | | | | | |s_end')
ylabel('sigmoidal tuning curve')
xlabel('s')
title('tuning curve')
