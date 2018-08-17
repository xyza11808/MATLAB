function DataOutput = fieldAvgProcess(DataStrc)

cfields = fieldnames(DataStrc);
nfileds = length(cfields);
DataOutput = zeros(nfileds,1);

for cf = 1 : nfileds
    DataOutput(cf) = mean(DataStrc.(cfields{cf}),'omitnan');
end