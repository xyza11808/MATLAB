function obj = tstamp(varargin)
% TSTAMP contructor for tstamp class objects
%
% TSTAMP objects allow data to be accessed as though the tstamp was a
% double array while storing the data in more compact form, including as a
% memmapfile object.TSTAMP objects are similar to ADCARRAY objects but are
% designed for storing timestamps rather than waveforms.
%
% An TSTAMP object usually contains a memmapfile object, together with
% a scale and time offset (shift) to convert the values stored on disc
% (and pointed to by the memmapfile object) to real world values which are
% returned as double precision. These can also be transformed by a function
% pointed to by a handle stored in the tstamp object.
%
% Referencing a TSTAMP object as though it were a double precision array
% i.e. using obj(...) returns a scaled, shifted and transformed double
% precision array regardless of the native format of the data in the
% .Data.Time field. These can be passed as input arguments to other MATLAB
% functions e.g. s=sum(obj()).
%
% Also, the memmapfile object can be replaced by a structure where
% tstamps are used to store data in MATLAB memory space without using
% memmapfile (which removes the need for linkage to a disc file).
%
% TSTAMP objects have six properties
%           MAP:   [1] A memmapfile object containing the data
%                  or
%                  [2] A structure containing the data
%                   In either case, the data is available in
%                   obj.Map.Data.Stamps or by using the obj() syntax (see
%                   below)
%           SCALE: Multiplier to convert data to basic clock units. When
%                  the scaled values are multiplied by Units (see below)
%                  the timestamps will be in seconds i.e.
%                       obj.Map.Data.Stamps*Scale*Units
%                  gives the time in seconds
%           SHIFT: Value added to returned data after scaling. This is
%                  usually zero. If non-zero it should be scaled in
%                  basic clock ticks to allow conversion to seconds using
%                  Units.
%           FUNC:  A function handle
%           UNITS: The multiplier needed to convert the scaled values to
%                  seconds e.g:
%                  1 if the scaled values are in seconds (default)
%                  10^-3 ........................millisconds
%                  10^-6 ........................microseconds
%                                                       etc.
%                  86400.........................days
%                  3600..........................hours
%                  60............................minutes
%                  Other values may also be used e.g. if the basic clock
%                  tick is 1.25 microseconds, Units would be 1.25*10^-6.
%           SWAP:  true/false flag indicating whether disc data need to be
%                  byte swapped
%
% Creating tstamp objects:
% Examples:
%   OBJ=TSTAMP() creates a default object (.Map is a structure)
%
%   OBJ=TSTAMP(IN) creates an object where:
%               obj.Map is a memmapfile object if IN is such as object.
%               Note that data should be in IN.MAP.DATA.STAMPS - explicitly
%               provide a format to memmapfile.m when creating IN to create
%               the Data structure with a DATA.STAMPS field e.g.
%   m=memmapfile('mydata.dat','format',{'int16' [20 200 200] 'Stamps'},...
%                   'repeat',1)
%               or
%               obj.Map is a structure if IN is not a memmapfile object, in
%               which case the contents if IN will be placed in the
%               .Data.Stamps field
%
%   OBJ=TSTAMP(IN, SCALE)
%   OBJ=TSTAMP(IN, SCALE, SHIFT)
%   OBJ=TSTAMP(IN, SCALE, SHIFT, FUNC)
%   OBJ=TSTAMP(IN, SCALE, SHIFT, FUNC, UNITS)
%   OBJ=TSTAMP(IN, SCALE, SHIFT, FUNC, UNITS, SWAPBYTES)
%       set the relevant properties as described above.
%
%   OBJ=TSTAMP(S)
%       casts structure s to tstamp class. s must have the appropriate
%       fields.
%
% READING TSTAMP PROPERTIES:
% TSTAMP objects can be read as though they were simple double
% precision matrices using the '()' subscriptor. Thus,
% obj(), obj(:), obj(1:10), obj(2,1:5,10:end) etc return double precision
% results after applying the scale and offset to the appropriate elements
% of obj.Map.Data.Stamps and transforming them via obj.Func i.e.
%       obj(...) is equivalent to
%       func(double(obj.Map.Data.Stamps(...))*obj.Scale+obj.Shift)
% It follows that you can not use this syntax to access arrays of
% tstamps e.g. x(2)=tstamp() is invalid (though cell arrays of tstamps
% are OK e.g. x{2}=tstamp()).
%
% Note that SIZE() and END are overloaded for tstamp objects and return
% the size (or end index) of the obj.Map.Data.Stamps field.
%
% Field access with '.' or using GET works as with other objects
% E.g.  get(obj,'Scale') or obj.Map.Data.Stamps returns the stored result
% in its native class.
% Subscription of fields using '()' also works normally, thus
%       a=obj.Map.Data.Stamps(1:10)
% returns the first 10 elements of data (in the native format without
% scaling or offseting).
%
% obj without subscription passes the object
% obj at the command prompt displays a summary of the contents of obj
%
% USING FUNC
% FUNC may be a handle to a simple function to transform the data.
%
% Markers
% The marker field is added to a tstamp on creation but is always set
% empty. Values should be added to the marker field through the set or
% subsasgn methods
%
% See also adcarray
%
% Author: Malcolm Lidierth
% Copyright © 2006 King’s College London
%
% Revisions:
%            05.12.06 Coding tidied
%            03.01.10    Add default constructor


if nargin==0
    obj.Map=[];
    obj.Scale=[];
    obj.Shift=[];
    obj.Func=[];
    obj.Units=[];
    obj.Swapbytes=[];
else
    % Structure as input
    if isstruct(varargin{1})
        s=varargin{1};
        if isa(s.Map, 'memmapfile')
            temp=s.Map;
        else
            temp=s.Map.Data.Stamps;
        end
        if isstruct(temp)
            % Prevent infinite loop
            error('Map.Data.Stamps field may not contain a structure');
        else
            % Recursive call
            obj=tstamp(temp,...
                s.Scale,...
                s.Shift,...
                s.Func,...
                s.Units,...
                s.Swapbytes);
            return
        end
    end
    
    obj.Map.Data.Stamps=int16([]);
    obj.Scale=1;
    obj.Shift=0;
    obj.Func=[];
    obj.Units=1;
    obj.Swapbytes=false;
    
    if nargin>=1
        if isa(varargin{1},'memmapfile')
            obj.Map=varargin{1};
        else
            obj.Map.Data.Stamps=varargin{1};
        end
    end
    
    if nargin>=2
        obj.Scale=varargin{2};
    end
    
    if nargin>=3
        obj.Shift=varargin{3};
    end
    
    if nargin>=4
        obj.Func=varargin{4};
    end
    
    if nargin>=5
        obj.Units=varargin{5};
    end
    
    if nargin>=6
        obj.Swapbytes=varargin{6};
    end
    
    % if input was not a memmapfile object, add fields to the
    % map struct (N.B. obj.Map.Data.Stamps already assigned)
    if isstruct(obj.Map)
        obj.Map.Filename='';
        obj.Map.Writable=false;
        obj.Map.Offset=0;
        obj.Map.Format={};
        obj.Map.Repeat=1;
    end;
    
    % check that repeat is 1.
    if obj.Map.Repeat~=1
        error('tstamp.tstamp: the repeat property of the memmapfile object must to set to 1');
    end;
    
    if isempty(obj.Units)
        obj.Units=1;
    end;
    
    % This is needed only for kcl files that were imported with sigTOOL version
    % 0.5 and earlier. obj.Units has been redefined.
    if ischar(obj.Units)
        switch obj.Units
            case {'seconds' 's'}
                obj.Units=1;
            case {'milliseconds' 'msec' 'ms'}
                obj.Units=10^-3;
            case {'microseconds' 'µs'}
                obj.Units=10^-6;
        end
    end
end

obj=class(obj,'tstamp');

return
end


