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
%This function loads the variables from the previous session from the
%given filename which include the date on which it was saved. 
%This loads the structures 
% *input
% *output
% *plot_spec
%these will enable the relevant plots from the previous session to be
%recreated by using FM_plot. 
% ------------------------------------------------------------------------v
function FM_save_struct(name,input,output)
filename = [name '-' date '.mat'];%take the given name to save as and append the date and the .mat file extention.
%check to see if filename already exists
%if so offer option to overwrite or save as v2?
FM_saved_dat.input = input;
FM_saved_dat.output = output;
save(filename, '-struct', 'FM_saved_dat');
%save the structures input, output and plot_spec. 
%The file is saved as a binary .mat file as a matlab default. 


