function str=getTimeUnits(channel)
% getTimeUnits returns the units used to represent time in the tim field
% of an scchannel object as a string
%
% Example:
% str=getTimeUnits(channel)
% 
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 03/08
% Copyright © The Author & King's College London 2008-
% -------------------------------------------------------------------------

units=channel.tim.Units;

switch units
    case 1
        str='seconds';
    case 1e-3
        str='milliseconds';
    case 1e-6
        str='microseconds';
    case 1e-9
        str='nanoseconds';
    case 1e-12
        str='picoseconds';
    case 60
        str='minutes';
    case 60*60
        str='hours';
    case 60*60*24
        str='days';
    otherwise
        str=['1 unit=' num2str(units) 'seconds'];
end

return
end
        
        