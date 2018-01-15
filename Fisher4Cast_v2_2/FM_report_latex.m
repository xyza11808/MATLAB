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
%This function allows you to generate a latex report given the input
%which in turn calls FM_run to generate the associated output structure. 
%The latex report contains a summary of the inputs and outputs generated
%this also includes a figure of the error ellipse or likelihood produced.
%
%This is particularly useful for Latex syntax cut-and-paste inclusion of 
%data and figures produced from Fisher4Cast. Lending itself to rapid and 
%convenient use for publications.
%
%You can specify the input to be used and in addition also a name for the 
%report to be saved as (you can include a .tex extension or one will be 
%added by default). The name of the associated figure will be the same as 
%the report name, except an .eps extension will be used instead. If you 
%dont specify a report name a default name of 
%'Fisher4Cast_Report-Day-Month-Year.tex' will be used, where the 
%Day-Month-Year are the date the report was generated on. This applies for 
%the figure as well, 'Fisher4Cast_Report-Day-Month-Year.eps'.
%Example:
%
%>>FM_report_latex(input,'report_name')
%
%This will generate a report with the name, 'report_name.tex', and a figure 
%of 'report_name.eps' given in the example above. If the same report_name 
%is used, the previous report and figure will be overwritten without 
%warning. Please specify a unique report_name if you want to be sure the 
%report and figure are safely saved.
%
%There is an an additional option to use a specific figure. This assumes 
%that the figure is appropriate to the input used but is useful if the user
%has customised the figure in a specific way for inclusion into the report. 
%The respective output for the given input will
%be generated in this case. 
%Example:
%
%>>FM_report_latex(input,'report_name','use_fig')
%
%This will generate a report with the name, 'report_name.tex', and use an 
%existing figure called 'use_fig.eps' (the .eps extension can be included 
%or excluded since it will be searched for by default if not included).
%
%There is a further option that allows the use of the output structure 
%associated with the given input structure. This would also require the 
%name of an appropriate figure to be used in conjunction with the input 
%and output. This is used in the instance where the report is called from 
%the GUI since it results in faster performance. Care should be taken when 
%using this feature since one runs the risk of not generating a 
%representative report where the input, output and used figure are not 
%correctly related.
%Example:
%
%>>FM_report_latex(input,'report_name','use_figure',output)
%
%This generates a report as before with the name, 'report_name.tex', using
%a figure called 'use_figure.eps' where the output and figure are assumed
%to be associated with the respective input supplied.
%

function FM_report_latex(input,filename,use_fig,output)

%if no report name is given then default to the Fisher4Cast_Report with the
%current date appended
if nargin ==1
    close all;
    output = FM_run(input);
    filename = ['Fisher4Cast_Report' '-' date];
    filename_tex = [filename '.tex'];
    figure_name = [filename '.eps'];
    saveas(gcf,figure_name);        
elseif nargin ==2
    %check if the filename has a .tex extension or not
    [pathstr, fname, ext_file] = fileparts(filename);
    if ~strcmp(ext_file ,'.tex')
        %if no .tex extension is given, append it by default
        filename_tex = [filename '.tex'];
        %generate a figure name that is the same as the filename just with
        %an .eps extension 
        figure_name = [filename '.eps'];
    else
        filename_tex = filename;
        %generate a figure name that is the same as the filename just with
        %an .eps extension 
        figure_name = [fname '.eps'];
    end
    close all;
    output = FM_run(input);
    %the above command will produce a plot which can be captured and saved
    %for the report
    saveas(gcf,figure_name);
else
    %check if the filename has a .tex extension or not
    [pathstr, fname, ext_file] = fileparts(filename);
    if ~strcmp(ext_file ,'.tex')
        %if no .tex extension is given, append it by default
        filename_tex = [filename '.tex'];
    else
        filename_tex = filename;
    end
    %check if the use_fig has a .eps extension or not
    [pathstr, figname, ext_fig] = fileparts(use_fig);
    if ~strcmp(ext_fig ,'.eps')
        %if no .eps extension is given, append it by default
        figure_name = [use_fig '.eps'];
    else
        figure_name = use_fig;
    end
    if nargin ==3
        close all;
        output = FM_run(input);
    end
end
[pathstr_fig, figname, ext_fig] = fileparts(figure_name);

%generate a filename and open it for writing 
fid = fopen(filename_tex, 'wt');
% NOTE: There are currently no warnings about overwritting the same report 
% name

%--------------------------------------------------------------------------
% Begin writing to the report

% Define the class and packages to be used in the latex document
fprintf(fid, '\\documentclass[a4paper,10pt]{article}\n');
fprintf(fid, '\n');
fprintf(fid, '\\usepackage{graphicx,array,lscape}\n');


fprintf(fid, '\\begin{document}');
fprintf(fid, '\n');
fprintf(fid, '%%------------Title------------%%\n');
fprintf(fid, '\n');
% Include the logo of fisher4cast 
fprintf(fid, '\\begin{figure}[htb]');
fprintf(fid, '\n');
fprintf(fid, '\\centering');
fprintf(fid, '\n');
fprintf(fid, '\\includegraphics[height=20mm]{logo_fisher_4cast_out.eps}');
fprintf(fid, '\n');
fprintf(fid, '\\end{figure}');
fprintf(fid, '\n');
fprintf(fid, '\\begin{center}');
fprintf(fid, '\n');
%--------------------------------------------------------------------------
% Title for the report
fprintf(fid, '\\begin{Large}\\underline{\\textbf{Generated Report}}\\end{Large} \\date{today}');
fprintf(fid, '\n');
fprintf(fid, '\\end{center}');
fprintf(fid, '\n');
fprintf(fid, '\\vspace{1cm}');
fprintf(fid, '\n\n');
% Section to write the inputs to the report
fprintf(fid, '%%------------Input------------%%\n');
fprintf(fid, '\\section{Inputs}');
fprintf(fid, '\n');
fprintf(fid, '\\hrulefill');
fprintf(fid, '\n');
fprintf(fid, '\\vspace{1cm}');
fprintf(fid, '\n');
fprintf(fid, '\\noindent');
fprintf(fid, '\n\n');
% Table for base parameters
fprintf(fid, '\\textbf{Base Parameters}'); 
fprintf(fid, '\n');
fprintf(fid, '\\begin{center}');
fprintf(fid, '\n');
fprintf(fid, '\\begin{tabular}{|');
% Loop over the base parameters to dynamically generate the number of 
% columns needed for the table 
for k = 1:length(input.base_parameters)
    fprintf(fid, 'c|');
end
fprintf(fid, '}\n');
fprintf(fid, '\\hline');
fprintf(fid, '\n');
% Loop over the parameter names to input names into the top of each column 
% of the table
for j = 1:length(input.parameter_names)
    if j == length(input.parameter_names)
        fprintf(fid, '$%s$ \\\\', input.parameter_names{j});
    else
        fprintf(fid, '$%s$ &', input.parameter_names{j});
    end
end
fprintf(fid, '\n');
fprintf(fid, '\\hline');
fprintf(fid, '\n');
% Loop over base parameters to input the data into the table
for j = 1:length(input.base_parameters)
    if j == length(input.base_parameters)
        fprintf(fid, ' %6.2f \\\\', input.base_parameters(j));
    else
        fprintf(fid, ' %6.2f &', input.base_parameters(j));
    end
end
fprintf(fid, '\n');
fprintf(fid, '\\hline');
fprintf(fid, '\n');
fprintf(fid, '\\end{tabular}');
fprintf(fid, '\n');
fprintf(fid, '\\end{center}\n');
% end table 
fprintf(fid, '\n');
fprintf(fid, '\n');
% Generate array for Prior Matrix
fprintf(fid, '\\textbf{Prior Matrix}\n');
fprintf(fid, '\\begin{flushleft}\n');
fprintf(fid, '\\[ \\left[ \\begin{array}');
fprintf(fid, '{');
% Loop over prior matrix dimension to dynamically generate the number of 
% columns needed for an array
for k = 1:min(size((input.prior_matrix)))
    fprintf(fid, 'c');
end
fprintf(fid, '}\n');
% Loop to input the data into the array
for j = 1:length(input.prior_matrix)
    for i = 1:min(size(input.prior_matrix))
        if i==min(size(input.prior_matrix))
            fprintf(fid, '%6.2f ', input.prior_matrix(j,i));
        else
            fprintf(fid, '%6.2f &', input.prior_matrix(j,i));
        end
    end
    fprintf(fid, '\\\\ \n');
end
fprintf(fid, '\\end{array} \\right].\\]');
fprintf(fid, '\n');
fprintf(fid, '\\end{flushleft}\n');
% end array
fprintf(fid, '\n\n');
% Generate table for Parameters selected to be plotted 
fprintf(fid, '\\textbf{Parameters selected to be Plotted}\n');
fprintf(fid, '\\begin{center}');
fprintf(fid, '\n');
fprintf(fid, '\\begin{tabular}{|');
% Loop over parameters to plot to dynamically generate the number of 
% columns needed for an array
for k = 1:length(input.parameters_to_plot)
    fprintf(fid, 'c|');
end
fprintf(fid, '}\n');
fprintf(fid, '\\hline');
fprintf(fid, '\n');
% Loop over parameters to plot to input names into the top of each column 
% of the table
for j = [input.parameters_to_plot(1:end)]
    if j == input.parameters_to_plot(end)
        fprintf(fid, '$%s$ \\\\', input.parameter_names{j});
    else
        fprintf(fid, '$%s$ &', input.parameter_names{j});
    end
end
fprintf(fid, '\n');
fprintf(fid, '\\hline');
fprintf(fid, '\n');
fprintf(fid, '\\end{tabular}');
fprintf(fid, '\n');
fprintf(fid, '\\end{center}\n');
fprintf(fid, '\n');
fprintf(fid, '\n');

fprintf(fid, '\\textbf{Observables Selected}\n');
fprintf(fid, '\\begin{center}');
fprintf(fid, '\n');
fprintf(fid, '\\begin{tabular}{|');
% Loop over the observables to dynamically generate the number of columns 
% needed for a table
for k = 1:length(input.observable_index)
    fprintf(fid, 'c|');
end
fprintf(fid, '}\n');
fprintf(fid, '\\hline');
fprintf(fid, '\n');
% Loop over the observables to input names into the top of each column 
% of the table
for j = [input.observable_index(1:end)]
    if j == input.observable_index(end);
        fprintf(fid, '$%s$ \\\\', input.observable_names{j});
    else
        fprintf(fid, '$%s$ &', input.observable_names{j});
    end
end
fprintf(fid, '\n');
fprintf(fid, '\\hline');
fprintf(fid, '\n');
fprintf(fid, '\\end{tabular}');
fprintf(fid, '\n');
fprintf(fid, '\\end{center}\n');
fprintf(fid, '\n');
fprintf(fid, '\n');

fprintf(fid, '\\textbf{Redshift Data}\n');
fprintf(fid, '\\begin{center}');
fprintf(fid, '\n');
fprintf(fid, '\\begin{tabular}{|');
% Loop to dynamically generate the number of columns needed for a table
for k = 1:length(input.observable_index)
    fprintf(fid, 'c|');
end
fprintf(fid, '}\n');
fprintf(fid, '\\hline');
fprintf(fid, '\n');
% Loop to input names into the top of each column of the table
for i=[input.observable_index(1:end)]
    if i == input.observable_index(end);
        fprintf(fid, ' $%s$ \\\\ \n',input.observable_names{i});
    else
        fprintf(fid, ' $%s$ & ',input.observable_names{i});
    end
end
fprintf(fid, '\\hline');
fprintf(fid, '\n');
for c=[input.observable_index(1:end)]
    elements(c) = length(input.error{c});
end
for i=1:max(elements) % Loop over the data points
    j=input.observable_index(1);
    % Loop over the observables to list data in tabbed columns
    for j=[input.observable_index(1:end)];
        if j==input.observable_index(end);
            if i<=length(input.data{j})
                fprintf(fid, '%6.2f ',input.data{j}(i));
            elseif i>length(input.data{j})
                fprintf(fid, '   ');
            end
        else
            if i<=length(input.data{j})
                fprintf(fid, '%6.2f &\t ',input.data{j}(i));
            elseif i>length(input.data{j})
                fprintf(fid, '  &\t ');
            end
        end
    end
    fprintf(fid, '\\\\\n');
end
fprintf(fid, '\\hline');
fprintf(fid, '\n');
fprintf(fid, '\\end{tabular}');
fprintf(fid, '\n');
fprintf(fid, '\\end{center}');
fprintf(fid, '\n');
fprintf(fid, '\n\n');

fprintf(fid, '\\textbf{Fractional Errors on Redshift}\n');
fprintf(fid, '\\begin{center}');
fprintf(fid, '\n');
fprintf(fid, '\\begin{tabular}{|');
% Loop over the observables to dynamically generate the number of columns 
% needed for a table
for k = 1:length(input.observable_index)
    fprintf(fid, 'c|');
end
fprintf(fid, '}\n');
fprintf(fid, '\\hline');
fprintf(fid, '\n');
% Loop to input names into the top of each column of the table
for i=[input.observable_index(1:end)]
    if i==[input.observable_index(end)]
        fprintf(fid, ' $%s$ \\\\ \n',input.observable_names{i});
    else
        fprintf(fid, ' $%s$ & ',input.observable_names{i});
    end
end
fprintf(fid, '\\hline');
fprintf(fid, '\n');
for c=[input.observable_index(1:end)];
    elements(c) = length(input.error{c});
end
for i=1:max(elements)
    % Loop to input data into respective columns of table
    for j=[input.observable_index(1:end)]
        if j==[input.observable_index(end)]
            if i<=length(input.error{j})
                fprintf(fid, '%6.2f ',input.error{j}(i));
            elseif i>length(input.error{j})
                fprintf(fid, '   ');
            end
        else
            if i<=length(input.error{j})
                fprintf(fid, '%6.2f &\t ',input.error{j}(i));
            elseif i>length(input.error{j})
                fprintf(fid, '  &\t ');
            end
        end
    end
    fprintf(fid, '\\\\\n');
end
fprintf(fid, '\\hline');
fprintf(fid, '\n');
fprintf(fid, '\\end{tabular}');
fprintf(fid, '\n');
fprintf(fid, '\\end{center}');
fprintf(fid, '\n');
fprintf(fid, '\n\n');

fprintf(fid, '\\textbf{Growth is Normalised at a Reshift of}\n');
% List the redshift normalisation for growth
fprintf(fid, '%6.2f\n', input.growth_zn);
fprintf(fid, '\n\n');
%--------------------------------------------------------------------------
% Section for output format

fprintf(fid, '\\newpage');
fprintf(fid, '\n');
fprintf(fid, '%%------------Output------------%%\n');
fprintf(fid, '\n');
fprintf(fid, '\\section{Outputs}');
fprintf(fid, '\n');
fprintf(fid, '\\hrulefill');
fprintf(fid, '\n');
fprintf(fid, '\\vspace{1cm}');
fprintf(fid, '\n');
fprintf(fid, '\\noindent\n');
fprintf(fid, '\n\n');

fprintf(fid,'\\textbf{Function Values}\n');
fprintf(fid, '\\begin{center}');
fprintf(fid, '\n');
fprintf(fid, '\\begin{tabular}{|');
% Loop over the observables to dynamically generate the number of columns needed for a table
for k=1:length(input.observable_index)
    fprintf(fid, 'c|');
end
fprintf(fid, '}\n');
fprintf(fid, '\\hline');
fprintf(fid, '\n');
% Loop over the observables to input names into the top of each column 
% of the table
for i=[input.observable_index(1:end)]
    if i==input.observable_index(end)
        fprintf(fid, ' $%s$ \\\\ \n',input.observable_names{i});
    else
        fprintf(fid, ' $%s$ & ',input.observable_names{i});
    end
end
fprintf(fid, '\\hline');
fprintf(fid, '\n');
for c=[input.observable_index(1:end)]
    elements(c) = length(output.function_value{c});
end
for i=1:max(elements) % Loop over the data points
        for j=[input.observable_index(1:end)] % Loop over observables 
        if j==input.observable_index(end)
            if i<=length(output.function_value{j})
                fprintf(fid, '%6.2f ',output.function_value{j}(i));
            elseif i>length(output.function_value{j})
                fprintf(fid, '  ');
            end
        else
            if i<=length(output.function_value{j})
                fprintf(fid, '%6.2f &\t',output.function_value{j}(i));
            elseif i>length(output.function_value{j})
                fprintf(fid, '& \t');
            end
        end
    end
    fprintf(fid, '\\\\\n');
end
fprintf(fid, '\\hline');
fprintf(fid, '\n');
fprintf(fid, '\\end{tabular}');
fprintf(fid, '\n');
fprintf(fid, '\\end{center}');
fprintf(fid, '\n');
fprintf(fid, '\n\n');

fprintf(fid,'\\textbf{Fractional Errors on Observable}\n');
fprintf(fid, '\n\n');
for c=[input.observable_index(:)']
    fprintf(fid, '\\begin{flushleft}\n');
    % The name of the observable that an array will be generated for
    fprintf(fid, ' $%s$  = ', input.observable_names{c});
    fprintf(fid, '\\[ \\left[ \\begin{array}');
    fprintf(fid, '{');
    [rows columns] = size(output.function_derivative{c});
    %loop to dynamically generate the number of columns needed for an array
    for k = 1:columns%length(c)%min(size((output.function_derivative{c})))
        fprintf(fid, 'c');
    end
    fprintf(fid, '}\n');
    %loop to input data into respective columns of an array
    for j = 1:rows
        for i = 1:columns
            if i==columns
                fprintf(fid, '%6.2f ', output.function_derivative{c}(j,i));
            else
                fprintf(fid, '%6.2f &', output.function_derivative{c}(j,i));
            end
        end
        fprintf(fid, '\\\\ \n');
    end
    fprintf(fid, '\\end{array} \\right].\\]');
    fprintf(fid, '\n');
    fprintf(fid, '\\end{flushleft}\n');
    fprintf(fid, '\n\n');
end
fprintf(fid, '\n');
fprintf(fid, '\n');
fprintf(fid, '\n');

fprintf(fid,'\\begin{landscape}\n');
fprintf(fid,'\\setlength\\topmargin{2cm}\n');
fprintf(fid,'\\textbf{Data Covariance Matrix}\n');
for c=[input.observable_index(1:end)]
    fprintf(fid, '\\begin{flushleft}\n');
    % The name of the observable that an array will be generated for
    fprintf(fid, ' $%s$  = ', input.observable_names{c});
    fprintf(fid, '\\[ \\left[ \\begin{array}');
    fprintf(fid, '{');
    %loop to dynamically generate the number of columns needed for an array
    for k = 1:min(size((output.data_covariance{c})))
        fprintf(fid, 'c');
    end
    fprintf(fid, '}\n');
    %loop to input data into respective columns of an array
    for j = 1:length(output.data_covariance{c})
        for i = 1:min(size(output.data_covariance{c}))
            if i==min(size(output.data_covariance{c}))
                fprintf(fid, '%6.2f ', output.data_covariance{c}(j,i));
            else
                fprintf(fid, '%6.2f &', output.data_covariance{c}(j,i));
            end
        end
        fprintf(fid, '\\\\ \n');
    end
    fprintf(fid, '\\end{array} \\right].\\]');
    fprintf(fid, '\n');
    fprintf(fid, '\\end{flushleft}\n');
    fprintf(fid, '\n\n');
end
fprintf(fid,'\\end{landscape}\n');
fprintf(fid,'\\setlength\\topmargin{0.5cm}\n');

fprintf(fid,'\\textbf{Individual Fisher Matrices}');
for c=[input.observable_index(1:end)]
    fprintf(fid, '\n');
    fprintf(fid, '\\begin{flushleft}\n');
    %The name of the observable that a table will be generated for 
    fprintf(fid, ' $%s$  = ', input.observable_names{c});
    fprintf(fid, '\\[ \\left[ \\begin{array}');
    fprintf(fid, '{');
    %loop to dynamically generate the number of columns needed for an array
    for k = 1:min(size((output.matrix{c})))
        fprintf(fid, 'c');
    end
    fprintf(fid, '}\n');
    %loop to input data into respective columns of an array
    for j = 1:length(output.matrix{c})
        for i = 1:min(size(output.matrix{c}))
            if i==min(size(output.matrix{c}))
                fprintf(fid, '%6.2f ', output.matrix{c}(j,i));
            else
                fprintf(fid, '%6.2f &', output.matrix{c}(j,i));
            end
        end
        fprintf(fid, '\\\\ \n');
    end
    fprintf(fid, '\\end{array} \\right].\\]');
    fprintf(fid, '\n');
    fprintf(fid, '\\end{flushleft}');
    fprintf(fid, '\n\n');
end
fprintf(fid, '\n');

fprintf(fid,'\\textbf{Summed Fisher Matrix}\n');
fprintf(fid, '\\begin{flushleft}\n');
fprintf(fid, '\\[ \\left[ \\begin{array}');
fprintf(fid, '{');
% Loop over the matrix dimension to dynamically generate the number of 
% columns needed for an array
for k = 1:min(size((output.summed_matrix)))
    fprintf(fid, 'c');
end
fprintf(fid, '}\n');
% Loop over the matrix to input data into respective columns of array
for j = 1:length(output.summed_matrix)
    for i = 1:min(size(output.summed_matrix))
        if i==min(size(output.summed_matrix))
            fprintf(fid, '%6.2f ', output.summed_matrix(j,i));
        else
            fprintf(fid, '%6.2f &', output.summed_matrix(j,i));
        end
    end
    fprintf(fid, '\\\\ \n');
end
fprintf(fid, '\\end{array} \\right].\\]');
fprintf(fid, '\n');
fprintf(fid, '\\end{flushleft}\n');
fprintf(fid, '\n\n');

fprintf(fid,'\\textbf{Marginalised Fisher Matrix}\n');
fprintf(fid, '\\begin{flushleft}\n');
fprintf(fid, '\\[ \\left[ \\begin{array}');
fprintf(fid, '{');
% Loop over the matrix dimension to dynamically generate the number of 
% columns needed for an array

for k = 1:min(size((output.marginalised_matrix)))
    fprintf(fid, 'c');
end
fprintf(fid, '}\n');
% Loop over the matrix to input data into respective columns of array
for j = 1:length(output.marginalised_matrix)
    for i = 1:min(size(output.marginalised_matrix))
        if i==min(size(output.marginalised_matrix))
            fprintf(fid, '%6.2f ', output.marginalised_matrix(j,i));
        else
            fprintf(fid, '%6.2f &', output.marginalised_matrix(j,i));
        end
    end
    fprintf(fid, '\\\\ \n');
end
fprintf(fid, '\\end{array} \\right].\\]');
fprintf(fid, '\n');
fprintf(fid, '\\end{flushleft}\n');
fprintf(fid, '\n\n');

fprintf(fid,'\\textbf{Figures of Merit}\n');
fprintf(fid, '\\begin{center}');
fprintf(fid, '\n');
fprintf(fid, '\\begin{tabular}{|');
% Loop over the size of FOM vector to dynamically generate the number of 
% columns needed for a table
for k = 1:length(output.fom)
    fprintf(fid, 'c|');
end
fprintf(fid, '}\n');
fprintf(fid, '\\hline');
fprintf(fid, '\n');
% Loop over the FOM vector to input data into respective columns of table
for j = 1:length(output.fom)
    if j == length(output.fom)
        fprintf(fid, ' %6.2f \\\\', output.fom(j));
    else
        fprintf(fid, ' %6.2f &', output.fom(j));
    end
end
fprintf(fid, '\n');
fprintf(fid, '\\hline');
fprintf(fid, '\n');
fprintf(fid, '\\end{tabular}');
fprintf(fid, '\n');
fprintf(fid, '\\end{center}');
fprintf(fid, '\n');
fprintf(fid, '\n');

%Include the selected figure into latex includegraphics
fprintf(fid,'\\begin{figure}');
fprintf(fid, '\n');
fprintf(fid, '\\centering');
fprintf(fid, '\n');
fprintf(fid, '\\includegraphics[width = 0.7\\textwidth]{');
fprintf(fid, '%s}',[figname ext_fig]);
fprintf(fid, '%% The path the figure was saved in is given by %s',pathstr_fig);
fprintf(fid, '\n');
fprintf(fid, '\\caption{A generated Fisher Ellipse.}');
fprintf(fid, '\n');
fprintf(fid, '\\label{fig:');
fprintf(fid, '%s}',figname);
fprintf(fid, '\n');
fprintf(fid, '\\end{figure}');
fprintf(fid, '\n');
fprintf(fid, '\\end{document}'); % end the latex report

fclose(fid);   %close the filename
