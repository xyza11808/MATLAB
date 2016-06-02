function scWindowKeyPressFcn(hObject, EventData)
% scWindowKeyPressFcn - keypress callback for sigTOOL windows
%
% Example:
% scWindowKeyPressFcn(hObject, EventData)
%             standard callback
%-------------------------------------------------------------------------
% Author: Malcolm Lidierth 09/06
% Copyright © The Author & King’s College London 2006-2007
%-------------------------------------------------------------------------
            
switch get(hObject, 'Tag')
    case {'sigTOOL:ResultView'}
        switch EventData.Key
            case {'pageup' 'uparrow' 'pagedown' 'downarrow'}
                chm=getappdata(hObject, 'ResultManager');
                val=str2num(chm.Frames.getText()); %#ok<ST2NM>
                if length(val)>1
                    return
                end
                switch EventData.Key
                    case {'pageup' 'uparrow'}
                        val=max(1, val-1);
                        chm.Frames.setText(num2str(val));
                        chm.Frames.postActionEvent();
                    case {'pagedown' 'downarrow'}
                        val=val+1;
                        chm.Frames.setText(num2str(val));
                        chm.Frames.postActionEvent();
                    case 'sigTOOL:DataView'
                end
        end
end

return
end