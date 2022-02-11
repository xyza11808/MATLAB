function [beta, total_mse, t] = rrr(X, Y, varargin)
%RRR Performed reduced rank multivariate regression.
%   [BETA] = RRR(X, Y) Finds the reduced rank regression using a full rank
%   assumption. X is a n-by-r matrix, and Y is a n-by-s matrix. The rank,
%   t, is defined as t = min(r, s).
%   RRR(X, Y, 'PARAM1', VALUE1, 'PARAM2', VALUE2) specifies additional
%   parameter name/value pairs chosen from the following:
%       'rank'      Specifies how to compute the apprporiate rank. Follow
%                   with an integer greater than or equal to 1 to specify
%                   the rank of the matrix directly. Follow with a floating
%                   point number less than 1 to specify a significance
%                   value to compute the rank by linear correlation between
%                   rows in Y.  A vector of two integer [N, K] defined a
%                   K-folds cross-validation pattern that subsamples N data
%                   points from X and Y. The appropriate rank is then
%                   estimated via minimum square error of the k-folds
%                   testing set.
%       'weighting' Define a positive-definite s-by-s weighting matrix.
%                   Default value is inv(cov(Y)).
%
%
% Make sure matrices are the same length
% Source: https://www.mathworks.com/matlabcentral/fileexchange/53024-reduced-rank-regression
% #########################################################################
% % testing script
% % Make data
% N = 1000;
% X = rand(N, 4);
% Y = [X(:,1)+X(:,2), X(:,3)+0.1*X(:,4).^2, X(:,1) + 0.25*randn(N,1), randn(N,1)];
% W = eye(4); W(1,1) = 0.01; W(2,2) = 100;
% % Test unspecified case
% [~, mse, t] = rrr(X, Y);
% fprintf('Leave t full rank:\n\tMSE = %.3f\n\tt = %d\n', mse, t);
% % Test specified case
% [~, mse, t] = rrr(X, Y, 'rank', 2);
% fprintf('Specify the value of t:\n\tMSE = %.3f\n\tt = %d\n', mse, t);
% % Test correlation control case
% [~, mse, t] = rrr(X, Y, 'rank', 0.05);
% fprintf('Select t with correlation analysis:\n\tMSE = %.3f\n\tt = %d\n', mse, t);
% % Test minimized mse case
% [~, mse, t] = rrr(X, Y, 'rank', [1000, 5]);
% fprintf('Select t with MSE minimization:\n\tMSE = %.3f\n\tt = %d\n', mse, t);
% % Test unspecified case
% [~, mse, t] = rrr(X, Y, 'weighting', W);
% fprintf('Leave t full rank with specified weighting:\n\tMSE = %.3f\n\tt = %d\n', mse, t);
% % Test specified case
% [~, mse, t] = rrr(X, Y, 'rank', 2, 'weighting', W);
% fprintf('Specify the value of t with specified weighting:\n\tMSE = %.3f\n\tt = %d\n', mse, t);
% % Test correlation control case
% [~, mse, t] = rrr(X, Y, 'rank', 0.05, 'weighting', W);
% fprintf('Select t with correlation analysis with specified weighting:\n\tMSE = %.3f\n\tt = %d\n', mse, t);
% % Test minimized mse case
% [~, mse, t] = rrr(X, Y, 'rank', [1000, 5], 'weighting', W);
% fprintf('Select t with MSE minimization with specified weighting:\n\tMSE = %.3f\n\tt = %d\n', mse, t);

% #########################################################################


assert(size(X,1)==size(Y,1), 'X and Y must have the same number of observations.')
% Make sure the arguments are in the right format
for i=1:2:length(varargin)
    assert(isstr(varargin{i}), 'Additional arguments must specify a parameter string first.');
end
% Define prima facie constants.
r = size(X, 2);
s = size(Y, 2);
n = size(X, 1);
% Handle the optimal arguments
t = min(r, s);
G = 0;
if nargin > 2
    for i=3:2:nargin
        if strcmp(varargin{i-2}, 'weighting')
            G = varargin{i-1};
            assert((size(G,1)==s && size(G,2)==s), 'The weighting matrix must be square and have dimension equal to the number of dependent variables.');
            [~, posdef] = chol(G); assert((posdef==0), 'The weighting matrix must be positive definite.');
        end
    end
    for i=3:2:nargin
        if strcmp(varargin{i-2}, 'rank')
            if length(varargin{i-1}) == 2
                % Extract constants
                N = varargin{i-1}(1);
                K = varargin{i-1}(2);
                assert((n >= N), sprintf('The data contains only %d samples, but you specified a subsample of %d for cross-fold validation.', n, N));
                assert((K <= N), 'The number of folds for cross-validation must be less than or equal to the sub-sample.');
                assert((N/K == round(N/K)), 'Please specify a subsample number that is an integer multiple of the number of folds.');
                % Initialize vectors
                mse_k = zeros(1,K);
                mse_t = zeros(1,s);
                % Make folds
                cv = make_folds(N, K, n);
                % Test folds
                for j=1:1:s
                    for k=1:1:K
                        bb = compute_rrr(X(cv(k).train, :), Y(cv(k).train, :), j, G);
                        mse_k(k) = compute_mse(bb, X(cv(k).test, :), Y(cv(k).test, :));
                    end
                    mse_t(j) = mean(mse_k);
                end
                % Find the best value for t
                t = find(mse_t == min(mse_t));
            elseif varargin{i-1} >= 1
                % Just define t and run with it
                t = varargin{i-1};
                assert((round(t)==t), sprintf('The specified rank must be an integer value (you used t = %.2f).', t));
            elseif varargin{i-1} < 1
                % Find t based on correlation analysis
                assert((varargin{i-1} > 0), sprintf('The specified confidence value must be greater than 0 (you used rho = %.2f)', varargin{i-1}));
                t = num_uncorr(Y, varargin{i-1});
            end
        end
    end
end
beta = compute_rrr(X, Y, t, G);
total_mse = compute_mse(beta, X, Y);
    function b = compute_rrr(xx, yy, tt, gg)
        % Define constants
        rr = size(xx, 2);
        full_covariance = cov([xx yy]);
        SSXX = full_covariance(1:rr, 1:rr);
        SSYX = full_covariance((rr+1):end, 1:rr);
        SSXY = full_covariance(1:rr, (rr+1):end);
        SSYY = full_covariance((rr+1):end, (rr+1):end);
        % Define the weighting matrix
        if length(gg) == 1
            gg = inv(SSYY);
        end
        % Define the matrix of eigen-values
        [VVt,~] = eigs(sqrtm(gg)*SSYX*inv(SSXX)*SSXY*sqrtm(gg),tt);
        
        % Define the decomposition and mean matrices
        AAt = sqrtm(inv(gg))*VVt;
        BBt = VVt'*sqrtm(gg)*SSYX*inv(SSXX);
        MMt = mean(yy)' - AAt*BBt*(mean(xx)');
        b = [MMt AAt*BBt];
    end
    function  t = num_uncorr(yy, p_crit)
        while true
            [~, p] = corr(yy);
            score = sum(min(p) < p_crit);
            if score == 0
                break;
            end
            idx = find(min(p) == min(min(p)));
            yy(:,idx(1)) = [];
        end
        t = size(yy, 2);
    end
    function cv = make_folds(number_of_samples, number_of_folds, max_samples)
        options = randsample(max_samples, number_of_samples);
        fold_size = number_of_samples/number_of_folds;
        for ii=1:1:number_of_folds
            temp = options;
            test_slice = ((ii-1)*fold_size+1):1:(ii*fold_size);
            cv(ii).test = temp(test_slice);
            temp(test_slice) = [];
            cv(ii).train = temp;
        end
    end
    function mse = compute_mse(B, X, Y)
        Y_pred = [ones(size(X, 1), 1) X]*B';
        er = (Y - Y_pred).^2;
        mse = mean(er(:));
    end
end