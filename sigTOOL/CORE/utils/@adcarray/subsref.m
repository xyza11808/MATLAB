function out=subsref(obj, index)
% SUBSREF method overloaded for adcarray objects.
%
% READING ADCARRAY PROPERTIES:
% adcarray objects can be read or passed as though they were simple double
% precision matrices using the '()' subscriptor. Thus,
% obj(), obj(1:10), obj(2,1:5,10:20) etc return double precision
% results after applying the scale and offset to the appropriate elements
% of obj.Map.Data.Adc and transforming them via obj.Func. Data will be byte
% swapped first if necessary i.e.
%       obj(...) is equivalent to:
%       if obj.Swapbytes==true
%           obj=swapbytes(obj.Map.Data.Adc(...));
%       else
%       obj=func(double(obj)*obj.Scale+obj.DC)
%   or
%       obj=Func{1}(double(obj)*obj.Scale+obj.DC, obj.Func{2:end})
%   if func is a cell array (help adcarray for details)
%
% It follows that you can not use '()' syntax to access arrays of
% adcarrays e.g. x(2)=adcarray() is invalid (although you can access cell
% arrays of adcarrays).
%
%-------------------------------------------------------------------------
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
% Examples:
% A=OBJ();
% A=OBJ(1:10);
% A=FUNCTION(OBJ());
%
% Field access with '.'  works as with other objects e.g.
% obj.Map.Data.Adc returns the stored result in its native class.
%
% Subscription of fields using '()' also works normally, thus
%       a=obj.Map.Data.Adc(1:10)
% returns the first 10 elements of data (in the native format without
% scaling etc.).
%
% obj without subscription assigns/passes the object see ADCARRAY/SUBSASGN
% for further details [e.g. A=FILTFILT(OBJ);]
%
% obj at the command prompt displays a summary of the contents of obj
%
% See also ADCARRAY/SUBSASGN, ADCARRAY/GET
%
% Author: Malcolm Lidierth
% Copyright © The Author & King's College London 2006-
%
% Revisions
% 23.12.06 obj(:) exception handling for vectors introduced
% 27.09.07 See within
% 15.30.08 Add byte swapping when accessing the memmapfile data directly
%               as Map.Data.Adc(...)

b=size(index,2);

switch index(1).type

    case '()'
        %----------------------------
        % Handle an exceptional case:
        %----------------------------
        % obj(:) is commonly used in MATLAB functions to ensure that
        % a vector is a column vector, but this would ordinarily destroy
        % an adcarray, returning type double. Introducing the following
        % exception allows obj to be maintained as an adcarray following
        % a call to obj(:).
        %
        % Actions:
        % When called as obj(:), check if obj contains a vector.
        % If it does and it is already a column vector return the adcarray
        % unchanged. If it is a row vector, return as an adcarray containing
        % a column vector instead.
        %
        % If you want to cast to double in such a  case, do so explicitly with
        % double(obj) or use obj();obj(:) in sequence.
        if length(index)==1 &&...
                length(index.subs)==1 &&...
                strcmp(index.subs,':')==1
            [r,c]=size(obj);
            if r==1 || c==1
                % Is it a vector
                if r==1
                    % If it is a row vector
                    if isa(obj.Map,'memmapfile')
                        % Map is a memmapfile object
                        obj.Map.Format{2}=sort(obj.Map.Format{2});
                    else
                        % Map contains a standard MATLAB vector
                        obj.Map.Data.Adc=obj.Map.Data.Adc(:);
                    end
                end
                % Return column vector
                out=obj;
                return
            end
        end
        %---------------------
        % All other cases:
        %---------------------
        % Treat obj as though it were a double array
        % cast to double if necessary

        % 21.09.07 Remove isa for double - takes too long and is not needed
        if isempty(index(1).subs)
            out=obj.Map.Data.Adc;% obj()
        else
            out=obj.Map.Data.Adc(index(1).subs{:});% obj(...)
        end

        % Swap bytes if required
        if obj.Swapbytes==true
            out=swapbytes(out);
        end
        out=double(out);


        % scale if scale factor is non-unity
        if obj.Scale~=1.0
            out=out*obj.Scale;
        end;
        % add offset if non-zero
        if obj.DC~=0.0
            out=out+obj.DC;
        end;
        % apply func
        if isa(obj.Func,'function_handle')
            out=obj.Func(out);
        elseif iscell(obj.Func)
            out=obj.Func{1}(out, obj.Func{2:end});
        end

    case '.'
        % Return fields in native format
        switch lower(index(1).subs)
            case 'scale'
                out=obj.Scale;
            case 'dc'
                out=obj.DC;
            case 'func'
                switch b
                    case 1
                        out=obj.Func;
                    case 2
                        temp1=obj.Func;
                        temp2=(index(2).subs{1});
                        out=temp1(temp2);
                    otherwise
                        error('adcarray.subsref: unexpected number of index entries');
                end;
            case 'units'
                out=obj.Units;
            case 'labels'
                if b==1 %not indexed
                    out=obj.Labels;
                else %indexed
                    cols=size(index(2).subs,2);
                    if cols>1 && index(2).subs{1}~=1 %2-d indexing used - only row 1 valid
                        error('adcarray.subsref: illegal row index into %s.Labels',inputname(1));
                    end;
                    for i=1:length(index(2).subs{cols})
                        out{i}=obj.Labels{index(2).subs{cols}(i)}; %#ok<AGROW>
                    end;
                end;
            case 'map'
                if b==1
                    out=obj.Map;
                else
                    out=subsref(obj.Map, index(2:end)); 
                    % Add byte swapping (15.03.08)
                    if obj.Swapbytes==true && length(index)>=3 && strcmp(index(3).subs, 'Adc')
                        out=swapbytes(out);
                    end
                end
            case 'swapbytes'
                out=obj.Swapbytes;
            otherwise
                error('adcarray.subsref: no %s property in adcarray class',index(1).subs);
        end;

    case '{}'
        error('adcarray.subsref: ''{}'' not supported for adcarrays');
end;
return
end

