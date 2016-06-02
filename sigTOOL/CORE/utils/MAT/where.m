function [s, swapbyteorder]=where(filename, varargin)
% WHERE returns byte offsets to the variables in a -v6 MAT-file.
%
% The output from WHERE is similar to that of WHOS but can be used to map
% variables in a a MAT-file and therefore to read/write to them using
% fread/fwrite or memmapfile.
%
% WHERE can be used on Level 5 & 7 MAT-files but only maps those variables
% stored in Level 5 format up to -v6.
% Gzip compressed data saved with SAVE -v7 will be skipped over and not
% mapped.
% Files saved with SAVE -v7.3 (introduced in R2006b) presently
% cause WHERE to terminate.
%
% Examples:
% WHERE(FILENAME),
% WHERE(FILENAME, VARNAME)
% and WHERE(FILENAME, VARNAME, FIELD1/PROP1, FIELD2/PROP2....)
% display the results
%
% S=WHERE(FILENAME)
% S=WHERE(FILENAME, VARNAME, FIELD1/PROP1, FIELD2/PROP2....)
% S=WHERE(FILENAME, VARNAME)
% [S,SWAP]=WHERE(FILENAME)
% [S,SWAP]=WHERE(FILENAME, VARNAME)
% [S,SWAP]=WHERE(FILENAME, VARNAME, FIELD1/PROP1, FIELD2/PROP2....)
%
% SWAP is set to 1 if the endian order of the file is different from that
% of the host computer (0 otherwise).
%
% S=WHERE(FILENAME, TAGOFFSET)
% [S, SWAP]=WHERE(FILENAME, TAGOFFSET)
% return information about the variable at the supplied tag offset. The
% tag offset would normally be derived from a previous call to WHERE.
%
% FILENAME and VARNAME are strings
% If VARNAME is specified, only information relating to that variable will
% be returned. If field/property names are not specified, wildcards ('*')
% can be used as with WHOS.
%
% WHERE produces a structure  output (S) similar to WHOS but with
% additional fields as described below
%
%
% For a standard MATLAB matrix class:
%    S = WHERE(...) returns a structure with the fields:
%         name    -- variable name
%         size    -- variable size
%         bytes   -- number of bytes allocated for the array
%         class   -- class of variable
%         global  -- logical indicating whether variable is global
%         sparse  -- logical indicating whether value is sparse
%         complex -- logical indicating whether value is complex
%         nesting -- struct with the following two fields:
%            function -- name of function where variable is defined
%            level    -- nesting level of the function
%         flags -- 8 bit uint: currently indicates complex, global, logical
%                   and persistent data - see MAT-file documentation
%         TagOffset -- the offset into the file to the Tag for this
%                      variable
%         DataOffset -- a cell containing a structure with a field
%                       '.DiscOffset' which specifies the offset into the
%                       file for the data area of this variable.
%                       For complex data,DiscOffset is a 1x2 vector with
%                       offsets to both real and  imaginary parts. For a
%                       structure or object, DataOffset is a cell array
%                       with one element for each field/property. Each
%                       element will contain a set of ields describing
%                       each field/property variable name, size, bytes etc
%                       as for a standard matrix (including a DataOffset
%                       field).
%         DiscClass -- a cell containing the storage format for the variable
%                       on disc - which may be different from class -
%                       as a string or 1x2 cell array of strings for
%                       complex data with the DiscClass for both real and
%                       imaginary parts
%
% Flags, TagOffset, DataOffset and DiscFormat are supplied by WHERE. The
% remaining fields are derived from a call to WHOS by WHERE (and will vary
% according to the version of WHOS being used).
%
% For structures and objects
% If the variable is a structure or object, DataOffset will be a cell array
% of structures describing each field or property of the variable as above.
%
% With a double precision float variable var=1:10 saved
% to file myfile.mat with the MATLAB 'SAVE MYFILE VAR -V6' command
%
% WHERE('myfile','var') then produces:
%
% ----------------------------------------------------------------------
% 	Name 	Size    Bytes       Class   	TagOffset   DataOffset
% ----------------------------------------------------------------------
% 	var     1x10      80    uint8=>double		128         184
%
% Note that to save disc space, MATLAB stores var as uint8 and it needs to
% be cast to double (hence uint8=>double i.e. DiscClass=>Class).
%
% If var is a structure the output might look as follows:
%
% -------------------------------------------------------------------------
% 	Name    	Size    Bytes           Class       TagOffset DataOffset
% -------------------------------------------------------------------------
% 	var          1x1    1068       struct=>struct       128
% 	.field1      1x1   	48          uint8=>double		224   276
% 	.field2      1x6   	64           uint16=>char		280   336
% 	.field3      1x10  	64          uint8=>double		352   408
% 	.field4      1x1   	280        struct=>struct		424   NaN
%
% A TagOffset is returned for the structure, and for each field. Names,
% DataOffsets and formats are supplied for each field. However, structures
% within structures (as for field4) are not analyzed further and
% DataOffsets are returned as NaN. To analyze these fields further use the
% WHERE(FILENAME,VARNAME, FIELD1/PROP1, FIELD2/PROP2....) form e.g for a
% structure S containing a structure A containing a structure B containing
% a matrix C use where(filename,'S','A','B','C'). This form recursively calls
% WHERE(FILENAME, TAGOFFSET) to dig through the nest.
%
% Details for objects are returned as above for structures.
%
% If 'unknown' appears in a class field it indicates that the variable has
% not been fully analyzed by WHERE. In this case, DiscOffset will be NaN.
% This will be the case for custom variables, functions, structure arrays,
% cells and sparse arrays (TagOffsets will be returned for these if they are
% fields/properties of a structure/object).With compressed data
% (v7) all offsets will be NaNs.
%
% Example: using with memmapfile to map a standard matlab matrix:
% s=where('myfile.mat','A');
% map=memmapfile('myfile.mat','Format',{s.class s.size 'mydata'},...
%       'Repeat',1,'Offset',s.DataOffset{1}.DiscOffset);
%
%
% See also WHOS, memmmapfile, fread
%
% Revisions: 16.09.06 WHERET functionality incorporated into WHERE
%                     Coding generally tidied - global variables removed.
%                     WHERET obsolete and deleted.
%            21.09.06 Now works with big-endian files on Windows
%            03.11.06 Now platform independent - Works on both big-endian
%                       and little-endian platforms with both big-endian 
%                       and little-endian MAT-files. Tested on Windows XP
%                       and Mac OS X (4.4.8 on a PowerMac G4).
%            04.11.06 Size now consistently returned as row vector (column
%                       vector returned for fields/props previously)
%            08.11.06 Matrix size now prints correctly. 
%            16.11.06 The output .bytes field now consistently contains the
%                     number of bytes for a matrix when loaded. For a
%                     structure/object  .bytes contains the size on disc.
%                     (This is consistent with the builtin WHOS)
%                     A .DiscBytes field has been introduced. This is the
%                     size of the variable on disc (for all data types)i.e.
%                     the size of the header + data.
%           28.11.06  DataOffset changed to include a DataOffset subfield
%                     for each field/property - previously the DiscOffset
%                     was placed directly in DataOffset. The new
%                     arrangment allows elements of DataOffset to be used
%                     in the same way as those from standard variables,
%                     e.g. s=where(filename, structname);
%                           ws=s(1).DataOffset{5};
%                     will return ws with a ws.DataOffset field of its own.
%          28.11.06   .size now contains trailing singleton dimensions. This
%                     is unlike whos, but is needed after using
%                     AddDimension with the AppendXXXX functions
%          29.11.06  Sort output fields alphabetically
%          26.06.07-26.08.07 Further formating improvements
%          21.01.10   R2010a compatible               
%
%__________________________________________________________________________
%
% This program is distributed without any warranty,
% without even the implied warranty of fitness for a particular purpose.
%__________________________________________________________________________
%
% Author: Malcolm Lidierth Updated 11/06
% Copyright © The Author & King's College London 2006
%__________________________________________________________________________
%


% Matlab standard codes for data formats
mi=StandardMiCodes();
mx=StandardMxCodes();

% CHECK MATLAB VERSION

if scverLessThan('MATLAB','7')
    error('WHERE: MATLAB Version 7 or higher required');
end


% DEFAULT RETURN VALUES
s=struct([]);
swapbyteorder=[];

% CHECK ARGUMENTS
if nargin<1
    disp('WHERE: filename must be specified');
    return
end

if nargin>2
    for argn=1:nargin-1
        if ~isempty(strfind(varargin{argn},'*'))
            disp('WHERE: wildcards not permitted with field/property search');
            return
        end
    end
end

% Append default .mat extension if none supplied
[pathstr, name, ext] = fileparts(filename);
if isempty(ext)
    filename=[pathstr name '.mat'];
end

% BEGINNING OF MAIN FUNCTION
% Called as where(filename,TagOffset)
if nargin==2 && isnumeric(varargin{1})
    [fh, swapbyteorder]=MATOpen(filename,'r');
    if fh<0
        return
    end
    fseek(fh,double(varargin{1}),'bof');
    s(1).name='';
    NumberOfVar=1;
else
    %Otherwise
    try
        s=whos('-file',filename);
    catch %#ok<CTCH>
        m=lasterror; %#ok<LERR>
        lasterror('reset'); %#ok<LERR>
        disp(sprintf('WHERE: %s',m.message));
        s=struct([]);
        return
    end
    NumberOfVar=length(s);
     if nargin>=2
        s=whos('-file',filename, varargin{1});
     end
    [fh, swapbyteorder]=MATOpen(filename,'r');
    if fh<0
        return
    end
    fseek(fh,128,'bof');
end

[f1, p1, fileformat]= fopen(fh);

%>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
%MAIN ROUTINE

% Default return values
for variable=1:length(s)
    s(variable).flags=uint8(0);
    s(variable).TagOffset=NaN;
    %Restore 24.6.07
    %s(variable).DataOffset{1}.DiscOffset=[NaN NaN];
    s(variable).DiscClass={'unknown' 'unknown'}; 
end

% LOOP FOR EACH VARIABLE
for variable=1:NumberOfVar

    [Name TOffset nbytes VClass flags vbytes dim DiscClass DiscOffset]...
        =GetVariableHeader(fh);

    % If where(filename, tagoffset) call type, s(1).name will be empty
    if strcmp(Name,'0123456789') && ~isempty(s(1).name)
        continue
    end

    if nargin==2 && isnumeric(varargin{1})
        % Called as where(filename,TagOffset)
        ThisVar=1;
        s(1).name=Name;
        s(1).size=dim;
        s(1).class=VClass;
        s(1).bytes=vbytes;
        s(1).DiscBytes=nbytes;
        s(1).global=bitget(flags,3);
        s(1).complex=bitget(flags,4);
        s(1).flags=uint8(flags);
        s(1).TagOffset=TOffset;
        % Restore 24.6.07
        s(1).DataOffset{1}.DiscOffset=DiscOffset;
        s(1).DiscClass=DiscClass;
    else
        % Otherwise
        ThisVar=0;
        for ivar=1:length(s)
            if strcmp(Name,s(ivar).name)
                ThisVar=ivar;
                break;
            end
        end
    end

    % This variable not in required list
    if ThisVar==0
        fseek(fh,double(TOffset+nbytes+8),'bof');
        continue
    end

    % Return values if a standard MATLAB matrix
    % (Other fields come from prior call to WHOS)
    s(ThisVar).size=dim;
    s(ThisVar).flags=uint8(flags);
    s(ThisVar).TagOffset=TOffset;
    s(ThisVar).DiscBytes=nbytes;
    s(ThisVar).DataOffset{1}.DiscOffset=DiscOffset;
    s(ThisVar).DiscClass=DiscClass;

    % But, check if we are dealing with a structure
    % If so, s(i).DataOffset becomes a cell array with one
    % element for each field
    if strcmpi(VClass,'struct') || strcmpi(VClass,'object')
        % object
        if strcmpi(VClass,'object')
            ObjectType=fread(fh,1,'uint32=>uint32');
            if (ObjectType>2^16)
                fseek(fh,-4,'cof');
                [ObjectBytes, ObjectType, values]=...
                    GetSmallDataElement(fh, fileformat);
                % ObjectType=mi{ObjectType};
            else
                ObjectType=mi{ObjectType};
                ObjectBytes=fread(fh,1,'uint32');
                temp=fread(fh,ObjectBytes,ObjectType);
                ByteAlign(fh);
            end
        end

        % object or structure
        [a b FieldNameLength]=GetSmallDataElement(fh, fileformat);
        FieldNameType=fread(fh,1,'uint32');
        FieldNameType=mi{FieldNameType};
        FieldNameArraySize=fread(fh,1,'uint32');
        for f=1:FieldNameArraySize/FieldNameLength
            s(ThisVar).DataOffset{f}.name=...
                deblank(fread(fh,double(FieldNameLength),...
                [FieldNameType '=>char'])');
        end
        ByteAlign(fh);

        for f=1:FieldNameArraySize/FieldNameLength
            [name os n cl flags bytes dim DiscClass DiscOffset]...
                =GetVariableHeader(fh);
            s(ThisVar).DataOffset{f}.size=dim;
            s(ThisVar).DataOffset{f}.class=cl;
            s(ThisVar).DataOffset{f}.bytes=bytes;
            if strcmp(cl,'struct') ||...
                    strcmp(cl,'object') ||...
                    strcmp(cl,'cell') ||...
                    strcmp(cl,'unknown')
                s(ThisVar).DataOffset{f}.DiscBytes=n;
            else
                s(ThisVar).DataOffset{f}.DiscBytes=prod(dim)*sizeof(cl);
            end
            s(ThisVar).DataOffset{f}.global=bitget(flags,3);
            s(ThisVar).DataOffset{f}.complex=bitget(flags,4);
            s(ThisVar).DataOffset{f}.flags=uint8(flags);
            s(ThisVar).DataOffset{f}.TagOffset=os;
            s(ThisVar).DataOffset{f}.DataOffset{1}.DiscOffset=DiscOffset;
            s(ThisVar).DataOffset{f}.DiscClass=DiscClass;
            fseek(fh,double(os+n+8),'bof');
        end

    end
    %Next variable on disc
    fseek(fh,double(TOffset+nbytes+8),'bof');

end

% Failed to find field or property
if isempty(s)
    disp(sprintf('WHERE: the variable "%s" was not found',varargin{1}));
    s=[];
    return;
end

% Digging through nested fields/properties
if nargin>=3
    for argn=2:length(varargin)
        found=false;
        for indexn=1:length(s(1).DataOffset)
            if strcmp(s(1).DataOffset{indexn}.name,varargin{argn})==1
                %Re-entrant call to where
                s=where(filename, s(1).DataOffset{indexn}.TagOffset);
                found=true;
                break;
            end
        end
        if found==false
            s=[];
            mess='';
            for w=1:argn
                mess=horzcat(mess,[varargin{w} '.']);
            end
            mess=mess(1:end-1);
            disp(sprintf('WHERE: The field or property %s was not found',mess));
            return;
        end
    end
end

% Form the name if WHERE was called with field/property list
if nargin>2
    for narg=2:nargin-1
        s(1).name=[s(1).name varargin{narg-1} '.'];
    end
    s(1).name=[s(1).name varargin{end}];
end

% Sort fields alphabetically (note: capitals first)
s=orderfields(s);
for i=1:length(s)
    if isfield(s(i),'DataOffset')
        for j=1:length(s(i).DataOffset)
            s(i).DataOffset{j}=orderfields(s(i).DataOffset{j});
        end
    end
end


% If no output arguments, display the results
if nargout==0
    DisplayOutput(s);
end

fclose(fh);

%<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function [N_name, TagOffset, NumberOfBytes, AF_class, AF_flags,...
            BytesOfData, DA_dim, DiscClass, DiscOffset]=GetVariableHeader(fh)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        N_name='0123456789';%invalid variable name
        DiscClass{1}='unknown';
        AF_class='compressed';
        AF_flags=uint8(0);
        DiscOffset=NaN;
        BytesOfData=NaN;
        DA_NumberOfBytes=NaN; %#ok<NASGU>
        DA_dim=[NaN NaN];

        %Read the Tag
        TagOffset=ftell(fh);
        DataType=fread(fh,1,'uint32=>uint32');
        DataType=mi{DataType};
        NumberOfBytes=fread(fh,1,'uint32');
        if strcmpi(DataType,'compressed')
            fseek(fh,TagOffset+NumberOfBytes+8,'bof');
            return
        end

        %Array Flags
        fread(fh,1,'uint32=>uint32');
        fread(fh,1,'uint32=>uint32');

        temp=fread(fh,4,'uint8=>uint8');
        if strcmp(fileformat,'ieee-le')
            AF_flags=temp(2);
            AF_class=mx{temp(1)};
        else
            AF_flags=temp(3);
            AF_class=mx{temp(4)};
        end


        % Check this is a mappable class - if not return & skip to next entry
        if strcmpi(AF_class,'custom') ||...
                strcmpi(AF_class,'cell') ||...
                strcmpi(AF_class,'function') ||...
                strcmpi(AF_class,'sparse')
            fseek(fh,TagOffset+NumberOfBytes+8,'bof');
            ByteAlign(fh);
            return
        end


        fseek(fh,4,'cof');

        %Dimensions array
        temp=fread(fh,1,'uint32=>uint32');
        DA_DataType=mi{temp};
        DA_NumberOfBytes=fread(fh,1,'uint32');
        n=DA_NumberOfBytes/sizeof(DA_DataType);
        
        DA_dim=fread(fh,n,DA_DataType)';%transpose added 03.11.06

        if strcmpi(AF_class,'struct') && max(DA_dim)>1
            fseek(fh,TagOffset+NumberOfBytes+8,'bof');
            ByteAlign(fh);
            return
        end
        ByteAlign(fh);

        %Name Array
        N_DataType=fread(fh,1,'uint32');
        if (N_DataType>2^16)
            fseek(fh,-4,'cof');
            [N_NumberOfBytes, N_DataType, values]=...
                GetSmallDataElement(fh, fileformat);
            N_name=char(values);
        else
            N_DataType=mi{N_DataType};
            N_NumberOfBytes=fread(fh,1,'uint32');
            n=N_NumberOfBytes/sizeof(N_DataType);
            N_name=fread(fh,n,[N_DataType '=>char'])';
        end
        N_name=deblank(N_name);
        ByteAlign(fh);

        switch AF_class
            case 'struct'
                DiscClass{1}='struct';
                DiscOffset=NaN;
                BytesOfData=NumberOfBytes;
            case 'object'
                DiscClass{1}='object';
                DiscOffset=NaN;
                BytesOfData=NumberOfBytes;
            case 'unknown'
                fseek(fh,TagOffset+NumberOfBytes+8,'bof');
            otherwise
                temp=fread(fh,1,'uint32');
                if (temp>2^16)
                    fseek(fh,-4,'cof');
                    [BytesOfData, temp, values]=...
                        GetSmallDataElement(fh, fileformat);
                    DiscOffset=ftell(fh)-4;
                    %BytesOfData=BytesOfData*sizeof(AF_class);
                else
                    BytesOfData=fread(fh,1,'uint32');
                    DiscOffset=ftell(fh);
                end
                DiscClass{1}=mi{temp};
                if bitget(AF_flags,4)% complex data
                    fseek(fh,DiscOffset+BytesOfData,'bof');
                    ByteAlign(fh);
                    temp=fread(fh,1,'uint32');
                    BytesOfData(2)=NaN;
                    if (temp>2^16)
                        fseek(fh,-4,'cof');
                        [BytesOfData(2), temp, values]=...
                            GetSmallDataElement(fh, fileformat);
                        DiscOffset(2)=ftell(fh)-4;
                    else
                        fread(fh,1,'uint32');
                        DiscOffset(2)=ftell(fh);
                    end
                    DiscClass{2}=mi{temp};
                end
        end
    end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function DisplayOutput(s)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DisplayOutput is called when there are no output argument
%General header
fprintf('\n-------------------------------------------------------------------------------------------------\n');
fprintf('\t%-8s\t',...
    'Name',...
    'Size',...
    'Bytes',...
    'Class',...
    'TagOffset',...
    'DataOffset');
fprintf('\n');
fprintf('---------------------------------------------------------------------------------------------------\n');

%Loop for each variable

for i=1:length(s)

    if bitget(s(i).flags,4)==1
        c='(real)';
    else
        c='';
    end
    fprintf('\n\t%-12s\t',s(i).name);
    n=length(s(i).size);
    if n==0
        fprintf('Wrong format\n');
        continue
    end
    for j=1:n-1
        fprintf('%dx',s(i).size(j));
    end
    fprintf('%d\t',s(i).size(n));
    fprintf('%10d\t%15s',...
        s(i).bytes,[s(i).DiscClass{1} '=>' s(i).class c])
    fprintf('\t\t%-12d',s(i).TagOffset);

    % Structure/object or simple matrix
    % add isfield(s{i},'DataOffset') 24.06.07
    % modify 26.07.08
    if isfield(s,'DataOffset')
        if isfield(s(i).DataOffset{1},'name')
            fprintf('\n');
            for k=1:length(s(i).DataOffset)
                if s(i).DataOffset{k}.complex==1
                    c='(real)';
                else
                    c='';
                end
                fprintf('\t.%-12s\t',s(i).DataOffset{k}.name);
                n=length(s(i).DataOffset{k}.size);
                for j=1:n-1
                    fprintf('%8dx',s(i).DataOffset{k}.size(j));
                end
                fprintf('%-8d\t',s(i).DataOffset{k}.size(n));
                fprintf('%-10d%15s',s(i).DataOffset{k}.bytes,...
                    [s(i).DataOffset{k}.DiscClass{1} '=>' s(i).DataOffset{k}.class c]);
                fprintf('\t\t%-12d',s(i).DataOffset{k}.TagOffset);
                fprintf('\t%-12d \n',s(i).DataOffset{k}.DataOffset{1}.DiscOffset);
                %Second line for imaginary part if complex
                if bitget(s(i).DataOffset{k}.flags,4)==1
                    fprintf('%70s',...
                        [s(i).DataOffset{k}.DiscClass{2} '=>' s(i).DataOffset{k}.class '(imag)']);
                    fprintf('\t%20d \n',s(i).DataOffset{k}.DiscOffset(2));
                end
            end
        else
            %Simple matrix
            fprintf('\t%-12d \n',s(i).DataOffset{1}.DiscOffset(1));
        end
    else
        fprintf('\n');
    end

    %Second line for imaginary part if complex
    if s(i).complex==1
        fprintf('%70s',...
            [s(i).DiscClass{2} '=>' s(i).class '(imag)']);
        fprintf('\t%20d \n',s(i).DataOffset{1}.DiscOffset(2));
    end
end
end



