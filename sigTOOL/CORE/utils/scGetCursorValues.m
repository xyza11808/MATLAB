function y=scGetCursorValues(varargin)
% scGetCursorValues gets data values based on cursor position in sigTOOL
%
% Example:
% y=scGetCursorValues(CursorNumber)
% y=scGetCursorValues(fhandle, CursorNumber)
%
% fhandle defaults to the current figure if not supplied or empty
%
% Returns y, a cell array of values with one entry per channel
%
% In a sigTOOL data view:
% For waveform channels, the value of the nearest sample at or after the
% cursor us subject to the condition that it falls within one pixel of the
% cursor. Returns [] if there is no point within one pixel.
%
% For edge and pulse channels, the returned y-value will be true or false
% corresponding to a high or low state at the the cursor location. For
% edges, the edge must be within one pixel width to register.
%
% %TODO: In a sigTOOL result view:
%
% See Also  GetCursorLocations
%
%--------------------------------------------------------------------------
% Author: Malcolm Lidierth 01/07
% Copyright © The Author & King's College London 2007
%--------------------------------------------------------------------------

switch nargin
    case 1
        fhandle=gcf;
        CursorNumber=varargin{1};
    case 2
        fhandle=varargin{1};
        CursorNumber=varargin{2};
end

% Get the x-values from the cursor positions
xcursor=GetCursorLocation(fhandle, CursorNumber);
if isempty(xcursor)
    y=[];
    return
end

y=scGetChannelValues(fhandle, xcursor, 'pixel');
end


