function FunHand = FuncHandle(Funtype,varargin)
% this function will return the function handle depends on input type
switch Funtype
    case 'gauss'
        FunHand = @(c,x) c(1)*exp((-1)*((x - c(2)).^2)./(2*(c(3)^2)));
    case 'logit'
%         FunHand = @(b,x) (b(1)+ b(2)./(1+exp(-(x - b(3))./b(4))));
        FunHand = @(b,x) (b(1)+ b(2)./(1+exp(-(x)./b(3))));
    case 'loggauss'
        % the coeffcient q should be given before nonlinear fitting
        q = varargin{1};
        FunHand = @(p,x) p(1)*exp((-1)*((x - q(1)).^2)./(2*(q(2)^2))) + ...
            (p(2)./(1+exp(-(x - q(3))./p(3))));
    otherwise
        error('undefined function types.');
end
