function s=inspect(obj)
% inspect method for scchannel objects
% 
% Examples:
% s=inspect(obj)
%     returns a structure that can then be inspected using the MATLAB
%     array editor. Custom defined objects in each field of obj are also cast
%     to structures (and the fieldname changed to indicate this).
%     memmapfile objects remain as objects and are not editable within the
%     array editor
% inspect(obj)
%     places the structure in 'ans' in the base workspace and opens it in
%     the array editor
%
%-------------------------------------------------------------------------
% Author: Malcolm Lidierth 03/08
% Copyright © The Author & King’s College London 2008-
%-------------------------------------------------------------------------

s=struct(obj);   
if isobject(obj.adc)
    field=['adc_' class(obj.adc) 'AsStructure'];
    s.(field)=struct(s.adc);
    s=rmfield(s, 'adc');
end
if isobject(obj.tim)
    field=['tim_' class(obj.tim) 'AsStructure'];
    s.(field)=struct(s.tim);
    s=rmfield(s, 'tim');
end
if nargout==0
     assignin('base', 'ans', s);
     openvar('ans');
end
return
end
