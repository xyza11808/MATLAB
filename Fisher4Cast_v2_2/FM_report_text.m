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
%This function allows you to generate a text report given the input
%which in turn calls FM_run to generate the associated output structure. 
%The text report contains a summary of the inputs and outputs generated.
%
%This is useful since one can then at a glance review all input and outputs
%used. The user can also use this tabulated data to cut-and paste results 
%into reports or it can be used to generate additional plots.
%
%You can specify the input to be used and in addition also a name for the 
%report to be saved as (you can include a .txt extension or one will be 
%added by default). If you dont give a report name a default name of 
%'Fisher4Cast_Report-Day-Month-Year.txt' will be used, where the 
%Day-Month-Year are the date the report was generated on.
%Example:
%
%>>FM_report_text(input,'report_name')
%
%This will generate a report with the name, 'report_name.txt', 
%given in the example above. If the same report_name is used, the
%previous report will be overwritten without warning. Please specify a unique
%report_name if you want to be sure the report is safely saved. 
%
%Lastly there is an option of including the output structure as an input 
%into the function. This is used in the instance where the report is called
%from the GUI since it results in better performance. Care should be taken 
%when using this feature since one runs the risk of generating a report 
%where the input and output are not appropriately related.
%Example:
%
%>>FM_report_text(input,'report_name',output)
%
%This generates a report as before with the name, 'report_name.txt', using
%the input supplied and assuming that the given output is associated with the 
%respective input.

function FM_report_text(input,name,output)

%If no report name is given then default to the Fisher4Cast_Report
if nargin ==1
    output = FM_run(input);
    name = 'Fisher4Cast_Report';
    filename = [name '-' date '.txt'];
else
    %check if given filename has a .txt extension
    [pathstr, fname, ext_file] = fileparts(name);
    if ~strcmp(ext_file ,'.txt')
        %if no .txt extension is given, append it by default
        filename = [name '.txt'];
    else
        filename = name;
    end
    if nargin ==2
        output = FM_run(input);
    end
end
%Generate a filename and open it for writing 
fid = fopen(filename, 'wt');
%NOTE: There are currently no warnings about overwritting the same report
%name

%--------------------------------------------------------------------------
%Title for the report

fprintf(fid, '-----------------------------------------------------------------------------------------\n');
fprintf(fid, '                                   Fisher4Cast Report                                    \n');
fprintf(fid, '-----------------------------------------------------------------------------------------\n\n');

% Section to write the inputs to the report
fprintf(fid, '------------------------------------------Input------------------------------------------\n\n\n');


fprintf(fid, 'Base Parameters =\n');
%Define a list of the parameter names that will be at the top of tabbed columns
fprintf(fid, ' [%s]\t',input.parameter_names{:});
fprintf(fid, '\n');
%List parameter data in tabbed columns
fprintf(fid, '%6.2f\t',input.base_parameters(:)); 
fprintf(fid, '\n\n\n');

fprintf(fid, 'Prior Matrix = \n');
%Loop over the number of parameters to list parameter data in columns
for j = 1:length(input.prior_matrix)
        for i = 1:min(size(input.prior_matrix))
            fprintf(fid, ' %6.2f ', input.prior_matrix(j,i));
        end
        fprintf(fid, '\n');
end
fprintf(fid, '\n\n');

fprintf(fid, 'Parameters selected to be Plotted = \n');
param_to_plot = {input.parameter_names{input.parameters_to_plot(:)}};
% Column  with the parameters of interest to be plotted
fprintf(fid, ' [%s]\t', param_to_plot{:}); 
fprintf(fid, '\n\n\n');

fprintf(fid, 'Observables Selected =\n');
% Tabbed column with the names of the observables considered
fprintf(fid, ' [%s]\t',input.observable_names{input.observable_index(:)}); 
fprintf(fid, '\n\n\n');

fprintf(fid, 'Redshift Data =\n');
%list of names at the top of tabbed columns
fprintf(fid, ' [%s]\t ',input.observable_names{input.observable_index(1:end)});
fprintf(fid, '\n');
for c=[input.observable_index(1:end)]%length(input.observable_names)
    elements(c) = length(input.data{c});
end
% The data points at which the observable are listed
for i=1:max(elements) % Loop over the data points to plot all the rows
    j=input.observable_index(1);
    % Loop over the observables themselves
    for j=[input.observable_index(1:end)];
        if j==input.observable_index(end);
            if i<=length(input.data{j})
                fprintf(fid, '%6.2f ',input.data{j}(i));
            elseif i>length(input.data{j})
                fprintf(fid, '  ');
            end
        else
            if i<=length(input.data{j})
                fprintf(fid, '%6.2f\t ',input.data{j}(i));
            elseif i>length(input.data{j})
                fprintf(fid, '\t ');
            end
        end
    end
    fprintf(fid, '\n');
end
fprintf(fid, '\n\n');

fprintf(fid, 'Fractional Errors on Observable =\n');
% List of the errors
fprintf(fid, ' [%s]\t ',input.observable_names{input.observable_index(1:end)});
fprintf(fid, '\n');
for c=[input.observable_index(1:end)];
    elements(c) = length(input.error{c});
end
% The error vector for all data
for i=1:max(elements)
    % Loop over the data points
    for j=[input.observable_index(1:end)]
        % Loop over observables
        if j==[input.observable_index(end)]
            if i<=length(input.error{j})
                fprintf(fid, '%6.2f ',input.error{j}(i));
            elseif i>length(input.error{j})
                fprintf(fid, '  ');
            end
        else
            if i<=length(input.error{j})
                fprintf(fid, '%6.2f\t ',input.error{j}(i));
            elseif i>length(input.error{j})
                fprintf(fid, '\t ');
            end
        end
    end
    fprintf(fid, '\n');
end
fprintf(fid, '\n\n');

fprintf(fid, 'Growth is Normalised at a Reshift of = \n');
fprintf(fid, '%6.2f\n', input.growth_zn);
fprintf(fid, '\n\n');

fprintf(fid, 'Derivative Type = \n');
% Check box to see if derivative of interest is analytically or numerically calculated
for i=[input.observable_index(1:end)]   
    fprintf(fid, ' [%s] is being evaluated', input.observable_names{i});
    if input.numderiv.flag{i}==0
        derivative_type = 'Analytically';
        function_used = input.function_names{i};
    elseif input.numderiv.flag{i}==1
        derivative_type = 'Numerically';
        function_used = input.numderiv.f{i};
    end
    fprintf(fid, ' %s ', derivative_type);
    fprintf(fid, 'with function %s\n', function_used);
end
fprintf(fid, '\n\n');

%--------------------------------------------------------------------------
% Section for output format
fprintf(fid, '------------------------------------------Output-----------------------------------------\n\n\n');


fprintf(fid,'Function Value = \n');
% Listing the function value evaluated at the data points
fprintf(fid, ' [%s]\t ',input.observable_names{input.observable_index(1:end)});
fprintf(fid, '\n');
for c=[input.observable_index(1:end)]
    elements(c) = length(output.function_value{c});
end
for i=1:max(elements) %Loop over data points 
    for j=[input.observable_index(1:end)] 
        if j==input.observable_index(end) % Loop over observables
            if i<=length(output.function_value{j})
                fprintf(fid, '%6.2f ',output.function_value{j}(i));
            elseif i>length(output.function_value{j})
                fprintf(fid, ' ');
            end
        else
            if i<=length(output.function_value{j})
                fprintf(fid, '%6.2f\t',output.function_value{j}(i));
            elseif i>length(output.function_value{j})
                fprintf(fid, '\t');
            end
        end
    end
    fprintf(fid, '\n');
end
fprintf(fid, '\n\n');

fprintf(fid,'Fisher Derivatives of Function = \n');
%Loop to generate a series of tables
for c=[input.observable_index(1:end)]
    % The name of the observable that table will be generated for 
    fprintf(fid, ' [%s]\n', input.observable_names{c});
    %loop to list data in columns
    [rows columns] = size(output.function_derivative{c});
    for j = 1:rows %length(output.function_derivative{c})
        for i = 1:columns %min(size(output.function_derivative{c}))
            fprintf(fid, ' %6.2f ', output.function_derivative{c}(j,i));
        end
        fprintf(fid, '\n');
    end
    fprintf(fid, '\n');
end
fprintf(fid, '\n');

fprintf(fid,'Data Covariance Matrix = \n');
%Loop to generate a series of tables
for c=[input.observable_index(1:end)]
    % The name of the observable that covariance matrix will be generated for 
    fprintf(fid, ' [%s]\n', input.observable_names{c});
    %loop to list data in columns
    for j = 1:length(output.data_covariance{c})
        for i = 1:min(size(output.data_covariance{c}))
            fprintf(fid, '%6.2f ', output.data_covariance{c}(j,i));
        end
        fprintf(fid, '\n');
    end
    fprintf(fid, '\n');
end
fprintf(fid, '\n');

fprintf(fid,'Individual Fisher Matrices = \n');
%Loop to generate a series of tables
for c=[input.observable_index(1:end)]
    %The name of the observable that table will be generated for
    fprintf(fid, ' [%s]\n', input.observable_names{c});
    %loop to list data in columns
    for j = 1:length(output.matrix{c})
        for i = 1:min(size(output.matrix{c}))
            fprintf(fid, '%6.2f ', output.matrix{c}(j,i));
        end
        fprintf(fid, '\n');
    end
    fprintf(fid, '\n');
end
fprintf(fid, '\n');

fprintf(fid,'Summed Fisher Matrix = \n');
% Loop over observables for the the Fisher matrix
for j = 1:length(output.summed_matrix)
        for i = 1:min(size(output.summed_matrix))
            fprintf(fid, ' %6.2f ', output.summed_matrix(j,i));
        end
        fprintf(fid, '\n');
end
fprintf(fid, '\n\n');

fprintf(fid,'Marginalised Fisher Matrix = \n');
% Loop over parameters of interest for the marginalised matrix
for j = 1:length(output.marginalised_matrix)
        for i = 1:min(size(output.marginalised_matrix))
            fprintf(fid, ' %6.2f ', output.marginalised_matrix(j,i));
        end
        fprintf(fid, '\n');
end
fprintf(fid, '\n\n');

fprintf(fid,'Figures of Merit = \n');
% Looping over the individual Figures of Merit
fprintf(fid, '%6.2f\t', output.fom);

%close filename
fclose(fid); 
%End the text report
