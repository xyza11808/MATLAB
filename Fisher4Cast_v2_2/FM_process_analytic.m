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
% This function calculates the analytical derivatives. 
% It takes as input the index of the observable of interest and produces a
% matrix of fisher derivatives (deriv) and a column vector of the
% observable itself calculated at the data points
% ------------------------------------------------------------------------
function [deriv, val] = FM_process_analytic(x)
global input output z_n flag;

fun_name = input.function_names{x};

if isfield(input,'growth_zn')
    z_n = input.growth_zn;
end
if isfield(input,'growth_zn_flag')
    flag = input.growth_zn_flag;
end

if iscell(input.data)
    [deriv, val] = eval(sprintf([fun_name,'(input.data{ %0.5g }, input.base_parameters)'],x));
                    % calling the fisher derivative file for this observable -
                    % it assumes the analytical derivative files are given as
                    % FM_analytical_deriv_i.m where i is the index of the
                    % observable
elseif isvector(input.data)
        [deriv, val] = eval(sprintf([fun_name,'(input.data, input.base_parameters)']));
                    % calling the fisher derivative file for this observable -
                    % it assumes the analytical derivative files are given
                    % as FM_analytical_deriv_i.m where i is the index of the
                    % observable
else
    error('data is not defined in proper format (cell or array)')
end
                
