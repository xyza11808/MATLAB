
[p,s,mu]=polyfit((1:length(AvgFrameValue)),AvgFrameValue,10);
f_y=polyval(p,(1:length(AvgFrameValue)),[],mu);
newAvgFrameData=AvgFrameValue-f_y;

figure
subplot(3,1,1)
plot(AvgFrameValue)
subplot(3,1,2)
plot(f_y)
subplot(3,1,3)
plot(newAvgFrameData)