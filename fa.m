function [W, psi, mu, llh] = fa(X, p)
% EM algorithm for factor analysis model
% reference:
% Pattern Recognition and Machine Learning by Christopher M. Bishop 
[d,n] = size(X);  % ntimePoints-by-nROIs
mu = mean(X,2); % nRows
X = bsxfun(@minus,X,mu); % rows mean substraction

tol = 1e-8;
converged = false;
llh = -inf;

% initialize parameters
W = rand(d,p);  % p is the factor number
invpsi = 1./rand(d,1);

% precompute quantities
I = eye(p);
normX = sum(X.^2,2);

U = bsxfun(@times,W,sqrt(invpsi));
M = U'*U+I;                     % M = W'*inv(Psi)*W+I
R = chol(M);
invM = R\(R'\I);
WinvPsiX = bsxfun(@times,W,invpsi)'*X;       % WinvPsiX = W'*inv(Psi)*X
while ~converged
    % E step
    Ez = invM*WinvPsiX;
    Ezz = n*invM+Ez*Ez';
    % end
    
    R = chol(Ezz);  
    XEz = X*Ez';
    
    % M step
    W = (XEz/R)/R';
    invpsi = n./(normX-sum(W.*XEz,2));
    % end

    % compute quantities needed
    U = bsxfun(@times,W,sqrt(invpsi));
    M = U'*U+I;                     % M = W'*inv(Psi)*W+I
    R = chol(M);
    invM = R\(R'\I);
    WinvPsiX = bsxfun(@times,W,invpsi)'*X;       % WinvPsiX = W'*inv(Psi)*X
    % end
    
    % likelihood
    last = llh;
    logdetC = 2*sum(log(diag(R)))-sum(log(invpsi));              % log(det(C))
    trinvCS = (normX'*invpsi-sum(sum((R'\WinvPsiX).^2)))/n;  % trace(inv(C)*S)
    llh = -n*(d*log(2*pi)+logdetC+trinvCS)/2;
    % end
    converged = abs(llh-last) < tol*abs(llh);   % check likelihood for convergence
end
psi = 1./invpsi;
