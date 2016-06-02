% utility to import Axon binary files v10 into MATLAB
%
%   USAGE
% 1: data = import_abf( filename )
% 2: data = import_abf( filename, episode )
% 3: data = import_abf( filename, offset, samples )
%
%   DETAILED USAGE
% 1: Reads all samples from all recorded channels in FILENAME, if the
% file type is gap-free. If the file type is episodic, this reads only
% the first episode.
%
% 2: If the file was collected in episodic mode, reads all samples from
% a particular episode. If the file type is gap-free, this raises an error.
%
% 3: Reads SAMPLES samples beginning at OFFSET, from all channels. If the
% file type is episodic, this raises an error.
%
% Attempting to read a file which was not collected in either
% episodic or gap-free mode raises an error; no tests have been made
% of the suitability of this code for reading such files.
%
%   TECHNICAL INFORMATION
% import_abf() uses a DLL from Molecular Devices' website
% (http://www.moleculardevices.com/pages/software/developer_info.html)
% with a MATLAB MEX/C wrapper. The library is only available for Windows,
% so import_abf will only ever work on Windows. It was compiled for
% WinXP SP2, using Borland's free command line tools
% (http://www.codegear.com/downloads/free/cppbuilder).
%
%   LICENSE AND ATTRIBUTION
% This code is released with, and may be freely modified and redistributed
% under, the terms of the GNU General Public License
% (http://www.gnu.org/licenses/gpl.html), which means that NO WARRANTY is
% expressed or implied and that credit must be given to each author who
% modifies the code.
%
% created: John Bender 6/15/07 jbender@caltech.edu
