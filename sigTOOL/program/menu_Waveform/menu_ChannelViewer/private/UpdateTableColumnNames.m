function UpdateTableColumnNames(fhandle, chan)
h=getappdata(fhandle, 'cvUitable');
channels=getappdata(fhandle, 'channels');
units=channels{chan}.adc.Units;
try
    set(h, 'ColumnName', {'Time(s)' units});
catch
    set(h, 'ColumnNames', {'Time(s)' units});
end
return
end