function obj=subsasgn(obj, index, val)
% SUBSASGN method overloaded for tstamp objects.
%
% Examples:
% OBJ.PROP =VAL
% OBJ.PROP1.PROP2 = VAL
% etc. assigns the value B to the specified property of the tstamp object
% See TSTAMP/TSTAMP for a list of properties
%
% Note:
% Treating obj as a double precision array i.e. using
% OBJ(...)= x
% is not expected to be used in code specifically designed for
% tstamps but works as follows:
%
% SUBSASGN converts all the data to double precision, scales it, applies
% the offset, executes obj.Func, does the assignment on the result and then
% returns it, i.e.
%   obj(...) = ...mycode...
% is equivalent to
%   obj=obj(); % Calls tstamp.subsref and returns a double precision array
%   obj(...) = ...mycode... % Assigns values to the double array
% Note that the tstamp object is destroyed
%
% This behaviour is sometimes useful as it allows tstamp objects to be
% passed as inputs to some MATLAB functions that were not designed to take
% them  e.g.,
%   y=filtfilt(a, b ,obj)
% where obj contains an MxN array executes a line in filtfilt:
%   y = obj;
% that will make a copy of the object (no call to SUBSASGN). Then
%   for i=1:n  % loop over columns
%   y(:,i) = filtfilt(b,a,obj(:,i));
%   end
% calls SUBSASGN which converts y to double precision on its first iteration.
% Throughout, obj remains an tstamp object accessed via SUBSREF so this
% is more memory efficient than
%   y=filtfilt(a, b ,obj())
% where both obj and y are stored throughout as double precision arrays.
%
% See also SUBSASGN, TSTAMP/SUBSREF, TSTAMP/TSTAMP, TSTAMP/SET
%
% Author: Malcolm Lidierth
% Copyright © The Author & King's College London 2006
%
%Correction 21/7/06 - delete isfield(val,'Repeat')

b=size(index,2);
% disp('tstamp.subsasgn');
% for i=1:b
%     index(i)
% end;

switch index(1).type

    case '()'
        % Check we are not trying to make an array of tstamps
        if strcmp(class(val),'tstamp')
            if index(1).subs{1}==1 %OK if first element - i.e. scalar
                obj=val;
                return;
            else
                error('tstamp.subsasgn: arrays of tstamps are not supported');
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
            case 'shift'
                obj.Shift=val;
            case 'func'
                obj.Func=val;
            case 'units'
                obj.Units=val;
            case 'swapbytes'
                obj.Swapbytes=val;
            case 'map'
                if b==1
                    if isempty(val)
                        obj.Map=[];
                        return
                    end
                    if isa(val,'memmapfile')==1 || (isstruct(val)==1 && isfield(val,'Data')==1 && isfield(val.Data,'Shift'))
                        temp=val;
                    else
                        error('tstamp.subsasgn: memmapfile object or valid structure required on input');
                    end;
                else
                    temp=builtin('subsasgn',obj.Map,index(2:end),val);
                end;
                                
                if temp.Repeat==1 % Check
                    obj.Map=temp;
                else
                    error('tstamp:subsasgn: Invalid input. ''.Map.Repeat'' must exist and be 1');
                end;
            otherwise
                error('tstamp.subsref: no %s property in tstamp class',index(1).subs);
        end;

    case '{}'
        error('tstamp.subsasgn: ''{}'' not supported for tstamps');
end;


