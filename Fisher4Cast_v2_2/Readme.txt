% -----------------------------------------------------------------------
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
For more information, see the Manual, or contact the developers.
-----------------------------------------------------------------

#################################################################
Fisher4Cast v 2.2 - 10 Sept 2010
#################################################################

If the results produced from the use of Fisher4Cast have been
used in a publication, we kindly request that its use and the
authors of Fisher4Cast are acknowledged.

-----------------------------------------------------------------
Introduction
-----------------------------------------------------------------

Fisher4Cast has been developed to provide a general, flexible
and easily extendible framework for Fisher matrix analysis with
both Graphical User Interface (GUI) and command line versions.
Here we provide a very brief guide. For more complete
guidelines to the code please see the manual
(Users_Manual.pdf). The code and its scientific
application are also discussed in Bassett et al. (2009).

-----------------------------------------------------------------
Hardware and software requirements
-----------------------------------------------------------------

This software is written to be run in Matlab (Linux and Windows).
The user needs Matlab installed (Tested on Version 7) to be able
to run this code. Free disk space of approximately 2MB and the
minimum recommended processor and memory specifications required
by the Matlab version you are using is suggested.

-----------------------------------------------------------------
Getting started
-----------------------------------------------------------------

* Downloading Fisher4Cast

Currently the code is available at http://www.cosmology.org.za or
http://www.mathworks.com/matlabcentral/fileexchange/. Save
this .zip file into the directory you want to run the Fisher4Cast
suite from.

The code can be run from the command line or the Graphical User
Interface (GUI). We describe the command line below, and mention
how to get the GUI started. For more information on the GUI,
please see the manual.


-----------------------------
The GUI
-----------------------------

* Running the GUI
The GUI can be started from the Matlab editor. The file FM_GUI.m
must be opened from the directory, and once the file is opened
(click on the file icon from within the Command-line interface to
open it with an editor) press F5 to run the code. This will open
up the GUI screen.

You can also launch the GUI from the command line by typing:

 >>FM_GUI

This then functions in the same way as using FM_run in the command
line (as explained below) and you can now similarly examine your
output structure from the command line by accessing the parts of
the structure `ans' for each of the GUI inputs you run. For example
typing `ans.fom' will give you the entries in the Figure of Merit
field of the structure.

For more information on the technicalities of the GUI, see the
full manual.

-----------------------------
The Command Line
-----------------------------

* Running the code

Open your version of Matlab and change the working directory to be
the same as where you saved Fisher4Cast in. To run the code from
the command line with one of the standard test input structures
supplied, type:

 >>output = FM_run(Cooray_et_al_2004)

This will call the code using the pre-supplied test input data
(Cooray_et_al_2004) and then generate an error ellipse plot for
the parameters and observables supplied in the chosen input. All
the relevant generated output is written to the output structure.
You can see the range of outputs to access by typing:

 >>output

and then examine each output individually by specifying it exactly.
For example:

 >>output.marginalised_matrix

You can use the supplied input files as a template for generating
new input files with your own customised parameters and values.

The code can also be run from the Matlab editor. Once the code is
opened (open it from inside the Matlab window), you can press F5
to run the code. Note that if the code is run from the Editor it
will call the default input structure, which is the
Cooray_et_al_2004.m file. This is an example file containing input
data from the paper by Cooray_et_al. (astro-ph/0304268). This
output can be directly compared to that of Figure 1 of that paper.
If your output compares correctly, you have a working installation
of the code.

-----------------------------------------------------------------
Important known problems
-----------------------------------------------------------------

*Overlapping filled error ellipses:
If 'hold on' and 'fill' are both selected and a larger error
ellipse (B) is plotted after a smaller error ellipse has already
been plotted (A), then B will overlap A and A wont be visible in
the graph.

*Unresponsive color change in linux version
There is a block of color just next to the input base parameters
that doesn't change color appropriately with the skin color that
is selected.

*Area fill for the FoMSWG GUI Extension does not work:
No area fill for the plots of the FoMSWG ellipse can be produced
from the GUI. This would have to be done manually using the plot
specifications in the figure window or manually from the command
line.

*If you follow this sequence of instructions:
1) Load 'Seo & Eisenstein' from the drop down input list
2) Select the Growth observable (it will be empty and not normaly
   selected). 
3) When you press RUN, F4C will correctly report and error 
   message: "Improper assignment with rectangular empty matrix."
This message will however persist even if you go back to 
a legitemate input that contains Growth inputs, such as the 
'Cooray' input file. If you press RUN now, the same error will 
appear: "Improper assignment with rectangular empty matrix."

-----------------------------------------------------------------
Version History
-----------------------------------------------------------------

* Angel Fish - Fisher4Cast - Alpha Release 20/02/2008
A limited release to willing testers.

* Barracuda - Fisher4Cast - Beta Release 21/05/2008
We have improved the code in general and made new additions.
- Added ability to plots the likelihood for chosen parameter.
- Applied extensive development on GUI options
   + added numerical/analytic selection drop down menu
   + the growth normalisation can be set from GUI
   + variety of FoM added and made accessible through the GUI
   + the ability to edit the plot axis has been added
   + the option to select the background color and image for the 
     GUI was added
- Optimised the efficiency of the numerical functions.

* Fisher4Cast - v 1.1 27/05/2008
- Removed Background image bug, reported by Cristiano Sabiu.
- Added horizontal orientation for y label axis.

* Fisher4Cast - v 1.2 16/12/2008
- Extensions added:
   + Text + Latex reporting function added via [FM_report_text.m +
     FM_report_latex.m]. These are accessible from both command
     lines and through buttons on the GUI. Reports can be saved
     to any path specified by the user, and error messages
     created if the Hold On is applied while the reports are
     generated.
   + Baryon Acoustic Oscillation (BAO) errors from survey
     parameters. This is done with either the Blake et al. (2005)
     fitting formula or the Seo & Eisenstein (2007) algorithm. 
     These are run from the command line. The inputs to these
     functions have been changed to an input structure.
- Removed y label rotation bug for Likelihood plots.
- Replaced FM_generate_ellipse.m with FM_generate_plot.m which 
  then either calls FM_plot_likelhood.m of FM_plot_ellipse.m.
- Made improvement to the Likelihood function 
  [FM_plot_likelihood.m previously FM_plot_ellipse.m] so that the 
  resolution is not a problem when plotting while the linestyle 
  and sigma level can be changed via the GUI.
- Made the GUI buttons uniform for all versions [FM_GUI_colors.m].
- Improved the growth normalisation function so it is more robust
  [FM_analytic_deriv.m].
- Removed a bug from the Matrix and Dark Skin colour theme. Now 
  the axis label colours remain green [FM_GUI.m].
- Removed the errors associated with using the edit axis button on 
  a Likelihood function in the GUI [FM_axis_specfication] and the 
  axis labels are now bold by default. 
- Fixed the functionality of the xlim and ylim checkboxes in the 
  GUI [FM_GUI.m]. 

* Fisher4Cast - v 2.0 28/05/2009
- Extensions added: 
	+ Interactive plotting which enable you to choose values 
          for the parameters being plotted. This can be activated 
          from the Fisher4Cast Extension menu within FM_GUI and 
          then allows the user to interactively set the parameter 
          values for plotting by clicking on the plotting area 
          with the mouse [FM_GUI FM_GUI_interactive_plot.m].
- Corrected an input error for loading text files to redshift data 
  from the GUI [FM_GUI.m].
- To avoid confusion the BAO extensions both now take fractional 
  errors, as used in the GUI, and not percentage errors for 
  redshift data [EXT_FF_Blake_etal2005_Main.m 
  EXT_FF_Blake_etal2005_calculate_error.m 
  EXT_FF_SeoEisenstein2007_errFit.m 
  EXT_FF_SeoEisenstein2007_Main.m]. 
- The option for analytic derivatives has been removed from the
  GUI for growth. Now the derivatives are only calculated 
  numericaly [FM_GUI].
- The function that performs the numerical derivatives has been
  further optimized and imrpoved. Specifically for the growth 
  function [FM_num_deriv.m].
- There is a check that is done to see if G or Growth are used in 
  the observable names of the input. If they are then a further 
  check is made to ensure that the numerical derivative flag is 
  used for growth when it is selected in the observable index 
  [FM_errorchecker.m].
- The check to ensure that the length of the function names and 
  the number of observable names should be the same, has been 
  removed [FM_errorchecker.m].
- FM_analytic_deriv_3.m has been removed.
- The input structures no longer have FM_analytic_deriv_3 listed 
  in the input.functions_name [Cooray_et_al_2004.m 
  Seo_Eisenstein_2003.m]
- The 1 & 2 sigma levels for the likelihood plot can now each be 
  plotted in a user specified color [FM_plot_specifications.m 
  FM_plot_likelihood.m].
- A unique error of choosing parameters to plot as being [1 2] or
  visa versa was resloved [FM_marganilise.m]. 
- Use Prior checkbox is included in the GUI [FM_GUI FM_GUI_colors].
- There is an additional warning if no obseravables are selected
  [FM_errorchecker.m]. 
- A new sub-directory with a selection of codes used to generate 
  the figures in the release paper is included [FIG_release_paper].

* Fisher4Cast - v 2.1 13/03/2010
- The DETF Figure of Merit was changed to match the Task Force 
  Report directly.
- A bug which changed the background color when the command 
 'whitebg' is used, was corrected.
- A redundant edit field was removed, which was only visible while 
  running on Mac OS X. 
- A bug was corrected where the history of FoM values was not being
  saved while using the Interactive Plotting module.
- Amended the Interactive Plotting routine to correctly work for 
  1-Dimensional likelihoods.
- Adjusted the GUI to display only errors (rather than Figures of Merit)
  for the 1-D likelihood case.
- Added code to the 1-D likelihood to indicate the central value.

* Fisher4Cast - v 2.2 29/02/2012
- Added new extension, EXT_fomswg. [folder: EXT_fomswg/ files:
  EXT_fomswg.m EXT_fomswg_gui.m EXT_fomswg_gui.fig EXT_fomswg_plot_PC.m 
  EXT_fomswg_plot_specifications.m EXT_fomswg_plot_ellipse.m]
  [folder: EXT_fomswg/DATA/ files: PLANCK.dat preJDEM_BAO.dat
  preJDEM_SN.dat preJDEM_WL.dat] [folder: EXT_fomswg/OUTPUT].
- Modified FM_GUI to include menu option to access the new extension
  [FM_GUI.m].
- Can be run from both command line and GUI. 
- Includes a function to plot PC generated from output structure.
  [EXT_fomswg_plot_PC.m].
- Can also plot error ellipse for DETF FoM for direct comparison within 
  Fisher4Cast GUI. This has its own plotting function 
  [EXT_fomswg_plot_ellipse.m] which calls the default FM function 
  [FM_plot_error_ellipse.m] and also uses 
  [EXT_fomswg_plot_specifications.m] which is based on the default
  [FM_plot_specifications.m].
- The 1st principal component (PC) can also be plotted via the GUI or
  the command line using [EXT_fomswg_plot_PC.m]. 
- A loading error was corrected for the GUI which limited the number of
  data entries for redshift to be loaded from a spreadsheet [FM_GUI.m].
- An improvement was introduced to the error checker to account for 
  all possibilities of the index_growth variable [FM_errorchecker.m]. 
- Removed a phantom gray block next to the Omega_m checkbox in FM_GUI. 
  This was only reported as visible on versions running on MAC OS X.

-----------------------------------------------------------------
Contributors
-----------------------------------------------------------------
* Cristiano Sabiu - for insight into solving the Background
image bug.
* Daniel Holz - for discovering an input error for text files 
that are loaded for redshift data from the GUI.
* Patrice Okouma - for pointing out that the extensions for BAO took 
the errors as percentage errors and not fractional errors. 
* Dragan Hurter - for discussion on the growth function leading 
to a correction in FM_function_3.m
* Anže Slosar - for discussion on the DETF Figure of Merit.

-----------------------------------------------------------------
Contact us at:
-----------------------------------------------------------------

fisher4cast@gmail.com (bugs, problems, questions, suggestions)
