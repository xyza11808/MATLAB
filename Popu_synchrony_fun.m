function x_N = Popu_synchrony_fun(ROidatas)
AvgTrace = mean(ROidatas);
ROIAvgStd = std(AvgTrace);

ROISingle_Std = std(ROidatas,[],2);

x_N = sqrt(ROIAvgStd^2/(sum(ROISingle_Std.^2)/numel(ROISingle_Std)));