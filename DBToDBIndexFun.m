function DBIndex = DBToDBIndexFun(TrDBs)
% convert real DB values into different DB levels
nDBTypes = unique(TrDBs);
DBIndex = zeros(numel(TrDBs),1);
for cDB = 1 : length(nDBTypes)
    cDBInds = TrDBs == nDBTypes(cDB);
    DBIndex(cDBInds) = cDB;
end

