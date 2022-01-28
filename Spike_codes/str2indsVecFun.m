function IndsVec = str2indsVecFun(IndexStrings)
if ischar(IndexStrings)
    if contains(IndexStrings,';')
        StrCells = strsplit(IndexStrings,';');
        NumCells = length(StrCells);

        Str2numbers = cell(1 , NumCells);
        for cStr = 1 : NumCells
            if contains(StrCells{cStr},'-')
                finalStrs = strsplit(StrCells{cStr},'-');
                finalIndexes = str2double(finalStrs{1}):str2double(finalStrs{2});
                Str2numbers{cStr} = finalIndexes;
            else
                Str2numbers{cStr} = str2double(StrCells{cStr});
            end
        end
        IndsVec = (cell2mat(Str2numbers))';
    elseif contains(IndexStrings,'-')
        finalStrs = strsplit(IndexStrings,'-');
        finalIndexes = str2double(finalStrs{1}):str2double(finalStrs{2});
        IndsVec = finalIndexes';
    else
        IndsVec = str2double(IndexStrings);

    end
elseif isnumeric(IndexStrings)
    IndsVec = IndexStrings;
    
end