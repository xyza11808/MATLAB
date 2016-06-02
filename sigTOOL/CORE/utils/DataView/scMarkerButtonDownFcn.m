function scMarkerButtonDownFcn(fin)
% scMarkerButtonDownFcn provides a gateway to user-specified functions
%
% Example:
% scMarkerButtonDownFcn(FIN)
% passes control to the function specified by FIN. FIN must be a string
% (i.e a function name). When scMarkerButtonDownFcn is
% called as a callback, it will examine the application data area for the
% calling object. If this contains a 'Data' field, this will be passed to
% the function specified by FIN as its input. The 'Data' field be a 2
% elemnt vector contaning [channelnumber index] where index is the index
% into the highest dimension of the data on the channel e.g. for a video
% channel on channel 1, to examine frame number 22 'Data' should be [1 22]
%
% scMarkerButtonDownFcn is used as a callback routine for objects
% in the sigTOOL data view and passes control to a user specified function
% (FIN). FIN is specified in the channel{X}.hdr.channeltypeFcn field which
% should be set by the ImportXXXX function for the relevant channel type
% e.g. for image data chan{1}.hdr.channeltypeFcn will be set to
% 'scViewImageData'.
%
% Author: Malcolm Lidierth 09/06
% Copyright © King’s College London 2006
%
% Revisions:
%   26.01.10 Correct help. Function handles not supported


% Code below supports function handles but sigTOOL does not.
% Function handles can not be moved between PCs in kcl files because they
% contain absolute paths

if ~isa(fin,'function_handle') && ~ischar(fin)
    disp('scMarkerButtonDownFcn: Invalid input - string or function handle required');
return
end
    
if isa(fin,'function_handle')
    % Function handle on input
    funchandle=func;
else
    % String on input
    funchandle=str2func(fin);
end

% Get data asscoiated woth the calling object
% ([] if there is none)

% Call the function
funchandle();
end