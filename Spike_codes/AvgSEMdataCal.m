function [Data_TrNum,Data_Avg,Data_SEM] = AvgSEMdataCal(Data, NumFrameBins)

if ~isempty(Data)
    % TrType Exists
    Data_data = Data;
    Data_TrNum = size(Data_data,1);
    if Data_TrNum == 1
        Data_Avg = (smooth(Data_data,7))';
        Data_SEM = zeros(size(Data_data));
    elseif Data_TrNum == 2
        Data_Avg = (smooth(mean(Data_data),7))';
        Data_SEM = zeros(1,NumFrameBins);
    else
        Data_Avg = mean(Data_data);
        Data_SEM = std(Data_data)/sqrt(Data_TrNum);
    end
else
    Data_TrNum = 0;
    Data_Avg = nan(1,NumFrameBins);
    Data_SEM = nan(1,NumFrameBins);
end



