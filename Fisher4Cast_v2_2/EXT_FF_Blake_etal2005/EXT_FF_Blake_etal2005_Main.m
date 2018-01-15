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
function [z_H_central,z_DA_central,vol_H, vol_DA,sigH, sigDA] = EXT_FF_Blake_etal2005_Main(Input_survey)
% EXT_FF_Blake_etal2005_Main - This function calls the following functions
%                  to perform the desired calculations
%
% 1)EXT_FF_Blake_etal2005_calculate_error.m - calculates the error on the Hubble parameter and the
%                  angular diameter distance given a survery data.
%                  To calculates these errors, it implements the 
%                  fitting formula in Blake et al. 2005 (astro-ph/0510239)
%                  paper.
%
%The different fields for the Input_survey are described below.
%
%============INPUTS========================================
%vecH - redshift vector for H binning. The values can either be
%       the centre or edge of the bin they are specifying. 
%
%vecDA - redshift vector for d_A binning. The values can either be
%        the centre or edge of the bin they are specifying. 
%
%surv_type - survey type, a string specifying spectroscopic ('spec') or
%            photometric ('phot') survey.
%
%z_type - a string specifying the type of the vecH and vecDA redshifts. 
%         This can be either central ('central') or edge ('edge').
%
%dz - a vector or scalar specifying the width of the bins. If z_type = 'edge', dz doesn't need to be specified,
%     and can be passed as empty vector [].
%
% area - area of the survey in units of 1000 sq. deg.
%
% n   -  number density of the survey in units of 1e-3Mpc^-3h^3. If it is a scalar, it will be interpreted
%        as a vector of the same size of the vecH or vecDA with the same values
%        
% biasH - bias values at each redshift for the Hubble parameter. If it is a scalar, it will be 
%         interpreted as a vector of the same values with size equal to that of vecH 
%
% biasDA - bias values at each redshift for the angular diameter distance. If it is a scalar, it will be 
%         interpreted as a vector of the same values with size equal to that of vecDA

% The different Output parameters are described below

%===========OUTPUTS=============================================
%z_H_central - a vector of the central redshifts for the H bins.
%
%z_H_central - a vector of the central redshifts for the DA bins.
%
%vol_H - a volume vector for H redshift bins.
%
%vol_DA - a volume vector for DA redshift bins.
%
%sigH - the vector of fractional errors: sigH/H calculated by the function EXT_FF_Blake_etal2005_calculate_error.m.
%       Multiply by 100 to get percentage errors.
%
%sigDA - the vector of errors: sigDA/DA calculated by the function EXT_FF_Blake_etal2005_calculate_error.m.
%        Multiply by 100 to get percentage errors.
%
%==================CHECKS PERFORMED AND INITIALISATION======================
if nargin==0
    Input_survey = EXT_FF_Blake_etal2005_Input;
end

TempInput = Input_survey;   %stores the input structure in a new tempinput struct

% Checking if the bias vector is defined
if isfield(TempInput,'biasH')==0
    display('Please enter a the bias for the H redshifts')
    elseif isfield(TempInput,'biasDA')==0
    display('Please enter a the bias for the dA redshifts')
end 
%---------------------
% If a constant bias vector is given, multiply it to make a vector for the
% bias.
if (length(TempInput.biasH) ==1) & (length(TempInput.vecH) >1)
    TempInput.biasH = TempInput.biasH.*ones(size(TempInput.vecH));
end

if (length(TempInput.biasDA) ==1) & (length(TempInput.vecDA) >1)
    TempInput.biasDA = TempInput.biasDA.*ones(size(TempInput.vecDA));
end
%----------------------
% Checking if the number density vector is the same length as the vector
% for H, DA measurements (it must be equal to both lengths)

if (length(TempInput.n) ==1) & (length(TempInput.vecH) >1)
    TempInput.biasDA = TempInput.n.*ones(size(TempInput.vecH));
elseif(length(TempInput.n) ~= length(TempInput.vecH))|| (length(TempInput.n) ~= length(TempInput.vecDA))
    error('The length of the number density vector n must be equal to the length of vectors for H, d_A')
end
%-----------------------
% Computing the errors for a survey with the vectors of H, DA specified as
% edges
if strcmp(TempInput.z_type,'edge')  %the values in the vectors are edge of the bins 
    %compute the central redshift of each bin
    z_H_central = EXT_FF_Blake_etal2005_cummean(TempInput.vecH);   
    z_DA_central = EXT_FF_Blake_etal2005_cummean(TempInput.vecDA); 
    
    %compute dz for each H bin
    if length(z_H_central)==1
        TempInput.dz_H = z_H_central - TempInput.vecH(1);
    else
        TempInput.dz_H = z_H_central - TempInput.vecH(1:end-1);
    end

    %compute dz for each DA bin 
    if length(z_DA_central)==1
        TempInput.dz_DA = z_DA_central - TempInput.vecDA(1);
    else
        TempInput.dz_DA = z_DA_central - TempInput.vecDA(1:end-1);
    end
    
    % Computing the errors for central redshifts
else  %the passed vectors are already central redshifts 
    z_H_central = TempInput.vecH;
    z_DA_central = TempInput.vecDA;
    
    %For central redshift vectors dz must be specified
    if isempty(TempInput.dz)
        error('The bin width, dz,is not specified for the passed central redshifts.') 
    end
    
    TempInput.dz_H = TempInput.dz./2;
    TempInput.dz_DA = TempInput.dz./2;
end  %end of big if 

TempInput.z_H = z_H_central;
TempInput.z_DA = z_DA_central;

%Finally, TempInput structure now has the following fields in addition to
%those in the input structure used in FM_run.m:
%   TempInput.area; TempInput.n; TempInput.sigz; TempInput.z_H
%   TempInput.z_DA; TempInput.dz_H; TempInput.dz_DA

[vol_H, vol_DA,sigH,sigDA] = EXT_FF_Blake_etal2005_calculate_error(TempInput); % call the function to calculate the errors on H and d_A
% Note that the errors are fractional errors. Multiply sigH and sigDA by
% 100 to get percentage errors.

