close all;
m=5;
n=1;

figure('position',[299   404   560   421])
plot(squeeze(Nhat(m,n,:)))
hold on
plot(squeeze(Nhat_nothres(m,n,:)))

figure('position',[1060 404 560 420])
plot(smooth(squeeze(Nhat(m,n,:)))*55)
hold on
plot(smooth(squeeze(Nhat_nothres(m,n,:)))*55)