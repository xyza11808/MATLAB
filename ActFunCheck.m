function [ActFun, ActFunDeriv] = ActFunCheck(FunString)
ActFun = [];
ActFunDeriv = [];

switch FunString
    case 'Sigmoid'
        ActFun = @(x) 1./(1+exp(-1*x));
        ActFunDeriv = @(x) ActFun(x) .* (1 - ActFun(x));
    case 'Tanh'
        ActFun = @(x) (1 - exp(-2.*x))./(1 + exp(-2.*x));
        ActFunDeriv = @(x) 1 - (ActFun(x)).^2;
    case 'ReLU'
        ActFun = @(x) max(0,x);
        ActFunDeriv = @(x) double(x > 0);
    case 'LeakyReLU'
        ActFun = @(x) max(x,0.01*x);
        ActFunDeriv = @(x) double(x > 0) + double(x <= 0)*0.01;
    case 'SoftMax'
        ActFun = @(x) exp(x)./sum(exp(x)); % x must be a scalar vector
%         ActFunDeriv = [];
    otherwise
        error('Underfined activation type.');
end