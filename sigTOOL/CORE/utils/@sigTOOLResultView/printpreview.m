function printpreview(obj)
% printpreview method for sigTOOLResultView objects
% Example:
% printpreview(obj)
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 02/09
% Copyright © The Author & King's College London 2009-
% -------------------------------------------------------------------------

% Print can mess up hgjavacomponent objects so manage them through
% printprepare and postprinttidy

[fhandle, AxesPanel, annot, pos, displaymode]=printprepare(obj);
h=printpreview(fhandle);
while ishandle(h)
    pause(0.1);
    % Allow queued events
    drawnow();
end
postprinttidy(obj, AxesPanel, annot, pos, displaymode);
return
end




