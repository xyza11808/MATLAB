function obj=scchannel(s)
% scchannel constructor for sigTOOL channel object
%
% Example:
% obj=scchannel(s)
% returns an scschannel object given a sigTOOL channel structure as input
%
% scchannel object methods fall into 4 classes:
%   convXXXXXXXX
%   getXXXXXXXXX
%   findXXXXXXXX
%   and
%   extractXXXXXXXX
%
% When the input is a time, or time range conv and get methods will convert
% the supplied start time(s) to the next time coincident with a sample on
% the channel.
% The find methods work similarly to the get methods, but there are
% restrictions on the supplied inputs.  Generally they require the supplied
% start or trigger times to fall within an epoch if data are episodic.
% If they do not, find methods will either:
%           [1] return zero, typically e.g. when the expected returned
%                   value is an epoch number
%           or
%           [2] throw an error e.g. when the expected value is an index.
%
% extractXXXXXX methods are higher level, convenience, methods used to
% extract data from the scchannel objects
%
% findMaxPreTime
% findVectorIndices
% getPhysicalTriggers
% getValidTriggers
% convIndex2Time
%

% The following methods operate on physical epochs
% convTime2PhysicalEpochs
% convTime2PhysicalIndex
% findPhysicalEpochs
% extractPhysicalEpochData     returns data in the adc field for the epochs
% extractPhysicalEpochTimes    returns the timestamps associated with the
%                              epochs
%
%
% The following methods operate on valid epochs
% convTime2ValidEpochs
% convTime2ValidIndex
% extractValidEpochData     returns data in the adc field for the epochs
% extractValidFrames
% extractValidEpochTimes    returns the timestamps associated with the
%                           epochs
% findValidEpochs
% findValidFrameIndices
% getValidEpochNumbers      returns the physical numbers for the valid epochs
%                           in the specified time range
% findMaxPostTime
% findMaxPreTime

%--------------------------------------------------------------------------

% Revisions
%       03.01.10    Add default constructor
%          01.10    Various for improved backwards compatability, see within

% 03.01.10
if nargin==0
    % Default constructor
    s.CurrentSubchannel=[];
    s.EventFilter=[];
    s.adc=[];
    s.channelchangeflag=[];
    s.hdr=[];
    s.mrk=[];
    s.tim=[];
else
    % Add the Event Filter field if it is absent
    if ~isfield(s, 'EventFilter')
        s.EventFilter.Mode='off';
        s.EventFilter.Flags=[];
    end
    
    % Add the channelchangeflag field if it is absent
    if ~isfield(s, 'channelchangeflag')
        s.channelchangeflag.hdr=false;
        s.channelchangeflag.adc=false;
        s.channelchangeflag.tim=false;
        s.channelchangeflag.mrk=false;
    end
    
    % Add the subchannel field to support multiplexed data
    if ~isfield(s, 'CurrentSubchannel')
        s.CurrentSubchannel=1;
    end
    
    % 09.12.09 Add the group level to the header if absent
    if ~isfield(s.hdr, 'Group')
        s.hdr.Group.Number=1;
        s.hdr.Group.Label='';
        s.hdr.Group.SourceChannel=0;
        s.hdr.Group.DateNum=datestr(now());
    end
    
    % 23.01.10 Add the patch field to the header if absent
    if ~isfield(s.hdr, 'Patch')
        s.hdr.Patch.Type=[];
        s.hdr.Patch.Em=[];
        s.hdr.Patch.isLeak=[];
        s.hdr.Patch.isLeakSubtracted=[];
        s.hdr.Patch.isZeroAdjusted=[];
    end
    
    % 23.01.10 Add the environment field to the header if absent
    if ~isfield(s.hdr, 'Environment')
        s.hdr.Environment.Coordinates=[];
        s.hdr.Environment.Temperature=[];
    end
    
    % 26.01.10 Add the source field to the header if absent
    if ~isfield(s.hdr, 'source') 
        s.hdr.source.name='';
        s.hdr.source.date='';
        s.hdr.source.bytes=0;
        s.hdr.source.isdir=0;
        s.hdr.source.datenum=0;
    elseif ischar(s.hdr.source)
        % Backwards compatability
        temp=s.hdr.source;
        s.hdr.source=[];
        s.hdr.source.name=temp;
        s.hdr.source.date='';
        s.hdr.source.bytes=0;
        s.hdr.source.isdir=0;
        s.hdr.source.datenum=0; 
    end
    
    
end

% Order the fields
% (constant order is needed in all instances of a class)
s=orderfields(s);
% Cast to scchannel
obj=class(s, 'scchannel');
return
end