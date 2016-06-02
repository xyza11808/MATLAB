function obj = adcarray(varargin)
% ADCARRAY contructor for adcarray class objects
%
% ADCARRAY objects allow data to be accessed as though the adcarray was a
% double array while storing the data as a memmapfile object, or as an
% array of another class e.g. int16. The data in an adcarray might
% typically be  values from an analog-digital convertor that are stored in
% a file and mapped via the memmapfile object.
%
% An ADCARRAY object usually contains a memmapfile object, together with
% a scale and offset to convert the values stored on disc (and pointed to
% by the memmapfile object) to real world numbers which are returned as
% double precision. These can also be transformed by a function pointed to
% by a handle stored in the adcarray object. Referencing an ADCARRAY object
% as though it were a double precision array i.e. using obj(...) returns
% a scaled, offset and transformed double precision array regardless of
% the native format of the data in the memmapfile object. These can be
% passed as input arguments to other MATLAB functions e.g. s=sum(obj()).
%
% Also, the memmapfile object can be replaced by a structure where
% adcarrays are used to store data in MATLAB memory space without using
% memmapfile (which removes the need for linkage to a disc file).
%
% ADCARRAY objects have seven properties
%           MAP:   [1] A memmapfile object containing the data
%                  or
%                  [2] A structure containing the data
%               In either case, the data is available in
%               obj.Map.Data.Adc or by using the obj() syntax (see
%               below)
%           SCALE:  Multiplier to convert data to real world values
%           DC: Value added to returned data after scaling
%           FUNC: A function handle
%           UNITS: A string indicating the real world units after scaling
%                   (e.g. µV)
%           LABELS: a call array of strings giving the real world
%               meaning for each dimension of the MAP.DATA.ADC
%               array e.g. {'Time' 'Sensor number'} - default 'Not Set'.
%           SWAPBYTES: true/false flag indicating whether disc data need to be
%               byte swapped
%
% NOTE: SCALE and DC should be doubles but are not forced to double
% precision. If you use a different class, be aware that mixed-class
% arithmetic will be executed, e.g. by subsref, and the returned values
% may not be double.
%
% Creating adcarray objects:
% Examples:
%   OBJ=ADCARRAY() creates a default object (.Map is a structure)
%
%   OBJ=ADCARRAY(IN) creates an object where:
%               obj.Map is a memmapfile object if IN is such as object.
%               Note that data should be in IN.MAP.DATA.ADC - explicitly
%               provide a format to memmapfile.m when creating IN to create
%               the Data structure with a DATA.ADC field e.g.
%       m=memmapfile('mydata.dat','format',{'int16' [20 200 200] 'Adc'},...
%                           'repeat',1)
%               or
%               obj.Map is a structure if IN is not a memmapfile object, in
%               which case the contents of IN will be placed in
%               the .Data.Adc field. In this case .Data.Adc may be sparse.
%
%   OBJ=ADCARRAY(IN, SCALE)
%   OBJ=ADCARRAY(IN, SCALE, DC)
%   OBJ=ADCARRAY(IN, SCALE, DC, FUNC)
%   OBJ=ADCARRAY(IN, SCALE, DC, FUNC, UNITS)
%   OBJ=ADCARRAY(IN, SCALE, DC, FUNC, UNITS, LABELS)
%   OBJ=ADCARRAY(IN, SCALE, DC, FUNC, UNITS, LABELS, SWAPBYTES)
%   set the relevant properties as described above.
%
%   OBJ=ADCARRAY(S)
%       casts structure s to adcarry class. s must have the appropriate
%       fields.
%
% READING ADCARRAY PROPERTIES:
% ADCARRAY objects can be read as though they were simple double
% precision matrices using the '()' subscriptor. Thus,
% obj(), obj(:) (but see *Note below), obj(1:10), obj(2,1:5,10:end) etc
% return double precision results after byte swapping if required, then
% applying the scale and offset to the appropriate elements of
% obj.Map.Data.Adc and transforming them via obj.Func i.e.
%       obj(...) is equivalent to:
%       if obj.Swapbytes==true
%           obj=swapbytes(obj.Map.Data.Adc(...));
%       else
%           obj=obj.Map.Data.Adc(...);
%       end
%       obj=func(double(obj)*obj.Scale+obj.DC)
% It follows that you can not use this syntax to assign arrays of
% adcarrays e.g. x(2)=adcarray() is invalid (though cell arrays of adcarrays
% are OK e.g. x{2}=adcarray()).
%
% Note that SIZE() and END are overloaded for adcarray objects and return
% the size (or end index) of the obj.Map.Data.Adc property (or field).
%
%-------------------------------------------------------------------------
% *Note:
% CHANGE: 23.12.06
% The following exception has been introduced:
% If the adcarray object contains a vector, the obj(:) syntax returns the
% object as an adcarray containing a column vector. This allows us to
% maintain the advantage of the adcarray memory mapping in MATLAB supplied
% functions that call, e.g., x=x(:) to ensure that x is aligned as a column
% vector
%
% On a 2D or higher matrix, obj(:) still returns a double matrix
%-------------------------------------------------------------------------
%
% Field access with '.' or using GET works as with other objects
% E.g.  get(obj,'Scale') or obj.Map.Data.Adc returns the stored result
% in its native class.
% Subscription of fields using '()' also works normally, thus
%       a=obj.Map.Data.Adc(1:10)
% returns the first 10 elements of data (in the native format without
% scaling or offseting).
%
% obj without subscription passes the object
% obj at the command prompt displays a summary of the contents of obj
%
% USING FUNC
% FUNC may be a handle to a simple function to transform the data (e.g.
% @abs). This function will be called whenever adcarrays return data via
% subsref. The untransformed output from subsref is automatically passed as
% the first input argument. If func is a cell array, FUNC{2:end} will be
% passed as additonal arguments to FUNC.
% e.g. FUNC={@detrend, 'linear') will invoke detrend(data, 'linear') so
%           x=obj(1:1000)
% will return
%        x=detrend(double(x.Map.Data.Adc(1:1000)*x.Scale+obj.DC,'linear')
%
% WRITING TO ADCARRAY PROPERTIES:
% Fields can be changed using '.' or SET e.g. obj.Func=@abs or
% set(obj,'Scale',10). The adcarray data field is intended to be primarily
% read only but write access to the obj.Map.Data.Adc property
% is available if the obj.Map.Writable function is 'true'( Note that you will
% need to apply the inverse of func (where appropriate), remove the offset
% and scale the data (by 1.0/obj.Scale) then cast to the appropriate class
% explicitly).
%
% Direct assignment to an adcarray as though if were a double precision
% array overwrites the adcarray with a double precision array - and
% therefore is generally pointless
% obj(1:10)=1
% where obj is an adcarray is equivalent to
% obj=obj() %Convert to double via SUBSREF (scaled,offset and transformed)
% obj(1:10)=1 % set elements 1:10 in the double array to 1
% This behaviour can be useful when passing adcarrays to standard MATLAB
% functions (see ADCARRAY/SUBSASGN for further details)
% HORZCAT and VERTCAT also give double precision results with adcarrays
%
% See also MEMMAPFILE, ADCARRAY/SUBSREF, ADCARRAY/SUBSASGN, ADCARRAY/GET,
% ADCARRAY/SET, ADCARRAY/HORZCAT, ADCARRAY/VERTCAT, ADCARRAY/DISPLAY,
% ADCARRAY/END, ADCARRAY/SIZE
%
% Author: Malcolm Lidierth
% Copyright © 2006 King’s College London
%
% Revisions: 01.10.06 Bytes swapping added
%            05.12.06 Coding tidied
%            05.11.07 Force char cast on Units when empty
%            19.03.08 Support structure input
%            03.01.10    Add default constructor

if nargin==0
    %default values
    obj.Map=[];
    obj.Scale=[];
    obj.DC=0;
    obj.Func=[];
    obj.Units=[];
    obj.Labels=[];
    obj.Swapbytes=[];
else
    % Structure as input
    if isstruct(varargin{1})
        s=varargin{1};
        if isa(s.Map, 'memmapfile')
            temp=s.Map;
        else
            temp=s.Map.Data.Adc;
        end
        if isstruct(temp)
            % Prevent infinite loop
            error('Map.Data.Adc field may not contain a structure');
        else
            % Recursive call
            obj=adcarray(temp,...
                s.Scale,...
                s.DC,...
                s.Func,...
                s.Units,...
                s.Labels,...
                s.Swapbytes);
            return
        end
    end
    
    %default values
    obj.Map.Data.Adc=NaN;
    obj.Map.Repeat=1;
    obj.Scale=1;
    obj.DC=0;
    obj.Func=[];
    obj.Units='';% 05.11.07
    obj.Labels={};
    obj.Swapbytes=false;
    
    
    if nargin>=1
        if isa(varargin{1},'memmapfile')
            % memmapfile on input
            obj.Map=varargin{1};
        else
            % MATLAB matrix on input
            obj.Map.Filename='';
            obj.Map.Writable=true;
            obj.Map.Offset=0;
            obj.Map.Format={class(varargin{1}) size(varargin{1}) 'Adc'};
            obj.Map.Repeat=1;
            obj.Map.Data.Adc=varargin{1};
        end
    end
    
    if nargin>= 2
        obj.Scale=varargin{2};
    end
    
    if nargin>=3
        obj.DC=varargin{3};
    end
    
    if nargin>=4
        obj.Func=varargin{4};
    end
    
    if nargin>=5
        obj.Units=varargin{5};
    end
    
    if nargin>=6
        if ~iscell(varargin{6})
            obj.Labels={varargin{6}};
        else
            obj.Labels=varargin{6};
        end
    end
    
    if nargin>=7
        obj.Swapbytes=logical(varargin{7});
    end
    
    
    % % if input was not a memmapfile object, add fields to the
    % % map struct (N.B. obj.Map.Data.Adc already assigned)
    % if isstruct(obj.Map)
    %     obj.Map.Filename='';
    %     obj.Map.Writable=false;
    %     obj.Map.Offset=0;
    %     obj.Map.Format={};
    %     obj.Map.Repeat=1;
    % end
    
    % check that repeat is 1.
    if obj.Map.Repeat~=1
        error('adcarray.adcarray: the repeat property of the memmapfile object must to set to 1');
    end
    
    if isempty(obj.Labels)
        k=ndims(obj.Map.Data.Adc);
        if k==2 && (size(obj.Map.Data.Adc,1)<=1 || size(obj.Map.Data.Adc,2)<=1)%Vector
            obj.Labels{1}='Not Set';
        else %Array - label each
            for i=1:k
                obj.Labels{i}='Not Set';
            end
        end
    end
    
end

obj=class(obj,'adcarray');

return
end

