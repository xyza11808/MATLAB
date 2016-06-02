function test_logistic_lope
t=[0.00001,0.00005,0.0001,0.0005,0.001,0.005,0.01,0.05,0.1,0.5,1,5,10,50];
x=-5:0.1:5;

for k=1:length(t)
   y=1./(1+exp(-t(k).*x));
   plot(x,y,'linewidth',k/5);
   axis([-5,5,0,1])
   title(['with slope value',num2str(t(k))]);
   hold on;
   
   pause(1);
end
hold off