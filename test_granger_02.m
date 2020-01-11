%
% R. Boldi
% Zayed University, Dubai, UAE
% 2017
%
% test  granger_cause
% Zayed University, UAE
%
clear all ;
close all ;
%
% test using random numbers
%
tmp_n =     128 ;
xraw = randn( tmp_n , 1)         ;
yraw = randn( tmp_n , 1)         ;
io = 5;
y = yraw(io+1:end);
alpha = 0.4 ;
x = alpha*xraw(io+1:end)+ (1-alpha)*yraw(1:end-io) ;
firstYlag = 1 ;
alpha     = 0.05 ;
            %
            %
            % test fixed lags
            %
            %
            % use a fixed data set
            
            maxX = ( io + 4  );
            maxY = ( io + 4 );
            
F_array = zeros(maxX, maxY);
P_array = zeros(maxX, maxY);
dBIC_array = zeros(maxX, maxY);
 for ixlag = [ 1 : maxX ]
       for iylag = [ 1 : maxY ]
           
           % display( sprintf('Compute F for %d , %d', ixlag, iylag));
           max_x_lag =  ixlag;   use_best_x = 0 ;
           max_y_lag =  iylag;   use_best_y = 0 ;
           
           % draw one graph
           desired = 0 ;
           if ( ixlag == (io+1) ) && (iylag == (io+1) )
               desired = 1 ;
           end
           
            [  F , c_v ,   Fprob , Fprob_cor  , dAIC, dBIC  , chosen_x_lag , chosen_y_lag   ] = ...
                granger_cause_1(x, y,  alpha, max_x_lag , use_best_x, ...
                max_y_lag , use_best_y, firstYlag , ...
                'xName','yName', 0 , '.', 'FixedLags','FixedLags', desired) ;
            
            F_array(ixlag,iylag) = F ;
            P_array(ixlag,iylag) = Fprob;
            dBIC_array(ixlag,iylag) = dBIC ;
       end
 end
 
 
 
    fprintf('\n\n   F  vs  ( max x_lag , max  y_lag   )          \n');
    fprintf('                   ---  max  x lags ---\n                ');
    for ix = [ 1 : maxX]
        fprintf('   %3d   ',ix);
    end
    fprintf('\n');
    
    for iy = [ 1 : maxY ]
        fprintf('max Y lags  %3d ',iy);
        for ix = [ 1 : maxX ]
            fprintf('  %6.2f ',F_array(ix,iy));
        end;
        fprintf('\n');
    end
    
    
     
    fprintf('\n\n   dBIC  vs  ( max x_lag , max  y_lag   )          \n');
    fprintf('                   ---  max  x lags ---\n                ');
    for ix = [ 1 : maxX]
        fprintf('    %3d   ',ix);
    end
    fprintf('\n');
    
    for iy = [ 1 : maxY ]
        fprintf('max Y lags  %3d ',iy);
        for ix = [ 1 : maxX ]
            fprintf('  %8.1f ',dBIC_array(ix,iy));
        end;
        fprintf('\n');
    end
