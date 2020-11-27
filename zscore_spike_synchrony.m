cclr
close all
% read xls file
% filepath = 'N:\Documents\xnnData_20201107\np1_ipsc.xlsx';
filepath = 'epsc_ipsc_1119.xlsx';
[~,~,raw1] = xlsread(filepath,1);
[~,~,raw2] = xlsread(filepath,2);
Neu1_SpikeTime = cell2mat(raw1(2:end,2));
Neu2_SpikeTime = cell2mat(raw2(2:end,2));

%
TotalTime = raw2{1,end}; %seconds
if ischar(TotalTime)
    TotalTime = str2double(TotalTime(1:end-1));
end
if isnan(TotalTime)
    TotalTime = 330;
end
%%
Delta_t = 1; %ms
frNeu1 = length(Neu1_SpikeTime)/(TotalTime*1000); % averaged firing rate for neuron 1, Hz
frNeu2 = length(Neu2_SpikeTime)/(TotalTime*1000); % averaged firing rate for neuron 2, Hz
n_shift_scale = 1000;
ZerosPadRange = [-n_shift_scale, n_shift_scale];

% defaultly, we will use Less fired neuron as reference, and check the correation
% from another one
if frNeu1 < frNeu2
    Ref_Neu_SP = Neu1_SpikeTime;
    Corr_Neu_SP = Neu2_SpikeTime;
else
    Ref_Neu_SP = Neu2_SpikeTime;
    Corr_Neu_SP = Neu1_SpikeTime;
end

%% shuf spike time
Corr_Neu_SPBack = Corr_Neu_SP;
RandShiftRange = TotalTime*500;
RandValue = round((rand(1,length(Corr_Neu_SP)) - 0.5)*2*RandShiftRange);
Corr_Neu_SP = Corr_Neu_SP + RandValue(:);
Corr_Neu_SP(Corr_Neu_SP < 1) = Corr_Neu_SP(Corr_Neu_SP < 1) + TotalTime*1000 - 1;
Corr_Neu_SP(Corr_Neu_SP > TotalTime*1000) = Corr_Neu_SP(Corr_Neu_SP > TotalTime*1000) - TotalTime*1000;

%% reverse of shuffle
Corr_Neu_SP = Corr_Neu_SPBack;

%%
zsDataAll = zeros(100, n_shift_scale*2+1);

for cRepeat = 1 : 100
    Corr_Neu_SP = Corr_Neu_SPBack;
    RandShiftRange = TotalTime*500;
    RandValue = round((rand(1,length(Corr_Neu_SP)) - 0.5)*2*RandShiftRange);
    Corr_Neu_SP = Corr_Neu_SP + RandValue(:);
    Corr_Neu_SP(Corr_Neu_SP < 1) = Corr_Neu_SP(Corr_Neu_SP < 1) + TotalTime*1000 - 1;
    Corr_Neu_SP(Corr_Neu_SP > TotalTime*1000) = Corr_Neu_SP(Corr_Neu_SP > TotalTime*1000) - TotalTime*1000;


    ZerosPadBins = (ZerosPadRange(1) - 1) : (ZerosPadRange(2) + 1);
    Expect_fr = (frNeu1 * frNeu2) * TotalTime * Delta_t; %frNeu1 * frNeu2 * TotalTime * 1000 * Delta_t / 1000;
    %
    RefSPNum = length(Ref_Neu_SP);
    ynNum = nan(RefSPNum, n_shift_scale*2+1);
    for cp = 1 : RefSPNum
        cSP_Time = Ref_Neu_SP(cp);

        CorrNeu_RelativeSPTime = Corr_Neu_SP - cSP_Time; % relative spike time to ref spike
        [SP_binned_count, edges] = histcounts(CorrNeu_RelativeSPTime, ZerosPadBins);

        UsedCountData = SP_binned_count(2:end);
        if cSP_Time < (n_shift_scale + 1)
            ynNum(cp, (end-n_shift_scale-ceil(cSP_Time)):end) = UsedCountData((end-n_shift_scale-ceil(cSP_Time)):end);
        elseif cSP_Time > (TotalTime*1000 - n_shift_scale)
            Dis2End = TotalTime*1000 - floor(cSP_Time);
            ynNum(cp, 1:(n_shift_scale+Dis2End)) = UsedCountData(1:(n_shift_scale+Dis2End));
        else
            ynNum(cp, :) = UsedCountData;
        end

    end

%
    PlotEdges  = edges(2:end-1);
    yn_averaged = mean(ynNum,'omitnan');
    zs_data = (yn_averaged - Expect_fr) / std(yn_averaged);
    zsDataAll(cRepeat,:) = smooth(zs_data,5);
end

%% for real data processing
ZerosPadBins = (ZerosPadRange(1) - 1) : (ZerosPadRange(2) + 1);
Expect_fr = (frNeu1 * frNeu2) * TotalTime * Delta_t; %frNeu1 * frNeu2 * TotalTime * 1000 * Delta_t / 1000;
%
RefSPNum = length(Ref_Neu_SP);
ynNum = nan(RefSPNum, n_shift_scale*2+1);
for cp = 1 : RefSPNum
    cSP_Time = Ref_Neu_SP(cp);

    CorrNeu_RelativeSPTime = Corr_Neu_SP - cSP_Time; % relative spike time to ref spike
    [SP_binned_count, edges] = histcounts(CorrNeu_RelativeSPTime, ZerosPadBins);

    UsedCountData = SP_binned_count(2:end);
    if cSP_Time < (n_shift_scale + 1)
        ynNum(cp, (end-n_shift_scale-ceil(cSP_Time)):end) = UsedCountData((end-n_shift_scale-ceil(cSP_Time)):end);
    elseif cSP_Time > (TotalTime*1000 - n_shift_scale)
        Dis2End = TotalTime*1000 - floor(cSP_Time);
        ynNum(cp, 1:(n_shift_scale+Dis2End)) = UsedCountData(1:(n_shift_scale+Dis2End));
    else
        ynNum(cp, :) = UsedCountData;
    end

end

%
PlotEdges  = edges(2:end-1);
yn_averaged = mean(ynNum,'omitnan');
zs_data = (yn_averaged - Expect_fr) / std(yn_averaged);


%%
hzsf = figure;
plot(PlotEdges, smooth(zs_data,5), 'Color',[.7 .7 .7])
set(gca,'xlim',[-1000 1000])
xlabel('Time (ms)');
ylabel('Normlized score');
title('spike synchrony');
set(gca,'Fontsize',10);
%%
saveas(hzsf,sprintf('%s spike bin synchrony',filepath(1:end-5)));
saveas(hzsf,sprintf('%s spike bin synchrony',filepath(1:end-5)),'png');
%%
Binedges = 0:TotalTime*1000;
Neu1SPCount = histcounts(Neu1_SpikeTime, Binedges);
Neu2SPCount = histcounts(Neu2_SpikeTime, Binedges);
% figure;plot(Neu1SPCount, 'bo')
% hold on
% plot(Neu2SPCount+0.2, 'ko')

[r,lags] = xcorr(Neu1SPCount,Neu2SPCount,1000,'coeff');
hf = figure;
plot(lags, r, 'k');
xlabel('time (ms)');
ylabel('SP corrcoef');
title('spike train cross correlation');
set(gca,'Fontsize',10);
%%
saveas(hf,sprintf('%s spike train crosscoef',filepath(1:end-5)));
saveas(hf,sprintf('%s spike train crosscoef',filepath(1:end-5)),'png');


