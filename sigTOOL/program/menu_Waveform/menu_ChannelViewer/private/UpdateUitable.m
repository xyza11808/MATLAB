function UpdateUitable(fhandle, start, stop)
thandle=getappdata(fhandle,'cvUitable');
try
    flag=get(thandle, 'Enable');
    switch(flag)
        case 'on'
            flag=1;
        case 'off'
            flag=0;
    end
catch
    flag=get(thandle, 'Visible');
end

if flag
    xdata=getappdata(fhandle, 'xdata');
    ydata=getappdata(fhandle, 'ydata');
    try
        set(thandle, 'Data', [xdata(start:stop) ydata(start:stop)]);
    catch
        set(thandle, 'Data', num2cell([xdata(start:stop) ydata(start:stop)]));
        return
    end
end
end
