OSORT README
============

This is the readme file for the matlab implementation of the online spike sorting algorithm (Osort)

version: 3.00, released March 2013
(see below for a change log)

Copyright (c) 2005-2013 by Ueli Rutishauser. urut (---at---) caltech.edu

This software runs on linux, windows and MacOS X. My experience is that the memory
management of matlab is worse under windows, which naturally leads to
''out of memory'' messages even for loading rather small data files. 

1) Pre-requisites
=================

1. Matlab, including the statistics and signal processing toolbox. Parts also require the wavelet toolbox.
This release is tested with matlab version R2012b, but older versions should work as well.

2. Neuralynx DLLs (windows) or mex files (linux/mac) to read Ncs files - these are included for convenience 
(code/3rdParty folder). The latest version can be downloaded from http://www.neuralynx.com/download.asp (Windows) or from my homepage (Unix and MacOSX).

2) Introduction
===============

There are three types of data files that OSort can process: 
1. simulated data
2. binary data in neuralynx format (*.Ncs, both analog and digital cheetah versions).
3. text files
 
Other data types can easily be incorporated by changing the read routines. 
It is also possible to write neuralynx binary files from matlab (Matlab functions to write Ncs files are
available for download on www.neuralynx.com). This allows easy conversion from any format to Ncs.

There are two user interfaces: graphical and command line. This software was created to allow automatic processing of
large numbers of files. Thus, the main focus was on the command line version. The graphical user interface 
calls the same routines but only allows modification of a few key parameters. It is most useful to quickly process
data to get a feeling for the parameters and the quality of the data. The whole set of parameters 
are set in a textfile and the results of the sorting (figures) are written as png files for later viewing.
Plotting to png files is much faster than to the screen (when you start matlab without the GUI). If you 
would like to see the figures as the program runs simply start matlab with the GUI and remove the commands 
that close the figures immediately after producing them. There are also a few matlab scripts that allow you to 
later discard, merge and accept clusters after viewing the files.


3) How to get started
=====================

Best thing is to work with the simulated data first. We are providing a file that allows you to reproduce all the figures
for the simulations without changing anything (see below).

First: change the setpath.m file to the directory where you unpacked the code to. After you start matlab, execute this file
first.				

3.1) How to process the simulated data files
============================================

1. modify sortingNew/model/loadSimulatedFiles.m to point to the correct path for the datafiles (i.e. osort-v3-rel/data). You have to download the data files separately.

2. Run sortingNew/model/mainSimulatedEval.m with the default parameters - it will run the first simulation ("simulation 1" in paper) with the 3rd noiselevel
and the approximate method of choosing the threshold. It will plot a number of figures illustrating the result (Figs 3, 4, 5).

Modify simNr and levels (first few lines) to process the other simulations / noise levels.

		
3.2 How to process real data files (textmode - osortTextUI directory)
=====================================================================

The osortTextUI is the principal user interface to OSort for production use. It is command-line only. See below for a graphical version.

Included in this package is a demo data file 'A18.Ncs'. This is a stretch of data (~8min) recorded from a
single microwire implanted in the left amygdala of an epilepsy patient. The real recording is much longer but
is not included in the default dataset due to space constraints. This file is in the format "analog cheetah".

1. modify osortTextUI/Standalone_textGUI_demo.m to adjust the path parameters. This demo file is setup to process the A18 demo file provided.
The default parameters are set such that figures are displayed and not exported (exportFigures setting). However, for real usage, it is advisable to set this
parameter to true and start matlab without the GUI. This is much faster. Also, the stages of the sorting can be run separately (doSorting, doDetection, doFigures). 
Files are stored such that sorting can use a previous detecting stage. Same for production of figures. 

2. run osortTextUI/Standalone_textGUI_demo.m . The result will be stored in data/sort and data/figs

To process your own data, make your own copy of Standalone_textGUI_demo.m . One good way to operate is to have one such file for each experimental session.

3.3 How to process real data files (graphical user interface - osortGUI directory)
=============================================================

The graphical user interface is located in code/osortGUI. It can only process real data (see above on how to process simulated data).
Start the GUI by going to code/osortGUI and start Osort.m. This will display the graphical user interface.

See the separate tutorial for a quick walk-through of how to use the GUI to process a real data file.
[The tutorial has not been updated for v3, but is essentially still valid].

The graphical user interface also has a merge GUI and a "define usable clusters" GUI. These can be used to merge and define final clusters graphically, even if sorting is done
with the textmode UI.

The GUI has tooltips (hoover over the items) to explain the options available.

3.3.1 Explanation of data fields and options of the GUI
=======================================================
For windows users, enter paths with slashes instead of backslashes (i.e. z:/data/demo/data).

Raw data path: location of the raw data (for the example above,the path where A18.Ncs is located)
Raw files need to be called Ax.YYY, where x is the channel number and YYY the postfix
(Ncs for neuralynx, txt for text).

Data out path: location where OSort stores the detected spikes.
OSort will automatically create subdirectories in this path. The subdirectories name is the extraction
threshold used. Thus, spikes can be extracted with different extraction thresholds without the files overwriting
each other.

Timestamps include file: (leave empty if not used)
A text file with a list of from/to timestamps (first column from, second column to) of data that should be sorted. The rest is ignored
(spikes are not extracted). This is used to exclude parts of the raw file if it contains data from several experiments or long delays
between experiments.

Channels to process:
which channels to process (i.e. "12 15 19 22")

Ground channels:
which of the channels are grounds (wont be processed and are used for normalization if enabled)

data format: raw data format. analog cheetah assumes 25kHz sampling rate, digital cheetah 32556Hz. For text, 
the sampling rate needs to be specified.

figure label prefix: prefix for all the figures (I use a session ID that identifies the subject&day).

figures path: where the figures are stored. A subdirectory is automatically created in this path for each different 
extraction threshold.

figure format: in which format to export the figures. All extensions that the matlab command "print" supports can be used.

save params (button and text field): stores all the parameters entered into a file that can be loaded. Useful for storing
different parameter combinations.

load params (button and text field): loads the parameters from the file specified.

merge (button): starts the merge GUI (see separate documentation)

define usable clusters: starts the define usable clusters GUI (see separate documentation)

big button ("start" or "sort): start sorting with the parameters specified.

3.3.2 Spike detection
=====================

Spike detection in itself is a rather involved process. It consists of first detecting the spike and then determining its peak (alignment).
OSort supports multiple different methods of spike detection:
1. simple thresholding (positive, negative or absolute)
2. thresholding of the power/local energy (see the paper)
3. wavelet method (see reference list)

For amplitude thresholding, the threshold (T is the "extraction threshold") is specified in terms of mean(signal)+std(signal)*T.
Typical values for T are 4 or 5. If spikes are clearly only to the negative or positive direction, it is useful to only threshold
there. Amplitude thresholding in general only works reliably for very good signals and won't pick up spikes in difficult situations.

Power thresholding: thresholds the local energy signal. Typical threshold valus are ~4-5. The kernel size is the window size that is
used to calculate the local energy - typically 18 is a good value (which is slightly less than 1ms at 25-32kHz sampling,which is the
approximate width of an action potential. Adjust this value if your sampling rate is different).

Wavelet: this method decomposes the signal into a discreet set of wavelets at different scales (see refs). 
Typical detection thresholds are -0.1-0.2. The more positive, the more conservative. 0.1 is usually a good value.
The default scales range is 0.2-1.0 and the default wavelet is 'bior1.5'. 

In terms of computational cost, amplitude thresholding is fastest, followed by power thesholding. The most expensive is the wavelet method
(it is significantly slower).

3.3.3 Spike alignment
=====================

After a spike is detected, it needs to be determined where its peak is. In some situations spikes are very ambiguous. Several methods
are supported:

1. none. The peak of the spike is where the signal crossed the extraction threshold.
2. findPeak. A method that determines how many peaks are significant (relative to the noise levels) and which of the significant once
are larger. The method allows specification of whether all peaks are positive (maximum), negative (minimum) or mixed.
Mixed is the default, but it pays to use max/min if it is clear that on a given channel the spikes are all dominantly in one
direction.
3. peak of the power signal determines the peak location.
4. MTEO (see references). A multiscale method that is most reliable in complicated cases (peaks in both directions, mixed cases).

The methods above are listed in order of increasing computational cost.

3.3.4 Execution options
=======================
Pressing the "Sort" button starts one or more of the following processes, depending on the options that are checked. All
options can be executed independently. For example, it is possible to first detect all spikes but not sort them.

1. Detect spikes (option: "execute spike detection"). Detects and aligns spikes (from raw trace). 

2. Generate a graph of the raw trace and the detected spikes (option: "make spike extraction figure"). This option can be
executed independently from spike detection, but it requires that valid spike extraction parameters are set. To set them,
enable the "execute spike detection" option, choose the parameters and deselect them.

3. Sort spikes (option: "do sorting"). The min. spikes per cluster is the minimal number of spikes that need to be assigned to a cluster
to keep it (otherwise it is assigned to noise).

4. Generate figures of clustering result (option: "make figures of clusters"). Makes a separate figure for each cluster as well as summary
figures. The figures are exported and closed immediately, unless "display figures after sorting" is checked.

5. Generate projection test figures ("do projection test")


4) How to get it running for your own data
==========================================

To get an intuition for the algorithm and the evaluation plots it produces, try playing with the parameters in Standalone_textGUI.m . This is the
main file for changing parameters. One of the critical parameters is the extraction threshold,which,based on noise levels, has to be changed.
For example, if you set a certain extraction level and get strong 60Hz noise in your clusters, it is probably too low. Also if the clusters become
non-separable because of MUA activity. For example, for the demo data file, try setting the extraction threshold to 4 instead of 5.5 as in the
default configuration. You will notice how "sinus-wave" like waveforms start to appear and how you can detect them in the projection plots.

The algorithm produces a substantial amount of debugging output. Also the plotting of all the figures takes time. 
In a real production environemnt it is advisable to export the figures to files and start matlab in textmode only (matlab -nojvm).
After processing is finished, look at the figures in a graphics file viewer like png to evaluate which clusters are good.
This speeds up processing substantially.

4.2 Text format
===============

The algorithm also allows processing of textfiles as input. This works fine, but is considerably slower then using the binary format.

Format: 2 columns. First column: time (equal timesteps, no jumps). Second column: measured voltage (in uV).

The sampling rate of the text file (in Hz, one line per data point) needs to be specified in the field "sampling rate" of the GUI.


5) References
=============

The wavelet based spiked detection methods is implemented as described in the following paper:
Nenadic, Z. and J. W. Burdick (2005). "Spike detection using the continuous wavelet transform." 
Ieee Transactions on Biomedical Engineering 52(1): 74-87.

The MTEO peak finding method:
Choi, J. H., H. K. Jung, et al. (2006). "A new action potential detector using the MTEO and its effects on spike sorting 
systems at low signal-to-noise ratios." Ieee Transactions on Biomedical Engineering 53(4): 738-746.

The spikes sorting itself as well as the findPeak method of alignment is described here:
Rutishauser, U., E. M. Schuman, et al. (2006). "Online detection and sorting of extracellularly recorded action potentials in 
human medial temporal lobe recordings, in vivo." J Neurosci Methods 154(1-2): 204-24.

For an example of real data sorted using our method:
Rutishauser, U., A. N. Mamelak, et al. (2006). "Single-trial learning of novel stimuli by individual neurons of the 
human hippocampus-amygdala complex." Neuron 49(6): 805-13.

6) Copyright
============

We make this source code freely available in the spirit of academic freedom and reproducability of research.
However, it comes with no warranties whatsoever. Use at your own risk. Backup your data before you use it with this
software. We can't guarantee support. You are welcome to modify the code, but please send us updates if you fix a bug
or add a useful feature. We might integrate it into the distribution.

OSort was written by Ueli Rutishauser (Caltech); The GUI was written by Matthew McKinely (MIT).
All the code in 'code/3rdParty' was written by others and is included for convenience.

Copyright (c) by Ueli Rutishauser.

During 2005-2011, this Research was conducted in collaboration with E.M. Schuman and A.N. Mamelak and funded by the
Gimbel Discovery Fund as well as the Howard Hughes Medical Institute, through the laboratory of E.M. Schuman at
Caltech. 2012-present, this research is conducted at Cedars-Sinai Medical Center & California Institute of Technology in the 
laboratory of Ueli Rutishauser (www.rutishauserlab.org).

7) Change Log
=============

v2.00 Sept2007 Initial release of version 2
v2.10 Dec2007  Minor bugfixes related to txt-data files. Other data formats
are not affected. 
v2.20 Feb2008  MedTronic Leadpoint bin format is now supported (GUI). This is a
straight-forward 16-bit two-complement data file, so its easy to convert other
data formats to this one. Reading it is very fast.
v3.00 March 2013: release of various improvements and bugfixes from the development source tree. 

8) Some common problems/FAQ
===========================

1. If matlab reports "Attempt to execute SCRIPT XXX as a function" (where XXX
is something like Nlx2MatCSC_v3 or similar) this means that the appropriate
mex dlls could not be found. If you work on windows, make sure that the Linux
versions of the same mex dlls are not in the path. i.e. to make sure, delete
the two files Nlx2MatCSC_v3.mexglx and Nlx2MatEV_v3.mexglx if you're a windows
user.

2. If matlab reports "file OSort.fig corrupt" or other errors related to
corrupted files, make sure you uncompress the .tar.gz. files correctly. I have
had version of winzip that corrupted binary files! 


====
