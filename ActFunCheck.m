function varargout = ActFunCheck(FunString)
ActFun = [];
ActFunDeriv = [];
ActFunInverse = [];
ActFunInvDev = [];
switch FunString
    case 'Sigmoid'
        ActFun = @(x) 1./(1+exp(-x));
        ActFunDeriv = @(x) ActFun(x) .* (1 - ActFun(x));
        ActFunInverse = @(x) -log(1/x - 1);
        ActFunInvDev = @(x) 1/(x^2*(1/x - 1));
    case 'Tanh'
        ActFun = @(x) (1 - exp(-2.*x))./(1 + exp(-2.*x));
        ActFunDeriv = @(x) 1 - (ActFun(x)).^2;
        ActFunInverse = @(xxx) -log(-(xxx - 1)/(xxx + 1))/2;
        ActFunInvDev = @(xxx) -((1/(xxx + 1) - (xxx - 1)/(xxx + 1)^2)*(xxx + 1))/(2*(xxx - 1));
    case 'ReLU'
        ActFun = @(x) max(0,x);
        ActFunDeriv = @(x) double(x > 0);
        ActFunInverse = ActFun;
        ActFunInvDev = ActFunDeriv;
    case 'LeakyReLU'
        ActFun = @(x) max(x,0.01*x);
        ActFunDeriv = @(x) double(x > 0) + double(x <= 0)*0.01;
        ActFunInverse = @(x) x*double(x > 0) + 100*x&double(x <= 0);
        ActFunInvDev = @(x) double(x > 0) + double(x <= 0)*100;
    case 'SoftMax'
        ActFun = @(x) exp(x)./sum(exp(x)); % x must be a scalar vector
%         ActFunDeriv = [];
    otherwise
        error('Underfined activation type.');
end

if nargout == 2
    varargout{1} = ActFun;
    varargout{2} = ActFunDeriv;
elseif nargout == 4
    varargout{1} = ActFun;
    varargout{2} = ActFunDeriv;
    varargout{3} = ActFunInverse;
    varargout{4} = ActFunInvDev;
end
