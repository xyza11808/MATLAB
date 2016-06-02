function y = rsolve( p, c, x )
% RSOLVE Radial Basis Function solver
% Solves a Radial Basis func. (cubic, given a coeff. vector and centers)
% for a vector input
% J. Watlington, 11/18/95

[m,num_samples] = size( x );
[m,order] = size( p );

y = zeros( [ 1, num_samples ]);   %  preallocate results
A = zeros( [ 1, order ] );        %  preallocate temp storage

for loc = 1:num_samples
  for center = 1:order

    A( center ) = abs(x( loc ) - c( center ))^3;

    %A( center ) = exp( - abs(x(loc)-c(center))^2 ); 
    
    
  end
  y( loc ) = A * p';
end
