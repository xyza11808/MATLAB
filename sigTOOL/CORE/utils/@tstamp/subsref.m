function out=subsref(obj, index)
% SUBSREF method overloaded for tstamp objects.
%
% READING TSTAMP PROPERTIES:
% tstamp objects can be read or passed as though they were simple double
% precision matrices using the '()' subscriptor. Thus,
% obj(), obj(:), obj(1:10), obj(2,1:5,10:20) etc return double precision
% results after applying the scale and offset to the appropriate elements
% of obj.Map.Data.Stamps and transforming them via obj.Func i.e.
%       a=obj(...) is equivalent to
%       a=func(double(obj.Map.Data.Stamps(...))*obj.Scale+obj.Shift)
% It follows that you can not use this syntax to access arrays of
% tstamps e.g. x(2)=tstamp() is invalid (although you can access cell
% arrays of tstamps).
%
% Examples:
% A=OBJ();
% A=OBJ(1:10);
% A=FUNCTION(OBJ());
%
% Field access with '.'  works as with other objects e.g.
% obj.Map.Data.Stamps returns the stored result in its native class.
%
% Subscription of fields using '()' also works normally, thus
%       a=obj.Map.Data.Stamps(1:10)
% returns the first 10 elements of data (in the native format without
% scaling etc.).
%
% obj without subscription assigns/passes the object see TSTAMP/SUBSASGN
% for further details [e.g. A=FILTFILT(OBJ);]
%
% obj at the command prompt displays a summary of the contents of obj
%
% See also TSTAMP/SUBSASGN, TSTAMP/GET
%
% Author: Malcolm Lidierth
% Copyright © The Author & King's College London 2006

b=size(index,2);
% disp('tstamp.subsref');
% for i=1:b
%     index(i)
% end;

switch index(1).type
    case '()'
        
        % Treat obj as though it were a double array
        % cast to double if necessary
        if isempty(index(1).subs)
            out=obj.Map.Data.Stamps;% obj()
        else
            out=obj.Map.Data.Stamps(index(1).subs{:});% obj(...)
        end
        % Swap bytes if required
        if obj.Swapbytes==true
            out=swapbytes(out);
        end
        out=double(out);

        % scale if scale factor is non-unity
        if obj.Scale~=1
            out=out*obj.Scale;
        end;
        % add offset if non-zero
        if obj.Shift~=0
            out=out+obj.Shift;
        end;
        if isa(obj.Func,'function_handle')
            out=obj.Func(out);
        end;

    case '.'
        % Return fields in native format
        switch lower(index(1).subs)
            case 'scale'
                out=obj.Scale;
            case 'shift'
                out=obj.Shift;
            case 'func'
                switch b
                    case 1
                        out=obj.Func;
                    case 2
                        temp1=obj.Func;
                        temp2=(index(2).subs{1});
                        out=temp1(temp2);
                    otherwise
                        error('tstamp.subsref: unexpected number of index entries');
                end;
                
            case 'units'
                out=obj.Units;

            case 'map'
                if b==1
                    out=obj.Map;
                else
                    out=builtin('subsref',obj.Map,index(2:end));
                end;
            otherwise
                error('tstamp.subsref: no %s property in tstamp class',index(1).subs);
        end;

    case '{}'
        error('tstamp.subsref: ''{}'' not supported for tstamps');
end;


