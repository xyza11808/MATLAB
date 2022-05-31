% Make data
N = 1000;
X = rand(N, 4);
Y = [X(:,1)+X(:,2), X(:,3)+0.1*X(:,4).^2, randn(N,1)];%, X(:,1) + 0.25*randn(N,1)
W = eye(4); 
W(1,1) = 0.01; 
W(2,2) = 100;
%% Test unspecified case
[beta, mse, t] = rrr(X, Y);
fprintf('Leave t full rank:\n\tMSE = %.3f\n\tt = %d\n', mse, t);
%% Test specified case
[beta, mse, t] = rrr(X, Y, 'rank', 2);
fprintf('Specify the value of t:\n\tMSE = %.3f\n\tt = %d\n', mse, t);
%% Test correlation control case
[beta, mse, t] = rrr(X, Y, 'rank', 0.05);
fprintf('Select t with correlation analysis:\n\tMSE = %.3f\n\tt = %d\n', mse, t);
%% Test minimized mse case
[beta, mse, t] = rrr(X, Y, 'rank', [1000, 10]);
fprintf('Select t with MSE minimization:\n\tMSE = %.3f\n\tt = %d\n', mse, t);
%% Test unspecified case
[beta, mse, t] = rrr(X, Y, 'weighting', W);
fprintf('Leave t full rank with specified weighting:\n\tMSE = %.3f\n\tt = %d\n', mse, t);
%% Test specified case
[beta, mse, t] = rrr(X, Y, 'rank', 2, 'weighting', W);
fprintf('Specify the value of t with specified weighting:\n\tMSE = %.3f\n\tt = %d\n', mse, t);
%% Test correlation control case
[beta, mse, t] = rrr(X, Y, 'rank', 0.05, 'weighting', W);
fprintf('Select t with correlation analysis with specified weighting:\n\tMSE = %.3f\n\tt = %d\n', mse, t);
%% Test minimized mse case
[beta, mse, t] = rrr(X, Y, 'rank', [1000, 5], 'weighting', W);
fprintf('Select t with MSE minimization with specified weighting:\n\tMSE = %.3f\n\tt = %d\n', mse, t);