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
% This function plots error ellipses using the matrix defined in the global
% output structure. It also uses the plot_spec function to define
% specifications like the confidence level of the plot and the centre of
% the ellipse etc. It uses the matlab function contour.m
% ------------------------------------------------------------------------
function FM_plot_ellipse(marginalized_matrix)

global input output plot_spec;
if nargin == 0
    F = output.marginalised_matrix;
else
    F = marginalized_matrix;
end
if isstruct(plot_spec)
    m = plot_spec.resolution;%the steps in the grid
    c = plot_spec.center_ellipse; % the fiducial model around which you calculate errors

    sB = plot_spec.sb; % the range of the grid
    x = (-sB:1/m:sB)';
else
    m = 1000;
    c = [0,0];
    x = (-10:1/m:10)';
    plot_spec.linecolor = 'r';
    plot_spec.linestyle = '-';
    plot_spec.sigma_level = 2.32;
end
 
%An ellipse equation is given by : coef_y2*y^2 + coef_y*y + coef_con = CE
%where CE is confidence interval   

[xy_pos,xy_neg,x_new] = ellipse_soln(F,c,x,plot_spec);

%calculate new xy_pos and xy_neg solution for the new x vector
if ~isempty(x_new)
    
    
    [xy_pos, xy_neg, x] = ellipse_soln(F,c,x_new,plot_spec);

    %Need to rotate the one matrix, either xy_pos or xy_neg, by 180 degree to
    %head to tail connection plot
    length_pos = size(xy_pos,1);
    xy_pos_rot = xy_pos(length_pos-1:-1:1,:); %rotate the xy_pos matrix. Rotating xy_neg works as well

    if isempty(xy_neg)
        xy_data = xy_pos_rot;
    elseif isempty(xy_pos)
        xy_data = xy_neg;
    else
        xy_data = [xy_neg(end-1,:);xy_pos_rot;xy_neg(1:end-1,:)]; %adding the end values in the beggning
    end
    
    %plot the xy data points
    if plot_spec.fill_flag == 0 %check to see if the fill_flag is set. This is always initialised in the FM_plot_specifications.m file
        %if it is zero, there is no need to try an plot using the patch
        %command since no fill of the ellipse is needed
        plot(xy_data(:,1),xy_data(:,2),'color',plot_spec.linecolor,'Linestyle',plot_spec.linestyle,'LineWidth', plot_spec.line_width);    
    else
        %the ellipse is chosen to be filled with color
        if ishold           
            p_h = patch(xy_data(:,1),xy_data(:,2),plot_spec.fill_color,...
                'AlphaDataMapping','scaled',...
                'AlphaData','none',...
                'EdgeColor',plot_spec.linecolor, 'LineWidth', plot_spec.line_width);
        else        
            cla reset
            patch(xy_data(:,1),xy_data(:,2),plot_spec.fill_color,'EdgeColor',plot_spec.linecolor,'LineWidth', plot_spec.line_width)
        end
    end    
    
else    
    msgbox('The selected combination of parameters does not form an error ellipse for the supplied input data. Please check output.marginalised_matrix or try a different set of observations.')
end    

%====================================================================
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function [xy_pos, xy_neg, x_new] = ellipse_soln(F,c,x_val,plot_spec)
%An ellipse equation is given by : coef_y2*y^2 + coef_y*y + coef_con = CE
%where CE is confidence interval

x = x_val(:);

coef_y2 = F(2,2);  %y^2 coefficient  
coef_y = F(1,2).*(x-c(1)) + F(2,1).*(x-c(1))- 2.*c(2).*F(2,2) ; %y coefficient 
coef_con = c(2)^2.*F(2,2) + c(2)*c(1)*F(2,1) + c(1)*c(2)*F(1,2)...
         + F(1,1).*(x - c(1)).^2 - c(2).*F(2,1).*x - c(2).*F(1,2).*x - plot_spec.sigma_level;
       
% coef_con = F(1,1).*(x.^2 - 2.*c(1).*x + c(1)^2) + 2.*F(1,2).*c(1).*c(2) - ...
%            2.*F(1,2).*c(2).*x + F(2,2).*c(2)^2 - plot_spec.sigma_level;

%solution of a quadratic equation of the form ay^2+ by + c = 0 is
%y = (-b +/- sqrt(b^2 - 4ac))/2a. We can write the positive and 
%negative solution of the above ellipse equation as follows

ysol_pos = (-coef_y + sqrt(coef_y.^2 - 4.*coef_y2.*coef_con))./(2.*coef_y2);
ysol_neg = (-coef_y - sqrt(coef_y.^2 - 4.*coef_y2.*coef_con))./(2.*coef_y2);

%since it is only the real values of ysol_pos and ysol_neg that describe
%the
%ellipse, we select out the imaginary solution.  
imag_ysol_pos  = imag(ysol_pos);  %extracts the imaginary part of ysol_pos
imag_ysol_neg = imag(ysol_neg);   %extracts the imaginary part of ysol_neg
indx1 = find(imag_ysol_pos == 0); %a zero value of the imaginary part is the solution
indx2 = find(imag_ysol_neg == 0);

if ~isempty(indx1)
    
    xy_pos = [x(indx1) ysol_pos(indx1)]; %real values of ysol_pos with the corrsponding x values
    xy_neg = [x(indx2) ysol_neg(indx2)]; %real values of ysol_neg with the corrsponding x values
    
    if length(indx1)<length(x)    
        indx_x_imag_beg = indx1(1)-1;
        indx_x_imag_end = indx1(end)+1;

        x_temp = [x(indx_x_imag_beg); x(indx1); x(indx_x_imag_end)];
        
        x_new = (x_temp(1):(x_temp(end) - x_temp(1))/20000:x_temp(end))';
        x_new = [(x_new(1):(x_new(2)-x_new(1))/10000:x_new(2))'; x_new(3:end-3); (x_new(end-2):(x_new(end)-x_new(end-1))/10000:x_new(end))'];
        
        xy_pos_add_top = [x(indx_x_imag_beg) real(ysol_pos(indx_x_imag_beg))];
        xy_pos_add_bott = [x(indx_x_imag_end) real(ysol_pos(indx_x_imag_end))];

        xy_pos = [xy_pos_add_top; xy_pos; xy_pos_add_bott];
        xy_neg = [xy_pos_add_top; xy_neg; xy_pos_add_bott];
        
    elseif length(indx1)==length(x)
        x_new = x; 
    end    
else
    xy_pos = [];
    xy_neg = [];
    x_new = [];
end
