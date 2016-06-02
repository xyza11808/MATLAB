function obj=sigTOOLResultView(rhandle)
% sigTOOLResultView constructor
% 
% Example:
%     obj=sigTOOLResultView(rhandle)
%     where rhandle is the handle of a figure created via the
%     sigTOOLResultData/plot method
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 02/09
% Copyright © The Author & King's College London 2009-
% -------------------------------------------------------------------------
    
obj.Parent=rhandle;
obj.AxesPanel=findobj(rhandle, 'Tag', 'sigTOOL:ResultAxesPanel');
obj.ResultManager=getappdata(rhandle, 'ResultManager');

obj=orderfields(obj);
obj=class(obj, 'sigTOOLResultView');

setappdata(rhandle, 'sigTOOLResultView', obj);
return
end