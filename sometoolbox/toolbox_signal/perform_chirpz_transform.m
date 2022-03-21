function y = perform_chirpz_transform(x,z)

% perform_chirpz_transform - compute the chirp Z-transform
%
%   y = perform_chirpz_transform(x,z);
%
%   Compute, for z \in C,  
%       y[k]=sum{ x[n]*z^{-n*k} }
%   with a fast chirp-like algorithm.
%
%   Copyright (c) 2003 Gabriel Peyr�

x = x(:);
n = length(x);
g = z.^(1/2*(0:n-1)'.^2); 
h = x./g;
k = ceil(log2(2*n-1)); 
M = 2^k;
g = [g; zeros(M-2*n+1,1); g(n:-1:2)];
h = [h; zeros(M-n,1)];
y = ifft( fft(g).*fft(h) );
y = y(1:n)./g(1:n);