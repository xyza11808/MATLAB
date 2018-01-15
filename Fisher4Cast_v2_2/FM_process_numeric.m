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
% This function calculates the numerical derivatives for the functions
% whose names are specified in the input.numderiv.f{i} entries in the input
% strucure and produces a matrix of fisher derivatives (deriv) and a column vector of the
% observable itself calculated at the data points.
%
% It calls FM_num_deriv which performs the numerical differentiation on the
% function specified by the function handle (fhandle).
% ------------------------------------------------------------------------

function [derivative, func_val] = FM_process_numeric(x)
global input z_n flag;

if isfield(input,'growth_zn')
    z_n = input.growth_zn;
end
if isfield(input,'growth_zn_flag')
    flag = input.growth_zn_flag;
end
fhandle = str2func(input.numderiv.f{x});
        % the function handle that you will pass to the numerical derivative code

        
if iscell(input.data)   
    func_val = (fhandle(input.data{x}, input.base_parameters)); % saving the actual value of the function
        % calling the function itself to get the observable evaluated at
        % the data points.
    derivative = FM_num_deriv(fhandle, input.data{x}, input.base_parameters);
        % the output of the numerical fisher deriv - this can now be used
        % in the usual way

elseif isvector(input.data)
        func_val = (fhandle(input.data, input.base_parameters)); % saving the actual value of the function
        % calling the function itself to get the observable evaluated at
        % the data points.
        derivative = FM_num_deriv(fhandle, input.data, input.base_parameters);
        % the output of the numerical fisher deriv - this can now be used
        % in the usual way
else
        error('data is not defined in proper format (cell or array)')
end
