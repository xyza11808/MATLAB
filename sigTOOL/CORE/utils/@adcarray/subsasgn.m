function obj=subsasgn(obj, index, val)
% SUBSASGN method overloaded for adcarray objects.
%
% Examples:
% OBJ.PROP =VAL
% OBJ.PROP1.PROP2 = VAL
% etc. assigns the value B to the specified property of the adcarray object
% See ADCARRAY/ADCARRAY for a list of properties
%
% When a reference to an adcarray occurs to the left of an equals sign
% SUBSASGN converts all the data to double precision, scales it, applies
% the offset, executes obj.Func, does the assignment on the result and then
% returns it, i.e.
%   obj(...) = ...mycode...
% is equivalent to
%   obj=obj(); % Calls adcarray.subsref and returns a double precision array
%   obj(...) = ...mycode... % Assigns values to the double array
% Note that the adcarray object is destroyed in the process. This behaviour
% is useful because it allows adcarrays to be passed as arguments to MATLAB
% functions (though not builtins). If the function attempts to assign a
% value to the object, it will be converted to double (which may cause 
% out-of-memory problems with large data sets). Otherwise it will
% remain an adcarray, with the usual memory saving. 
%
% See also SUBSASGN, ADCARRAY/SUBSREF, ADCARRAY/ADCARRAY, ADCARRAY/SET
%
% Author: Malcolm Lidierth
% Copyright © The Author & King's College London 2006
%
% Correction 21/7/06 - delete isfield(val,'Repeat')

b=size(index,2);
% disp('adcarray.subsasgn');
% for i=1:b
%     index(i)
% end;

switch index(1).type

    case '()'
        % Check we are not trying to make an array of adcarrays
        if strcmp(class(val),'adcarray')
            if index(1).subs{1}==1 %OK if first element - i.e. scalar
                obj=val;
                return;
            else
                error('adcarray.subsasgn: arrays of adcarrays are not supported');
            end;
        end;
        % Treat input as though it were a double array - and return double result
        % Convert to double array via SUBSREF
        obj=subsref(obj,substruct('()',{}));
        % Let the MATLAB builtin subsasgn do the assignment
        % and return the double precision result
        obj=builtin('subsasgn',obj,index,val);


    case '.'
        switch lower(index(1).subs)
            case 'scale'
                obj.Scale=val;
            case 'dc'
                obj.DC=val;
            case 'func'
                obj.Func=val;
            case 'units'
                obj.Units=val;
            case 'swapbytes'
                obj.Swapbytes=logical(val);
            case 'labels'
                % convert to cell if char array input
                if iscell(val)==0
                    val=cellstr(val);
                end;
                if b==1 %not indexed
                    obj.Labels=val;
                else %indexed
                    cols=size(index(2).subs,2);
                    if cols>1 && index(2).subs{1}~=1 %2-d indexing used - only row 1 valid
                        error('adcarray.subsasgn: illegal row index into %s.Labels',inputname(1));
                    end;
                    if length(val)~=length(index(2).subs{cols})
                        error('adcarray.subsasgn: wrong number of strings supplied ');
                    end;
                    for i=1:length(index(2).subs{cols})
                        obj.Labels{index(2).subs{cols}(i)}=val{i};
                    end;
                end;

            case 'map'
                
                % Setting map to empty -added 09.11.07
                if isempty(val)
                    obj.Map=[];
                    return
                end
                if b==1
                    if isa(val,'memmapfile')==1 || (isstruct(val)==1 && isfield(val,'Data')==1 && isfield(val.Data,'Adc'))
                        temp=val;
                    else
                        error('adcarray.subsasgn: memmapfile object or valid structure required on input');
                    end;
                else
                    temp=subsasgn(obj.Map, index(2:end), val);
                end

                if temp.Repeat==1 % Check
                    obj.Map=temp;
                else
                    error('adcarray:subsasgn: Invalid input. ''.Map.Repeat'' must exist and be 1');
                end

            otherwise
                error('adcarray.subsref: no %s property in adcarray class',index(1).subs);
        end;

    case '{}'
        error('adcarray.subsasgn: ''{}'' not supported for adcarrays');
end;


