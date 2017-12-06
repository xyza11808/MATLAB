function Data = BatchStrcFun(Strc,fieldn)
% return the fieldname values if strc is a strcture array
if length(Strc) == 1
    Data = Strc.(fieldn);
    return;
else
    Num = length(Strc);
    if (numel(Strc(1).(fieldn)) == 1) && isnumeric(Strc(1).(fieldn))
        Data = zeros(Num,1);
        for nt = 1 : Num
            Data(nt) = Strc(nt).(fieldn);
        end
    else
        Data = cell(Num,1);
        for nt = 1 : Num
            Data{nt} = Strc(nt).(fieldn);
        end
    end
end