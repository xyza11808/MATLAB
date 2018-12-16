function p = TwoSampleBinoTest(Data_1,Data_2)

n1 = numel(Data_1);
n2 = numel(Data_2);
p1 = mean(Data_1 == max(Data_1));
p2 = mean(Data_2 == max(Data_2));

p_Avg = (n1*p1 + n2*p2)/(n1 + n2);

Z_value = (p1 - p2)/sqrt(p_Avg*(1-p_Avg)*(1/n1+1/n2));

p = (1 - normcdf(abs(Z_value)))*2;