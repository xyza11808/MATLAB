function varargout=RecordHistory(func, arglist, WriteOnly)
% RecordHistory creates a history log while executing menu commands
%
% Examples:
% RecordHistory(func, arglist, WriteOnly)
%
% where
% func                is the handle to the function to call
% arglist             is a cell array of arguments to func.
%                             arglist{1} should be the sigTOOL data view
%                               figure handle
%                             arglist(2:end} are arguments to func and
%                               may be argument name string/value pairs
%                         Arguments should normally resolve to a numeric or
%                         logical value or to a string. Vectors,
%                         matrices and cell arrays are valid.
%                         If the arguments are not numeric, logical
%                         or char types, they must either:
%                         [1] be resolved to an object by calling a function
%                         listed in the last element of the 'functions' field
%                         of the history record
%                         or
%                         [2] be a function handle. In this case the
%                         function must be in scope from within the output
%                         m-file i.e. it must be a function that is
%                         accessible on the MATLAB path
%                         [3] be a structure, each field of which resolves
%                         within the limitations cited above.
% WriteOnly           if true, causes output to be written to the history
%                         record without executing func        
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 08/07
% Copyright © The Author & King's College London 2007-
%
% This is a modified version of the scExecute function developed for the
% sigTOOL signal analysis package:
% http://www.mathworks.com/matlabcentral/fileexchange/loadFile.do?objectId=
% 20575&objectType=FILE
% -------------------------------------------------------------------------

%-------------------------------------------------------------------------
% Write the command to the history if we are recording
RecordFlag=getappdata(arglist{1},'RecordFlag');

if RecordFlag
    h=getappdata(arglist{1},'History');
    % Function name
    if ischar(func)
        % String input
        str=sprintf('%s(thisview, ',func);
    else
        % Function handle
        str=sprintf('%s(thisview, ',func2str(func));
    end

    if length(arglist)>1
        % Argument list
        PairedArgs=true;
        for i=2:2:length(arglist)
            if ~ischar(arglist{i})
                PairedArgs=false;
                break;
            end
        end
        switch PairedArgs
            case true
                % Arguments (except for the first) are in paired
                % description/value pairs
                % e.g. MyFunction(fhandle, 'Position', [0 0 1 1], 'Start', 0)
                for i=2:2:length(arglist)-3;
                    str=ProcessArg(str, arglist, i, h);
                    str=[str sprintf(',...\n\t')]; %#ok<AGROW>
                end
                % Final argument
                str=ProcessArg(str, arglist, length(arglist)-1, h);
                str=[str sprintf(');\n\n')];
            case false
                % Resolve all inputs as values - no parameter
                % description/value pairs
                % e.g. MyFunction(fhandle, a, 2, c{1}, 'off')
                for i=2:length(arglist)-1
                    str=ProcessArg2(str, arglist, i, h);
                    str=[str sprintf(', ')]; %#ok<AGROW>
                end
                str=ProcessArg2(str, arglist, length(arglist), h);
                str=[str sprintf(');\n\n')];
        end
        % Add the new string to the history field in the application data area
        % of the parent figure. Reload history as called functions may have
        % updated it.
        h2=getappdata(arglist{1}, 'History');
        h2.main=[h.main str];
        setappdata(arglist{1}, 'History', h2);
    end
end


if nargin>=3 && WriteOnly==true
    %---------------------------------------------------------
    % WriteOnly call, do not execute the function
    %---------------------------------------------------------
    return
else
    %---------------------------------------------------------
    % Call the required function
    %---------------------------------------------------------
    if nargin==2
        if nargout>0
            varargout=func(arglist{:});
        else
            func(arglist{:});
        end
    end
end

return
end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% These functions compile text output for the history information that is
% collected in the application data area prior to being saved as an m-file
% function

function str=ProcessArg(str, arglist, i, h)
% Paired arguments - deal with the property description
str=[str sprintf('''%s'', ', arglist{i})]; %#ok<AGROW>
% Then the value
str=ProcessArg2(str, arglist, i+1, h);
return
end


function str=ProcessArg2(str, arglist, k, h)
% Value arguments
if isnumeric(arglist{k}) || islogical(arglist{k})
    % Numeric or logical - resolve as constant
    if length(arglist{k})>1
        if isvector(arglist{k})
            % Vector
            if size(arglist{k},1)>1
                % Convert to row vector
                arg=arglist{k}';
            else
                % Already row vector
                arg=arglist{k};
            end
            str=[str sprintf('[%s]', num2str(arg))]; %#ok<AGROW,ST2NM>
        else
            % Matrix
            str=[str sprintf('[%s;...\n', num2str(arglist{k}(1,:)))];
            if size(arglist{k},1)>2
                for m=2:size(arglist{k},1)-1
                    str=[str sprintf('\t\t%s;...\n', num2str(arglist{k}(m,:)))]; %#ok<AGROW>
                end
            end
            str=[str sprintf('\t\t%s]', num2str(arglist{k}(end,:)))];
        end
    else
        % Scalar
        str=[str sprintf('%s', num2str(arglist{k}))]; %#ok<AGROW,ST2NM>
    end
elseif ischar(arglist{k})
    % String - copy as argument
    str=[str sprintf('''%s''', arglist{k})]; %#ok<AGROW>
elseif iscell(arglist{k})
    % Cell array
    if isnumeric(arglist{k}{1})
        % Numeric contents
        str=[str '{' num2str(cell2mat(arglist{k})) '}'];
    elseif ischar(arglist{k}{1})
        str=[str arglist{k}{:}];
    else
        % Non-numeric, not supported
        str=[str 'UNRESOLVEDCELL'];
    end
elseif isa(arglist{k}, 'function_handle')
    % Function handles - these must be in scope when the history m-file is
    % executed i.e. they must resolve to a function on the search path
    if nargin(arglist{k})<0
        % Function handle
        str=[str sprintf('@%s', char(arglist{k}))]; %#ok<AGROW>
    else
        % Anonymous function
        str=[str sprintf('%s', char(arglist{k}))];
    end
elseif isstruct(arglist{k})
    % Structure
    [str, h]=CreateStructure(str, h, arglist{k});
    setappdata(arglist{1}, 'History', h);
else
    % Unresolved object. Do we have any functions in the history record?
    if isfield(h, 'functions') && numel(h.functions)>0
        % Yes - proceed on the assumption that the final entry is the one we
        % presently want
        str=sprintf('NEWVAR%d=function%d();\n%s NEWVAR%d', length(h.functions),...
            length(h.functions), str, length(h.functions));
    else
        % No - flag as UNRESOLVED in the m-file
        str=[str 'UNRESOLVED'];
    end
end
return
end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
function [str, h]=CreateStructure(str, h, s)
%--------------------------------------------------------------------------
n=length(h.functions)+1;
str=sprintf('STRUCT%d=function%d();\n%s STRUCT%d', n, n, str, n);
fstr=sprintf('function STRUCT%d=function%d()\n', n, n);
names=fieldnames(s);
for i=1:length(names)
    temp=ProcessArg2('', {s.(names{i})}, 1, h);
    fstr=sprintf('%sSTRUCT%d.%s=%s;\n', fstr, n, names{i}, temp);
end
h.functions{end+1}=fstr;
return
end
%--------------------------------------------------------------------------