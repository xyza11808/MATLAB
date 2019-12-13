function [Avgs,SEMs] = AvgSEMCalcu_Fun(Datas)
Datas = Datas(:);
Avgs = mean(Datas);
SEMs = std(Datas)/sqrt(numel(Datas));
