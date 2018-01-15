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
function s = EXT_FF_SeoEisenstein2007_sound_horizon(TempInput)

%This function is part of the code used to determine the errors on the 
% oscillation scale used in Seo & Eisenstein (2007)
%arXiv:astro-ph/0701079 BAO.

%This function computes the sound horizon equation, according to the
%equations found in Wang (2006) arXiv:astro-ph/0601163v2.

% ========================================================================
% The INPUTS required are specified in the TempInput structure, which is
% the original input structure modified in EXT_FF_SeoEisenstein2007_errFit.m
% The required entries are:

% TempInput.om:             The matter density
% TempInput.ob:             The baryon density          
% TempInput.h:              The fractional Hubble parameter

% The  OUTPUT is the sound horizon, s
% =========================================================================
c = 3e5;  %km/s
H0= 100*TempInput.h;
TCMB = 2.725;

zd = 1089;                           
zeq = 2.5*10^4*TempInput.om*TempInput.h^2*(TCMB/2.7)^(-4);

[Rd, cs_d] = soundSpeed(zd,TempInput.ob,TempInput.h,TCMB);
[Req, cs_eq] = soundSpeed(zeq,TempInput.ob,TempInput.h,TCMB);

s = 1./sqrt(TempInput.om*H0)*(2*c/(3*zeq*Req))*log((sqrt(1+Rd) + sqrt(1+Rd))./(1+sqrt(Req))); 

%===============================

function [Rb, cs] = soundSpeed(z,ob,h,TCMB)
%ob - omega baryon
%h - hubble parameter

Rb = 31.5.*ob.*h.^2.*(TCMB/2.7).^(-4).*(z./1000)^(-1);
cs = 1./sqrt(3.*(1+Rb));
