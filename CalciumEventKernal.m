function TimeTrace = CalciumEventKernal(time,FBase,Ft0,Ftau_on,Ftau_1,Ftau_2,FA1,FA2)
time = time(:);
AfterStartInds = time > Ft0;
AfterStartTime = time(AfterStartInds);
CurveBase = rand(numel(time),1)*sqrt(0.02*FA1);
% AfterStartFun = @(x,FBase,Ft0,Ftau_on,Ftau_1,Ftau_2,FA1,FA2) (1 - exp(-(x - Ft0)/Ftau_on)).*(...
%     FA1.*exp(-(x - Ft0)/Ftau_1) + FA2 .* exp(-(x - Ft0)/Ftau_1)) + FBase;
AfterStartFun = @(x) (1 - exp(-(x - Ft0)/Ftau_on)).*(...
    FA1.*exp(-(x - Ft0)/Ftau_1) + FA2 .* exp(-(x - Ft0)/Ftau_2));

AfterStartTrace = AfterStartFun(AfterStartTime);

TimeTrace = zeros(numel(time),1) + FBase;
TimeTrace(AfterStartInds) = AfterStartTrace;
TimeTrace = TimeTrace + CurveBase;


% x = Times(:);
% y = TestDatas(:)/100;
% 
% tt0 = 57/29;
% startPoint = [mean(TestDatas(1:50)),tt0,0.5,1,3,max(y)/2,max(y)/2];
% UPBountd = [max(y)/3,tt0+3/29,Inf,Inf,Inf,max(y)*10,max(y)*10];
% LoBound = [-max(y)/3,tt0-3/29,0.01,0.01,0.01,-Inf,-Inf];
% ffo = fitoptions('Method','NonlinearLeastSquares',...
%     'StartPoint',startPoint,'Lower',LoBound,'Upper',UPBountd,'MaxIter',10000);
% g = fittype(' CalciumEventKernal(x,a,b,c,d,e,f,g)','options',ffo);
% 
% [Curve,mmfit] = fit(x,y,g);
% figure;
% plot(Curve,x,y)

% ###################################
% calcium event simulation codes
% t0 = 1;
% t_step = 0.05;
% TimeLength = 5;
% TimePointsAll = 0:t_step:TimeLength;
% tau_on = 0.5;
% tau_1 = 1;
% tau_2 = 1;
% A1 = 1;
% A2 = 2;
% 
% % calculate the function values
% AboveThresTimesInds = TimePointsAll > t0;
% AboveThresTimes = TimePointsAll(AboveThresTimesInds);
% 
% Func = @(x,Ft0,Ftau_on,Ftau_1,Ftau_2,FA1,FA2) (1 - exp(-(x - Ft0)/Ftau_on)).*(...
%     FA1.*exp(-(x - Ft0)/Ftau_1) + FA2 .* exp(-(x - Ft0)/Ftau_2));
% 
% Cal_Fun = Func(AboveThresTimes,t0,tau_on,tau_1,tau_2,A1,A2);
% 
% SimuData = zeros(numel(TimePointsAll),1);
% SimuData(AboveThresTimesInds) = Cal_Fun;
% 
% figure;
% plot(TimePointsAll,SimuData)
