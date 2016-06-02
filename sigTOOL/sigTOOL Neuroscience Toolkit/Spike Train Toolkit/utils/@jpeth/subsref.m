function out=subsref(obj, index)
% subsasgn method for jpeth class
% 
% Example:
% out=subsref(obj, index, val)
% 
% Standard method
%
%
% See also jpeth
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 02/09
% Copyright © The Author & King's College London 2009-
% -------------------------------------------------------------------------



switch index(1).type
    case '.'
        try
            if length(index)==1
                out=obj.(index(1).subs);
            else
                out=subsref(obj.(index(1).subs), index(2:end));
            end
        catch %#ok<CTCH>
            error('No such property in jpeth class: ''%s''', index(1).subs);
        end
    case '()'
        out=obj;
    otherwise
        error('Access method not supported');
end

return
end