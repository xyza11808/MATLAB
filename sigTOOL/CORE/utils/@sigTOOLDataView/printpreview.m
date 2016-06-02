function printpreview(obj)
% printpreview method for sigTOOLResultView objects
% Example:
% printpreview(obj)
%

% Print can mess up hgjavacomponent objects so manage them through
% printprepare and postprinttidy

[fhandle, AxesPanel, annot, pos]=printprepare(obj);
h=printpreview(fhandle);
while ishandle(h)
    pause(0.1);
    % Allow queued events
    drawnow();
end
postprinttidy(obj, AxesPanel, annot, pos);
return
end




