%
%uses truncated SVD to remove white noise from pre-whitened waveforms.
%returns a low-rank approximation of the original signal.
%
%
%rankCut: cut off after which rank
%
%returns: spectr is the singular value spectrum (diag of S)
%         transformed is low rank approx
%
%urut/nov04
function [transformed,spectr] = removeWhitenoise( spikes, rankCut )

%dimensions of hankel matrix
N=25;
M=64-N+1;
K=M+N-1;

transformed=zeros(size(spikes,1), size(spikes,2));
spectr=zeros(size(spikes,1), N);
spectr=[];


for i=1:size(spikes,1)
    X=hankel( spikes(i,1:M), spikes(i,M:K));
    [U,S,V]=svd(X,0);
    Ux1=U(:,1:rankCut);
    transformed(i,:)=aaad(Ux1*Ux1'*X);   %truncate and average across diagonals of hankel matrix to get signal back, which is now a low-rank approximation
    spectr(i,:)=(diag(S)')/S(1,1);
end