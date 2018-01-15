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
% This general results file produces the resulting plots etc from the FM_run code.
% It uses the matrix saved in the global output structure. It is
% under construction, and only works at the moment for the 1d and 2d cases
% (ie, an input matrix with sides > 2 will result in an error message)
% For the 2d case, it also determines the Figure of Merit (for a range of FOM's defined)
% for the Fisher matrix. 
% ------------------------------------------------------------------------

function fom = FM_output_fom
global input output

x = input.parameters_to_plot;

if input.num_parameters == 1    
    newmat =inv(output.summed_matrix); 
    error = sqrt(newmat(x,x));
    fom = error;
elseif input.num_parameters == 2
    OneSig_val = 2.31;
    TwoSig_val = 6.17;
    area_detf = sqrt(det(inv(output.marginalised_matrix))); 
    area_1sig = pi.*sqrt(OneSig_val./det(output.marginalised_matrix)); 
    area_2sig = pi.*sqrt(TwoSig_val./det(output.marginalised_matrix));
    
    C = trace(inv(output.marginalised_matrix));
    C2 = sum(sum((inv(output.marginalised_matrix).^2)));
    fom_inv2sig = 1./area_2sig; % This FOM is used in the plots for the Fisher4Cast release paper
    fom_detf = 1./area_detf; % this is the DETF FOM, corrected for convention
    fom_inv1sig = 1./area_1sig;
    fom = [fom_detf fom_inv2sig fom_inv1sig area_1sig C C2];
end
