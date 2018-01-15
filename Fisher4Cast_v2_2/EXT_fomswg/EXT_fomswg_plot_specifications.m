% ------------------------------------------------------------------------
% Copyright (C) 2008-2009
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
% This function is specfically written to be used in combination with the 
% FoMSWG extension, EXT_fomswg_gui. It allows one to customise and sets the 
% plot_spec structure to produce unique error ellipses. It is called inside 
% the FM_plot_ellipse function from Fisher4Cast.
% ------------------------------------------------------------------------
function EXT_fomswg_plot_specifications
global plot_spec;

% Flags for producing plots of the derivatives 

plot_spec.derivs(1) = 0;
plot_spec.derivs(2) = 0;
plot_spec.derivs(3) = 0;

%------------------------------------------------------------------------

plot_spec.center_ellipse = [-1,0];
        % where will the error ellipse be centered
plot_spec.resolution = 10; % the resolution of the ellipse

plot_spec.sb = 1000; % the mesh grid parameter

%--------------------------------------------------------------------
%============ confidence interval control ===========

%confidence level definition

plot_spec.sigma_level = 2.31;  %default confidence interval
%------------------------------------------------------------------------
%================ line format control ============================
plot_spec.line_width = 1;
%set line color, line style and fill color as defined

%define tacklebox as the 'UserData' for the current figure. This will allow
%tacklebox to contain information of FM_GUI plot selections which can be
%integrated with EXT_fomswg_GUI ellipse plots.
tacklebox = get(gcf,'UserData');
if isstruct(tacklebox)%check to see if the tacklebox structure exists
    %the majority of this section is cut-and-paste from FM_GUI to recognise
    %the settings set from GUI plot features. This is then initiated 
    %to correctly construct the plot_spec strcuture.
    
    %check if hold on is selected
    holdon_cb_val = get(tacklebox.holdon,'value');
    if holdon_cb_val==1 
        hold on             
    else 
        hold off            
    end 
    
    %check what line style is selected
    line_style_val = get(tacklebox.line_style,'value');
    line_style_str = {'-','--',':','-.','none'};
    plot_spec.linestyle = line_style_str{line_style_val};

    %check which line color is selected
    val_line_color = get(tacklebox.line_color,'value');
    map = colormap('lines');
    if val_line_color == 1
        plot_spec.linecolor = tacklebox.c_line;
    else
        if holdon_cb_val == 1
            %if hold on is chosen the line color changes randomly
            indx = floor(1+rand.*length(map)); 
            plot_spec.linecolor = map(indx,:); 
        else 
            plot_spec.linecolor = map(1,:);
        end
    end     
    
    %check which confidence level is chosen
    indx_sigma_level = get(tacklebox.confidenceLevel,'value');
    sigma_level = [2.31 6.17 11.83]; 
    plot_spec.sigma_level = sigma_level(indx_sigma_level);

    %set a flag for filling the ellipse with solid color
    val_fill = get(tacklebox.fill,'value');
    if val_fill == 1
        if isfield(tacklebox.input,'c_fill')                
            plot_spec.fill_flag = 1;   
            plot_spec.fill_color = tacklebox.input.c_fill;%tacklebox.input.c_fill is set from FM_GUI
        else                    
            errordlg('No fill color is defined')                    
        end
    else
        plot_spec.fill_flag = 0;
    end
else %if no current figure structure is found, i.e. no tacklebox, then set the plot_spec struct to default values 
    map = colormap('lines');
    if ishold==1
        indx = floor(1+rand.*length(map)); 
        plot_spec.linecolor = map(indx,:); 
    else 
        plot_spec.linecolor = map(1,:);
    end  

    plot_spec.sigma_linecolor = [1 0 0];
    plot_spec.linestyle = '--'; %default line style of the ellipse
end
