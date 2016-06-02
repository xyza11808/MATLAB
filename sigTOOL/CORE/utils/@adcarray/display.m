function display(obj)
% DISPLAY method overloaded for adcarray objects
%
% Author: Malcolm Lidierth
% Copyright © The Author & King's College London 2006

fprintf(1, '%12s = %g\n', 'Scale', obj.Scale);
fprintf(1, '%12s = %g\n', 'DC', obj.DC);
if isempty(obj.Func)
    fprintf(1, '%12s = %s\n','Func','[]');
elseif isa(obj.Func,'function_handle')
    fprintf(1, '%12s = @%s\n','Func', char(obj.Func));
elseif iscell(obj.Func)
    fprintf(1, '%12s =','Func');
    disp(obj.Func);
end;
fprintf(1, '%12s = %s\n', 'Units', obj.Units);
fprintf(1, '%12s = %dx%d %s\n', 'Map',size(obj.Map),class(obj.Map));
if ~isempty(obj.Map)
    fprintf(1, '%14scontaining: ','');
    x=size(obj.Map.Data.Adc);
    fprintf(1,'%dx',x(1:end-1));
    fprintf(1,'%d ',x(end));
    fprintf(1,'%s array in %s.Map.Data.Adc\n', class(obj.Map.Data.Adc),inputname(1));
end
fprintf(1,'%12s = %s\n','Swapbytes',mat2str(obj.Swapbytes));
fprintf(1,'%12s = ','Labels');
fprintf(1,'{''%s''} ',obj.Labels{1:end});

fprintf(1,'\n\n');
whos('obj');

return
end