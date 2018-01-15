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
%This function expects a matrix of fisher derivatives (fisher_deriv - of 
% form [no of params, no of data points])
% and a data covariance matrix, (data_cov - of form [no of data points, no of data
% points]). It also expects as a variable x the number of the matrix (i.e.
% observable index )to be calculated (ie for our example 1 = Hubble parameter, 2 = D_A)

% The output of this function is the individual Fisher matrix for the 
% required observable as a function of the cosmological parameters.

function f = FM_matrix(data_cov, deriv, x)
global input output;
double all;

v = deriv; % derivative matrix
C = data_cov; % covariance matrix
    
c = inv(C);% calculating the error term
f =  (v'*c)*v; % calculating the fisher derivative;


