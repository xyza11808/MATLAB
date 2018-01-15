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
% This function sums the individual Fisher matrices that have been saved to
% the global output structure (hence it takes no input).
% It then produces a complete Fisher matrix (summed_matrix) which it
% returns as output.
% ------------------------------------------------------------------------
function summed_matrix = FM_sum
double all;
global input output;
summed_matrix = input.prior_matrix;  % instead of initialising the total fisher matrix to zeros, we can take the prior
                          % matrix as the initial matrix - onto which we sum the individual fisher
                          % matrices

for i = 1:input.num_observables   % loop over the obserables to be considered as specified in the input structure
    x = input.observable_index(i); 
    summed_matrix = summed_matrix + output.matrix{x};
end
