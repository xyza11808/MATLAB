function [TaskSigColData,PassSigColData] = SigROIdataExtraction(TaskData,PassData,p_value)
% this function is used for cellfun call to evaluate the significant data
% from given input "TaskData" and "PassData" using input p value, p value
% less then 0.05 was taken as significantly different
ColumnNum = size(TaskData,2);
PassSigColData = cell(ColumnNum,1);
TaskSigColData = cell(ColumnNum,1);
for ncol = 1 : ColumnNum
    SigInds = p_value(:,ncol) < 0.05;
    PassSigColData(ncol) = {PassData(SigInds,ncol)};
    TaskSigColData(ncol) = {TaskData(SigInds,ncol)};
end
