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

###########################################################################
Errors on H, d_A from the Seo & Eisenstein formulae arXiv:astro-ph/0701079
###########################################################################

If the results produced from the use of this extension of Fisher4Cast 
have been used in a publication, we kindly request that its use and the 
authors of Fisher4Cast and this extension are acknowledged, 
as well as the original authors of arXiv:astro-ph/0701079.

This EXT_FF_SeoEisenstein2007 contains the following files, (which must be 
copied from the original folder and placed in the same directory
as the Fisher4Cast main code, as they access files in the main Fisher4Cast
suite):

* EXT_FF_SeoEisenstein2007_Main.m
    This is a wrapper for all the codes which takes in the input structure 
    with the following survey parameters: 
    z,om,h,ode,ob,wmap,volume,sigma8,Sigma_z,number_density,zdistortion. 
    These include the redshifts, the cosmic parameters of matter density, 
    hubble constant, dark energy density and baryon density, as well as a 
    term wmap which indicates which wmap data set to use in the code. The 
    volume, sigma8 value, galaxy number density and redshift distortions 
    are also required. Should no input structure be defined, default 
    values are taken from the structure EXT_FF_SeoEisenstein2007_Input.m

    The code then produces the required errors on the angular diameter 
    distance Drms (where rms is the root mean square), and the Hubble 
    parameter,Hrms. The output r, gives the correlation coefficient between 
    the measurements of H and D, and Rrms gives root mean square error on 
    D/s and H*s, if one assumes that the oscillation scale in the radial 
    and tangential directions is the same. 

This is done by calling:

* EXT_FF_SeoEisenstein2007_errFit_2007.m
    This code is a Matlab version of the code in C given by Seo & Eisenstein,
    and includes comments from the original code. It uses the next two codes, 
    namely

