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
% FM_generate_ellipse takes as input two veraibles 
%  * fun - the 2D matrix you wish to plot - if not specified this will take
%  the input.marginalised matrix as the matrix to plot.
%  * lc - line colour.
% It calls FM_plot_specifications to load the structure for all the 
% relevant plot specifications and FM_plot_ellipse to finally plot the ellipse.


function FM_generate_plot(fun,lc)
global input output plot_spec;


FM_plot_specifications;

if nargin==2
    plot_spec.linecolor = lc;
end

x = input.parameters_to_plot;

if length(input.parameters_to_plot)==1
    FM_plot_likelihood;
else
    if nargin==0
        FM_plot_ellipse;
    else
        FM_plot_ellipse(fun);
    end
end
FM_axis_specifications;
