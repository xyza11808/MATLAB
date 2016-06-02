function display(obj)
% DISPLAY method overloaded for tstamp objects
%
% Author: Malcolm Lidierth
% Copyright © The Author & King's College London 2006

disp(' ');
fprintf(1, '%12s = %g\n', 'Scale', obj.Scale);
fprintf(1, '%12s = %g\n', 'Shift', obj.Shift);
if isempty(obj.Func)
    fprintf(1, '%12s = %s\n','Func','[]');
else
fprintf(1, '%12s = @%s\n','Func', char(obj.Func));
end;


fprintf(1, '%12s = %g (s)\n', 'Units', obj.Units);
fprintf(1, '%12s = %dx%d %s\n', 'Map',size(obj.Map),class(obj.Map));
if isa(obj.Map,'memmapfile') || isstruct(obj.Map)
    fprintf(1, '%14scontaining: ','');
    x=size(obj.Map.Data.Stamps);
    fprintf(1,'%dx',x(1:end-1));
    fprintf(1,'%d ',x(end));
    fprintf(1,'%s array in %s.Map.Data.Stamps\n', class(obj.Map.Data.Stamps),inputname(1));
end
fprintf(1,'%12s = %s\n','Swapbytes',mat2str(obj.Swapbytes));
fprintf(1,'\n\n');
whos('obj');
