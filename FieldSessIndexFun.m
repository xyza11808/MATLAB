function IndexAlls = FieldSessIndexFun(CellStr,Type)
% search type can be field or session or index
NumStrs = length(CellStr);
IndexAlls = zeros(NumStrs,1);
switch lower(Type)
    case 'field'
        % find field index
        for cStrInds = 1 : NumStrs
            cStrs = CellStr{cStrInds};
            [StartI,EndI] = regexp(lower(cStrs),'field\d{2,3}');
            FieldIndex = str2num(cStrs((StartI+5):EndI));
            IndexAlls(cStrInds) = FieldIndex;
        end
    case 'index'
        % find final index value
        for cStrInds = 1 : NumStrs
            cStrs = CellStr{cStrInds};
            [StartI,EndI] = regexp(lower(cStrs),'00\d{1,2}');
            if length(StartI) > 1
                FieldIndex = str2num(cStrs(StartI(end):EndI(end)));
                IndexAlls(cStrInds) = FieldIndex;
            else
                FieldIndex = str2num(cStrs(StartI:EndI));
                IndexAlls(cStrInds) = FieldIndex;
            end
        end
    case 'session'
        % find session index value
        for cStrInds = 1 : NumStrs
            cStrs = CellStr{cStrInds};
            [StartI,EndI] = regexp(lower(cStrs),'sess\d{2,3}');
            FieldIndex = str2num(cStrs((StartI+4):EndI));
            IndexAlls(cStrInds) = FieldIndex;
        end
    otherwise
        error('Unknown input search type.');
end

