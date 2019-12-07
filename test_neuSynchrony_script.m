% method 1
% http://www.scholarpedia.org/article/Neuronal_synchrony_measures
cf = 5;
ROidatas = FieldDatas_AllCell{cf,1};
%
AvgTrace = mean(ROidatas);
ROIAvgStd = std(AvgTrace);

ROISingle_Std = std(ROidatas,[],2);

x_N = sqrt(ROIAvgStd^2/(sum(ROISingle_Std.^2)/numel(ROISingle_Std)));

figure;
imagesc(ROidatas)
title(num2str(x_N,'%.3f'));

%%

cInputPath = 'G:\xsn_imaging_data\sum_20191129_all_imaging_NewEventAna\p18_wt\20190808_xsn_wt_p16_done';
cd(cInputPath);
IsFieldDataPath_LOADMAT(cInputPath);
