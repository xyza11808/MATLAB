function header=scCreateChannelHeader()
% scCreateChannelHeader returns a default channel header for a sigTOOL channel
% 
% Example:
% header=scCreateChannelHeader
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 09/09
% Copyright © The Author & King's College London 2009-
% -------------------------------------------------------------------------

% For a full description the header structure, see the 
% sigTOOL Programming Manual

% Revisions:
%   31.12.09    Add group structure
%   24.01.10    Add Patch and Environment structures
% The target channel number, from 1 upwards
header.channel=NaN;
% The channel type. A string, Basic types are:
% Edge, Rising Edge, Falling Edge, Pulse, Waveform, Episodic Waveform,
% Framed Waveform.
header.channeltype='';
% For custom channel types, a function can be specified to handle the data.
% Specify as a string which must be in scope on the target machine to be
% called
header.channeltypeFcn='';
% Channel comment. A string
header.comment='';
% Channel title. A string
header.title='';
% The class of data used to store the channel markers. A string
header.markerclass='';

% 31.12.09 Add the group data
header.Group.Number=1;
header.Group.Label='';
header.Group.SourceChannel=0;
header.Group.DateNum=datestr(now());

% 24.01.10 Add the patch field
header.Patch.Type=[];
header.Patch.Em=[];
header.Patch.isLeak=[];
header.Patch.isLeakSubtracted=[];
header.Patch.isZeroAdjusted=[];

% 24.01.10 Add the environment field
header.Environment.Coordinates=[];
header.Environment.Temperature=[];

% These are for future use
header.classifier.By=[];
header.classifier.For=[];

% The adc field. Type "help adcarray" for details.
% DC offset to add to data
header.adc.DC=0;
% Function to transform the data stored on disc (usually empty)
header.adc.Func='';
% Labels for each dimension of the data matrix e.g. {'Time' 'Epoch'}
% Strings in a cell array
header.adc.Labels={};
% Interval between samples on different channels for multiplexed data
header.adc.MultiInterval=[0 0];
% Number of channels
header.adc.Multiplex=1;
% Number of points in the waveform. A row vector with one entry for each
% epoch
header.adc.Npoints=0;
% The sampling interval. The interval is the product of the two numbers.
% Typically the forst should be an flint and the second the scale e.g
% 25.0 and 1e-6 for 25 microsecond sample intervals
header.adc.SampleInterval=[1 1];
% The scale required to convert the values to the real world units
% specified in header.adc.Units
header.adc.Scale=1;
% The target class for the data as a string. Typically 'adcarray'
header.adc.TargetClass='';
% The real world units. A string
header.adc.Units='';
% The limits of the data in real world units. Used to scale the display in
% sigTOOL
header.adc.YLim=[-5 5];

% Timestamps field
% Type "help tstamp" for further details.
% The target class as a string. Typically 'tstamp'
header.tim.Class='';
% Function to transform the data stored on disc (usually empty)
header.tim.Func=[];
% Multiplier to scale the the data to real world units specified in 
% header.tim.Units
header.tim.Scale=1;
% A shift factor to apply to the data after scaling (typically zero)
header.tim.Shift=0;
% The factor needed to convert to seconds e.g. 1e-6 if the scaled data are
% in microseconds
header.tim.Units=1;

% Source file field
% This can be replaced in the output by a call to dir 
% e.g. header.source=dir(sourcefilename)
header.source.name='';
header.source.date='';
header.source.bytes=0;
header.source.isdir=0;
header.source.datenum=0;

% Put in alphabetical order for later class construction
header=orderfields(header);
header.adc=orderfields(header.adc);
header.tim=orderfields(header.tim);

return
end