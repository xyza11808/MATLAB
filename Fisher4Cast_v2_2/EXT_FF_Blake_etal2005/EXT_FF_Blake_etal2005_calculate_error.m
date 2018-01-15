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
function [vol_H,vol_DA,sigH,sigDA] = EXT_FF_Blake_etal2005_calculate_error(TempInput)
% This function EXT_FF_Blake_etal2005_calculate_error.m computes the error on the  
%Angular diameter distance (DA), from the perpendicular oscillation scale
%and Hubble parameter H, from the parallel oscillation scale, by calling Blake et al. (2005) fitting 
%formula, Blake_etal2005_fitting_formula.m.
%The volumes of the redshift bins specified  
%by the redshift Tempinput.z_H, and Tempinput.z_DA 
%are calculated using the function com_volume.m.

%============INPUTS========================================
%TempInput - a structure that contains the input parameters needed for
%FM_run.m and the following fields:
%   TempInput.area; TempInput.n; TempInput.sigz; TempInput.z_H; TempInput.z_DA; 
%   TempInput.dz_H; TempInput.dz_DA


%============OUTPUTS========================================
%  vol_H: the vector of volumes corresponding to the redshift inputs for H
%  vol_DA: the vector of volumes corresponding to the redshift inputs for
%          DA
%  sigH:  the corresponding vector of fractional errors:  sigmaH/H.
%  (Multiply by 100 to get percentages)
%  sigDA: the corresponding vector of fractional errors: sigmaDA/DA.
%  (Multiply by 100 to get percentages)

base_parameters = TempInput.base_parameters;
area = TempInput.area.*1e3;

A_fullSky = 41253;%.9612494193; %are of the full sky in square degrees;
A_survey = area.*4.*pi./A_fullSky; %in units of radians

%Calculate the volumes for redshifts that the Hubble
%parameter is specified
%calculate the edges of the bins from z and dz vectors
zi_H = TempInput.z_H - TempInput.dz_H;
zf_H = TempInput.z_H + TempInput.dz_H;

Vi_H = EXT_FF_Blake_etal2005_com_volume(A_survey,zi_H,base_parameters);
Vf_H = EXT_FF_Blake_etal2005_com_volume(A_survey,zf_H,base_parameters);
vol_H = (Vf_H - Vi_H); %%in units of h^-3Gpc^3 

%Calculate the volumes for redshifts that the Angular diameter
%distance parameter is specified
%calculate the edges of the bins from z and dz vectors
zi_DA = TempInput.z_DA - TempInput.dz_DA;
zf_DA = TempInput.z_DA + TempInput.dz_DA;

Vi_DA = EXT_FF_Blake_etal2005_com_volume(A_survey,zi_DA,base_parameters);
Vf_DA = EXT_FF_Blake_etal2005_com_volume(A_survey,zf_DA,base_parameters);
vol_DA =(Vf_DA - Vi_DA); %in units of h^-3Gpc^3 

%Errors on Hubble (y_pll) and Angular diameter distance(y_perp)
y_perp = EXT_FF_Blake_etal2005_fitting_formula(TempInput.surv_type,'tangential',vol_DA,TempInput,base_parameters);
y_pll = EXT_FF_Blake_etal2005_fitting_formula(TempInput.surv_type,'radial',vol_H,TempInput,base_parameters);

%Assuming CMB measures the true sound horizon length, s, with 
%a precision much better than the precision on sH and DA/s 
%from galaxy redshift surveys, the errors on the s_perp and 
%s_paral are virtually equivalent to the errors on DA and H
%s = 100;  %in units of Mpc

sigH = (y_pll)./100;   %multiplication by 100 converts the fractional error to a percentage 
sigDA = (y_perp)./100; %multiplication by 100 converts the fractional error to a percentage 
