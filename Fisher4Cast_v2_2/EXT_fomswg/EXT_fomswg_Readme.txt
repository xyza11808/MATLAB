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
1)Module EXT_fomswg

############################################################################
Figure of Merit Science Working Group (FoMSWG) F4C Extension produced by 
the Joint Dark Energy Mission (JDEM) Albrecth et al. arXiv:0901.0721
############################################################################

If the results produced from the use of this extension of Fisher4Cast 
have been used in a publication, we kindly request that its use and the 
authors of Fisher4Cast and this extension are acknowledged, as well as the 
authors of (astro-ph/0510239).

* EXT_fomswg.m
    This is the main function of the FoMSWG extension. It takes as input a 
    numerical value between 1 and 8 which corresponds to default 
    combinations of the Fisher matrices stored in DATA/ sub-directory. The 
    options are:
       SN only          (1)
       WL only          (2)
       SN+PLANCK        (3)
       WL+PLANCK        (4)
       SN+WL+PLANCK     (5)
       BAO only         (6)
       BAO+PLANCK       (7)
       SN+WL+PLANCK+BAO (8)
    There is also an option to input the user defined fisher matrix file 
    by providing a string which details the directory and file name. An 
    output structure is produced after running this function along with a 
    set of files that are written to the OUTPUT/ sub-directory. The output
    structure contains the name of Fisher matrix file used as input;
    sigma w0; sigma wa; zp; the marginalised Fisher matrix; DETF FoM; 
    sigma wp; sigma w_const; sigma gamma; FoM gamma and a matrix of all the 
    Principle Components. The output files include the PC accuracies 
    (unpriored and priored) which are written to: OUTPUT/sigma_*.dat ; 
    First four PCs (i.e. eigenvectors) are written to: OUTPUT/PC_1234_*.dat;
    All PCs (i.e. eigenvectors) are written to: OUTPUT/PC_all_*.dat;
    2x2 Fisher matrix for w0-wa is in: OUTPUT/w0wa_*.dat. 

* EXT_fomswg_gui.m
    This is a light weight GUI which calls EXT_fomswg.m with the respective 
    user supplied inputs. It can be launched from the command line or from 
    the menu option under 'F4C Extensions->FoMSWG Pop-Up Extension' the 
    Fisher4Cast GUI  The output structure is displayed in the right panel 
    of the GUI. The output files are produced as per normal from 
    EXT_fomswg.m. There is an additional option to plot the first Principle
    Component (PC) as a function of redshift produced from the last run. 
    One can also plot the DETF FoM error ellipse for the given fisher 
    matrix which can be displayed directly in the Fisher4Cast GUI and 
    allows for an easy comparison with other DETF FoM error ellipses. 

* EXT_fomswg_gui.fig
    This function is to accompany the EXT_fomswg_gui.m file and is produced
    using Guide. It lays out the GUI configuration.

* EXT_fomswg_plot_PC.m
    This functions plots the absolute value of the Principle Components 
    (PC's) as a function of the redshift bins and thus requires an inpout 
    of a matrix of at least two column containing the redshift and PC's. 
    The PC_all field for the output structure can be used for this purpose, 
    i.e. output.PC_all. The second input is optional and allows the line 
    colour of the plot to be specified.

* DATA/ 
    The default data files for the Fisher Matrices contained in this
    sub-directory include PLANCK.dat preJDEM_BAO.dat preJDEM_SN.dat and 
    preJDEM_WL.dat.
 
    