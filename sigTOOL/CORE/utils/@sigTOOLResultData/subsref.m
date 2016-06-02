function out=subsref(obj, index)
% subsref method for sigTOOLResultData objects
% 
% Example:
% out=subsref(obj, index)
% 
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 12/07
% Copyright © The Author & King's College London 2007-
% -------------------------------------------------------------------------
switch index(1).type
    case '.'
        if length(index)==1
            try
                out=obj.(index(1).subs);
            catch
                CatchErr();
                obj.(index(1).subs); %#ok<VUNUS>
            end
        else
            try
                out=subsref(obj.(index(1).subs), index(2:end));
            catch
                CatchErr();
                subsref(obj.(index(1).subs), index(2:end));
            end
        end
    case {'()' '{}'}
        error('Non-scalar ''%s'' objects not currently supported', class(obj));
end

return
end

function CatchErr()
% This is needed to cope with invoking functions that have no
% output assigments from obj.plotstyle{1},
err=lasterror();
if strcmp(err.identifier, 'MATLAB:TooManyOutputs') ||...
        strcmp(err.identifier,'MATLAB:unassignedOutputs') ;
    return
else
    error(err);
end
end