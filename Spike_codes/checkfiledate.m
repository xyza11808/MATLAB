function IsFileLatter = checkfiledate(filePath, compDate)
% compDate should be a vector contains year,month,day. if more precised
% time is needed, the extra data could be added later

if ~exist(filePath,'file')
    fprintf('File not existed.\n');
    IsFileLatter = nan;
    return;
end

d = System.IO.File.GetLastWriteTime(filePath);
if length(compDate) == 3
    ModiDatetime = datetime(d.Year, d.Month, d.Day);
    TargetDatetime = datetime(compDate(1),compDate(2),compDate(3));
elseif length(compDate) > 3
    ModiDatetime = datetime(d.Year, d.Month, d.Day, d.Hour, d.Hour, d.Minute);
    TargetDatetime = datetime(compDate(1),compDate(2),compDate(3),compDate(4),compDate(5),compDate(6));
end
IsFileLatter = ModiDatetime > TargetDatetime;





