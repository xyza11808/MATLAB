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
% This function is intended to plot the absolute value of the first 
% Principle Components (PC's) as a function of redshift bins. The input 
% variable PC_all is usually passed from the output structure with field 
% name PC_all generated from EXT_fomswg. This is a 36x37 matrix with the 
% first column being used for the redshifts and the second listing the 
% PC's. The second input variable is optional and specifies the linestyle 
% and linecolor. 
function EXT_fomswg_plot_ellipse(Marg_F,ellipse_color, ellipse_linestyle)
global plot_spec;
%set plot_spec data
EXT_fomswg_plot_specifications;
%error messages if there is no input
if nargin==0
    errordlg('No input variable was specified. Please supply the Marginalised Fisher Matrix as an input'); 
    return;
%if only one variable is passed then set the default linecolor and linestyle 
elseif nargin==3
    plot_spec.linecolor = ellipse_color;
    plot_spec.linestyle = ellipse_linestyle;
 end
%plot data
FM_plot_ellipse(Marg_F);
grid on;
%label axes and give title
xlabel('w_0','FontWeight', 'bold');
ylabel('w_a','FontWeight', 'bold');
title('Error Ellipse Generated from FoMSWG EXT','FontWeight', 'bold');
