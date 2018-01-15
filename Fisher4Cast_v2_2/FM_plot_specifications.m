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
% This function sets the plot_spec structure according to what you want for
% the error ellipses. It is called inside the FM_plot_ellipse function.
% ------------------------------------------------------------------------
function FM_plot_specifications
global input plot_spec tacklebox;

% Flags for producing plots of the derivatives 

plot_spec.derivs(1) = 0;
plot_spec.derivs(2) = 0;
plot_spec.derivs(3) = 0;

%------------------------------------------------------------------------

plot_spec.center_ellipse = input.base_parameters(input.parameters_to_plot); 
        % where will the error ellipse be centered
plot_spec.resolution = 10; % the resolution of the ellipse

plot_spec.sb = 1000; % the mesh grid parameter

%--------------------------------------------------------------------
%============ confidence interval control ===========

%confidence level definition

if isfield(input,'CL_value')
    plot_spec.sigma_level = input.CL_value; % the confidence level you want
else
    plot_spec.sigma_level = 2.31;  %default confidence interval
end

%------------------------------------------------------------------------
%================ line format control ============================

%set line color, line style and fill color as defined

if isfield(input,'line_color')
    plot_spec.linecolor = input.line_color; % the colour of the ellipse    
else
    map = colormap('lines');
    if ishold==1
        indx = floor(1+rand.*length(map)); 
        plot_spec.linecolor = map(indx,:); 
    else 
        plot_spec.linecolor = map(1,:);
    end  
end

plot_spec.sigma_linecolor = [1 0 0];

%line style definition
if isfield(input,'line_style')    
    plot_spec.linestyle = input.line_style; %line style of the ellipse
else    
    plot_spec.linestyle = '-'; %default line style of the ellipse
end

%===============

%set plot_spec to reflect if the ellipse should be filled with a colour
if ~isfield(input,'fill_flag')%if the fill_flag does not exist in the input structure, 
    %make sure it is created and set to zero 
    input.fill_flag = 0;
end
%plot_spec is given the flag from the input structure
plot_spec.fill_flag = input.fill_flag;


%fill color (the ellipse) definition
if isfield(input,'c_fill')
    plot_spec.fill_color = input.c_fill;
else
    plot_spec.fill_color = 'w'; %default fill color
end


plot_spec.line_width = 1.0; % default line thickness
