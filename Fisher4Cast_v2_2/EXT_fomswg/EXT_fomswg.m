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
% This Fisher4Cast extension is based on the "fisher_fomswg.c" code, 
% VERSION  8 December 2008, written by Dragan Hurter 
% (see http://jdem.gsfc.nasa.gov/science/fomswg/) produced for the Joint 
% Dark Energy Mission (JDEM) FoM Science Working Group (FoMSWG). More 
% details about the original code and its purpose can be found in 
% arXiv:0901.0721v1. The Fisher4Cast User Manual also contains more 
% specifics about the output structure and files generated from this 
% extension.  
%
% To use the default Fisher matrices, this function requires a single 
% numerical value given as input, between 1-8, which specifies the default 
% Fisher matrix data file to be used. This mimics the same input options as 
% in the original code.
%
% The choices are:
%
%   SN only          (1)
%   WL only          (2)
%   SN+PLANCK        (3)
%   WL+PLANCK        (4)
%   SN+WL+PLANCK     (5)
%   BAO only         (6)
%   BAO+PLANCK       (7)
%   SN+WL+PLANCK+BAO (8)
%
% The default files used in the above selection are saved in the DATA/ 
% sub-directory of the main code's path. 
%
% A user can also select their own 45x45 dimension Fisher matrix file as an 
% input string by giving the selected file name (and directory, if the file 
% is in a different path to where the code is being run from) as the input 
% variable.
%
%------------------------------------------------------------------------
% Example:
% 
% >>output = EXT_fomswg('file_name.dat') 
%
%------------------------------------------------------------------------
%
% An output structure is produced from the given input which contains 
% useful information. In the below example we select the SN (option 1) 
% default Fisher matrix as input and the output is asigned to the variable 
% 'output'. For more details about the definition of each of the structure 
% fields refer to the Fisher4Cast user manual.
%
%------------------------------------------------------------------------
% Example:
% 
% >>output = EXT_fomswg(1) 
%
% >>output = 
%     input_data: 'SN'
%          sig_w0: 13.4320
%          sig_wa: 36.5445
%              zp: -0.2652
%          Marg_F: [2x2 double]
%        DETF_FoM: 0.0108
%          sig_wp: 2.5291
%     sig_w_const: 2.5305
%       sig_gamma: 'Na'
%       FoM_gamma: 'Na'
%          PC_all: [36x37 double]
%
%------------------------------------------------------------------------
%
% Note that only when the default input selection includes WL (2,5,6 & 8)
% will sig_gamma and FoM_gamma produce numerical values. In all other
% selections these fields in the output structure will be given as 'Na'.
%
% Once the code is run, output files are generated for the respective 
% input. If a default option is selected which does not include WL 
% (options 1, 3, 6 & 7), the following files are produced: 
%
% PC accuracies (unpriored and priored) are in:
% 
%                  OUTPUT/sigma_SN_22-April-2010.dat
% 
% First four PCs (i.e. eigenvectors) are in:
% 
%                  OUTPUT/PC_1234_SN_22-April-2010.dat
% 
% All PCs (i.e. eigenvectors) are in:
% 
%                  OUTPUT/PC_all_SN_22-April-2010.dat
% 
% 2x2 Fisher matrix for w0-wa is in:
% 
%                  OUTPUT/w0wa_SN_22-April-2010.dat
%
% The output files are appended with the Fisher matrix input file name used 
% and the date the file was generated on, e.g. the above files are the 
% output for the default input option 1, SN, and were generated on the 
% 22-April-2010. The files are saved to the OUTPUT/ sub-directory of the 
% main code's path and a list of the files generated are printed to the 
% command window after completion.
%
% If any of the default options selected include WL (options 2, 4, 5 & 8) 
% then additional output files are generated with a *_gamma_* annotated  
% before the input file name and date.e.g. default input option 2, WL, 
% would produce an additional file containing all the principle components, 
% 'PC_all_gamma_WL_22-April-2010.dat'.   
%
%------------------------------------------------------------------------



function output = EXT_fomswg(default)
clc;
%define variables
VERYSMALL=1e-50;    
DA=0.025;           %/* stepsize in scale factor */
NW=36;              %/* 36 fiducially, number of w(z) bins */
N_OTHER=9;          %/* stands for n, omh2, obh2, okh2, odeh2, gamma, M, lnG0, lnAs */
NTOT=(NW+N_OTHER);  %/* total number of parameters */

%Establish if the current path is that of the main Fisher4Cast directory:
if exist('EXT_fomswg')==7
    EXT_fomswg_dir = ['EXT_fomswg' filesep];
else
    EXT_fomswg_dir = [''];
end
%Is this code being run from the correct path?
if exist([EXT_fomswg_dir 'OUTPUT'],'dir')~=7
    errordlg({' ',...
        'The EXT_fomswg/OUTPUT/ directory cannot be found in the current path:',...
        ' ',...
        ['                      ' pwd],...
        ' ',...
        'Please ensure you are running this code from the FoMSWG directory or else no data fles will successfully be saved.'});
    return;
end
%Do the default data files exist?
if exist([EXT_fomswg_dir 'DATA/preJDEM_SN.dat'],'file')~=2 || exist([EXT_fomswg_dir 'DATA/preJDEM_WL.dat'],'file')~=2 || exist([EXT_fomswg_dir 'DATA/preJDEM_BAO.dat'],'file')~=2 || exist([EXT_fomswg_dir 'DATA/PLANCK.dat'],'file')~=2
    errordlg({' ',...
        'The default input files in EXT_fomswg/DATA/ cannot be found in the current path:',...
        ' ',...
        ['                      ' pwd],...
        ' ',...
        'Please ensure you are running this code from the FoMSWG directory or else check that these files still exist:',...
        ' ',...
        '                      DATA/preJDEM_SN.dat',...
        '                      DATA/preJDEM_WL.dat',...
        '                      DATA/preJDEM_BAO.dat',...
        '                      DATA/PLANK.dat'});
    return;
end
    
%Read pre-defined Fisher matrix file data in
F_SN = dlmread([EXT_fomswg_dir 'DATA/preJDEM_SN.dat']);
F_PLANCK = dlmread([EXT_fomswg_dir 'DATA/PLANCK.dat']);
F_WL = dlmread([EXT_fomswg_dir 'DATA/preJDEM_WL.dat']);
F_BAO = dlmread([EXT_fomswg_dir 'DATA/preJDEM_BAO.dat']);

%Initialize Fisher matrices
prejdem_sn_matrix = zeros(NTOT,NTOT);
prejdem_plank_matrix = zeros(NTOT,NTOT);
prejdem_wl_matrix = zeros(NTOT,NTOT);
prejdem_bao_matrix = zeros(NTOT,NTOT);
own_matrix = zeros(NTOT,NTOT);

%Convert pre-defined Fisher matrix data files, as defined in orginal paper and code, to Fisher matrix
for(a=1:length(F_SN))
    prejdem_sn_matrix(F_SN(a,1)+1,F_SN(a,2)+1)=F_SN(a,end);
    prejdem_sn_matrix(F_SN(a,2)+1,F_SN(a,1)+1)=F_SN(a,end);
end
for(a=1:length(F_PLANCK))
    prejdem_plank_matrix(F_PLANCK(a,1)+1,F_PLANCK(a,2)+1)=F_PLANCK(a,end);
    prejdem_plank_matrix(F_PLANCK(a,2)+1,F_PLANCK(a,1)+1)=F_PLANCK(a,end);
end
for(a=1:length(F_WL))
    prejdem_wl_matrix(F_WL(a,1)+1,F_WL(a,2)+1)=F_WL(a,end);
    prejdem_wl_matrix(F_WL(a,2)+1,F_WL(a,1)+1)=F_WL(a,end);
end
for(a=1:length(F_BAO))
    prejdem_bao_matrix(F_BAO(a,1)+1,F_BAO(a,2)+1)=F_BAO(a,end);
    prejdem_bao_matrix(F_BAO(a,2)+1,F_BAO(a,1)+1)=F_BAO(a,end);
end

%Check which default combination of pre-defined fisher file data is to be
%used. If no selected default value is given an error dialog is produced 
if nargin==0    
    errordlg('No input selected');
    clc;
    fprintf('\n\n You can select one of the default Fisher matrix by specifying the numeric values of one of the choices:\n\n\n');
    fprintf(' SN only          (1)\n WL only          (2)\n SN+PLANCK        (3)\n WL+PLANCK        (4)\n SN+WL+PLANCK     (5)\n BAO only         (6)\n BAO+PLANCK       (7)\n SN+WL+PLANCK+BAO (8)\n\n');
    fprintf('Eg:\n\n     >>EXT_fomswg(2)\n\n');
    fprintf('In the above example the WL default Fisher matrix is selected and run.\n\n');
    fprintf('You can select to input your own user defined Fisher matrix by specifying the filename.\n\nEg:\n\n     >>EXT_fomswg(''myfilename'')\n\n');
    return;
%The below default selections are the same as given in the orginal code
elseif nargin==1
    %Test if default is a string, in which case read in default as a user
    %selected Fisher matrix.
    if isstr(default)
        if ~(exist(default)==2)
           clc
           fprintf(2, 'Error, this filename could not be found.\n\n');
           fprintf('Please check that the correct filename and path is given from\n the current location where this function is being run from.\n\n');
           return;
        else
            input_file=default;
            if strcmp(input_file,'uiimport')
                file_data_cell = uiimport;
                selected_filename = fieldnames(file_data_cell);
                file_data = eval(cell2mat(['file_data_cell.',selected_filename]));
                output.input_data = selected_filename{1};
            else
                file_data = dlmread(input_file,' ');
                [input_file_pathstr,input_file_name,input_file_ext,input_file_versn] = fileparts(input_file);
                output.input_data = input_file_name;
            end
            for(a=1:length(file_data))
                own_matrix(file_data(a,1)+1,file_data(a,2)+1)=file_data(a,end);
                own_matrix(file_data(a,2)+1,file_data(a,1)+1)=file_data(a,end);
            end
            F = own_matrix;
        end
    %Test if default is a real value, in which case read in appropriate
    %default Fisher matrix.
    elseif isreal(default)
        if default == 1
            F = prejdem_sn_matrix;
            output.input_data = 'SN';
        elseif default == 2
            F = prejdem_wl_matrix;
            output.input_data = 'WL';
        elseif default == 3
            F = prejdem_sn_matrix+ prejdem_plank_matrix;
            output.input_data = 'SN+PLANK';
        elseif default == 4
            F = prejdem_plank_matrix + prejdem_wl_matrix;
            output.input_data = 'WL+PLANK';
        elseif default ==5
            F = prejdem_sn_matrix + prejdem_plank_matrix + prejdem_wl_matrix;
            output.input_data = 'SN+WL+PLANK';
        elseif default == 6
            F = prejdem_bao_matrix;
            output.input_data = 'BAO';
        elseif default == 7
            F = prejdem_plank_matrix + prejdem_bao_matrix;
            output.input_data = 'BAO+PLANK';
        elseif default ==8
            F = prejdem_sn_matrix + prejdem_plank_matrix + prejdem_wl_matrix + prejdem_bao_matrix;
            output.input_data = 'SN+WL+PLANK+BAO';
        elseif (default > 8) || (default < 1)
            clc
            fprintf(2,'\n\nError, not a valid selection.\n\n');
            fprintf('Please only select options between 1 and 8:\n\n');
            fprintf(' SN only          (1)\n WL only          (2)\n SN+PLANCK        (3)\n WL+PLANCK        (4)\n SN+WL+PLANCK     (5)\n BAO only         (6)\n BAO+PLANCK       (7)\n SN+WL+PLANCK+BAO (8)\n\n');
            fprintf('Eg:\n\n     >>fisher_fomswg(2)\n\n');
            fprintf('In the above example the WL default Fisher matrix is selected and run.\n\n');
            fprintf('You can select to input your own user defined Fisher matrix by specifying the filename.\n\nEg:\n\n     >>fisher_fomswg("myfilename")\n\n');
            return;
        end
    end



for(i=1:NTOT)
    for(j=1:NTOT)
     FGAMMA(i,j)=F(i,j);
    end
end

%/***********************************************************/
%/*** WHEN reporting the error on Gamma, fix Gamma and G0 ***/
%/*************************************************************/
F(6,6) = F(6,6)+1.0/VERYSMALL;  %/* prior on Gamma */
F(8,8) = F(8,8)+1.0/VERYSMALL;  %/* prior on G0 */

%/*****************************************************************/
%/*** When doing gamma, add a weak prior on F_ww to regularize F **/
%/***  The prior <=> w is not varying more than +/-10 in w bins  **/
%/*****************************************************************/
for(i=N_OTHER+1:N_OTHER+36)
         FGAMMA(i,i) = FGAMMA(i,i) + DA/100.0;
end

Finit = F;

%Convert zero value Fisher matrix diagonals to non-zero small values
for(i=1:NTOT)
    if (F(i,i)< VERYSMALL) 
        F(i,i)= VERYSMALL;
    end
    if (FGAMMA(i,i) < VERYSMALL) 
        FGAMMA(i,i)= VERYSMALL;
    end
end

%Create arrays of scale factor and w_i values
for(i=1:NW) %/* over all w_i parameters */
        a_arr(i) = 1.0 - DA/2 - (i-1)*DA;     %/* linear in a */
        w_arr(i) = -1.0;
end

%Invert fisher matrix
Finv = inv(F);

%Selected subset of Finv call it Ginv
for (i=1:NW)
        for (j=1:NW)
            Ginv(i,j)=Finv(i+N_OTHER,j+N_OTHER);
        end
end

%Invert Ginv to produce G
G = inv(Ginv);

%get eigenvectors and eigenvalues
for(i=1:NW)
        for(j=1:NW)
            F1(i,j)=G(i,j);
        end
end

%/******************************/
%/* rows of W are eigenvectors */
%/* so, for W(a,b)           **/
%/* vary a to vary index      **/
%/* vary b to vary redshift  **/
%/*******************************/

%Retrieve eigenvectors and eigenvalues for F1
[eigenvec, eigenval] = eig(F1);%'nobalance' option

%---------------------based on'function.c'-----------------------
d=diag(eigenval);
v=eigenvec;
n=NW;
for (i=1:(n-1))
        k=i;
        p=d(k);
		for (j=[(i+1):n])
			if (d(j) >=p)
                k=j;
                p=d(k);
            end
        end
        
		if (ne(k,i)) 
			d(k)=d(i);
			d(i)=p;
			for (j=1:n) 
				p=v(j,i);
				v(j,i)=v(j,k);
				v(j,k)=p;
            end
        end
end
eigenval_sort = d;
eigenvec_sort = v;
eigenval_diag=diag(eigenval);
for (j=1:NW) 
        for(i=1:NW) 
             W(i,j)=eigenvec_sort(j,i);
         end
end
%----------------------------------------------------------------

RHS = 1.0;
summ=0;%used summ not to confuse the variable with the matlab function sum


%/***************************************************************************************/
%/** Normalize each PC to \int e^2(a) da=1 and determine coefficients of eigenvectors  **/
%/** RHS is the normalization \int (e_a)^2*da just in case you want that changed from 1**/
%/***************************************************************************************/
for(i=1:NW) 
    summ=0;
    for(j=1:NW) 
       summ=summ+(W(i,j).^2).*DA; 
    end
    norm(i) = summ./RHS;  % /* da in the fiducial case */

    %/***************************************************/
    %/** renormalize W(i,j) so that the norm is unity **/
    %/** consistently renormalize the eigenvalues too  **/
    %/***************************************************/
    eigenval_norm(i) =eigenval_sort(i)./norm(i);
    for (j=1:NW)
        W(i,j) = W(i,j)./sqrt(norm(i));
    end
end

%/************************************************************************/
%/**            determine the coefficients of 1+w(z)                    **/
%/**               (they are trivially zero for LCDM, but               **/
%/** changing w(z) to something else above you can check how they look) **/
%/************************************************************************/
summ=0; 
for (j=1:NW) 
    summ=summ+(1+w_arr(j)).*W(i,j)./RHS; %/* summ is the coefficient alpha_i */
    coeff(i)=summ;

end

%/*******************************************************/
%/** print out the unpriored and priored uncertainties **/
%/**    in the coefficients alpha_i; si=sigma(alpha_i) **/
%/*******************************************************/
ifp=fopen([EXT_fomswg_dir 'OUTPUT/sigma_' output.input_data '_' date '.dat'],  'w');
fprintf(ifp, 'PC  sigma(wo/prior) sigma(w/prior)\n');
for (j=1:NW) 
    si(j) = eigenval_norm(j).^(-0.500);
    %/* prior of unity on the PC coefficients - DEFAULT */
    fprintf(ifp, '%2.2d %12f %14f\n', j, si(j), si(j)./sqrt(1.0 + si(j).^2));

end
fclose(ifp);

ifp=fopen([EXT_fomswg_dir 'OUTPUT/PC_1234_' output.input_data '_' date '.dat'], 'w'); 
fprintf(ifp, '     z');
for (j=1:4)
    fprintf(ifp, '      PC%d', j);
end
fprintf(ifp, '\n');
fclose(ifp);
for (j=1:NW) 
    PC_1234(j,1) = 1./a_arr(j)-1;
    PC_1234(j,2) = W(1,j);
    PC_1234(j,3) = W(2,j);
    PC_1234(j,4) = W(3,j);
    PC_1234(j,5) = W(4,j);
end
dlmwrite([EXT_fomswg_dir 'OUTPUT/PC_1234_' output.input_data '_' date '.dat'], PC_1234(:,:),'-append','delimiter',' ','precision','%+5.5f%');
    
ifp=fopen([EXT_fomswg_dir 'OUTPUT/PC_all_' output.input_data '_' date '.dat'], 'w'); %/* write out all of the PC */
fprintf(ifp, '    z ');
for (j=1:9) 
    fprintf(ifp, '      PC%d', j);
end
for (j=10:NW) 
    fprintf(ifp, '     PC%d', j);
end
fprintf(ifp, '\n');    

for (j=1:NW)
   fprintf(ifp, '%f ', 1.0./a_arr(j)-1);
  PC_all(j,1)=1.0./a_arr(j)-1;
  for (i=1:NW) 
      fprintf(ifp, '%+5.5f ',  W(i,j));
      PC_all(j,i+1) = W(i,j);
  end
  fprintf(ifp, '\n');
end
fclose(ifp);

%/****************************************************************/
%/** Rotate into errors on w0 and wa                           ***/
%/** note you need derivs wrt w0 and wa, not wrt the PCs!!     ***/
%/** D(i,1) = dw_i/dw0, D(i,2) = dw_i/dwa                    ***/
%/****************************************************************/
for (i=1:NW)  
    D(i,1) = 1.0;
    D(i,2) = 1.0-a_arr(i);
end


%/*******************************************/
%/** perform the projection onto (w0, wa) ***/
%/*******************************************/
for(k=1:2)
    for(l=1:2)
          summ=0;
          for (i=1:NW)
              for (j=1:NW)
                  summ = summ+D(i,k).*G(i,j).*D(j,l);
              end
          end
          F_w0wa(k,l)=summ;
    end
end

dlmwrite([EXT_fomswg_dir 'OUTPUT/w0wa_' output.input_data '_' date '.dat'], F_w0wa,' ');



%/**************************************************************/
%/** print the w0-wa errors, unmarginalized and marginalized ***/
%/**************************************************************/
F_w0wa_inv = inv(F_w0wa);

output.sig_w0 = sqrt(F_w0wa_inv(1,1));
output.sig_wa = sqrt(F_w0wa_inv(2,2));

%/*************************************************/
%/** rotate into zpivot and wpivot and print 'em **/
%/**   Also calculate and print the DETF FOM     **/
%/*************************************************/
Cov_w0w0 = F_w0wa_inv(1,1);
Cov_w0wa = F_w0wa_inv(1,2);
Cov_wawa = F_w0wa_inv(2,2);
one_minus_ap = - Cov_w0wa/Cov_wawa;
output.zp = one_minus_ap/(1-one_minus_ap);
Cov_wpwp   = Cov_w0w0 - (Cov_w0wa^2)/Cov_wawa;

%%%%%%output.DETF_FoM = 1.0/sqrt(Cov_wpwp)/sqrt(F_w0wa_inv(2,2));
output.Marg_F = F_w0wa;
output.DETF_FoM= 1./sqrt(det(F_w0wa_inv));
output.sig_wp = sqrt(Cov_wpwp);

%/******************************************/
%/** Rotate also into error in w=const   ***/
%/******************************************/
F_wconst=0;
for (i=1:NW)
    for (j=1:NW)
        F_wconst = F_wconst+D(i,1).*G(i,j).*D(j,1);
    end
end
output.sig_w_const = 1.0/sqrt(F_wconst);   
%convert to errors on w0 and wa


if isstr(default)
    output.sig_gamma = 'Na';
    output.FoM_gamma = 'Na';
    output.PC_all = PC_all;
        %Output to command line confirming the location of where the Data files have
        %been saved.
    clc;
    'test'
    default
    fprintf(2,'\n\nThe following data files have been generated and saved:\n\n');
    fprintf('PC accuracies (unpriored and priored) are in:\n\n');
    fprintf(2,'                 OUTPUT/sigma_%s_%s.dat\n\n',output.input_data,date);
    fprintf('First four PCs (i.e. eigenvectors) are in:\n\n');
    fprintf(2,'                 OUTPUT/PC_1234_%s_%s.dat\n\n',output.input_data,date);
    fprintf('All PCs (i.e. eigenvectors) are in:\n\n');
    fprintf(2,'                 OUTPUT/PC_all_%s_%s.dat\n\n',output.input_data,date);
    fprintf('2x2 Fisher matrix for w0-wa is in:\n\n');
    fprintf(2,'                 OUTPUT/w0wa_%s_%s.dat\n\n',output.input_data,date);
elseif  find(default==[2,4,5,8])
    FGAMMAinv = inv(FGAMMA);
        
    for (i=1:NW)
        for (j=1:NW)
            Ginv(i,j)=FGAMMAinv(i+N_OTHER,j+N_OTHER);
        end
    end

    G = inv(Ginv);

    for(i=1:NW)
        for(j=1:NW)
            F1(i,j)=G(i,j);
        end
    end
    
    [eigenvec, eigenval] = eig(F1);
        
    d=diag(eigenval);
    v=eigenvec;
    n=NW;
    for (i=1:(n-1))
            k=i;
            p=d(k);
            for (j=[(i+1):n])
                if (d(j) >=p)
                    k=j;
                    p=d(k);
                end
            end

            if (ne(k,i)) 
                d(k)=d(i);
                d(i)=p;
                for (j=1:n) 
                    p=v(j,i);
                    v(j,i)=v(j,k);
                    v(j,k)=p;
                end
            end
    end
    eigenval_sort = d;
    eigenvec_sort = v;
    for (j=1:NW) 
        for(i=1:NW) 
            W(i,j)=eigenvec_sort(j,i);
        end
    end

    RHS = 1.0;
    summ=0;
    for (i=1:NW) 
        summ=0;
        for (j=1:NW) 
            summ=summ+((W(i,j).^2) .*DA);
        end
        norm(i) = summ./RHS;
        eigenval_norm(i) = eigenval_sort(i)./norm(i);

        for (j=1:NW)
            W(i,j) = W(i,j)./sqrt(norm(i));
        end

        summ=0; 
        for (j=1:NW) 
            summ=summ+(1+w_arr(j)).*(W(i,j)./RHS);
        end
        coeff(i)=summ;            
    end
    ifp = fopen([EXT_fomswg_dir 'OUTPUT/sigma_gamma_' output.input_data '_' date '.dat'], 'w');
    fprintf(ifp, 'PC  sigma(wo/prior) sigma(w/prior)\n');
    for (j=1:NW) 
        si(j) = eigenval_norm(j).^(-0.500);
        fprintf(ifp, '%2.2d %12f %14f\n', j, si(j), si(j)./sqrt(1.0 + si(j).^2));
    end
    fclose(ifp);

    ifp=fopen([EXT_fomswg_dir 'OUTPUT/PC_1234_gamma_' output.input_data '_' date '.dat'], 'w'); 
    fprintf(ifp, '     z');
    for (j=1:4)
        fprintf(ifp, '      PC%d', j);
    end
    fprintf(ifp, '\n');
    fclose(ifp);
    for (j=1:NW) 
            PC_1234_gamma(j,1) = 1./a_arr(j)-1;
            PC_1234_gamma(j,2) = W(1,j);
            PC_1234_gamma(j,3) = W(2,j);
            PC_1234_gamma(j,4) = W(3,j);
            PC_1234_gamma(j,5) = W(4,j);
    end
    dlmwrite([EXT_fomswg_dir 'OUTPUT/PC_1234_gamma_' output.input_data '_' date '.dat'], PC_1234(:,:),'-append','delimiter',' ','precision','%+5.5f%');

    ifp=fopen([EXT_fomswg_dir 'OUTPUT/PC_all_gamma_' output.input_data '_' date '.dat'], 'w'); 
    fprintf(ifp, '    z ');
    for (j=1:9) 
        fprintf(ifp, '      PC%d', j);
    end
    for (j=10:NW) 
        fprintf(ifp, '     PC%d', j);
    end
    fprintf(ifp, '\n');    

    for (j=1:NW) 
        fprintf(ifp, '%f ', 1.0/a_arr(j)-1);
        PC_all_gamma(j,1)=1.0./a_arr(j)-1;
        for (i=1:NW) 
              fprintf(ifp, '%+5.5f ',  W(i,j));
              PC_all_gamma(j,i+1) = W(i,j);
        end
        fprintf(ifp, '\n');
    end
    fclose(ifp);


    for (i=1:NW)  
        D(i,1) = 1.0;
        D(i,2) = 1.0-a_arr(i);
    end

    for(k=1:2)
        for(l=1:2)
            summ=0;
            for (i=1:NW)
                for (j=1:NW)
                    summ = summ+D(i,k).*G(i,j).*D(j,l);
                end
            end
            F_w0wa(k,l)=summ;
        end
    end
    dlmwrite([EXT_fomswg_dir 'OUTPUT/w0wa_gamma_' output.input_data '_' date '.dat'], F_w0wa,' ');
    output.sig_gamma = sqrt(FGAMMAinv(6,6));
    output.FoM_gamma = 1./sqrt(FGAMMAinv(6,6));

    output.PC_all_gamma = PC_all_gamma;

    %Output to command line confirming the location of where the Data files have
    %been saved.
    clc;
    fprintf(2,'\n\nThe following data files have been generated and saved:\n\n');
    fprintf('PC accuracies (unpriored and priored) are in:\n\n');
    fprintf(2,'                 OUTPUT/sigma_gamma_%s_%s.dat\n\n',output.input_data,date);
    fprintf(2,'                 OUTPUT/sigma_%s_%s.dat\n\n',output.input_data,date);
    fprintf('First four PCs (i.e. eigenvectors) are in:\n\n');
    fprintf(2,'                 OUTPUT/PC_1234_gamma_%s_%s.dat\n\n',output.input_data,date);
    fprintf(2,'                 OUTPUT/PC_1234_%s_%s.dat\n\n',output.input_data,date);
    fprintf('All PCs (i.e. eigenvectors) are in:\n\n');
    fprintf(2,'                 OUTPUT/PC_all_gamma_%s_%s.dat\n\n',output.input_data,date);
    fprintf(2,'                 OUTPUT/PC_all_%s_%s.dat\n\n',output.input_data,date);
    fprintf('2x2 Fisher matrix for w0-wa is in:\n\n');
    fprintf(2,'                 OUTPUT/w0wa_gamma_%s_%s.dat\n\n',output.input_data,date);
    fprintf(2,'                 OUTPUT/w0wa_%s_%s.dat\n\n',output.input_data,date);
else
    output.sig_gamma = 'Na';
    output.FoM_gamma = 'Na';
    output.PC_all = PC_all;

    %Output to command line confirming the location of where the Data files have
    %been saved.
    clc;
    fprintf(2,'\n\nThe following data files have been generated and saved:\n\n');
    fprintf('PC accuracies (unpriored and priored) are in:\n\n');
    fprintf(2,'                 OUTPUT/sigma_%s_%s.dat\n\n',output.input_data,date);
    fprintf('First four PCs (i.e. eigenvectors) are in:\n\n');
    fprintf(2,'                 OUTPUT/PC_1234_%s_%s.dat\n\n',output.input_data,date);
    fprintf('All PCs (i.e. eigenvectors) are in:\n\n');
    fprintf(2,'                 OUTPUT/PC_all_%s_%s.dat\n\n',output.input_data,date);
    fprintf('2x2 Fisher matrix for w0-wa is in:\n\n');
    fprintf(2,'                 OUTPUT/w0wa_%s_%s.dat\n\n',output.input_data,date);
end
end