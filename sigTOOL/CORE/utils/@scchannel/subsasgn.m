function obj=subsasgn(obj, index, val)
% subsasgn method for overloaded for the scchannel class
%
%
% Example:
% obj=subsasgn(obj, index, val)
%   see the builtin subsasgn for details
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 12/07
% Copyright © The Author & King's College London 2007-2008
% -------------------------------------------------------------------------
switch lower(index(1).subs)
    case 'adc'
        if length(index)==1
            obj.adc=val;
        else
            obj.adc=subsasgn(obj.adc, index(2:end), val);
        end
    case 'tim'
        if length(index)==1
            obj.tim=val;
        else
            obj.tim=subsasgn(obj.tim, index(2:end), val);
        end
    case 'mrk'
        if length(index)==1
            obj.mrk=val;
        else
            obj.mrk=subsasgn(obj.mrk, index(2:end), val);
        end
    case 'hdr'
        if length(index)==1
            obj.hdr=val;
        else
            obj.hdr=subsasgn(obj.hdr, index(2:end), val);
        end
    case 'sequence'
        if length(index)==1
            obj.Sequence=val;
        else
            obj.Sequence=subsasgn(obj.Sequence, index(2:end), val);
        end
    case 'eventfilter'
        if length(index)==1
            obj.EventFilter=val;
        else
            obj.EventFilter=subsasgn(obj.EventFilter, index(2:end), val);
        end
    case 'channelchangeflag'
        if length(index)==1
            obj.channelchangeflag=val;
        else
            obj.channelchangeflag.(index(2).subs)=val;
        end
    case 'currentsubchannel'
        obj.CurrentSubchannel=val;
    otherwise
        error('Invalid property %s', index(1).subs);
end
