function MM = matrix_sampling_set(M, v, I)

% matrix_sampling_set - set the value of matrix M at given index.
%
%   MM = matrix_sampling_set(M, v, I);
%
%   M is a 2D array, and I=[I1;I2] is of size 2xn. Return
%   y(i) = M( I1(i), I2(i) )
%
%   Copyright (c) 2004 Gabriel Peyr�

J = sub2ind(size(M), I(1,:),I(2,:) );
M(J) = v;
MM = M;
