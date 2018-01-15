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
% This function checks to see if the user has specified their own data
% covariance matrix, or if they have only given a variance vector, in which
% case it calculates the data covariance matrix

function data_cov_mat = FM_covariance(func_val,x)
global input output

s = size(input.error{x});
s1 = s(1); % the number of rows of the input variance matrix
s2 = s(2); % the number of columns of the input variance matrix

if length(input.error{x})==1    
    data_cov_mat = diag(input.error{x}.*(func_val)).^2; % calculating covariance matrix    
else    
    if s1==s2 % the user-defined data covariance is a matrix
        data_cov_mat = input.error{x}.^2; % take as data covariance the user matrix    
    elseif (s1==1)||(s2 ==1) % check that the inputs are vectors
        data_cov_mat = diag(input.error{x}(:).*(func_val(:))).^2; % calculating covariance matrix
    else display('Error: neither a vector nor square data covariance matrix - please check' )
    end
end

   

        
