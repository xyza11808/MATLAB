% ------------------------------------------------------------------------
% Copyright (C) 2008-2010
% Bruce Bassett Yabebal Fantaye  Renee Hlozek  Jacques Kotze
%
%
%
% This file is part of Fisher4Cast.
%
% Fisher4Cast is free software: you can redistribute it and/or modify
% it under the terms of the Berkeley Software Distribution (BSD) license.
%
% Fisher4Cast is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% BSD license for more details.
% ------------------------------------------------------------------------
%
% This function numerically differentiates any function (func- specified with
% a function handle). 
% func = name of function = which is called as func(data, base)
% input.base = vector of fiducial model base values
% input.data = data vector you want derivatives for

% The code uses the complex-step numerical derivative algorithm by default (for reference see 
% http://www.kent.ac.uk/ims/personal/msr/Statappmsr.pdf), however a
% two-sided finite difference method is also included as an option, by
% changing the 'method' field to 'central'.

% It produces a matrix of derivatives of the function with repsect to the
% base parameters (assumed fiducial model)
% ------------------------------------------------------------------------
function numderiv = FM_num_deriv(func, data_vec, base_vec)
global input output base_orig base data
double all;

data = data_vec;
base_orig = base_vec;
base = base_vec;

h = 1e3*eps;

%We use the complex-step numerical derivative algorithm, for reference see 
%http://www.kent.ac.uk/ims/personal/msr/Statappmsr.pdf
method = 'complex'; %optionaly one can also use the 'central' algorithm

%Take the numerical derivative for each parameters specified in "base"
for i = 1:length(base) % loop over the cosmological parameters
    temp = base(i)-h;
    h = temp-base(i);    
    numderiv(:,i) = differ(func,h, i,method); 
    % save the colum vector in the matrix of derivatives to be used in
    % FM_run    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% This function g calculates the numerical derivative according to
% f'(x) = imag(f(x+h*i)/h) - the complex step numerical derivative
% or
% f'(x) = (f(x+h) - f(x-h))/2h; - the central double-sided finite
% difference method

function g = differ(func,step,ind,method)
global input output base_orig base data
base = base_orig;

if nargin<4
    method='complex';
end
switch method
    case 'central'
        %Check the value of the step size
        if step <sqrt(eps)
            step = sqrt(eps);
        end
        %Check representability of the step size
        steptemp = base(ind) + step;
        step = steptemp - base(ind);   
        
        base(ind) = base_orig(ind) + step;% increasing the base vector = x+h
        r = func(data, base); % calculating the function = f(x+h)
        base(ind) = base_orig(ind) - step;  % reducing the base vector = (x-h)
        l = func(data, base);% calculating the function = f(x-h)

        g = (r -l)/(2.*step);
    case 'complex'
        base(ind) = base_orig(ind) + step*i;
        g = imag(func(data, base)./step); % calculating the function at f(x+ih)
end

