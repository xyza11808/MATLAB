function print(obj, varargin)
% print method for sigTOOLResultView objects
% Example:
% print(obj, option1, option2 ......)
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 02/09
% Copyright © The Author & King's College London 2009-
% -------------------------------------------------------------------------

% Print can mess up hgjavacomponent objects so manage them through
% printprepare and postprinttidy

[fhandle, AxesPanel, annot, pos, displaymode]=printprepare(obj);
print(fhandle, varargin{:});
postprinttidy(obj, AxesPanel, annot, pos, displaymode);
return
end




