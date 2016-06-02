clear all
clc
x=0:pi/50:2*pi;
y=sin(x);
plot(x,y)
h=line(x,y,'color','r','marker','.','markersize',20);
axesValue=axis;
for i=1:10
for jj=1:length(x)
  %set(h,'xdata',x(jj),'ydata',y(jj));
    axis(axesValue);
    drawnow
    pause(0.1)
end
end