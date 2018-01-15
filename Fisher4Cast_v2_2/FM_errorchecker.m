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
%FM_ERRORCHECKER checks existance of all the necessary functions. In 
%addition it makes sure that the lengths of the input parameters are 
%consistent.
%
%Example:
%This function can be run from the command line by passing it the input 
%structure (here Cooray_et_al_2004 is used as an example):
%
%>>FM_errorchecker(Cooray_et_al_2004)
%
%If there are errors a message box will appear. A log.mat file is generated with 
%the errors in. It can be viewed with the command
%
%>>load(log.mat)
%

function input = FM_errorchecker(param_struct)

input = param_struct;

% Delete the old log file if necessary
if exist('log.mat', 'file')==2
    delete log.mat
end
 
% initialise the error message  counters
err_count =0;
mess_count = 0;

%Check to ensure that Growth is set to Numerical derivative
%----------------------------------------------------------
%check to see if G or Growth exist as observable names
index_growth = find(1==(strcmp('G',input.observable_names))|(strcmp('Growth',input.observable_names)));
%if there is more than one G or Growth that exists as an observable name
%then create an error.
if length(index_growth)>1
    err_count = err_count + 1;
    error_box{err_count} = sprintf('You cant have more than one Observable name of G or Growth. Please use only one and ammend the observable name in the input structure.');
%if the index_growth does exist and it is being used in the observable
%index, then ensure that the numerical flag for Growth is set. 
elseif ((index_growth==input.observable_index)&(input.numderiv.flag{index_growth}==0));
      warning('WarnTests:convertTest', ...
          'You are using the Growth in the Observable index but the numerical derivative flag has not been set. \n This has now been automatically set by the FM_errorchecker.m.')
      input.numderiv.flag{index_growth}=1;
end
%check whether any Observable is selected or not. 
if isempty(input.observable_index) & max(input.prior_matrix)~=0
    warning('PriorMatrix:NoObservable','No observable is selected! Only the prior matrix is used to plot the error ellipse.')
elseif isempty(input.observable_index) & max(input.prior_matrix)==0
     error('PriorMatrix:NoObservable','You have not selected any observable and the prior matrix is zero.')
end

% Check that files exist
for k = 1:length(input.function_names)
       fun_name = input.function_names{k};
    if exist(sprintf(fun_name, 'file')) == 0
        err_count = err_count + 1;
        error_box{err_count} = sprintf('Your derivative file %s does not exist', fun_name);
      end
end
mess_count = mess_count + 1;
message_box{mess_count} = sprintf('Check for existence of Analytical derivative files (if needed) complete.');

if exist('numderiv.f')
    
    for jk = 1:length(input.observable_name)
        fun_name = input.numderiv.f{jk};
        if exist(sprintf(fun_name, 'file')) ==0
           err_count = err_count + 1;
           error_box{err_count} = sprintf('Your derivative file %s does not exist', fun_name);
         end
    end
    mess_count = mess_count + 1;
    message_box{mess_count} = sprintf('Check for existence of Numerical derivative files (if needed) complete.');
end

%checks if length of base parameter is equal to length of prior

if length(input.base_parameters) ~= length(input.prior_matrix)
    err_count = err_count + 1;
    error_box{err_count} = sprintf('Length of base_parameters must be equal to length of the prior_matrix.');   
    
end
mess_count = mess_count + 1;
message_box{mess_count} = sprintf('Check complete for base_parameters and prior_matrix length compatibility.');

%checks base_parameters and parameter_names length are consistent
if length(input.base_parameters) ~= length(input.parameter_names)
    err_count = err_count + 1;
    error_box{err_count} = sprintf('Length of base_parameters must be equal to length of parameter_names.');  
     
end
mess_count = mess_count + 1;
message_box{mess_count} = sprintf('Check complete for base_parameters and parameter_names length compatibility.');

%checks if data and error have same length
if iscell(input.data) & iscell(input.error)
    if length(input.data)~=length(input.error)
        err_count = err_count + 1;
       error_box{err_count} = sprintf('The data and error cells must have equal length.');
       
    end
    for i = 1:length(input.error)
        ld1 = length(input.data{i});        
        lv1 = length(input.error{i});        
        if ld1 ~= lv1 
            err_count = err_count + 1;
            
            error_box{err_count} = ['Length of data and error vector of ',input.observable_names{i}, ' must be the same to continue.']; 
            
        end 
    end
    
elseif isvector(input.data) & iscell(input.error)
    ld1 = length(input.data);
    for i = 1:length(input.error)                
        lv1 = length(input.error{i});        
        if ld1 ~= lv1 
            err_count = err_count + 1;
            error_box{err_count} = ['Length of data and error vector of ',input.observable_names{i}, ' must be the same to continue.'];
            
        end 
    end
    
elseif iscell(input.data) & isvector(input.error)
    lv1 = length(input.error);
    for i = 1:length(input.data)                
        ld1 = length(input.data{i});        
        if ld1 ~= lv1 
            err_count = err_count + 1;
            error_box{err_count} = ['Length of data and error vector of ',input.observable_names{i}, ' must be the same to continue.'];
            
        end 
    end
    
elseif isvector(input.data) & isvector(input.error)
    ld1 = length(input.data);
    lv1 = length(input.error);
        if ld1 ~= lv1 
            err_count = err_count + 1;
            error_box{err_count} = sprintf('Length of data must be equal to length of the error.');
            
        end 
        
else
    err_count = err_count + 1;
    error_box{err_count} = sprintf('Data and error inputs are not compatible. Consider revising them.');
    
end   
mess_count = mess_count + 1;
message_box{mess_count} = sprintf('Check complete for data and error length compatibility.');


%make sure columns have a length of 2 only 
if length(input.parameters_to_plot)>2
    err_count = err_count + 1;
    error_box{err_count} = sprintf('Length of columns must be 1 or 2.');
    
end
mess_count = mess_count + 1;
message_box{mess_count} = sprintf('Check complete to ensure parameters_to_plot has length less than or equal to 2.') ;

if err_count~=0
    for i = 1:err_count
        disp(error_box{i})
    end
    
    log.error_box = error_box;
    log.message_box = message_box;
    log.input = input;
    save('log.mat', 'log')
    disp(' ')
    disp('The information messages have been saved to log.mat.')    
    error(['Please correct the ',num2str(err_count),' errors found before you continue.'])
    return
end



