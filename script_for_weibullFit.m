

% weibull function fit for behavior data
Datax = Ocatves;
Datay = Performance;
modelfun = @(b,x) (1-exp(-(x/b(1)).^b(2))); %weibull function
md1 = fitnlm(Datax,Datay,modelfun,[1 1])

Linex = linspace(min(Datax),max(Datax),500);
Liney = predict(md1,Linex(:));
h_weibull = figure;
hold on;
plot(Datax,Datay,'ko','MarkerSize',10);
plot(Linex,Liney,'k');
