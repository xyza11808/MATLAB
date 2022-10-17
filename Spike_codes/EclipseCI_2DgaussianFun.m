function f_CI = EclipseCI_2DgaussianFun(PointData,alpha)
if ~exist('alpha','var')
    alpha = 0.05;
end
% Suppose you know the distribution params, or you got them from normfit()
% mu    = [3, 7];
% sigma = [1, 2.5
%          2.5  9];
mu = mean(PointData);
sigma = cov(PointData);

% X/Y values for plotting grid
% x = linspace(mu(1)-4*sqrt(sigma(1)), mu(1)+4*sqrt(sigma(1)),500);
% y = linspace(mu(2)-4*sqrt(sigma(end)), mu(2)+4*sqrt(sigma(end)),500);

% % Z values
% [X1,X2] = meshgrid(x,y);
% Z       = mvnpdf([X1(:) X2(:)],mu,sigma);
% Z       = reshape(Z,length(y),length(x));

% figure;
% hold on

% Plot
% h = pcolor(x,y,Z);
% set(h,'LineStyle','none')
% hold on

% Add level set

r     = sqrt(-2*log(alpha));
rho   = sigma(2)/sqrt(sigma(1)*sigma(end));
M     = [sqrt(sigma(1)) rho*sqrt(sigma(end))
         0              sqrt(sigma(end)-sigma(end)*rho^2)];

theta = 0:0.1:2*pi;
f_CI     = bsxfun(@plus, r*[cos(theta)', sin(theta)']*M, mu);
% plot(f(:,1), f(:,2),'--r')
% 
% plot(PointData(:,1),PointData(:,2),'ko');
