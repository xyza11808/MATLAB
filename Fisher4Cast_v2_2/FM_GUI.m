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
% FM_GUI sets a Gui for the Fisher matrix tacklebox. 
%
% It excutes the callbacks which are  
% USERIN- the input for the GUI. During the first 
% initialisation of this function, USERIN is zero
% which opens the new GUI window. All buttons and controls follow a specific
% format as outlined in the Matlab Help files, and indentation is key in
% this code. The GUI also contains floating help to aid the user.
% For more information on GUI's, please see the Matlab documentation.


function FM_GUI(USERIN) 

global axis_spec tacklebox


if nargin==0
    USERIN = 'creategui'; %initialise the GUI 
end

%Everytime the user presses or enters a 'uicontrol' in the GUI,
%the resulting 'UserData' will be assigned to 'USERIN' and the   
%following switch-case statement will be excuted. 
%The case statements define the 'Callbacks' associated 
%with the different uicontrols - they are the different results of pushing
%the buttons or changing the input.
 
switch USERIN
    
    case 'creategui'       %initialize the GUI 
    
    
      %===========================================  
        %initialise input data
        tacklebox.input = Cooray_et_al_2004;        
  
        if iscell(tacklebox.input.data)
        elseif isvector(tacklebox.input.data)                                                        
                tacklebox.input.data = cell(1,3);
                for i = 1:3                    
                    eval(['tacklebox.input.data{',num2str(i),'}=data_val(:);']);
                end  
        else
            error('Redshift data is neither a vector nor a cell')
        end 

       %setting the error boxes
       error_val = tacklebox.input.error;
       if iscell(error_val)       
       elseif isvector(error_val)
            tacklebox.input.error = cell(3,1);
            for i = 1:3                
                 eval(sprintf('tacklebox.input.error{%0.5g} = error_val(:);',i));
            end
        else
            error('The entered error value is neither a cell nor a matrix')
       end     
        
       tacklebox.InputErrorFlag = 0;
       tacklebox.InteractivePlot_flag = 0; %Interactive plotting off!
      %============================================================
      
        tacklebox.uiname = mfilename;    %get filename         

        fig = figure('Visible','off',...
             'Units','normalized',...             
             'Position',[0.1,0.24,0.85,0.75],...
             'NumberTitle','off',...
             'Interruptible','off',...             
             'Menubar','none');
        tacklebox.bg_image = axes('Units','normalized',...
            'position',[0,0,1,1]);
        set(tacklebox.bg_image,'visible','off')    

                  
        f = uimenu('Label','Fisher4Cast');
            uimenu(f,'Label','Fisher4Cast Readme','Callback',@Fisher4castReadme);
            uimenu(f,'Label','Guide to Fisher4Cast','Callback','open Quickstart.pdf');
            uimenu(f,'Label','Fisher4Cast Manual','Callback','open Users_Manual.pdf');            
            uimenu(f,'Label','About','Callback',@Fisher4castTeam,...
                   'Separator','on'); 
            uimenu(f,'Label','Fisher4Cast Licence','Callback',@Fisher4castLicence);
 
            
        tacklebox.fext = uimenu('Label','F4C Extensions');
            uimenu(tacklebox.fext,'Label','External Modules info','Callback',@FisherExtennsion)

        %Enable interactive plotting
        tacklebox.IntPlot = uimenu(tacklebox.fext,'Label','Activate Interactive Plotting',...         
        'Callback', {@activateInteractivePlot,tacklebox});
        
        uimenu(tacklebox.fext,'Label','FoMSWG Pop-Up Extension',...
            'Callback',@fomswg_extension)
  %======================================================================%
  % == Create tacklebox.ax_panel with axes and hold on checkbox on it == %
  %======================================================================%

        tacklebox.ax_panel = uibuttongroup('Units','normalized',...             
             'BorderWidth',2,...
             'visible','on',...             
             'Position',[0.425,0.123,0.56,0.13]);         
        
         tacklebox.edit_axis_button = uicontrol('parent',tacklebox.ax_panel,...
            'Style','Pushbutton',...
            'String','Edit axis labels',... 
            'TooltipString','When pressed, this button allows you to edit the Title; X-axis and Y-axis.',...
            'Units','normalized',...
            'Position',[0.81 0.36 0.18 0.28],...
            'Callback',[tacklebox.uiname,' edit_axis']);
        
%--------------------------------------------------------------------------
   
    %============== radiobutton for hold on=======================
         % This button allows for hold to be on or off 
         % while plotting.
         
        tacklebox.holdon=uicontrol('parent',tacklebox.ax_panel,...
             'Style','checkbox', ...
              'String','Hold on',...
              'TooltipString','When checked, this sets the Hold on for multiple plots to be displayed simultaneously.',... 
              'Unit','normalized',...
              'Value',0,...
              'Position',[0.01 0.7 0.15 0.2],...
              'CallBack',[tacklebox.uiname,' holdon']); 
      
        tacklebox.fill=uicontrol('parent',tacklebox.ax_panel,...
             'Style','checkbox', ...
              'String','Area Fill',...
              'TooltipString','When checked, this allows you to choose a colour that fills the area of the ellipse for the next plot.',... 
              'Unit','normalized',...
              'Value',0,...
              'Position',[0.01 0.4 0.15 0.2],... 
              'CallBack',[tacklebox.uiname,' fill']);    
              
        tacklebox.line_color =uicontrol('parent',tacklebox.ax_panel,...
             'Style','checkbox', ...
              'String','Line Color',...
              'TooltipString','When checked, this allows you to set the plot line color for the next plot.',... 
              'Unit','normalized',...
              'Value',0,...
              'Position',[0.01 0.1 0.17 0.2],...
              'CallBack',[tacklebox.uiname,' line_color']);
              
      tacklebox.line_style_tb =uicontrol('parent',tacklebox.ax_panel,...
             'Style','text', ...
              'String','Line Style',...               
              'Unit','normalized',...              
              'Position',[0.179 0.68 0.15 0.2]);
          
        tacklebox.line_style =uicontrol('parent',tacklebox.ax_panel,...
             'Style','popupmenu', ...
              'String','- | -- | : | -.| none',...
              'TooltipString','Select the plot line style for the next plot.',... 
              'Unit','normalized',...              
              'Position',[0.33 0.7 0.14 0.2],...
              'FontWeight', 'bold',...
              'CallBack',[tacklebox.uiname,' line_style']);  
%--------------------------------------------------------------------------
          
        %================== axis limit checkboxes ========================  
        % These boxes are where you define the limits of the axes in the
        % plot.
        
        tacklebox.cb_xlim= uicontrol('parent',tacklebox.ax_panel,...
              'Style','checkbox',...
              'String','xlim',...
              'value',0,...
              'TooltipString','When checked, the x-axis range is set for the current plot to the specified range.',...
              'Unit','normalized',...
              'Position',[0.525 0.62 0.1 0.2],...
              'Callback',[tacklebox.uiname,' xlim_resize']);  
              
          
        tacklebox.cb_ylim= uicontrol('parent',tacklebox.ax_panel,...
              'Style','checkbox',...
              'String','ylim',...
              'value',0,...
              'TooltipString','When checked, the y-axis range is set for the current plot to the specified range.',...
              'Unit','normalized',...              
              'Position',[0.525 0.2 0.1 0.2],...
              'Callback',[tacklebox.uiname,' ylim_resize']);          
                    
       
        tacklebox.xlim = uicontrol(gcf,'parent',tacklebox.ax_panel,...
            'Style','Edit',...
            'String','[-1.5 -0.5]',...            
            'TooltipString','This input allows you to edit the y-axis range.',... 
            'Units','normalized',...
            'Position',[0.625,0.58,0.14,0.28]);
        
            
        tacklebox.ylim = uicontrol(gcf,'parent',tacklebox.ax_panel,...
            'Style','Edit',...            
            'String','[-1 1]',...
            'TooltipString','This input allows you to edit the y-axis range.',... 
            'Units','normalized',...
            'Position',[0.625,0.18,0.14,0.27]);       
            
            
        %Check box for Grid. when checked Grid = 'on' else 'off'
        tacklebox.cb_grid= uicontrol('parent',tacklebox.ax_panel,...
              'Style','checkbox',...
              'String','Grid',...
              'value',1,...
              'TooltipString','Toggles the grid on when checked and off when not checked.',...
              'Unit','normalized',...              
              'Position',[0.21 0.12 0.1 0.2],...
              'Callback',[tacklebox.uiname,' grid_cb']);    
          
              
          
        %Grid on top or bottom option list box
        tacklebox.lb_grid= uicontrol('parent',tacklebox.ax_panel,...
              'Style','popupmenu',...
              'String','over plot|under plot',...              
              'TooltipString','Select a grid to either be over or under the plot area',...
              'Unit','normalized',...              
              'Position',[0.33 0.15 0.14 0.2],...
              'Callback',[tacklebox.uiname,' grid_lb']);           
        
        
%--------------------------------------------------------------------------

      tacklebox.confidenceLevel_name =uicontrol('parent',tacklebox.ax_panel,...
             'Style','text', ...
              'String','Sigma Level',... 
              'max',2,...
              'Unit','normalized',...              
              'Position',[0.19 0.38 0.15 0.2]);
          
        tacklebox.confidenceLevel =uicontrol('parent',tacklebox.ax_panel,...
             'Style','popupmenu', ...
              'String','1 sigma|2 sigma |3 sigma',...
              'TooltipString','This drop-down menu allows you to select the confidence level in terms of sigma.',... 
              'Unit','normalized',...              
              'Position',[0.33 0.45 0.14 0.16],...
              'CallBack',[tacklebox.uiname,' CL']);

        
        %============= Save plot button ================

        tacklebox.save_plot = uicontrol(gcf,'parent',tacklebox.ax_panel,...
            'Style','popupmenu',...
            'String','Saving Features|Text Report|Latex Report|Save Plot',...
            'TooltipString','This menu allows you to either save the plot area in a variety of formats or generate a Text or Latex report summarising the input and output.',... 
            'Units','normalized',...
            'Position',[0.81,0.05,0.18,0.29],...
            'Callback',[tacklebox.uiname,' save_plot']);    


        tacklebox.clear = uicontrol(gcf,'parent',tacklebox.ax_panel,...
            'Style','Pushbutton',...
            'String','Clear',...
            'TooltipString','Clears the plot axis.',... 
            'Units','normalized',...
            'Position',[0.81 0.65 0.18 0.3],...
            'Callback',[tacklebox.uiname,' reset']);  
        
            
            


%--------------------------------------------------------------------------

        %=========================================================  
        %==== detf panel with FOM value and Run button on it ==== 
        %=========================================================

        tacklebox.detf_panel = uipanel('Units','normalized',...
             'BorderType','etchedin',...
             'Position',[0.425,0.01,0.56,0.1]);

%-----------------------------------------------------------------------         
        %============= Run button ==========
        %The Run button runs/executes the FM_run.m function.
        
        tacklebox.Go = uicontrol(gcf,'parent',tacklebox.detf_panel,...
            'Style','Pushbutton',...
            'String','Run',... 
            'TooltipString','When pressed, this button calls the function FM_run.m with the specified input structure.',...
            'Units','normalized',...
            'Position',[0.01,0.07,0.18,0.83],...
            'FontWeight','bold','FontSize',16,...    
            'Callback',[tacklebox.uiname,' Go']);     
%--------------------------------------------------------------------------
         
        %Set a text box to write FOM values
        tacklebox.DetF_name = uicontrol('parent',tacklebox.detf_panel,...
             'Style','text',...
             'String','Figure of Merit  = ',...
             'FontSize',14,...
             'Units','normalized',...     
             'Position',[0.22,0.2,0.28,0.5],...
             'FontWeight','bold');
         
         
        tacklebox.fom_type = uicontrol(gcf,'parent',tacklebox.detf_panel,...
            'Style','popupmenu',...
            'String','DETF|1/Area 2-sigma|1/Area 1-sigma|Area 1-sigma|Trace(cov)|sum(cov^2)',...            
            'TooltipString','Choose the Figure of Merit from a range of values.',... 
            'Units','normalized',...
            'Position',[0.75,0.45,0.24,0.45],...
            'FontWeight', 'bold',...
            'Callback',[tacklebox.uiname,' fom_type']);

        
        tacklebox.fom = {'0','0','0','0','0','0'}; 
        tacklebox.detf_val = uicontrol(gcf,'parent',tacklebox.detf_panel,...
             'Style','popupmenu',...
             'String','0',...
             'FontSize',12,...
             'TooltipString','The FOM is defined in the drop-down menu to the right.',...
             'Units','normalized',...
             'FontWeight', 'bold',...
             'Position',[0.52,0.16,0.2,0.6]);    
         
             
         tacklebox.clear_fom = uicontrol(gcf,'parent',tacklebox.detf_panel,...
            'Style','Pushbutton',...
            'String','Reset FoM',...            
            'TooltipString','Clears the FoM history.',... 
            'Units','normalized',...
            'Position',[0.75,0.08,0.24,0.4],...
            'Callback',[tacklebox.uiname,' clear_fom']); 
             
        %===========================================================
        %=====input panel with input parameter boxes on it ========
        %===========================================================

            %Set a box for the user to add input parameters
        tacklebox.input_panel = uipanel('Units','normalized',...
             'Position',[0.01,0.01,0.4,0.8]);       %main input panel
        tacklebox.input_text_panel = uipanel('parent',tacklebox.input_panel,...
             'Units','normalized',...
             'Position',[0.0,0.0,0.24,1]);         %input text panel
        tacklebox.input_edit_panel = uipanel('parent',tacklebox.input_panel,...
             'Units','normalized',...
             'Position',[0.25,0.0,0.68,1]);         %input edit panel
        tacklebox.input_browse_panel = uipanel('parent',tacklebox.input_panel,...
             'Units','normalized',...
             'Position',[0.89,0.0,0.1,1]);       %input browse panel
%--------------------------------------------------------------------------
       % static text box for writing variable names
        tacklebox.tx1 = uicontrol('parent',tacklebox.input_text_panel,...
              'Style','text',...
              'String','Parameters',...
              'Unit','normalized',...
              'Position',[0.05,0.88,0.9,0.08],...
              'FontWeight','bold');
        tacklebox.tx2 = uicontrol('parent',tacklebox.input_text_panel,...
              'Style','text',...
              'max',2,...
              'String','Base parameters',...
              'Unit','normalized',...
              'Position',[0.12,0.8,0.8,0.1],...
              'FontWeight','bold');
        tacklebox.tx4 = uicontrol('parent',tacklebox.input_text_panel,...
              'Style','text',...
              'String','Prior matrix',...
              'Unit','normalized',...
              'Position',[0.1,0.68,0.8,0.1],...
              'FontWeight','bold');      
        tacklebox.tx5 = uicontrol('parent',tacklebox.input_text_panel,...
              'Style','text',...
              'String','Observable',...
              'Unit','normalized',...  
              'Position',[0.09,0.53,0.8,0.1],... 
              'FontWeight','bold');
        tacklebox.tx6 = uicontrol('parent',tacklebox.input_text_panel,...
              'Style','text',...
              'String','Data Redshifts',...
              'Unit','normalized',...  
              'Position',[0.15,0.355,0.7,0.1],... 
              'FontWeight','bold');
        tacklebox.tx7 = uicontrol('parent',tacklebox.input_text_panel,...
              'Style','text',...
              'String','Fractional Errors on Observables',...
              'Unit','normalized',...
              'Position',[0.11,0.07,0.7,0.12],...
              'FontWeight','bold');             
          
        % dynamic text box for writing variable values
        %------------------------------------------------------------------
        %This block of code produced the phantom grey area near O_m in Mac
        %OS X. We patched this by hiding the domensions of the block i.e.
        %reduced the size to near zero.
        tacklebox.observable_index = uicontrol(gcf,'parent',tacklebox.input_edit_panel,...
             'Style','Text',...
             'String',num2str(tacklebox.input.observable_index),...
             'Units','normalized',...
             'Position',[0.02,0.92,0.0001,0.0001],...
             'Callback',[tacklebox.uiname,' observable_index']);         
        %------------------------------------------------------------------
        
        tacklebox.base_parameters = uicontrol(gcf,'parent',tacklebox.input_edit_panel,...
             'Style','Edit',...
             'String',num2str(tacklebox.input.base_parameters),...
             'Units','normalized',...
             'Position',[0.02,0.83,0.9,0.08],...             
             'Callback',[tacklebox.uiname,' base_parameters']);
         
        
        tacklebox.prior_matrix = uicontrol(gcf,'parent',tacklebox.input_edit_panel,...
             'Style','Edit',...
             'String',num2str(tacklebox.input.prior_matrix),...
             'max',10,...
             'Units','normalized',...
             'Position',[0.02,0.65,0.9,0.17],...
             'Callback',[tacklebox.uiname,' prior_matrix']);
         
    
   %--------------------------------------------------------------------------------          
     
       tacklebox.data.cb1 = uicontrol('parent',tacklebox.input_edit_panel,...
             'Style','checkbox', ...
              'String',tacklebox.input.observable_names{1},...
              'TooltipString','Hubble rate data will be used for Fisher Matrix analysis when checked.',... 
              'Unit','normalized',...
              'Value',ismember(1,tacklebox.input.observable_index),...
              'Position',[0.16,0.59,0.16,0.05],...      
              'CallBack',[tacklebox.uiname,' data.cb1']);
     tacklebox.data.cb2 = uicontrol('parent',tacklebox.input_edit_panel,...
             'Style','checkbox', ...
              'String',tacklebox.input.observable_names{2},...
              'TooltipString','Angular Diameter Distance data will be used for Fisher Matrix analysis when checked.',... 
              'Unit','normalized',...
              'Value',ismember(2,tacklebox.input.observable_index),...
              'Position',[0.445,0.59,0.16,0.05],...      
              'CallBack',[tacklebox.uiname,' data.cb2']);
      tacklebox.data.cb3 = uicontrol('parent',tacklebox.input_edit_panel,...
             'Style','checkbox', ...
              'String',tacklebox.input.observable_names{3},...
              'TooltipString','Growth function data, normalized at the redshift set below, will be used for Fisher Matrix analysis when checked.',... 
              'Unit','normalized',...
              'Value',ismember(3,tacklebox.input.observable_index),...
              'Position',[0.75,0.59,0.16,0.05],...      
              'CallBack',[tacklebox.uiname,' data.cb3']);
          
%------derivative type (numerical or analytic) drop down menu--------------
           
      tacklebox.derivative_type_name =uicontrol('parent',tacklebox.input_text_panel,...
             'Style','text', ...
              'String','Derivative Type',... 
              'max',2,...
              'Unit','normalized',...              
              'Position',[0.05,0.53,0.9,0.05],...
              'FontWeight','bold');
          
        tacklebox.Hderivative_type =uicontrol('parent',tacklebox.input_edit_panel,...
             'Style','popupmenu', ...
              'String','Analytical|Numerical',...
              'Value',tacklebox.input.numderiv.flag{1}+1,...
              'TooltipString','This drop-down menu allows you to choose between Analytical and Numerical derivatives.',... 
              'Unit','normalized',...              
              'Position',[0.055 0.55,0.25,0.04],...
              'CallBack',[tacklebox.uiname,' Hderivative_type']);
          
        tacklebox.Dderivative_type =uicontrol('parent',tacklebox.input_edit_panel,...
             'Style','popupmenu', ...
              'String','Analytical|Numerical',...
              'Value',tacklebox.input.numderiv.flag{2}+1,...
              'TooltipString','This drop-down menu allows you to choose between Analytical and Numerical derivatives',... 
              'Unit','normalized',...              
              'Position',[0.368 0.55,0.25,0.04],...
              'CallBack',[tacklebox.uiname,' Dderivative_type']);
          
        tacklebox.Gderivative_type =uicontrol('parent',tacklebox.input_edit_panel,...
             'Style','text', ...
             'String','Numerical',...
              'Value',tacklebox.input.numderiv.flag{3}+1,...
              'TooltipString','Only Numerical derivatives are available for the Growth function.',... 
              'Unit','normalized',...              
              'Position',[0.665 0.55,0.25,0.04],...
              'CallBack',[tacklebox.uiname,' Gderivative_type']);          
%--------------------------------------------------------------------------          
   
tacklebox.data.f1 = uicontrol(gcf,'parent',tacklebox.input_edit_panel,...
             'Style','Edit',...
             'String',num2str((tacklebox.input.data{1}(:))),...
             'Units','normalized',...
             'max',10,...
             'Position',[0.08,0.3,0.2,0.24],...
             'Callback',[tacklebox.uiname,' data1']);
     tacklebox.data.f2 = uicontrol(gcf,'parent',tacklebox.input_edit_panel,...
             'Style','Edit',...
             'String',num2str((tacklebox.input.data{2}(:))),...
             'Units','normalized',...
             'max',10,...
             'Position',[0.39,0.3,0.2,0.24],...
             'Callback',[tacklebox.uiname,' data2']);
      tacklebox.data.f3 = uicontrol(gcf,'parent',tacklebox.input_edit_panel,...
             'Style','Edit',...
             'String',num2str((tacklebox.input.data{3}(:))),...
             'Units','normalized',...
             'max',10,...
             'Position',[0.69,0.3,0.2,0.24],...
             'Callback',[tacklebox.uiname,' data3']); 
         
%=====================================================================
      tacklebox.growth_name = uicontrol('parent',tacklebox.input_edit_panel,...
              'Style','Text', ...
              'String','Normalise Growth at z = ',...
              'TooltipString','This field allows you to set the redshift value at which the Growth function is normalised.',... 
              'Unit','normalized',...
              'Position',[0.15,0.24,0.65,0.05]);     
      tacklebox.growth_zn = uicontrol('parent',tacklebox.input_edit_panel,...
              'Style','Edit', ...
              'String',num2str(tacklebox.input.growth_zn),...
              'TooltipString','This field allows you to set the redshift value at which the Growth function is normalised.',... 
              'Unit','normalized',...
              'Position',[0.735,0.253,0.15,0.045],...      
              'CallBack',[tacklebox.uiname,' growth_zn']);     
          
%===========================================================================

      tacklebox.error.f1 = uicontrol(gcf,'parent',tacklebox.input_edit_panel,...
             'Style','Edit',...
             'String',num2str((tacklebox.input.error{1}(:))),...
             'max',10,...
             'Units','normalized',...
             'Position',[0.08,0.01,0.2,0.24],...
             'Callback',[tacklebox.uiname,' error1']);
      tacklebox.error.f2 = uicontrol(gcf,'parent',tacklebox.input_edit_panel,...
             'Style','Edit',...
             'String',num2str((tacklebox.input.error{2}(:))),...
             'max',10,...
             'Units','normalized',...
             'Position',[0.39,0.01,0.2,0.24],...
             'Callback',[tacklebox.uiname,' error2']);
      tacklebox.error.f3 = uicontrol(gcf,'parent',tacklebox.input_edit_panel,...
             'Style','Edit',...
             'String',num2str((tacklebox.input.error{3}(:))),...
             'max',10,...
             'Units','normalized',...
             'Position',[0.69,0.01,0.2,0.24],...
             'Callback',[tacklebox.uiname,' error3']);
 
 %--------------------------------------------------------------------------

    %==============================================================   
    %==============================================================
        
        tacklebox.param_cb1 = uicontrol(gcf,'parent',tacklebox.input_edit_panel,...
             'Style','checkbox',...
             'String',tacklebox.input.parameter_names{1},...
             'TooltipString','The Hubble constant, H_0, will be selected for plotting when checked.',... 
             'Units','normalized',...
             'value',ismember(1,tacklebox.input.parameters_to_plot),...%this should be set by the input
             'Position',[0.065,0.92,0.18,0.05],...
             'Callback',[tacklebox.uiname,' fiducial_cb1']);     

        tacklebox.param_cb2 = uicontrol(gcf,'parent',tacklebox.input_edit_panel,...
             'Style','checkbox',...
             'String',tacklebox.input.parameter_names{2},...
             'TooltipString','The matter density, Omega_m, will be selected for plotting when checked.',...
             'Units','normalized',...
             'value',ismember(2,tacklebox.input.parameters_to_plot),...
             'Position',[0.235,0.92,0.18,0.05],...
             'Callback',[tacklebox.uiname,' fiducial_cb2']);      
        tacklebox.param_cb3 = uicontrol(gcf,'parent',tacklebox.input_edit_panel,...
             'Style','checkbox',...
             'String',tacklebox.input.parameter_names{3},...
             'TooltipString','The curvature density, Omega_k, will be selected for plotting when checked.',...
             'Units','normalized',...
             'value',ismember(3,tacklebox.input.parameters_to_plot),...
             'Position',[0.41,0.92,0.18,0.05],...
             'Callback',[tacklebox.uiname,' fiducial_cb3']); 
         
        tacklebox.param_cb4 = uicontrol(gcf,'parent',tacklebox.input_edit_panel,...
             'Style','checkbox',...
             'String',tacklebox.input.parameter_names{4},...
             'TooltipString','The CPL dark energy coefficient, w_0, will be selected for plotting when checked.',...
             'Units','normalized',...
             'value',ismember(4,tacklebox.input.parameters_to_plot),...
             'Position',[0.58,0.92,0.18,0.05],...
             'Callback',[tacklebox.uiname,' fiducial_cb4']);          
         
         tacklebox.param_cb5 = uicontrol(gcf,'parent',tacklebox.input_edit_panel,...
             'Style','checkbox',...
             'String',tacklebox.input.parameter_names{5},...
             'TooltipString','The CPL dark energy coefficient, w_a, will be selected for plotting when checked.',...
             'Units','normalized',...
             'value',ismember(5,tacklebox.input.parameters_to_plot),...
             'Position',[0.755,0.92,0.18,0.05],...
             'Callback',[tacklebox.uiname,' fiducial_cb5']);      
           
%--------------------------------------------------------------------------

   %================= buttons for input data=======================

        tacklebox.priorBrowse = uicontrol(gcf,'parent',tacklebox.input_browse_panel,...
             'Style','Pushbutton',...
             'String','...',...
             'TooltipString','This button allows you to import/load a prior matrix in various file formats. The data must be a 5x5 matrix.',...
             'Units','normalized',...
             'Position',[0.065,0.75,0.85,0.05],...
             'Callback',[tacklebox.uiname,' priorBrowse']);    
         
        tacklebox.priorOnOff = uicontrol(gcf,'parent',tacklebox.input_text_panel,...
             'Style','checkbox',...
             'String','Use Prior',...
             'value',1,...
             'TooltipString','When checked, the Prior Matrix will be used and if unchecked it will not be used.',...
             'Units','normalized',...
             'Position',[0.18,0.69,0.7,0.05],...
             'Callback',[tacklebox.uiname,' priorOnOff']); 
         
        tacklebox.dataBrowse = uicontrol(gcf,'parent',tacklebox.input_browse_panel,...
             'Style','Pushbutton',...
             'String','...',...
             'TooltipString','This button allows you to import/load redshift data in various file formats. The data must have three columns corresponding to H, d_A and G.',...
             'Units','normalized',...
             'Position',[0.065,0.42,0.85,0.05],...
             'Callback',[tacklebox.uiname,' dataBrowse']);

        tacklebox.errorBrowse = uicontrol(gcf,'parent',tacklebox.input_browse_panel,...
             'Style','Pushbutton',...
             'String','...',...
             'TooltipString','This button allows you to import/load error data in various file formats. The data must have three columns corresponding to H, d_A and G.',...
             'Units','normalized',...
             'Position',[0.065,0.11,0.85,0.05],...
             'Callback',[tacklebox.uiname,' errorBrowse']);

%--------------------------------------------------------------------------
        %=================================================================
        % ============== Input load panel ===============================
        %=================================================================
        
        % When input data are loaded from a file.
        
        %Set a Browse pushbutton for the User to upload the input
        %parameters from a file
       
        tacklebox.load_panel = uipanel('Units','normalized',...            
             'Position',[0.01,0.82,0.4,0.15]);
       %========  Logo axis ==========================
        logo_axes = axes('parent', tacklebox.load_panel,'Units','normalized',...                        
             'Position',[0.01,0.05,0.23,0.9]);
       
        
         himage = imread('logo_fisher_4cast_out.jpg');          
         image(himage)
         axis off         

         tacklebox.lp_change_skin = uicontrol('parent', tacklebox.load_panel,'Style','text',...
             'String','Skin colour',...
             'Units','normalized',...  
             'Position',[0.3,0.55,0.25,0.3],...
             'FontSize', 9,'FontWeight','bold');

%--------------------------------------------------------------------------
    % choose from a drop-down list of standard input files.

        %=============== template input choose pop-up ================
        tacklebox.choose_1 = uicontrol('parent',tacklebox.load_panel,'Style','text',...
            'String','Default Input',...            
           'Units','normalized',...
            'Position',[0.3,0.05,0.25,0.25],...
            'FontSize',9,'FontWeight','bold');

        tacklebox.choose_2 = uicontrol(gcf,'parent',tacklebox.load_panel,...
            'Style','popupmenu',...
            'TooltipString','This drop-drown menu lists the different default input types that can be selected.',...
            'String', 'Cooray et al. 2004|Seo & Eisenstein 2003|Load from file',...
            'Units','normalized',...
            'Position',[0.55,0.02,0.4 ,0.3],...
            'Callback',[tacklebox.uiname,' choose']);
      
       tacklebox.image_choose = uicontrol(gcf,'parent',tacklebox.load_panel,...
            'Style','popupmenu',...
            'TooltipString','This drop-drown menu lists the different default input types that can be selected.',...
            'String', 'none|WMAP|Millenium Simulation|The Matrix|Load from file',...
            'Units','normalized',...
            'Position',[0.55,0.3,0.4,0.3],...
            'Callback',[tacklebox.uiname,' image_choose']);
       
            tacklebox.image_choose_text = uicontrol(gcf,'parent',tacklebox.load_panel,...
            'Style','Text',...
            'TooltipString','This drop-drown menu lists the different default input types that can be selected.',...
            'String', 'Background',...
            'Units','normalized',...
            'Position',[0.3,0.27,0.25,0.3],...
            'Callback',[tacklebox.uiname,' image_choose_text'],...
            'FontSize', 9,'FontWeight','bold');
            
            
        tacklebox.skin_change = uicontrol(gcf,'parent',tacklebox.load_panel,...
            'Style','popupmenu',...
            'TooltipString','This drop-drown menu lists the different types of color schemes for the GUI.',...
            'String', {'Winter Blues','Earthy Copper','Summer Greens','Subtle Pinks', 'Gray Tones', 'Dark Blacks'},...
            'Units','normalized',...
            'Position',[0.55,0.6,0.4 ,0.3],...
            'Callback',[tacklebox.uiname,' skin_change']);
%--------------------------------------------------------------------------
  %======================================================================%
  % == Create tacklebox.ax_panel with axes and hold on checkbox on it == %
  %======================================================================%
             
        tacklebox.ax = axes('parent',gcf,'Units','normalized',...            
             'box','on',...
             'ButtonDownFcn',{@axesButtonDownFcn,tacklebox}, ...
             'xlim',[-1 0],'ylim',[-1 1],...
             'Position',[0.465,0.33,0.5,0.6]);
         

        %============================================================
        % =====================  Show figure   =====================
        %============================================================
        
        % Plot the resulting ellipse
        
        FM_GUI_colors(tacklebox,1);
        name = strcat(['Tacklebox GUI   ' pwd]);
        %set the name of the GUI while desplaying the path
        set(fig,'Name',name) 
        %set the toolbar and menu property of the figure to our GUI
        set(fig,'toolbar','figure'); %adds a default toolbar
        set(fig,'menu','figure'); %adds default fig menu to the gui
        movegui(fig,'center') %moves the gui to the center of the screen
        set(fig,'Visible','on') %makes the fig visible at the center
        %put all the variables in a safe place (the figure's data area)
        
        %=======================================================
        
       set(fig,'UserData',tacklebox); 
        
    %=============================================================
    % ================== callback cases =========================
    %=============================================================
    
     % Modifying the input as to which observable the user wants to
     % consider - this then changes the input that will be fed into FM_run
     % through the input structure so that the priors etc are correct for
     % the data considered.
     
%----------------------------------------------------------------------     
   
     case 'image_choose'

        tacklebox = get(gcf,'UserData');
        im_str = get(tacklebox.image_choose,'String');
        im_chval = get(tacklebox.image_choose,'Value'); %Gets the value, order number of the selected choice  

        
        switch im_chval
            
            
            case 2
                name = 'wmap_back.jpg';                           
                %FM_GUI_colors(tacklebox, 2)
                [c,cmap] = imread(name);
                image(c,'parent',tacklebox.bg_image);        
                set(tacklebox.bg_image,'visible','on', 'layer', 'bottom')
                FM_GUI_colors(tacklebox, 2)
            
            case 3
                name = 'millenium6.jpg';                           
                %FM_GUI_colors(tacklebox, 1)
                [c,cmap] = imread(name);
                image(c,'parent',tacklebox.bg_image);
                set(tacklebox.bg_image,'visible','on')
                FM_GUI_colors(tacklebox, 1)
                
            case 4
                name = 'matrix_free.jpg';                           
                %FM_GUI_colors(tacklebox,6)
                [c,cmap] = imread(name);     
                image(c,'parent',tacklebox.bg_image);
                set(tacklebox.bg_image,'visible','on')
                FM_GUI_colors(tacklebox,6)
                  
            case 1                  
                cla(tacklebox.bg_image, 'reset')
                set(tacklebox.bg_image,'visible','off')
                
            case 5        
                %stores savepath for the phase plot
                [filename, pathname] = uigetfile(...
                        {'*.jpg;*.png;','MATLAB Files (*.jpg,*.png)';
                                 '*.jpeg','Figures (*.jpg)'; ...
                                 '*.png','MAT-files (*.png)'; ...
                                 '*.*',  'All Files (*.*)'}, ...
                                 'Save as');
              %if user cancels save command, nothing happens
                if isequal(filename,0) || isequal(pathname,0)
                    return
                end
                filename = fullfile(pathname,filename);
                [c,cmap] = imread(filename);
                image(c,'parent',tacklebox.bg_image);  
                set(tacklebox.bg_image,'visible','on')             
                 
        end
            tacklebox = get(gcf,'UserData');
    case 'Hderivative_type'
        tacklebox = get(gcf,'UserData');
        deriv_val = get(tacklebox.Hderivative_type,'Value');
        %Gets the value, order number of the selected choice
        if deriv_val == 1
            set_deriv_flag = 0;
        elseif deriv_val >1
            set_deriv_flag = 1;
        end
        tacklebox.input.numderiv.flag{1} = set_deriv_flag;
        set(gcf,'UserData',tacklebox);
        
    case 'Dderivative_type'
        tacklebox = get(gcf,'UserData');
        deriv_val = get(tacklebox.Dderivative_type,'Value');
        %Gets the value, order number of the selected choice
        if deriv_val == 1
            set_deriv_flag = 0;
        elseif deriv_val >1
            set_deriv_flag = 1;
        end
        tacklebox.input.numderiv.flag{2} = set_deriv_flag;
        set(gcf,'UserData',tacklebox);
        
    case 'Gderivative_type'
        tacklebox = get(gcf,'UserData');
        deriv_val = get(tacklebox.Gderivative_type,'Value');
        %Gets the value, order number of the selected choice
        if deriv_val == 1
            set_deriv_flag = 0;
        elseif deriv_val >1
            set_deriv_flag = 1;
        end
        tacklebox.input.numderiv.flag{3} = set_deriv_flag;
        set(gcf,'UserData',tacklebox);
        
%------------------------------------------------------------------        
        
    case 'growth_zn'
        tacklebox = get(gcf,'UserData');
        growth_zn_value = str2num(get(tacklebox.growth_zn,'String'));
        if isempty(growth_zn_value)
            set(tacklebox.growth_zn,'String',num2str(tacklebox.input.growth_zn))
            return
        end        
        tacklebox.input.growth_zn_flag = 1;
        tacklebox.input.growth_zn = growth_zn_value;
        set(gcf,'UserData',tacklebox);
        
    case 'skin_change'
        tacklebox = get(gcf,'UserData');        
        skval = get(tacklebox.skin_change,'Value');
        %Gets the value, order number of the selected choice  
        FM_GUI_colors(tacklebox,skval);
        set(gcf,'UserData',tacklebox);
                   
    case 'edit_axis'
        tacklebox = get(gcf,'UserData');
        prompt={'The title :',...
            'The x-axis label :',...
            'The y-axis label :'};
        name_t = 'Input the new axis labels and title.';
        numlines =1;
        FM_axis_specifications;
        
        x_axis_label = axis_spec.xlabel{:};        
        y_axis_label = axis_spec.ylabel{:};        
        title_axis_label = strcat(axis_spec.title{1},axis_spec.title{2});        

        defaultanswer={title_axis_label,x_axis_label,y_axis_label};
        options.Resize='on';
        options.WindowStyle='normal';
        options.Interpreter='tex';
        
        new_axis = inputdlg(prompt, name_t ,numlines,defaultanswer,options);
        if isempty(new_axis)
            FM_axis_specifications;
        else
            gca;
            xlabel(new_axis{2},'FontWeight','bold');
            ylabel(new_axis{3},'FontWeight','bold');
            title(new_axis{1},'FontWeight','bold');
            
            %if y label is less than 5 characters then rotate it to be
            %horizontal
            if length(new_axis{3})>5
                set(get(gca,'YLabel'),'Rotation',90.0)
            end

        end
    case 'observable_index'
        
        tacklebox = get(gcf,'UserData');        
        obs_array = str2num(get(tacklebox.observable_index,'String'));
        if isempty(obs_array)
            set(tacklebox.observable_index,'String',num2str(tacklebox.input.observable_index))
            errordlg('Input must be a number/vector/matrix','Error');
            return
        end        
        tacklebox.input.observable_index =obs_array;
        set(gcf,'UserData',tacklebox);
        
    case 'data.cb1'
        
        tacklebox = get(gcf,'UserData');
        val = get(tacklebox.data.cb1,'value');
        val_obs_indx = tacklebox.input.observable_index;
        
        if val ==1
            if ~ismember(1,val_obs_indx)
                new_obs_indx = sort(horzcat(1,val_obs_indx)); 
            else
                new_obs_indx = val_obs_indx;
            end
        else
            [yn,loc] = ismember(1,val_obs_indx);
            if yn
                new_obs_indx = val_obs_indx(find(loc~=1:length(val_obs_indx)));  
            else
                new_obs_indx = val_obs_indx;
            end
            
        end
        tacklebox.input.observable_index = new_obs_indx;
        tacklebox.observable_index = num2str(new_obs_indx);
        set(gcf,'UserData',tacklebox);
        
    case 'data.cb2'
        
        tacklebox = get(gcf,'UserData');
        val = get(tacklebox.data.cb2,'value');
        val_obs_indx = tacklebox.input.observable_index;
        
        if val ==1
            if ~ismember(2,val_obs_indx)
                new_obs_indx = sort(horzcat(2,val_obs_indx)); 
            else
                new_obs_indx = val_obs_indx;
            end            
        else
            [yn,loc] = ismember(2,val_obs_indx);
            if yn
                new_obs_indx = val_obs_indx(find(loc~=1:length(val_obs_indx))); 
            else
                new_obs_indx = val_obs_indx;
            end
        end   
        tacklebox.input.observable_index = new_obs_indx;
        
        tacklebox.observable_index = num2str(new_obs_indx);
        set(gcf,'UserData',tacklebox);     
        
    case 'data.cb3'
        
        tacklebox = get(gcf,'UserData');
        val = get(tacklebox.data.cb3,'value');
        val_obs_indx = tacklebox.input.observable_index;
        
        if val ==1
            if ~ismember(3,val_obs_indx)
                new_obs_indx = sort(horzcat(3,val_obs_indx));
            else
                new_obs_indx = val_obs_indx;            
            end
        else
            [yn,loc] = ismember(3,val_obs_indx);
            if yn
                new_obs_indx = val_obs_indx(find(loc~=1:length(val_obs_indx)));  
            else
                new_obs_indx = val_obs_indx;            
            end
        end
        tacklebox.input.observable_index = new_obs_indx;
        tacklebox.observable_index = num2str(new_obs_indx);
        set(gcf,'UserData',tacklebox);   
        
    case 'data1'
        
        tacklebox = get(gcf,'UserData');        
        data_array = str2num(get(tacklebox.data.f1,'String'));
        data_orig_val = tacklebox.input.data{1}(:);
        if isempty(data_array)
            tacklebox.InputErrorFlag = 1; set(gcf,'UserData',tacklebox); 
            %set(tacklebox.data.f1,'String',num2str(data_orig_val))
            errordlg('Input in Redshift data must be a number/vector/matrix','Error');
            return
        end 
        
        fd1 =data_array;        
        if isvector(fd1) | size(fd1,1) + size(fd1,2)==2
            if isreal(fd1)
                tacklebox.input.data{1} = fd1(:);
                tacklebox.InputErrorFlag = 0;
            else
                tacklebox.InputErrorFlag = 1; set(gcf,'UserData',tacklebox);
                %set(tacklebox.data.f1,'String',num2str(data_orig_val))
                errordlg('data must be real')
                return
            end
        else
            errordlg('wrong data vector entered')
        end
        
        set(gcf,'UserData',tacklebox);  
        
    case 'data2'
        
        tacklebox = get(gcf,'UserData');        
        data_array = str2num(get(tacklebox.data.f2,'String'));
        data_orig_val = tacklebox.input.data{2}(:);
        if isempty(data_array)
            tacklebox.InputErrorFlag = 1; set(gcf,'UserData',tacklebox);
            %set(tacklebox.data.f2,'String',num2str(data_orig_val))
            errordlg('Input in Redshift data must be a number/vector/matrix','Error');
            return
        end        
        fd2 =data_array;        
        if isvector(fd2) | size(fd2,1) + size(fd2,2)==2            
            if isreal(fd2)
                tacklebox.input.data{2} = fd2(:);
                tacklebox.InputErrorFlag = 0;
            else
                tacklebox.InputErrorFlag = 1; set(gcf,'UserData',tacklebox);
                %set(tacklebox.data.f2,'String',num2str(data_orig_val))
                errordlg('data must be real')
                return
            end
        else
            errordlg('wrong data vector entered')
        end
        
        set(gcf,'UserData',tacklebox);    
        
    case 'data3'
        
        tacklebox = get(gcf,'UserData');        
        data_array = str2num(get(tacklebox.data.f3,'String'));
        data_orig_val = tacklebox.input.data{3}(:);
        
        if isempty(data_array)
            tacklebox.InputErrorFlag = 1; set(gcf,'UserData',tacklebox);
            %set(tacklebox.data.f3,'String',num2str(data_orig_val))
            errordlg('Input in Redshift data must be a number/vector/matrix','Error'); 
            return
        end    
        
        fd3 =data_array;        
        if isvector(fd3) | size(fd3,1) + size(fd3,2)==2
            if isreal(fd3)
                tacklebox.input.data{3} = fd3(:);
                tacklebox.InputErrorFlag = 0;
            else
                tacklebox.InputErrorFlag = 1; set(gcf,'UserData',tacklebox);
                %set(tacklebox.data.f3,'String',num2str(data_orig_val))
                errordlg('data must be real')
                return
            end
        else
            errordlg('wrong data vector entered')
        end
        
        set(gcf,'UserData',tacklebox); 
        
    case 'base_parameters'
        
        tacklebox = get(gcf,'UserData');
        fiducial_array = str2num(get(tacklebox.base_parameters,'String'));
        if isempty(fiducial_array)
            set(tacklebox.base_parameters,'String',num2str(tacklebox.input.base_parameters))
            errordlg('Input must be a number/vector/matrix','Error');
            return
        end        
        tacklebox.input.base_parameters = fiducial_array;
        set(gcf,'UserData',tacklebox);
        
    case 'prior_matrix'
        
        tacklebox = get(gcf,'UserData');
        prior_array = str2num(get(tacklebox.prior_matrix,'String'));
        if isempty(prior_array)
            set(tacklebox.prior_matrix,'String',num2str(tacklebox.input.prior_matrix))
            errordlg('Input must be a number/vector/matrix','Error');
            return
        end        
        tacklebox.input.prior_matrix =prior_array;
        set(gcf,'UserData',tacklebox);
        
       
    case 'error1'
        
        tacklebox = get(gcf,'UserData');        
        error_array = str2num(get(tacklebox.error.f1,'String'));
        error_orig_val = tacklebox.input.error{1}(:);
        
        if isempty(error_array)
            tacklebox.InputErrorFlag = 1; set(gcf,'UserData',tacklebox);
            %set(tacklebox.error.f1,'String',num2str(error_orig_val))
            errordlg('Input in Fractional error must be a number/vector/matrix','Error'); 
            return
        end        
        fv1 =error_array;        
        if isvector(fv1) | size(fv1,1)+size(fv1,2)==1;
            if isreal(fv1)
                tacklebox.input.error{1} = fv1(:);
                tacklebox.InputErrorFlag = 0;
            else
                tacklebox.InputErrorFlag = 1; set(gcf,'UserData',tacklebox);
                %set(tacklebox.error.f1,'String',num2str(error_orig_val))
                errordlg('error must be real')
                return
            end
        else
            errordlg('wrong entry to error')
        end     
        set(gcf,'UserData',tacklebox);  
        
    case 'error2'
        
        tacklebox = get(gcf,'UserData');        
        error_array = str2num(get(tacklebox.error.f2,'String'));
        error_orig_val = tacklebox.input.error{2}(:);
        
        if isempty(error_array)
            tacklebox.InputErrorFlag = 1; set(gcf,'UserData',tacklebox);
            %set(tacklebox.error.f2,'String',num2str(error_orig_val))
            errordlg('Input in Fractional error must be a number/vector/matrix','Error');
            return
        end        
        fv2 =error_array;
        if isvector(fv2) | size(fv2,1)+size(fv2,2)==1;
            if isreal(fv2)
                tacklebox.input.error{2} = fv2(:);
                tacklebox.InputErrorFlag = 0;
            else
                tacklebox.InputErrorFlag = 1; set(gcf,'UserData',tacklebox);
                %set(tacklebox.error.f2,'String',num2str(error_orig_val))
                errordlg('error must be real')
                return
            end
        else
            errordlg('wrong entry to error')
        end     
        set(gcf,'UserData',tacklebox);    
        
    case 'error3'
        
        tacklebox = get(gcf,'UserData');        
        error_array = str2num(get(tacklebox.error.f3,'String'));
        error_orig_val = tacklebox.input.error{3}(:);
        
        if isempty(error_array)
            tacklebox.InputErrorFlag = 1; set(gcf,'UserData',tacklebox);
            %set(tacklebox.error.f3,'String',num2str(error_orig_val))
            errordlg('Input in Fractional error must be a number/vector/matrix','Error');
            return
        end        
        fv3 =error_array;
        if isvector(fv3) | size(fv3,1)+size(fv3,2)==1;
            if isreal(fv3)
                tacklebox.input.error{3} = fv3(:);
                tacklebox.InputErrorFlag = 0;
            else
                tacklebox.InputErrorFlag = 1; set(gcf,'UserData',tacklebox);
                %set(tacklebox.error.f3,'String',num2str(error_orig_val))
                errordlg('error must be real')
                return
            end
        else
            errordlg('wrong entry to error')
        end     
        set(gcf,'UserData',tacklebox);    
        
                    
    case 'choose'
        
        %Selects the default parameter values from the given input templats
        tacklebox = get(gcf,'UserData');
        str = get(tacklebox.choose_2,'String');
        chval = get(tacklebox.choose_2,'Value'); %Gets the value, order number of the selected choice  

           switch chval
               case 3
                    %loads an input structure from file and assigns it to param_struct
                    [filename, pathname] = uigetfile('*.m','Select the M - file that contains input structure');

                    if pathname==0 
                        return
                    end

                    [pathstr,name,ext] = fileparts(filename); 

                    current_dir = pwd;
                    cd(char(pathname))%change to the browsed file directory   

                    if name~=0 & strcmp(ext,'.m')

                        if ~isstruct(eval(name))
                            errordlg('Input file must be a structure!')                
                        end

                        new_struct = eval(sprintf(name));    %set the loaded structure as new_structure        
                        field_names = fieldnames(new_struct); %gets the field names of the loaded structure

                        for i = 1:length(field_names)                
                                eval(['tacklebox.input.',field_names{i},' = new_struct.',field_names{i},';']); 
                                %if the new_structure has less fields, the unspecified fields 
                                %will not be affected. If the new_structure has more
                                %fields, it will be added in the tacklebox.input fields

                        end

                        cd(char(current_dir)) %change to the original directory

                        %setting data boxes
                        data_val = tacklebox.input.data;
                        if iscell(tacklebox.input.data) 
                               if length(data_val)>3
                                    error('data cell length must be 3 or less') 
                               end
                                for i = 1:length(data_val)
                                    set(eval(['tacklebox.data.f',num2str(i)]),'string',num2str(data_val{i}(:)))
                                end
                        elseif isvector(tacklebox.input.data)                                                        
                                tacklebox.input.data = cell(1,3);
                                for i = 1:3
                                    set(eval(['tacklebox.data.f',num2str(i)]),'string',num2str(data_val(:)))
                                    eval(['tacklebox.input.data{',num2str(i),'}=data_val;']);
                                end  
                        else
                            error('data is not a vector nor a cell')
                        end 

                       %setting the error boxes
                       error_val = tacklebox.input.error;
                       lv = length(error_val);
                       if iscell(error_val)                
                            if lv>3
                                error('error cell length must be 3 or less') 
                            end
                            for i = 1:length(error_val)
                                set(eval(['tacklebox.error.f',num2str(i)]),'string',num2str(error_val{i}(:)))
                            end 

                        elseif size(error_val,1)>1 & size(error_val,2)>1

                           msgbox('Each row represents an error on each observable')

                           if size(error_val,1)>3
                                error('error cell length must be 3 or less') 
                           end

                           for i = 1:size(error_val,1)
                               set(eval(['tacklebox.error.f',num2str(i)]),'string',num2str(error_val(i,:)))
                                eval(['tacklebox.input.error{',num2str(i),'}=error_val(',num2str(i),',:);']);                 
                           end
                        elseif isvector(error_val)            
                            for i = 1:3
                                set(eval(['tacklebox.error.f',num2str(i)]),'string',num2str(error_val(:)))
                                 eval(sprintf('tacklebox.input.error{%0.5g} = error_val;',i));
                            end
                        else
                            error('error is not a cell, a vector or a matrix')
                       end  
                       
                        set(tacklebox.observable_index,'string',num2str(tacklebox.input.observable_index))
                        set(tacklebox.base_parameters,'string',num2str(tacklebox.input.base_parameters))
                        set(tacklebox.prior_matrix,'string',num2str(tacklebox.input.prior_matrix))
                        
                        set(tacklebox.data.cb1,'value',ismember(1,tacklebox.input.observable_index))
                        set(tacklebox.data.cb2,'value',ismember(2,tacklebox.input.observable_index))
                        set(tacklebox.data.cb3,'value',ismember(3,tacklebox.input.observable_index))
                        
                        set(tacklebox.growth_zn,'String',num2str(tacklebox.input.growth_zn))
                        
                        set(tacklebox.Hderivative_type,'Value',tacklebox.input.numderiv.flag{1}+1)
                        set(tacklebox.Dderivative_type,'Value',tacklebox.input.numderiv.flag{2}+1)
                        set(tacklebox.Gderivative_type,'Value',tacklebox.input.numderiv.flag{3}+1)                        

                        set(tacklebox.param_cb1,'value',ismember(1,tacklebox.input.parameters_to_plot))
                        set(tacklebox.param_cb2,'value',ismember(2,tacklebox.input.parameters_to_plot))
                        set(tacklebox.param_cb3,'value',ismember(3,tacklebox.input.parameters_to_plot))                        
                        set(tacklebox.param_cb4,'value',ismember(4,tacklebox.input.parameters_to_plot))
                        set(tacklebox.param_cb5,'value',ismember(5,tacklebox.input.parameters_to_plot))       

                    else
                    end                       
               case 2                                       
                    new_struct = Seo_Eisenstein_2003;
                    
                    field_names = fieldnames(new_struct); %gets the field names of the loaded structure

                    for i = 1:length(field_names)                
                            eval(['tacklebox.input.',field_names{i},' = new_struct.',field_names{i},';']); 
                            %if the new_structure has less fields, the unspecified fields 
                            %will not be affected. If the new_structure has more
                            %fields, it will be added in the tacklebox.input fields

                    end
                    
                    %setting data boxes
                    data_val = tacklebox.input.data;
                    if iscell(tacklebox.input.data) 
                       if length(data_val)>3
                            error('data cell length must be 3 or less') 
                       end                    
                        for i = 1:length(data_val)
                            set(eval(['tacklebox.data.f',num2str(i)]),'string',num2str(data_val{i}(:)))
                        end
                    elseif isvector(tacklebox.input.data)                                                        
                            tacklebox.input.data = cell(1,3);
                            for i = 1:3
                                set(eval(['tacklebox.data.f',num2str(i)]),'string',num2str(data_val(:)))
                                eval(['tacklebox.input.data{',num2str(i),'}=data_val;']);
                            end  
                    else
                        error('data is neither vector nor cell')
                    end 

                   %setting the error boxes
                   error_val = tacklebox.input.error;
                   if iscell(error_val)
                       if length(error_val)>3
                            error('error cell length must be 3 or less') 
                        end                   
                        for i = 1:length(error_val)
                            set(eval(['tacklebox.error.f',num2str(i)]),'string',num2str(error_val{i}(:)))
                        end 

                    elseif isvector(error_val)            
                        for i = 1:3
                            set(eval(['tacklebox.error.f',num2str(i)]),'string',num2str(error_val(:)))
                             eval(['tacklebox.input.error{' ,num2str(i), '} = error_val;']);
                        end
                    else
                        error('error is not a cell, a vector or a matrix')
                   end
                    
                    
                    set(tacklebox.observable_index,'string',num2str(tacklebox.input.observable_index))                    
                    set(tacklebox.base_parameters,'string',num2str(tacklebox.input.base_parameters))
                    set(tacklebox.prior_matrix,'string',num2str(tacklebox.input.prior_matrix))
                                       
                    set(tacklebox.data.cb1,'value',ismember(1,tacklebox.input.observable_index))
                    set(tacklebox.data.cb2,'value',ismember(2,tacklebox.input.observable_index))
                    set(tacklebox.data.cb3,'value',ismember(3,tacklebox.input.observable_index))
                    
                    set(tacklebox.growth_zn,'String',num2str(tacklebox.input.growth_zn))

                    set(tacklebox.Hderivative_type,'Value',tacklebox.input.numderiv.flag{1}+1)
                    set(tacklebox.Dderivative_type,'Value',tacklebox.input.numderiv.flag{2}+1)
                    set(tacklebox.Gderivative_type,'Value',tacklebox.input.numderiv.flag{3}+1)                    
                    
                    set(tacklebox.param_cb1,'value',ismember(1,tacklebox.input.parameters_to_plot))
                    set(tacklebox.param_cb2,'value',ismember(2,tacklebox.input.parameters_to_plot))
                    set(tacklebox.param_cb3,'value',ismember(3,tacklebox.input.parameters_to_plot))                        
                    set(tacklebox.param_cb4,'value',ismember(4,tacklebox.input.parameters_to_plot))
                    set(tacklebox.param_cb5,'value',ismember(5,tacklebox.input.parameters_to_plot))               
                   
               case 1 
                    
                    new_struct = Cooray_et_al_2004;            
                    field_names = fieldnames(new_struct); %gets the field names of the loaded structure

                    for i = 1:length(field_names)                
                            eval(['tacklebox.input.',field_names{i},' = new_struct.',field_names{i},';']); 
                            %if the new_structure has less fields, the unspecified fields 
                            %will not be affected. If the new_structure has more
                            %fields, it will be added in the
                            %tacklebox.input fields
                    end 
                    
                    %setting data boxes
                    data_val = tacklebox.input.data;
                    if iscell(tacklebox.input.data)
                       if length(data_val)>3
                            error('data cell length must be 3 or less') 
                       end                        
                        for i = 1:length(data_val)
                            set(eval(['tacklebox.data.f',num2str(i)]),'string',num2str(data_val{i}(:)))
                        end
                    elseif isvector(tacklebox.input.data)                                                        
                            tacklebox.input.data = cell(1,3);
                            for i = 1:3
                                set(eval(['tacklebox.data.f',num2str(i)]),'string',num2str(data_val(:)))
                                eval(['tacklebox.input.data{',num2str(i),'}=data_val;']);
                            end  
                    else
                        error('data is neither vector nor cell')
                    end 

                   %setting the error boxes
                   error_val = tacklebox.input.error;
                   if iscell(error_val)  
                       if length(error_val)>3
                            error('error cell length must be 3 or less') 
                        end
                        for i = 1:length(error_val)
                            set(eval(['tacklebox.error.f',num2str(i)]),'string',num2str(error_val{i}(:)))
                        end 

                    elseif size(error_val,1)>1 & size(error_val,2)>1

                       msgbox('Each row is representing an error on each observable')
                       for i = 1:size(error_val,1)
                           set(eval(['tacklebox.error.f',num2str(i)]),'string',num2str(error_val(i,:)))
                            eval(['tacklebox.input.error{',num2str(i),'}=error_val(',num2str(i),',:);']);                 
                       end
                    elseif isvector(error_val)            
                        for i = 1:3
                            set(eval(['tacklebox.error.f',num2str(i)]),'string',num2str(error_val(:)))
                             eval(sprintf('tacklebox.input.error{%0.5g} = error_val;',i));
                        end
                    else
                        error('error is not a cell, a vector or a matrix')
                   end 
                    
                    
                    set(tacklebox.observable_index,'string',num2str(tacklebox.input.observable_index))                
                    set(tacklebox.base_parameters,'string',num2str(tacklebox.input.base_parameters))
                    set(tacklebox.prior_matrix,'string',num2str(tacklebox.input.prior_matrix))
                    
                    set(tacklebox.data.cb1,'value',ismember(1,tacklebox.input.observable_index))
                    set(tacklebox.data.cb2,'value',ismember(2,tacklebox.input.observable_index))
                    set(tacklebox.data.cb3,'value',ismember(3,tacklebox.input.observable_index))
                    
                    set(tacklebox.growth_zn,'String',num2str(tacklebox.input.growth_zn))

                    set(tacklebox.Hderivative_type,'Value',tacklebox.input.numderiv.flag{1}+1)
                    set(tacklebox.Dderivative_type,'Value',tacklebox.input.numderiv.flag{2}+1)
                    set(tacklebox.Gderivative_type,'Value',tacklebox.input.numderiv.flag{3}+1)                    

                    set(tacklebox.param_cb1,'value',ismember(1,tacklebox.input.parameters_to_plot))
                    set(tacklebox.param_cb2,'value',ismember(2,tacklebox.input.parameters_to_plot))
                    set(tacklebox.param_cb3,'value',ismember(3,tacklebox.input.parameters_to_plot))                        
                    set(tacklebox.param_cb4,'value',ismember(4,tacklebox.input.parameters_to_plot))
                    set(tacklebox.param_cb5,'value',ismember(5,tacklebox.input.parameters_to_plot))               
                   
           end
        set(gcf,'UserData',tacklebox);
       
%--------------------------------------------------------------------------

%==================================================================        
% ============ run the UserData by calling FM_run ================     
%==================================================================
% Now that the input data are specified - run the
% code!
        
    case 'Go'           
        
        tacklebox = get(gcf,'UserData'); 
        %tacklebox.goCount = tacklebox.goCount + 1;
        holdon_cb_val = get(tacklebox.holdon,'value');
        map = colormap('lines');
        
        if holdon_cb_val==1 
            hold on             
        else 
            hold off            
        end 
        
        %========================================================
        %choose the line color
        val_line_color = get(tacklebox.line_color,'value');
        if val_line_color == 1
            tacklebox.input.line_color = tacklebox.c_line;
        else
            if holdon_cb_val==1
                indx = floor(1+rand.*length(map)); 
                tacklebox.input.line_color = map(indx,:); 
            else 
                tacklebox.input.line_color = map(1,:);
            end
        end
        
        %====================
        %set the line style as defined in the lineStyle box
        line_style_str = {'-','--',':','-.','none'};
        line_style_val = get(tacklebox.line_style,'value');
        tacklebox.input.line_style = line_style_str{line_style_val};
        
        %=====================
        % get the confidence level
        indx_sigma_level = get(tacklebox.confidenceLevel,'value');
        sigma_level = [2.31 6.17 11.83]; 
        tacklebox.input.CL_value = sigma_level(indx_sigma_level);
        
        %===================
        %set the x and y range of the ellipse plot  
        val_xaxis_lim = get(tacklebox.cb_xlim,'value'); %resize x axis check
        if val_xaxis_lim == 1
            tacklebox.input.xlim_val = str2num(get(tacklebox.xlim,'string'));            
        end
        val_yaxis_lim = get(tacklebox.cb_xlim,'value'); %resize y axis check 
        if val_yaxis_lim == 1
            tacklebox.input.ylim_val = str2num(get(tacklebox.ylim,'string'));            
        end    
        
        %======================
        %set a flag for filling the ellipse with solid color
        val_fill = get(tacklebox.fill,'value');
        if val_fill == 1
            if isfield(tacklebox.input,'c_fill')                
                tacklebox.input.fill_flag = 1;
                tacklebox.c_fill= tacklebox.input.c_fill;%this is duplicated to the tacklebox.c_fill field just to be sure that the access is consistent with other reference i.e. no need to search tacklebox.input
            else                    
                errordlg('No fill color is defined')                    
            end
        else
            tacklebox.input.fill_flag = 0;
        end
        
        %==================================================================       
        %------------------------------------------------------------------
       
        % If everything is fine - go to excution.
        %'try - catch' allows us to read error messages should anything go
        % wrong during excution
        
        if tacklebox.InputErrorFlag == 1  %if the user enters an incorrect input value
            errordlg('The value you entered in the input structure is not correct','Error')
            return
        end
        
        
        try
            
            h=waitbar(1,'Running...', 'Color',[204 204 204]./255);
            waitbar(1);
            close(h);      
            
            tacklebox.input = FM_errorchecker(tacklebox.input);

            
            tacklebox.input.guiRun = 1; %flag for GUI based run 
            set(gcf,'currentaxes',tacklebox.ax)
            output = FM_run(tacklebox.input); %call Fm_run and perform the fisher computation 
            tacklebox.output = output;
            outputStructure = output

        
        catch
            

            
            % show the last error - where the breakdown happened            
            s = lasterror;                      
            errordlg(s.message)          
            error(s.identifier,s.message)
            return

        end
        tacklebox.PlotPresent = 1; %plot is successful
        %--------------------------------------------
        %write the Figure of merit or the error on a single parameter
        if ~isempty(output.fom)   
            
           tacklebox.input.num_parameters = length(tacklebox.input.parameters_to_plot); % the number of parameters you are considering
           if tacklebox.input.num_parameters == 1
               set(tacklebox.DetF_name,'String',strcat('sigma(',tacklebox.input.parameter_names(tacklebox.input.parameters_to_plot), ') = '))
           else
               set(tacklebox.DetF_name,'String','Figure of Merit  = ')
           end             

            
            n = length(output.fom); %the number of different FoM types 
            
             for i = 1:n %run over the different type of FoMs                
                 for j = 1:length(tacklebox.fom{i})+1   %builds a history of each fom type                  
                  
                     if j==1 
                        each_fom_hist{j} = num2str(output.fom(i), '%-4.2f\t');
                     elseif length(tacklebox.fom{i})==1
                        each_fom_hist{j} = tacklebox.fom{i}(1);
                     else                         
                        each_fom_hist{j} = tacklebox.fom{i}{j-1};
                     end
                 end          
                 tacklebox.fom{i} = each_fom_hist;
             end            
                       
            fom_type_val = get(tacklebox.fom_type,'value');
            
           if tacklebox.input.num_parameters == 1
               % We have only a 1-dimensional likelihood, and hence 1 error
               % value instead of a range of FoMs
            
               tacklebox.fom_type = uicontrol(gcf,'parent',tacklebox.detf_panel,...
                   'Style','popupmenu',...
                   'String','1-sigma Error',...            
                   'TooltipString','Choose the Figure of Merit from a range of values.',... 
                   'Units','normalized',...
                   'Position',[0.75,0.45,0.24,0.45],...
                   'FontWeight', 'bold',...
                   'Callback',[tacklebox.uiname,' fom_type']);
               set(tacklebox.detf_val,'String',tacklebox.fom{fom_type_val}); %set the detf value in the detf box
         
           else
               % We have the usual 2D case
        
               tacklebox.fom_type = uicontrol(gcf,'parent',tacklebox.detf_panel,...
                   'Style','popupmenu',...
                   'String','DETF|1/Area 2-sigma|1/Area 1-sigma|Area 1-sigma|Trace(cov)|sum(cov^2)',...            
                   'TooltipString','Choose the Figure of Merit from a range of values.',... 
                   'Units','normalized',...
                   'Position',[0.75,0.45,0.24,0.45],...
                   'FontWeight', 'bold',...
                   'Callback',[tacklebox.uiname,' fom_type']);
        
                if  fom_type_val == n+1
                    set(tacklebox.fom_type,'value',1);
                    set(tacklebox.detf_val,'String',tacklebox.fom{1}); %set the detf value in the detf box
                else
                    set(tacklebox.detf_val,'String',tacklebox.fom{fom_type_val}); %set the detf value in the detf box
              
                end                
           end
           
        end
        set(tacklebox.cb_xlim,'value',0)
        set(tacklebox.cb_ylim,'value',0)
        
        
        FM_axis_specifications;
        
        im_chval = get(tacklebox.image_choose,'Value');
        skval = get(tacklebox.skin_change,'Value');
        FM_GUI_colors(tacklebox,skval);
        if im_chval==4
            FM_GUI_colors(tacklebox,6);
        end
        
        set(tacklebox.ax,'layer','top')
        tacklebox.fighandle = gca;
        
        %Always set the ButtonDownFcn of the plotting axis
        set(tacklebox.ax,'ButtonDownFcn',{@axesButtonDownFcn,tacklebox});
        
        set(gcf,'UserData',tacklebox);
        

    case 'priorBrowse'
        
        tacklebox = get(gcf,'UserData');        
        S = uiimport;
        if ~isstruct(S)            
            return
        end
        S_field_name = fieldnames(S);
        prior_matrix_value = eval(char(['S.',char(S_field_name)]));
        if ~isreal(prior_matrix_value)
            error('prior matrix must be real')
        end
        if isvector(prior_matrix_value)
            tacklebox.input.prior_matrix = diag(prior_matrix_value);
            msgbox('vector values are considered as the diagonal of a matrix')
        else
            tacklebox.input.prior_matrix = prior_matrix_value;
        end
        set(tacklebox.prior_matrix,'string',num2str(tacklebox.input.prior_matrix))
        set(gcf,'UserData',tacklebox);
        
    case 'priorOnOff'
        
        tacklebox = get(gcf,'UserData');        
        val = get(tacklebox.priorOnOff,'value');
        priorStrVal = get(tacklebox.prior_matrix,'string');
        PriorNumVal = str2num(priorStrVal);
        
        if val==1
            set(tacklebox.prior_matrix,'enable','on')
            tacklebox.input.prior_matrix = PriorNumVal;
        else
            set(tacklebox.prior_matrix,'enable','off')
            tacklebox.input.prior_matrix = zeros(size(tacklebox.input.prior_matrix));            
        end
        set(gcf,'UserData',tacklebox);
        
    case 'dataBrowse'
        
        tacklebox = get(gcf,'UserData');        
        S = uiimport;
        if ~isstruct(S)            
            return
        end        
        S_field_name = fieldnames(S);
        data_val = eval(char(['S.',char(S_field_name)]));
        
            %setting data boxes
            if iscell(data_val)  
                    if length(data_val)>3
                        error('data cell length must be 3 or less') 
                    end
                    for i = 1:length(data_val)
                        set(eval(['tacklebox.data.f',num2str(i)]),'string',num2str(data_val{i}(:)))
                    end
                    tacklebox.input.data = data_val;
                    
            elseif size(data_val,1)>1 & size(data_val,2)>1
                 if size(data_val,2)>3
                        error('There can only be 3 or less observables (columns) listed') 
                   end
                msgbox('Each column corresponds to the observable while each row element is treated as the redshift data')
                tacklebox.input.data  = cell(1,3);
                    for i = 1:size(data_val,2)
                        set(eval(['tacklebox.data.f',num2str(i)]),'string',num2str(data_val(:,i)'))
                        eval(['tacklebox.input.data{',num2str(i),'}=data_val(',num2str(i),',:);']);
                    end
            elseif isvector(data_val)  
                tacklebox.input.data = cell(1,3);
                    for i = 1:3
                        set(eval(['tacklebox.data.f',num2str(i)]),'string',num2str(data_val(:)))
                        eval(['tacklebox.input.data{',num2str(i),'} = data_val(:);']);
                    end 
            else
                error('data is not a cell, vector or matrix')
            end 
        set(gcf,'UserData',tacklebox);
            
        
    case 'errorBrowse'
        
        tacklebox = get(gcf,'UserData');
         
        S = uiimport; %opens a window to load a error matrix or vector
        if ~isstruct(S)            
            return
        end        
        S_field_name = fieldnames(S);
        error_val = eval(char(['S.',char(S_field_name)]));
        
        if iscell(error_val)
             if length(error_val)>3
                    error('error cell length must be 3 or less') 
             end
            tacklebox.input.error = error_val;
            for i = 1:length(error_val)
                set(eval(['tacklebox.error.f',num2str(i)]),'string',num2str(error_val{i}(:)))
            end 
            
        elseif size(error_val,1)>1 & size(error_val,2)>1
            
           msgbox('Each column corresponds to the observable while each row element is treated as the error data')
            if size(error_val,2)>3
                error('There can only be 3 or less observables (columns) listed') 
           end
           for i = 1:size(error_val,1)
               set(eval(['tacklebox.error.f',num2str(i)]),'string',num2str(error_val(:,i)))
                eval(['tacklebox.input.error{',num2str(i),'}=error_val(',num2str(i),',:);']);                 
           end
        elseif isvector(error_val)  
            tacklebox.input.error = cell(3,1);
            for i = 1:3
                set(eval(['tacklebox.error.f',num2str(i)]),'string',num2str(error_val(:)))
                 eval(['tacklebox.input.error{',num2str(i),'} = error_val(:);']);
            end
        else
            error('error is not a cell, a vector or a matrix')
        end        
       set(gcf,'UserData',tacklebox);
       
    case 'save_plot'
        
        tacklebox = get(gcf,'UserData');
        
        %++++++++++++
        %checks whether the user produced a plot with the input structure or not 
        if isfield(tacklebox,'PlotPresent')
            if tacklebox.PlotPresent == 0;
                errordlg('You need to first generate a plot with the given input structure by pressing the Run button. This will allow you to then produce a report or save the figure.','Error')
                return
            end
        else
            errordlg('You need to first generate a plot with the given input structure by pressing the Run button. This will allow you to then produce a report or save the figure.','Error')
            return
        end                
        %++++++++++++
        
        chose_val = get(tacklebox.save_plot,'value');
        
        %-add warning if hold on was on.
        if ishold && chose_val==3
            YNans = questdlg({'The Hold on feature is on. The input output structure to be saved',...
                'may not be representative of the current plot in the figure.' ...
                '                              ',...
                'Un-click Hold on and run again for a representative report.',...
                '                                              ',...
                'Do you still want to generate the report anyway?' },'** Holdon warning **','Yes');
            if strcmp(YNans,'No')
                chose_val=6;
            end
        end
        
        if chose_val==2
            [filename, pathname] = uiputfile(...
            {'*.txt','MATLAB Files (*.txt)';
             '*.txt','Models (*.txt)'}, ...
             'Save the .txt file for the text report');
         
            %if user cancels save command, nothing happens
            if isequal(filename,0) || isequal(pathname,0)
                return
            else
                [pathstr, filename, ext, versn] = fileparts(filename);
                fufilename = fullfile(pathname,filename);
                FM_report_text(tacklebox.input,fufilename,tacklebox.output);

                h = waitbar(0,'Please wait...');
                for i=1:100, % computation here %
                waitbar(i/100)
                end
                close(h)
                if ~strcmp('.txt',ext)
                    ext = '.txt';
                end
                h = msgbox({'A Text Report was sucessfully generated and is saved in the folder             ',...
                    '                         ',...
                    ['' pathname '.'], ['The filename is: ' filename ext '.']},...
                    'Text Report Saving confirmation');
                pause(30)
                if ishandle(h)
                    close(h)
                end
            end
            
        elseif chose_val==3
            
            [figname, pathname] = uiputfile(...
            {'*.eps','MATLAB Files (*.eps)';
             '*.eps','Models (*.eps)'}, ...
             'Save the .eps file for the latex report');
            %if user cancels save command, nothing happens
            if isequal(figname,0) || isequal(pathname,0)
                return
            else
                [pathstr, figname, ext_fig, versn] = fileparts(figname);
                figname = fullfile(pathname,figname);
                [filename, pathname] = uiputfile(...
                {'*.tex','MATLAB Files (*.tex)';
                 '*.tex','Models (*.tex)'}, ...
                 'Save the .tex file for the latex report');
                %if user cancels save command, nothing happens
                if isequal(filename,0) || isequal(pathname,0)
                    return
                else
                    [pathstr, fname, ext_file, versn] = fileparts(filename);
                    filename = fullfile(pathname,fname);
                    %create a new figure
                    axes_units = get(tacklebox.fighandle,'Units');
                    axes_pos = get(tacklebox.fighandle,'Position');
                    newfig = figure('visible', 'off', ...
                                     'Interruptible','off',...
                                     'Color',get(0,'DefaultUIControlBackgroundColor'));
                    set(newfig,'Units',axes_units);
                    set(newfig,'Position',[axes_pos(1) axes_pos(2) axes_pos(3) axes_pos(4)+0.1])


                    %get the units and position of the axes object

                    %copies hx onto new figure
                    axesObject2 = copyobj(tacklebox.fighandle,gcf);
                    %realign the axes object on the new figure
                    set(axesObject2,'Units',axes_units);  
                    set(axesObject2,'Position',[0.1,0.1,0.8,0.8])

                    legendObject = legend;
            % 
                    %if a legendObject was passed to this function . . .
                    if ~isempty(legendObject)

                        %get the units and position of the legend object
                        legend_units = get(legendObject,'Units');
                        legend_pos = get(legendObject,'Position');

                        %copies the legend onto the the new figure
                        legendObject2 = copyobj(legendObject,newFig);

                        %re-align the legend object on the new figure
                        set(legendObject2,'Units',legend_units);
                        set(legendObject2,'Position',[legend_pos(1) legend_pos(2) legend_pos(3) legend_pos(4)])


                    end

                    if ~strcmp(ext_fig,'.eps')
                        ext_fig = '.eps';
                    end
                    saveas(newfig,[figname ext_fig],'psc2')
                    FM_report_latex(tacklebox.input,filename,[figname ext_fig],tacklebox.output);

                    h = waitbar(0,'Please wait...');
                    for i=1:50 % computation here %
                    waitbar(i/50)
                    end
                    close(h)
                    [pathstr, figname, ext, versn] = fileparts(figname);
                    h = msgbox({'A Latex Report is sucessfully generated and is saved in the folder  ',...
                        '                         ',...
                        ['' pathname '.'], ['The filename is:  ' fname '.tex'],...
                         ['The eps filename of the plot is: ' figname '.eps.']},...
                        'Text Report Saving confirmation');
                    pause(60)
                    if ishandle(h)
                        close(h)
                    end
                end
            end
        elseif chose_val==4
            %stores savepath for the phase plot
            [filename, pathname] = uiputfile(...
            {'*.eps;*.jpg;*.png;*.ps;*.pdf','MATLAB Files (*.eps,*.fig,*.jpg,*.png,*.ps,*.pdf)';
             '*.fig', 'Figures (*.fig)'; ...
             '*.jpeg','Figures (*.jpg)'; ...
             '*.png','MAT-files (*.png)'; ...
             '*.eps','Models (*.eps)'; ...
             '*.pdf','Models (*.pdf)'; ...
             '*.*',  'All Files (*.*)'}, ...
             'Save as');

            %if user cancels save command, nothing happens
            if isequal(filename,0) || isequal(pathname,0)
                return
            end

            [pathstr, name, ext, versn] = fileparts(filename);
            %create a new figure
            axes_units = get(tacklebox.fighandle,'Units');
            axes_pos = get(tacklebox.fighandle,'Position');

            newfig = figure('visible', 'off', ...
                             'Interruptible','off',...
                             'Color',get(0,'DefaultUIControlBackgroundColor'));
            set(newfig,'Units',axes_units);
            set(newfig,'Position',[axes_pos(1) axes_pos(2) axes_pos(3) axes_pos(4)+0.1])


            %get the units and position of the axes object

            %copies hx onto new figure
            axesObject2 = copyobj(tacklebox.fighandle,gcf);
            %realign the axes object on the new figure
            set(axesObject2,'Units',axes_units);  
            set(axesObject2,'Position',[0.1,0.1,0.8,0.8])

            legendObject = legend;
    % 
            %if a legendObject was passed to this function . . .
            if ~isempty(legendObject)

                %get the units and position of the legend object
                legend_units = get(legendObject,'Units');
                legend_pos = get(legendObject,'Position');

                %copies the legend onto the the new figure
                legendObject2 = copyobj(legendObject,newFig);

                %re-align the legend object on the new figure
                set(legendObject2,'Units',legend_units);
                set(legendObject2,'Position',[legend_pos(1) legend_pos(2) legend_pos(3) legend_pos(4)])


            end


            %saves the plot
            switch ext
                case '.eps'
                    saveas(newfig,[pathname filename],'psc2')
                case '.fig'
                    set(gcf,'visible','on')
                    saveas(newfig,[pathname filename])
                otherwise
                    saveas(newfig,[pathname filename])
            end
            %closes the figure
            close(newfig)
            
        end
        
    case 'line_color'
        
        tacklebox = get(gcf,'UserData');
        val_line_color = get(tacklebox.line_color,'value');
        if val_line_color == 1           
            h1 = uimenu;
            tacklebox.c_line = uisetcolor(h1, 'Choose Line Color');

        else
            return
        end
        set(gcf,'UserData',tacklebox);    
        
    case 'fill'
        
        tacklebox = get(gcf,'UserData');                
        val_fill = get(tacklebox.fill,'value');
        
        if val_fill==1             
            h1 = uimenu;
            tacklebox.input.c_fill = uisetcolor(h1, 'Choose Fill Color');%this is not 100% consistent with setting the other plot specifications (should be tacklebox.c_fill or something similar)
        else
            return
        end
        
        set(gcf,'UserData',tacklebox);
        
        
    case 'xlim_resize'
        %resize the x axis 
        tacklebox = get(gcf,'UserData');
        
        val_xaxis_lim = get(tacklebox.cb_xlim,'value'); %resize x axis check
        if val_xaxis_lim == 1
            xlim_val = str2num(get(tacklebox.xlim,'string'));
            set(gca,'xlim',xlim_val)
        end
        
        set(gcf,'UserData',tacklebox);
                
    case 'ylim_resize'
        %resize the x axis 
        tacklebox = get(gcf,'UserData');
        
        val_yaxis_lim = get(tacklebox.cb_ylim,'value'); %resize y axis check 
        if val_yaxis_lim == 1
            ylim_val = str2num(get(tacklebox.ylim,'string'));  
            set(gca,'ylim',ylim_val)
        end
        
        set(gcf,'UserData',tacklebox);
        
     case 'reset'
         
        tacklebox = get(gcf,'UserData');
        cla reset
        tacklebox.PlotPresent = 0;
        
        %If interactive plotting is on, set ButtinDownFcn of the axes
        if strcmp(get(tacklebox.IntPlot, 'Checked'),'on')
            set(gca,'ButtonDownFcn',{@axesButtonDownFcn,tacklebox});
            set(gca,'xlim',[-2 0],'ylim',[-1 1])
        end
        box on
        
        set(gcf,'UserData',tacklebox);
        
    case 'xlimit'
        tacklebox = get(gcf,'UserData');
        xlim_str = get(tacklebox.xlim,'string');
        xlim_val = str2num(xlim_str);
        set(tacklebox.ax,'xlim',xlim_val)
       
    case 'ylimit'
        tacklebox = get(gcf,'UserData');
        ylim_str = get(tacklebox.ylim,'string');
        ylim_val = str2num(ylim_str);
        set(tacklebox.ax,'ylim',ylim_val)  
        
    case 'grid_cb'
        tacklebox = get(gcf,'UserData');
        Grid_state = get(tacklebox.cb_grid,'value');
        if Grid_state ==1
            grid on
        else
            grid off
        end 
        
    case 'grid_lb'
        tacklebox = get(gcf,'UserData');
        Grid_lay_state = get(tacklebox.lb_grid,'value');
        if Grid_lay_state ==1
            set(tacklebox.ax,'layer','top')
        else
            set(tacklebox.ax,'layer','bottom')
        end    
        
    case 'fom_type'
        
        tacklebox = get(gcf,'UserData');
        fom_type_val = get(tacklebox.fom_type,'value');
        if fom_type_val==length(tacklebox.fom)+1 
            tacklebox.fom = {'0','0','0','0','0', '0'};
            set(tacklebox.detf_val,'String','0');
            set(tacklebox.fom_type,'value',1)
        else
            if length(tacklebox.fom)==1
                set(tacklebox.detf_val,'String',tacklebox.fom{1});
            else
                set(tacklebox.detf_val,'String',tacklebox.fom{fom_type_val});
                %set the detf value in the detf box
            end
        end
        set(gcf,'UserData',tacklebox); 
        
    case 'clear_fom'
        
        tacklebox = get(gcf,'UserData'); 
        tacklebox.fom = {'0','0','0','0','0', '0'};
        set(tacklebox.detf_val,'String',{'0'}); 
        set(gcf,'UserData',tacklebox); 
        
%==============================================================
% ==========  fiducial model check boxes case ===========
    case 'fiducial_cb1'       
        
        
        tacklebox = get(gcf,'UserData');
        val = get(tacklebox.param_cb1,'value');
        val_fidu_indx = tacklebox.input.parameters_to_plot;
        
        if val ==1
            if ~ismember(1,val_fidu_indx)
                new_obs_indx = (horzcat(1,val_fidu_indx)); 
            else
                new_obs_indx = val_fidu_indx;
            end            
        else
            [yn,loc] = ismember(1,val_fidu_indx);
            if yn
                new_obs_indx = val_fidu_indx(find(loc~=1:length(val_fidu_indx))); 
            else
                new_obs_indx = val_fidu_indx;
            end
        end   
        tacklebox.input.parameters_to_plot = new_obs_indx;       
        set(gcf,'UserData',tacklebox);
   
    case 'fiducial_cb2'
        
        tacklebox = get(gcf,'UserData');
        val = get(tacklebox.param_cb2,'value');
        val_fidu_indx = tacklebox.input.parameters_to_plot;
        
        if val ==1
            if ~ismember(2,val_fidu_indx)
                new_obs_indx = (horzcat(2,val_fidu_indx)); 
            else
                new_obs_indx = val_fidu_indx;
            end            
        else
            [yn,loc] = ismember(2,val_fidu_indx);
            if yn
                new_obs_indx = val_fidu_indx(find(loc~=1:length(val_fidu_indx))); 
            else
                new_obs_indx = val_fidu_indx;
            end
        end   
        tacklebox.input.parameters_to_plot = new_obs_indx;        
        set(gcf,'UserData',tacklebox);
        
     case 'fiducial_cb3'

        tacklebox = get(gcf,'UserData');
        val = get(tacklebox.param_cb3,'value');
        val_fidu_indx = tacklebox.input.parameters_to_plot;
        
        if val ==1
            if ~ismember(3,val_fidu_indx)
                new_obs_indx = (horzcat(3,val_fidu_indx)); 
            else
                new_obs_indx = val_fidu_indx;
            end            
        else
            [yn,loc] = ismember(3,val_fidu_indx);
            if yn
                new_obs_indx = val_fidu_indx(find(loc~=1:length(val_fidu_indx))); 
            else
                new_obs_indx = val_fidu_indx;
            end
        end   
        tacklebox.input.parameters_to_plot = new_obs_indx;        
        set(gcf,'UserData',tacklebox);

     case 'fiducial_cb4'
         
        tacklebox = get(gcf,'UserData');
        val = get(tacklebox.param_cb4,'value');
        val_fidu_indx = tacklebox.input.parameters_to_plot;
        
        if val ==1
            if ~ismember(4,val_fidu_indx)
                new_obs_indx = (horzcat(4,val_fidu_indx)); 
            else
                new_obs_indx = val_fidu_indx;
            end            
        else
            [yn,loc] = ismember(4,val_fidu_indx);
            if yn
                new_obs_indx = val_fidu_indx(find(loc~=1:length(val_fidu_indx))); 
            else
                new_obs_indx = val_fidu_indx;
            end
        end        
        tacklebox.input.parameters_to_plot = new_obs_indx;        
        set(gcf,'UserData',tacklebox);
        
        
     case 'fiducial_cb5'
         
        tacklebox = get(gcf,'UserData');
        val = get(tacklebox.param_cb5,'value');
        val_fidu_indx = tacklebox.input.parameters_to_plot;
        
        if val ==1
            if ~ismember(5,val_fidu_indx)
                new_obs_indx = (horzcat(5,val_fidu_indx)); 
            else
                new_obs_indx = val_fidu_indx;
            end            
        else
            [yn,loc] = ismember(5,val_fidu_indx);
            if yn
                new_obs_indx = val_fidu_indx(find(loc~=1:length(val_fidu_indx))); 
            else
                new_obs_indx = val_fidu_indx;
            end
        end   
        tacklebox.input.parameters_to_plot = new_obs_indx;        
        set(gcf,'UserData',tacklebox);       

            
end


%================================================= 
%============Fisher4Cast menu callbacks===========    

function Fisher4castTeam(gcf,event_data,handles)
    %create an additional uimenu
    FisherTeam = {'            Version 2.2','                  ','          Bruce Bassett','        Yabebal Fantaye','          Renee Hlozek',...
                  '          Jacques Kotze'};

   msgbox(FisherTeam,'Fisher4Cast Team');
   
function Fisher4castReadme(gcf,event_data,hundles)
    fid = fopen('Readme.txt');
    count  = 1;
    while 1
        tline = fgetl(fid);
        if ~ischar(tline),   break,   end
        FMreadmeText{count} = tline;
        count = count + 1;
    end
    FMreadmeText{count} = ' ';
    
    hhh = figure('Units','normalized',...             
         'Position',[0.1,0.1,0.8,0.88],...
         'NumberTitle','off',...
         'Interruptible','off',...             
         'Menubar','none');
    uicontrol(hhh,'Style','listbox',...
          'max',count+5,...
          'String',FMreadmeText,...
          'Unit','normalized',...
          'Position',[0.01,0.01,0.99,0.99],...
          'FontWeight','bold');   
      
      fclose(fid);
        
   
function Fisher4castLicence(gcf,event_data,hundles)
    
    if exist('license.txt')==2
        fid = fopen('license.txt');
        count  = 1;
        while 1
            tline = fgetl(fid);
            if ~ischar(tline),   break,   end
            FMlicenceText{count} = tline;
            count = count + 1;
        end
        FMlicenceText{count} = ' ';

        hhh = figure('Units','normalized',...             
             'Position',[0.1,0.1,0.8,0.88],...
             'NumberTitle','off',...
             'Interruptible','off',...             
             'Menubar','none');
        uicontrol(hhh,'Style','listbox',...
              'max',count+5,...
              'String',FMlicenceText,...
              'Unit','normalized',...
              'Position',[0.01,0.01,0.99,0.99],...
              'FontWeight','bold');

          fclose(fid);
    else
        msgbox('The license.txt file is not found!')
    end
   
function FisherExtennsion(gcf,event_data,hundles)
    fid = fopen('EXT_FF_info.txt');
    count  = 1;
    while 1
        tline = fgetl(fid);
        if ~ischar(tline),   break,   end
        FMextensionText{count} = tline;
        count = count + 1;
    end
    FMextensionText{count} = '';
    
    hhh = figure('Units','normalized',...             
         'Position',[0.1,0.1,0.8,0.88],...
         'NumberTitle','off',...
         'Interruptible','off',...             
         'Menubar','none');
    uicontrol(hhh,'Style','listbox',...
          'max',count+5,...
          'String',FMextensionText,...
          'Unit','normalized',...
          'Position',[0.01,0.01,0.99,0.99],...
          'FontWeight','bold');    
      
    fclose(fid);
    
function fomswg_extension(handle,event_data)
    %get(gcf);
    global tacklebox;
    exist tacklebox
    addpath EXT_fomswg;
    %addpath ../
    EXT_fomswg_gui;
    
%==============Interactive plot menu================
%This function is excuted when the Interactive plot submenu in the F4C
%extensions menu is clicked. It toggles on or off the interactive
%plotting
function tacklebox = activateInteractivePlot(handle,event_data,tacklebox)
    if strcmp(get(handle, 'Checked'),'on')            
        set(handle, 'Checked', 'off');           
    else                                   
        set(handle, 'Checked', 'on');  
    end        

%---------------------------------------------------------
%This is a function that will be excuted when a mouse is clicked near
%the plotting axes. Depending on the Interactive plot flag it sets
%interactive plotting
function tacklebox = axesButtonDownFcn(handle,event_data,tacklebox)        

    if strcmp(get(tacklebox.IntPlot, 'Checked'),'on')
        tacklebox.InteractivePlot_flag = 1;
        FM_GUI_interactive_plot(gcf,handle,tacklebox);
    else
        tacklebox.InteractivePlot_flag = 0;
    end
    set(handle,'ButtonDownFcn',{@axesButtonDownFcn,tacklebox});

        
       
