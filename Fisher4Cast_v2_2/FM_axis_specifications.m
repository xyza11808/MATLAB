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
% This function sets the axis_spec structure according to your preference;
%It is called inside the FM_plot_ellipse function.

function FM_axis_specifications
global input axis_spec;

%--------------------------------------------------------------------------
%=======  Axis control commands  ================

%set the x and y limit

if isfield(input,'xlim_val') 
    xlim(input.xlim_val);
end
if isfield(input,'ylim_val')
    ylim(input.ylim_val);
end

%=========================
% Add title name based on the input.observable_names

title_name = ''; %space 
for i = 1:input.num_observables
    if i>1
        title_name = horzcat(title_name,', ',input.observable_names{input.observable_index(i)});
        title_name =horzcat(title_name, '(z)');   % adding names to the title
    else
        title_name = horzcat(title_name,' ',input.observable_names{input.observable_index(i)});
        title_name =horzcat(title_name, '(z)');   % adding names to the title
    end
end

%set x and y label
if input.num_parameters==1
    axis_spec.xlabel = (input.parameter_names(input.parameters_to_plot(1))); % Axis labels
    axis_spec.ylabel = {'Normalised Likelihood'};
    % Title label
    string = horzcat('Likelihood of Observables: ');
    axis_spec.title = {string,char(title_name)} ; 
else 
	axis_spec.xlabel = (input.parameter_names(input.parameters_to_plot(1))); % Axis labels
    axis_spec.ylabel = (input.parameter_names(input.parameters_to_plot(2)));
    axis_spec.title = {'Fisher Error Ellipse for Observables:'; char(title_name)} ; % Title label
end


xlabel(axis_spec.xlabel, 'FontWeight', 'bold' )
ylabel(axis_spec.ylabel, 'FontWeight', 'bold')
title(axis_spec.title,'FontWeight', 'bold')

%Axis Format
axis auto
box on
grid on

%--------------------------------------------------------------------------
