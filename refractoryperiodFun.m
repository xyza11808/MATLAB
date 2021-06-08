function RefracBinNum = refractoryperiodFun(ccgData,baselinewinscale)
% this function is used to calculate the refractory period using given ccg
% data, using the given baseline period to calculate the baseline count and
% calculate the time used to recover after a spike

if length(baselinewinscale) ~= 2 && diff(baselinewinscale) > 0
    error('The input baseline scale must be a 2 numbered vector and is positively increased.');
end
baselineValue = mean(ccgData((baselinewinscale(1):baselinewinscale(2))+1));

RefracBinNum = find(ccgData > baselineValue, 1, 'first');

RefracBinNum = RefracBinNum - 1;


