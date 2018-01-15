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
%This function is used in conjunction with FM_GUI and enables the
%interactive plotting feature through the "F4C Extension" Menu from the
%GUI.
%
        
    function FM_GUI_interactive_plot(handle,handle2,tacklebox) 
        %the Interactive plot functions is active if it is checked in the Fisher4Cast extension menu,
        %activate ginput (a mouse click listner in the axes). ginput function will 
        %recieve the x,y data value when a user click anywhere in the axes.
        
        if tacklebox.InteractivePlot_flag==1  
            [x,y,button] = ginput(1);
            
            if length(tacklebox.input.parameters_to_plot) ==1 
                tacklebox.input.base_parameters(tacklebox.input.parameters_to_plot(1)) = x;
            else
                
                tacklebox.input.base_parameters(tacklebox.input.parameters_to_plot(1)) = x;
                tacklebox.input.base_parameters(tacklebox.input.parameters_to_plot(2)) = y;
            end
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
            sigma_level = [2.31 6.2 11.83]; 
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
            try
                h=waitbar(1,'Running...');
                waitbar(1);
                close(h);      

                tacklebox.input = FM_errorchecker(tacklebox.input);           
                
                tacklebox.input.guiRun = 1; %flag for GUI based run 
                set(gcf,'currentaxes',handle2)
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
            %--------------------------------------------
            %write the Figure of merit or the error on a single parameter
            if ~isempty(output.fom)   
                tacklebox = get(gcf,'UserData');
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

            set(tacklebox.base_parameters,'string',num2str(tacklebox.input.base_parameters))
            
            FM_axis_specifications;
            skval = get(tacklebox.skin_change, 'value');
            set(handle2,'layer','top')
            tacklebox.fighandle = gca;
            
            %set(handle2,'ButtonDownFcn',{@FM_GUI_interactive_plot,tacklebox});

           
            set(gcf,'UserData',tacklebox);  
           
        end
