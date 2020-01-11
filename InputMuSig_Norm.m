function zs_x = InputMuSig_Norm(x,mu,sig)
ColNums = size(x,2);
Mtx_mu = repmat(mu(:),1,ColNums);
Mtx_sig = repmat(sig(:),1,ColNums);

zs_x = (x - Mtx_mu)./Mtx_sig;
