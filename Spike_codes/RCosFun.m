function y = RCosFun(x, c, w)
% define a raised cosine bumps function used for bases function
% x is the data points
% c is the center of each kernal
% w is the width for the basis function

y = zeros(size(x));
WithinofRangeInds = abs(x - c) < w/2;

Caled_x_Data = x(WithinofRangeInds);

y(WithinofRangeInds)  = 0.5*cos(2*pi*(Caled_x_Data - c)/w)+ 0.5;


