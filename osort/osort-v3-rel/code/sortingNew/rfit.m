function r = rfit( x, y, c, order )
% RFIT Radial Basis Function fitter (cubic)
% Generates coefficients for radial basis function fitting of a dataset,
% using pre-selected centers and a cubic basis function.
% J. Watlington, 11/18/95

[m,num_samples] = size( x );
[m,order] = size( c );

%  Define the matrix for the radial basis functions

A = ones( [ num_samples, order ] );    %  preallocate
for loc = 1:num_samples
  for center = 1:order

    %cubic basic function
    A( loc, center ) = abs( x( loc ) - c( center ) )^3;

    %gaussian basis function
    %A( loc, center ) = exp( - abs(x(loc)-c(center))^2 ); 
    
    
  end
end

%  Solve for the pseudo-inverse, and multiply it times the input
%  to obtain the optimal solution.
r = (pinv( A ) * y')';

