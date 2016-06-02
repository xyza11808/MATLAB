function CopyObjects(handle)
% CopyObjects makes the current axes handle the source for subsequent PasteObjects
% calls
% 
% Example
% CopyObjects(handle)
% where handle is the handle of an axes.
% 
% The handle is stored in a persistent variable by PasteObjects

if nargin<1
    return;
elseif strcmpi(get(handle,'Type'),'axes') 
    PasteObjects(handle);
    return
else
    return
end
end
