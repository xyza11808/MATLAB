function obj=sigTOOLDataView(fhandle)
% sigTOOLDataView constructor
% 
% Example:
%     obj=sigTOOLDataView(fhandle)
%     where fhandle is the handle of a figure created via the
%     scchannel/plot method
%
% 30.01.10  Remove references from result view
    
obj.Parent=fhandle;
obj.AxesPanel=getappdata(fhandle, 'AxesList');
obj.ChannelManager=getappdata(fhandle, 'ChannelManager');

obj=orderfields(obj);
obj=class(obj, 'sigTOOLDataView');

setappdata(fhandle, 'sigTOOLDataView', obj);

return
end