function codes=StandardMiCodes()
% STANDARDMICODES return Matlab standard codes for data formats
% Example:
% CODES=STANDARDMICODES();
%
% Author: Malcolm Lidierth 07/06
% Copyright © King’s College London 2006
% Revisions:

codes={'int8' 'uint8' 'int16' 'uint16' 'int32' 'uint32' 'single'...
    'unknown' 'double' 'unknown' 'unknown' 'int64' 'uint64'...
    'matrix' 'compressed' 'UTF8' 'UTF16' 'UTF32'};
return
end