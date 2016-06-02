function filesaveas(obj)
% filesaveas method for sigTOOLResultView objects
% Example:
% filesaveas(obj)
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 02/09
% Copyright © The Author & King's College London 2009-
% -------------------------------------------------------------------------

% filesaveas can mess up hgjavacomponent objects so manage them through
% printprepare and postprinttidy

[fhandle, AxesPanel, annot, pos]=printprepare(obj);
or=orient(fhandle);
orient(fhandle, 'landscape');
filemenufcn(fhandle, 'FileSaveAs');
orient(fhandle, or);
postprinttidy(fhandle, AxesPanel, annot, pos);
return
end




