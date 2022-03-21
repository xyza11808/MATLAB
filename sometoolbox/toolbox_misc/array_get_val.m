function y = array_get_val( x, ind )

% array_set_val - access a multidimensional array using a vector for the index
%
%   y = array_get_val( x, ind );
%
%   Copyright (c) 2004 Gabriel Peyr�

ind = num2cell(ind);
y = x( ind{:} );