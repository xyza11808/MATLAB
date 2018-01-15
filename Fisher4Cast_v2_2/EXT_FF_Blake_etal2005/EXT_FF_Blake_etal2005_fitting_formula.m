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

function y = EXT_FF_Blake_etal2005_fitting_formula(s_type,r_type,volume,TempInput,base_parameters)
% This function gives the errors on the oscillation scale depending
% on your survey parameters.
% From Blake et al. 2005 - astro-ph/0510239

% It uses the params structure which is initialised according to which 
% survey you are using to get the coefficients specified in the Blake et
% al. 2005 paper.


%============INPUTS========================================
%      s_type: a string giving the survey type (photometric or spectroscopic)
%      r_type: a string giving the radial or transverse
%      central_z: central redshift 
%      num_density: number density
%      volume: survey volume
%      survey_param: survey parameters 

% NOTE: The normalisation parameters are specific to the Blake et al.
% paper. 
%============OUTPUTS========================================

%      y: the error on the oscillation scale (either perpendicular or parallel scale)
%         given by equation (8) in Blake et al. (2005). 
%         The function returns 100 if the scale cannot be resolved.

volume = volume(:);
base = base_parameters; % base model of H0, om, ok, w0, wa;
if isreal(TempInput.n)
    TempInput.n = TempInput.n.*ones(size(volume));
end
    

%growth normalization flag and redshift
norm_G = 1;
norm_z = 0;

%=====================================================
%   Our reference (fiducial) survey parameters
%===================================================

z0 = 1;
dz0 = 0.61;%FM_function_3(z0, base,norm_G,norm_z) % growth function at z=1;
            % the growth function is normalized at z=0

V0 = 2.16; % units h^-3 GPc^3 - the normalisation volume for z0 = 1, A = 1
% (in units of 10^3 degrees) and D(z0) = 0.61 See Carroll, Press and Turner
% 1992
sigr0 = 34.1; % units h^-1 MPc<

%====================================================

%choose which z to use 
if strcmp(r_type,'tangential')
    TempInput.z = TempInput.z_DA(:);
    b0 = TempInput.biasDA(:);  %bias values at the given redshift
else
    TempInput.z = TempInput.z_H(:);
    b0 = TempInput.biasH(:);  %bias values at the given redshift
end

xt = zeros(length(TempInput.z),1);
x = zeros(length(TempInput.z),1);
y = zeros(length(TempInput.z),1);

if strcmp(s_type, 'spec')

    % you are using spectroscopic data
    params = EXT_FF_Blake_etal2005_spectro_params(r_type);
    sigr =sigr0.*ones(length(TempInput.z),1);  
    % TempInput.sigz(:)./E(TempInput.z, base(1), base(2),...
    % base(3), % base(4), base(5));%
%     display('We have a spectroscopic survey')
%     display(['The error computed is for the ',r_type,' distance'])

else strcmp(s_type, 'phot')

    params = EXT_FF_Blake_etal2005_photo_params;
    % you are using photometric data
    % there is an added error here in the radial direction
    sigr = TempInput.sigz./E(TempInput.z, base(1), base(2), base(3), base(4), base(5)); 
                                 % sigr = sigz.*drdz  = sig0.*(1+z)./E
    display('We have a photometric survey')
end

% calculate the value of the growth function to be used.
d = FM_function_3(TempInput.z, base,norm_G,norm_z); 
d = d(:);

Ix1 = find(TempInput.z <= params.zmax);  %index for z<zmax
Ix2 = find(TempInput.z > params.zmax); %index for z>=zmax

%calculate eq(9) of Blake et al. paper
if ~isempty(Ix1) 
    %where zmax < z
    xt(Ix1) = params.a.*(volume(Ix1)./V0).^params.alpha.*(params.zmax./TempInput.z(Ix1)).^params.beta;
end
if ~isempty(Ix2) 
    %where zmax > z
    xt(Ix2) = params.a.*(volume(Ix2)./V0).^params.alpha;
end

Ix1 = find(xt > 0);  %index for z<zmax
Ix2 = find(xt <= 0); %index for z>=zmax

if ~isempty(Ix1)    
    
     %from eq 6 page 5 of Blake et al.
    vfact = sqrt(V0./volume(Ix1));
    sigrfact = sqrt(sigr(Ix1)./sigr0);
    zfact = TempInput.z./params.zmax;
    
    neff = params.n0.*(1-params.b.*(1-zfact)); % from eq 7 page 5
    nfact = neff(Ix1)./TempInput.n(Ix1);
    
    dfact = (dz0./(b0(Ix1).*d(Ix1)));
    zfact2 = params.zmax./TempInput.z(Ix1);
    
    npfact = sigrfact.*(1+(nfact).*dfact.^2);
    np = 1./(nfact.*dfact.^2);
    
    x(Ix1) = params.x0.*vfact.*npfact.*(zfact2).^params.gamma;
    corr(Ix1) = (x(Ix1)./xt(Ix1)).^2;     

end
if ~isempty(Ix2)
       
    x(Ix2) =params.x0.*(V0./sqrt(volume(Ix2)).*sqrt(sigr(Ix2)./sigr0)).*...
           (1+(params.n0./TempInput.n(Ix2)).*(dz0./(b0(Ix2).*d(Ix2))).^2); % from eq 6 page 5
    corr(Ix2) = 0;
end
x = x(:);
corr = corr(:);

%If corr>1, the baryon acoustic oscilations will not be resolved by the
%survey
indx_bao_notResolved = find(corr>=1);
indx_bao_Resolved = find(corr<1);

%If the BAO's can be resolved, use eq(8) of Blake et al. (2005) paper
if ~isempty(indx_bao_Resolved)
    y(indx_bao_Resolved) = x(indx_bao_Resolved)./(1-corr(indx_bao_Resolved));
end
%For redshifts that BAO's are not resolved, set the fractional error to
%100;
if ~isempty(indx_bao_notResolved)
    y(indx_bao_notResolved) = 100;  
end


y = y(:);
