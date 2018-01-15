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


function FM_plot_likelihood(plot_param_specs)
global input output plot_spec


if nargin ==0
  FM_plot_specifications;
else
  plot_spec = plot_param_specs;  
end
 
x = input.parameters_to_plot;
sigma = output.fom;
center = input.base_parameters(x);
range = sigma*4;
top = center+range;
bottom = center - range;
res = 500;
step = range/res;
x = [bottom:step:top];
y = exp(-(x-center).^2/(2.*sigma.^2)); 
y_0 = max(y); 
y_norm = y;
plot(x,y_norm, 'color', plot_spec.linecolor, 'linestyle',plot_spec.linestyle,'LineWidth', plot_spec.line_width);

onesigp = (center + 1.*sigma);
onesign= (center-1.*sigma);
twosigp = (center + 2.*sigma)';
twosign= (center-2.*sigma);
threesigp = (center+3.*sigma);
threesign = (center-3.*sigma);

osn = y_norm(find(abs(x-onesign)< step./2));
osp = y_norm(find(abs(x-onesigp)< step./2));
tsn = y_norm(find(abs(x-twosign)< step./2));
tsp = y_norm(find(abs(x-twosigp)< step./2));
thsn = y_norm(find(abs(x-threesign)< step./2));
thsp = y_norm(find(abs(x-threesigp)< step./2));

onesigny = 0:0.001:osn;
onesigpy = 0:0.001:osp;
twosigny = 0:0.001:tsn;
twosigpy = 0:0.001:tsp;
threesigny=0:0.001:thsn;
threesigpy=0:0.001:thsp;

hold on
centery = 0:0.1:1;
plot(center.*ones(length(centery),1), centery, 'Color',plot_spec.sigma_linecolor , 'LineWidth', plot_spec.line_width);


if plot_spec.sigma_level ==2.31
    plot(onesign.*ones(length(onesigny),1), onesigny, 'Color',plot_spec.sigma_linecolor , 'LineWidth', plot_spec.line_width);
    hold on
    plot(onesigp.*ones(length(onesigpy),1), onesigpy, 'Color', plot_spec.sigma_linecolor , 'LineWidth', plot_spec.line_width );
elseif plot_spec.sigma_level == 6.17
    plot(twosign.*ones(length(twosigny),1), twosigny, 'Color', plot_spec.sigma_linecolor , 'LineWidth', plot_spec.line_width);
    hold on
    plot(twosigp.*ones(length(twosigpy),1), twosigpy, 'Color',plot_spec.sigma_linecolor , 'LineWidth', plot_spec.line_width);
else
    plot(threesign.*ones(length(threesigny),1), threesigny, 'Color',plot_spec.sigma_linecolor , 'LineWidth', plot_spec.line_width);
    hold on
    plot(threesigp.*ones(length(threesigpy),1), threesigpy, 'Color',plot_spec.sigma_linecolor , 'LineWidth', plot_spec.line_width);
end     

hold off
