function print(obj, varargin)
% print method for sigTOOLResultView objects
% Example:
% print(obj, option1, option2 ......)
%

% Print can mess up hgjavacomponent objects so manage them through
% printprepare and postprinttidy

[fhandle, AxesPanel, annot, pos]=printprepare(obj);
print(fhandle, varargin{:});
postprinttidy(obj, AxesPanel, annot, pos);
return
end




