function bytes=sizeof(class)
% SIZEOF returns the size in bytes of the class
% Example:
% BYTES=SIZEOF('CLASSNAME')
%
% Author: Malcolm Lidierth 07/06
% Copyright © The Author & King’s College London 2006-2007
%
% Revisions:
%           05.12.07  'custom' class input added


if strcmp(class, 'custom')
    % added 05.12.07
    bytes=NaN;
    return
end

a=cast(0,class);
w=whos('a');
bytes=w.bytes;
end