function filesaveas(obj)
% FileSaveAs method for sigTOOLDataView objects
%
% Example:
% filesaveas(obj)
%
% Used to generate graphics output
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 12/07
% Copyright © The Author & King's College London 2007-2008
% -------------------------------------------------------------------------
%
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




