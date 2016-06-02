function set(obj,varargin)
% SET method overloaded for adcarray objects
%
% Examples:
% A=SET(OBJ) returns a structure
%
% SET(OBJ,'PROP1',VAL1,'PROP2',VAL2....)
% SET(OBJ,<property cell array>,<property value array>)
%   sets the appropriate properties to the supplied values
%
% See also SET, ADCARRAY/SUBSREF, ADCARRAY/GET
%
% Author: Malcolm Lidierth
% Copyright © The Author & King's College London 2006


% make sure the target is an adcarray
% if not pass to builtin
% handles situations like set(gcf,'UserData',adcarrayobj);
if ~isa(obj,'adcarray')
    builtin('set',obj,varargin{:});
    return;
end

error(nargoutchk(0,1,nargout));

% a=set(obj)
% if nargin==1
%     switch nargout
%         case {0,1}
%             varargout{1}=struct(obj);
%         otherwise
%             error('adcarray.set: too many output arguments');
%     end;
%     return;
% end;

% set(obj,'prop1',val1,'prop2',val2...)
% Convert from string input
if ischar(varargin{1})
    val=cell(1,nargin-1);
    for i=1:2:nargin-2
        val{i}=varargin{i};
        val{i+1}=varargin{i+1};
    end;
end;

% set(obj,{propn},{valn})
if iscell(varargin{1})
    if length(varargin{1})==length(varargin{2})
        val=cell(1,length(varargin{1})*2);
    else
        error('adcarray.set: property names and values must have equal length');
    end;
    j=1;
    for i=1:length(varargin{1})
        val{j}=varargin{1,1}{i};
        val{j+1}=varargin{1,2}{i};
        j=j+2;
    end;
end;


for i=1:2:length(val)-1
    switch lower(val{i})
        case 'scale'
            if isnumeric(val{i+1}) && isscalar(val{i+1})
                obj.Scale=val{i+1};
            else
                error('adcarray.set: numeric scalar needed for ''.Scale'' property');
            end;
        case 'dc'
            if isnumeric(val{i+1}) && isscalar(val{i+1})
                obj.DC=val{i+1};
            else
                error('adcarray.set: numeric scalar needed for ''.DC'' property');
            end;
        case 'func'
            if isa(val{i+1},'function_handle')
                obj.Func=val{i+1};
            else
                error('adcarray.set: function handle  required for ''.Func'' property');
            end;
        case 'units'
            if ischar(val{i+1})
                obj.Units=val{i+1};
            else
                error('adcarray.set: string needed for ''.Units'' property');
            end;
        case 'Swapbytes'
            if islogical(val{i+1})
                obj.Swapbytes=val{i+1};
            else
                error('adcarray.set: logical needed for ''.Swapbytes'' property');
            end
        case 'labels'
            if iscell(val{i+1})
                obj.Labels=val{i+1};
            else
                error('adcarray.set: cell array of strings needed for ''.Labels'' property');
            end;
        case 'map'
            if isa(val{i+1},'memmapfile')
                obj.Map=val{i+1};
            else
                error('adcarray.set: memmapfile object required for ''.Map'' property');
            end;
        otherwise
            error('adcarray.set: There is no ''%s'' property in the ''adcarray'' class',val{i});
    end;
end;
if strcmp(inputname(1),'')==1
    error('adcarray.set: adcarray must be input as a variable, not an expression');
end
assignin('caller',inputname(1),obj);







