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
% This function specifies the skins of the Graphical User Interface. A
% matrix is defined in FM_maps (contained within this function) that
% contains all colour entries for the skins, with 9 entries per skin
% choice.
% ------------------------------------------------------------------------

function FM_GUI_colors(h, value)

map = FM_maps;

tacklebox = h;
value;
index_increment = value -1; % how much you move on in the fisher_map;
index_original = 1:9; % The number of elemenst in each color map
index = index_original + index_increment.*9; 
% to get to the new map after selecting it

set(gcf,'color',map(index(4),:)) % sets the background colours

%--------------------------------------------------------------------------
% Load panel inputs
%--------------------------------------------------------------------------
set(tacklebox.load_panel,'BackgroundColor',map(index(3),:))
set(tacklebox.load_panel,'ForegroundColor',map(index(7),:))
    % the input choosing text colour
    set(tacklebox.choose_1, 'BackgroundColor',map(index(3),:)) 
    set(tacklebox.choose_1, 'ForegroundColor', map(index(7),:))
    % the input choosing drop-down menu colour
    set(tacklebox.choose_2, 'BackgroundColor',map(index(3),:))
    set(tacklebox.choose_2, 'ForegroundColor', map(index(7),:))
    % the skin choosing text colour
    set(tacklebox.lp_change_skin,'BackgroundColor',map(index(3),:))
    set(tacklebox.lp_change_skin, 'ForegroundColor', map(index(7),:))
    % the skin choosing drop-down menu colour
    set(tacklebox.skin_change,'BackgroundColor',map(index(3),:)) 
    set(tacklebox.skin_change, 'ForegroundColor', map(index(7),:))
    % the image background drop-down menu color
    set(tacklebox.image_choose,'BackgroundColor',map(index(3),:))
    set(tacklebox.image_choose, 'ForegroundColor', map(index(7),:))
    % the image background text color
    set(tacklebox.image_choose_text,'BackgroundColor',map(index(3),:))
    set(tacklebox.image_choose_text, 'ForegroundColor', map(index(7),:))


%-------------------------------------------------------------------------
% Data input panel
%--------------------------------------------------------------------------

% The colour of the thin lines on the data panel
set(tacklebox.input_panel,'BackGroundColor',map(index(6),:))

    % The colour of the left hand panel with text labels on it for the
    % observables etc
    set(tacklebox.input_text_panel,'BackGroundColor',map(index(2),:))

        % The  text entries on the left-hand panel
        set(tacklebox.tx1,'BackGroundColor',map(index(2),:))
        set(tacklebox.tx1, 'ForegroundColor', map(index(1),:))

        set(tacklebox.tx2,'BackGroundColor',map(index(2),:))
        set(tacklebox.tx2, 'ForegroundColor', map(index(1),:))

        set(tacklebox.tx4,'BackGroundColor',map(index(2),:))
        set(tacklebox.tx4, 'ForegroundColor', map(index(1),:))

        set(tacklebox.tx5,'BackGroundColor',map(index(2),:))
        set(tacklebox.tx5, 'ForegroundColor', map(index(1),:))

        set(tacklebox.tx6,'BackGroundColor',map(index(2),:))
        set(tacklebox.tx6, 'ForegroundColor', map(index(1),:))

        set(tacklebox.tx7,'BackGroundColor',map(index(2),:))
        set(tacklebox.tx7, 'ForegroundColor', map(index(1),:))

        % the colours of the middle panel with the data entries on it
        set(tacklebox.input_edit_panel,'BackGroundColor',map(index(2),:))  

        % The colours for the text of the parameters
        set(tacklebox.param_cb1, 'ForegroundColor', map(index(1),:))
        set(tacklebox.param_cb1, 'BackgroundColor', map(index(2),:))

        set(tacklebox.param_cb2, 'ForegroundColor', map(index(1),:))
        set(tacklebox.param_cb2, 'BackgroundColor', map(index(2),:))

        set(tacklebox.param_cb3, 'ForegroundColor', map(index(1),:))
        set(tacklebox.param_cb3, 'BackgroundColor', map(index(2),:))

        set(tacklebox.param_cb4, 'ForegroundColor', map(index(1),:))
        set(tacklebox.param_cb4, 'BackgroundColor', map(index(2),:))

        set(tacklebox.param_cb5, 'ForegroundColor', map(index(1),:))
        set(tacklebox.param_cb5, 'BackgroundColor', map(index(2),:))
        % The colour entries for the input boxes
        set(tacklebox.base_parameters, 'BackGroundColor', map(index(5),:))
        set(tacklebox.base_parameters, 'ForegroundColor',map(index(1),:))
    
        % The colour entries for the prior matrix box
        set(tacklebox.prior_matrix, 'BackgroundColor',map(index(5),:))
        set(tacklebox.prior_matrix, 'ForegroundColor',map(index(1),:))
        
        % The colour entries for the data 

        set(tacklebox.data.cb1,'BackGroundColor',map(index(2),:))
        set(tacklebox.data.cb1, 'ForegroundColor', map(index(1),:))

        set(tacklebox.data.cb2,'BackGroundColor',map(index(2),:))
        set(tacklebox.data.cb2, 'ForegroundColor', map(index(1),:))

        set(tacklebox.data.cb3,'BackGroundColor',map(index(2),:))
        set(tacklebox.data.cb3, 'ForegroundColor', map(index(1),:))


        % The growth function normalisation buttons
        set(tacklebox.growth_name,'BackGroundColor',map(index(2),:))
        set(tacklebox.growth_name, 'ForegroundColor', map(index(1),:))
        set(tacklebox.growth_zn,'BackGroundColor',map(index(5),:))
        set(tacklebox.growth_zn, 'ForegroundColor', map(index(1),:))


        % The colour entries for the derivative types
        set(tacklebox.derivative_type_name,'BackGroundColor',map(index(2),:))
        set(tacklebox.derivative_type_name, 'ForegroundColor', map(index(1),:))

        set(tacklebox.Hderivative_type,'BackGroundColor',map(index(2),:))
        set(tacklebox.Hderivative_type, 'ForegroundColor', map(index(1),:))
        set(tacklebox.Gderivative_type, 'ForegroundColor', map(index(1),:))
        set(tacklebox.Gderivative_type,'BackGroundColor',map(index(2),:))
        set(tacklebox.Dderivative_type,'BackGroundColor',map(index(2),:))
        set(tacklebox.Dderivative_type, 'ForegroundColor', map(index(1),:))

        % The colour entries for the data and errors
        
        set(tacklebox.data.f1, 'BackgroundColor',map(index(5),:))
        set(tacklebox.data.f1, 'ForegroundColor',map(index(1),:))

        set(tacklebox.data.f2, 'BackgroundColor',map(index(5),:))
        set(tacklebox.data.f2, 'ForegroundColor',map(index(1),:))

        set(tacklebox.data.f3, 'BackgroundColor',map(index(5),:))
        set(tacklebox.data.f3, 'ForegroundColor',map(index(1),:))

        set(tacklebox.error.f1, 'BackgroundColor',map(index(5),:))
        set(tacklebox.error.f1, 'ForegroundColor',map(index(1),:))

        set(tacklebox.error.f2, 'BackgroundColor',map(index(5),:))
        set(tacklebox.error.f2, 'ForegroundColor',map(index(1),:))
        
        set(tacklebox.error.f3, 'BackgroundColor',map(index(5),:))
        set(tacklebox.error.f3, 'ForegroundColor',map(index(1),:))

% The colour entries for the browse panel on the right hand side        
        
    set(tacklebox.input_browse_panel,'BackGroundColor',map(index(2),:))        
        
        % The colour entries for the browse buttons
        
        set(tacklebox.errorBrowse,'BackGroundColor',map(index(9),:))        
        set(tacklebox.priorBrowse, 'ForegroundColor',map(index(8),:))
        
        set(tacklebox.dataBrowse,'BackGroundColor',map(index(9),:))
        set(tacklebox.dataBrowse, 'ForegroundColor',map(index(8),:))
        
        set(tacklebox.priorBrowse,'BackGroundColor',map(index(9),:))        
        set(tacklebox.errorBrowse, 'ForegroundColor',map(index(8),:))
        
        set(tacklebox.priorOnOff, 'ForegroundColor',map(index(1),:))
        set(tacklebox.priorOnOff,'BackGroundColor',map(index(2),:))

%-------------------------------------------------------------------------
%The plot panel
%-------------------------------------------------------------------------
%These are the colours for the plot axis and surrounding area
set(tacklebox.ax_panel,'BackGroundColor',map(index(2),:))

    % The colours for the plot axis and title etc..
    set(tacklebox.ax,'color','w');%map(index(3),:))
    set(tacklebox.ax,'xcolor',map(index(1),:))%map(index(4),:))
    set(tacklebox.ax,'ycolor',map(index(1),:))
    set(get(tacklebox.ax,'Title'),'Color',map(index(1),:))

    % The colours for the check boxes and their text

        % The hold on check box
        set(tacklebox.holdon,'BackGroundColor',map(index(2),:))
        set(tacklebox.holdon, 'ForegroundColor', map(index(1),:))

        % The Area Fill check box
        set(tacklebox.fill,'BackGroundColor',map(index(2),:))
        set(tacklebox.fill, 'ForegroundColor', map(index(1),:))

        % The check box to select the line colour
        set(tacklebox.line_color,'BackGroundColor',map(index(2),:))
        set( tacklebox.line_color, 'ForegroundColor', map(index(1),:))

        % The drop down menu to select the line style
        set(tacklebox.line_style_tb,'BackGroundColor',map(index(2),:))
        set(tacklebox.line_style_tb, 'ForegroundColor', map(index(1),:))
        set(tacklebox.line_style,'BackGroundColor',map(index(2),:))
        set(tacklebox.line_style, 'ForegroundColor', map(index(1),:))

        % The drop down menu for the confidence level
        set(tacklebox.confidenceLevel_name,'BackGroundColor',map(index(2),:))
        set(tacklebox.confidenceLevel_name, 'ForegroundColor', map(index(1),:))
        set(tacklebox.confidenceLevel,'BackGroundColor',map(index(2),:))
        set(tacklebox.confidenceLevel, 'ForegroundColor', map(index(1),:))

        % The check box for the x and y limits
        set(tacklebox.cb_xlim,'BackGroundColor',map(index(2),:))
        set(tacklebox.cb_ylim,'BackGroundColor',map(index(2),:))
        set(tacklebox.cb_xlim, 'ForegroundColor', map(index(1),:))
        set(tacklebox.cb_ylim, 'ForegroundColor', map(index(1),:))

        % The input entry for the x and y limits
        set(tacklebox.xlim,'BackGroundColor',map(index(5),:))
        set(tacklebox.ylim,'BackGroundColor',map(index(5),:))
        set(tacklebox.xlim, 'ForegroundColor',map(index(1),:))
        set(tacklebox.ylim, 'ForegroundColor', map(index(1),:))

        % The grid check box
        set(tacklebox.cb_grid,'BackGroundColor',map(index(2),:))
        set(tacklebox.lb_grid,'BackGroundColor',map(index(2),:))
        set(tacklebox.cb_grid, 'ForegroundColor', map(index(1),:))
        set(tacklebox.lb_grid, 'ForegroundColor', map(index(1),:))
 
        % The colours for the buttons on the Plot panel
        set(tacklebox.edit_axis_button,'BackGroundColor',map(index(9),:))
        set(tacklebox.edit_axis_button,'ForegroundColor',map(index(1),:))
        set(tacklebox.save_plot,'BackGroundColor',map(index(9),:))
        set(tacklebox.save_plot,'ForegroundColor',map(index(1),:))
        set(tacklebox.clear,'BackGroundColor',map(index(9),:))
        set(tacklebox.clear,'ForegroundColor',map(index(1),:))

%-------------------------------------------------------------------------
% The RUN + FOM panel
%-------------------------------------------------------------------------
set(tacklebox.detf_panel,'BackGroundColor',map(index(2),:))

    % The buttons on the FOM panel
    set(tacklebox.Go, 'ForegroundColor', map(index(1),:))
    set(tacklebox.Go, 'BackgroundColor', map(index(9),:))
    set(tacklebox.clear_fom, 'ForegroundColor', map(index(1),:))
    set(tacklebox.clear_fom, 'BackgroundColor', map(index(9),:))

    set(tacklebox.DetF_name,'BackGroundColor',map(index(2),:))
    set(tacklebox.DetF_name,'ForegroundColor',map(index(1),:))
    set(tacklebox.detf_val,'BackGroundColor',map(index(2),:))
    set(tacklebox.detf_val,'ForegroundColor',map(index(1),:))
    set(tacklebox.fom_type,'BackgroundColor',map(index(2),:))
    set(tacklebox.fom_type,'ForegroundColor',map(index(1),:))
%--------------------------------------------------------------------------
% The colormaps defined for this GUI
function map_fisher = FM_maps;

map_g = colormap(gray);
map_gi = flipud(map_g);

map_gray = [ [0 0 0]
    map_g(48,:)    
    map_g(48,:)  
    map_g(39,:)
    map_g(60,:)
    map_g(63,:)  
    [0 0 0]
    [0 0 0]
    map_g(60,:)
     ];

map_s = colormap(summer);
map_si = flipud(map_s);

map_summer= [[0 0 0] 
    map_s(39,:)
    map_s(39,:)
    map_s(48,:)
    map_g(60,:)
    map_s(25,:)
    [0 0 0]
    [0 0 0]
    map_g(60,:)
    ];

map_b = colormap(bone);
map_bi = flipud(map_b);

map_bone= [[0 0 0] 
    map_b(39,:)
    map_b(39,:)
    map_b(48,:)
    map_g(60,:)
    map_b(25,:)
    [0 0 0]
    map_bi(58,:)
    map_g(60,:)
    ];


map_p = colormap(pink);
map_pi = flipud(map_p);
map_pinks= [ [0 0 0]
    map_p(39,:)
    map_p(39,:)
    map_p(48,:)
    map_g(60,:)
    map_p(20,:)
    [0 0 0]
    [0 0 0]
    map_g(60,:)
    ];

map_c = colormap(copper);
map_ci = flipud(map_c);

map_copper = [[0 0 0]
            [246, 208, 94]./256
            [186, 133, 64]./256
            [235 210 169]./256
            map_g(60,:)
            [186, 133, 64]./256
            [246, 208, 94]./256
            [0 0 0] 
            map_g(60,:)]  ;

map_d = colormap(gray);

map_di = flipud(map_d);

map_dark = [ [73 198 60]./256
            [0 0 0]
            [0 0 0]
            [0 0 0]
            [0 0 0]
            [73 198 60]./256
            [73 198 60]./256
            [0 0 0] 
            map_g(60,:)];

     
map_fisher = [map_bone
    map_copper
    map_summer
    map_pinks
    map_gray
    map_dark];
