function StrIndexAlls = SheetNameIndexExtraction(NameStrs)
% return the sheet index from input strings or cell array
if ischar(NameStrs)
    [St,Ed] = regexp(NameStrs,'_N\d{1,2}');
    if isempty(St)
        [StNew,EdNew] = regexp(NameStrs,'_n\d{1,2}');
        StrIndexAlls = str2num(NameStrs(StNew+2:EdNew)); %#ok<*ST2NM>
    else
        StrIndexAlls = str2num(NameStrs(St+2:Ed));
    end
    if isempty(StrIndexAlls)
        StrIndexAlls = NaN;
    end
elseif iscell(NameStrs)
    Number_Strs = length(NameStrs);
    StrIndexAlls = zeros(Number_Strs,1);
    for cInds = 1 : Number_Strs
        cStr = NameStrs{cInds};
        [St,Ed] = regexp(cStr,'_N\d{1,2}');
        if isempty(St)
            [StNew,EdNew] = regexp(cStr,'_n\d{1,2}');
            StrIndex = str2num(cStr(StNew+2:EdNew));
        else
            StrIndex = str2num(cStr(St+2:Ed));
        end
        if isempty(StrIndex)
            StrIndex = NaN;
        end
        StrIndexAlls(cInds) = StrIndex;
    end
end
    
 