function bytes=sizeof(class)
% SIZEOF returns the size in bytes of the class
% Example:
% BYTES=SIZEOF('CLASSNAME')
%
% Author: Malcolm Lidierth 07/06
% Copyright © The Author & King’s College London 2006
% Revisions:

a=cast(0,class);
w=whos('a');
bytes=w.bytes;
end