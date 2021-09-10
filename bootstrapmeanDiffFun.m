function [p, mu] = bootstrapmeanDiffFun(Data1, Data2, bootrepeatNum)
% calculate the real t static value, and then fill the difference between
% two datasets and then bootstrap to calculate new null t statics, and
% finally calculate the propotion of null t-static values larger than real
% t-static as p values
if ~exist('bootrepeatNum','var') || isempty(bootrepeatNum)
    bootrepeatNum = 10000;
end

data1Num = numel(Data1);
data2Num = numel(Data2);

mu = mean(Data1) - mean(Data2);
t_static_real = mu/sqrt(var(Data1)/data1Num + var(Data2)/data2Num);

Data2_null = Data2 + (mean(Data1) - mean(Data2));

Data1_boot_value = bootstrp(bootrepeatNum, @(x) [mean(x) var(x)],Data1);
Data2_boot_value = bootstrp(bootrepeatNum, @(x) [mean(x) var(x)],Data2_null);

t_static_boot = (Data1_boot_value(:,1) - Data2_boot_value(:,1)) ./ sqrt(Data1_boot_value(:,2)/data1Num + Data1_boot_value(:,2)/data2Num);

p = mean(t_static_real > t_static_boot);
if t_static_real > 0
   p = 1 - p; 
end







