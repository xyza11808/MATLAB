function out=subsref(obj, index)
% subsref method for overloaded for the scchannel class
%
% Example:
% obj=subsref(obj, index, val)
%   see the builtin subsref for details
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 12/07
% Copyright © The Author & King's College London 2007-2008
% -------------------------------------------------------------------------

switch index(1).type
    case '.'
        switch lower(index(1).subs)
            case {'adc' 'tim' 'mrk' 'hdr' 'eventfilter' 'sequence'  'channelchangeflag' 'currentsubchannel'}
                if length(index)==1
                    out=obj.(index(1).subs);
                else
                    out=subsref(obj.(index(1).subs), index(2:end));
                end
            otherwise
                error('No such property in scchannel class: ''%s''', index(1).subs);
        end
    case '()'
        out=obj;
    otherwise
        error('Access method not supported');
end

if issparse(out)
    out=full(out);
end

return
end
