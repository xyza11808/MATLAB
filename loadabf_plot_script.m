% cclr
abffile1 = '2018_08_07_0041_ipsc.abf';
[d,si,h] = abfload(abffile1);
% cd(abffile1(1:end-4));
%%
fRate = 10000; % sample rate
excludedTime = 0.5; % seconds, the data before this time will be excluded
Used_datas = d(((excludedTime*fRate+1):end),:,:);
Nsweep = 1;

% sweepData = squeeze(Used_datas(:,:,Nsweep));
sweeplen = size(Used_datas,1);

%
%%
NeuData_permu = permute(Used_datas, [1,3,2]);
Neu1Data = squeeze(NeuData_permu(:,:,1));
Neu2Data = squeeze(NeuData_permu(:,:,2));

Neu1Traceraw = Neu1Data(:);
Neu2Traceraw = Neu2Data(:);
cDes = designfilt('lowpassfir','PassbandFrequency',1,'StopbandFrequency',10,...
             'StopbandAttenuation', 60,'SampleRate',fRate,'DesignMethod','kaiserwin'); 

Neu1Trace = filtfilt(cDes,Neu1Traceraw);
Neu2Trace = filtfilt(cDes,Neu2Traceraw);

% Neu1Trace = Neu1Traceraw;
% Neu2Trace = Neu2Traceraw;

hf = figure('position',[100 100 900 380]);
subplot(121)
hold on
plot(Neu1Traceraw,'color','k');
plot(Neu1Trace,'r','linewidth',1.5);
title('Raw record trace1');

subplot(122)
hold on
plot(Neu2Traceraw,'color','k');
plot(Neu2Trace,'r','linewidth',1.5);
plot(Neu2_SubtrendData,'b','linewidth',1.5);
title('Raw record trace2');

% saveas(hf,'Raw trace plot save');
% saveas(hf,'Raw trace plot save','png');
% close(hf);
%%
if mean(Neu1Trace) < 0
    [Neu1_SubtrendData,~]=BLSubStract(-Neu1Trace,8,20000);
    [Neu2_SubtrendData,~]=BLSubStract(-Neu2Trace,8,20000);
else
    [Neu1_SubtrendData,~]=BLSubStract(Neu1Trace,8,20000);
    [Neu2_SubtrendData,~]=BLSubStract(Neu2Trace,8,20000);
end 
% 
%%
if mean(Neu1Trace) < 0
    IsEPSC = 1;
    Neu1_zsData = zscore(-Neu1_SubtrendData);
    Neu2_zsData = zscore(-Neu2_SubtrendData);
else
    IsEPSC = 0;
    Neu1_zsData = zscore(Neu1_SubtrendData);
    Neu2_zsData = zscore(Neu2_SubtrendData);
end
save abfDatas.mat d Neu1_SubtrendData Neu2_SubtrendData Neu1Trace Neu2Trace Neu1_zsData Neu2_zsData -v7.3
if IsEPSC % negtive curve
    PeakThres_neu1 = prctile(Neu1_zsData,20);
    PeakThres_neu2 = prctile(Neu2_zsData,20);
else
    PeakThres_neu1 = prctile(Neu1_zsData,80);
    PeakThres_neu2 = prctile(Neu2_zsData,80);
end

hhf = figure('position',[150,400,1280,420]);
subplot(131)
hold on
plot(Neu1_zsData,'k')
line([1 numel(Neu1_zsData)],[PeakThres_neu1 PeakThres_neu1],'Color','g','linestyle','--',...
    'linewidth',1.2);
plot(Neu2_zsData,'r')
line([1 numel(Neu2_zsData)],[PeakThres_neu2 PeakThres_neu2],'Color','m','linestyle','--',...
    'linewidth',1.2);
title('Base corrected trace')
%
[r,lag] = xcorr(Neu1_zsData,Neu2_zsData,10000,'Coeff');
subplot(132)
hold on
plot(lag,r,'m')
set(gca,'ylim',[0 1]);
title('time-lagged coef')
[Maxcorr, maxinds] = max(r);
MaxCorrlags = lag(maxinds);
% shufCorrs = crosscoefthresFun(([Neu1_zsData(:),Neu2_zsData(:)])',10000);
shufCorrs = Eventscaleshuf(Neu1_zsData, PeakThres_neu1, fRate*2,Neu2_zsData);
MaxLagThres = prctile(shufCorrs(:,maxinds),95);
line([-10000,10000],[MaxLagThres MaxLagThres],'Color',[.6 .6 .6],'linewidth',1,...
    'linestyle','--');

% later half datas
halfstartInds = min(length(Neu1_zsData)/2, 2E6);
Neu1data_lasthalf = Neu1_zsData(halfstartInds:end);
Neu2data_lasthalf = Neu2_zsData(halfstartInds:end);
[r2,lag2] = xcorr(Neu1data_lasthalf,Neu2data_lasthalf,10000,'Coeff');
subplot(133)
plot(lag2,r2)
set(gca,'ylim',[0 1]);
title('second half crosscoef')

%%
saveas(hhf,'Crosscoef plot save')
saveas(hhf,'Crosscoef plot save','png')
close(hhf);

% %% batched scripts
% cclr
% sourcefolderpath = '/Users/xinyu/Documents/dataAll/xnntest/neuron_distance_vs_laged_time';
% cd(sourcefolderpath);
% Folderswithin = dir(sourcefolderpath);
% foldNameLens = arrayfun(@(x) length(x.name),Folderswithin);
% isfolder = arrayfun(@(x) x.isdir,Folderswithin);
% Usedfoldersinds = foldNameLens(:) > 2 & isfolder(:) > 0;
% UsedfolderStrc = Folderswithin(Usedfoldersinds);
% Numusedfolders = length(UsedfolderStrc);
% %
% laggedcorr = cell(Numusedfolders,2);
% for cfold = 1 : Numusedfolders
%     cfoldName = UsedfolderStrc(cfold).name;
%     cd(cfoldName);
%     
%     abffiles = dir('*.abf');
%     numabfs = length(abffiles);
%     abfDatas = cell(numabfs,3);
%     for cabf = 1 : numabfs
%         cabfname = abffiles(cabf).name;
%         if ~isdir(cabfname(1:end-4))
%             mkdir(cabfname(1:end-4));
%         end
%         abffile1 = cabfname;
% %         loadabf_plot_script;
%         
%         abfDatas{cabf,1} = [Maxcorr, MaxCorrlags,MaxLagThres];
%         abfDatas{cabf,2} = cabfname(1:end-4);
%         
%         clearvars Neu1_SubtrendData Neu2_SubtrendData Maxcorr MaxCorrlags
%         
% %         cd ..;
%     end
%     
%      laggedcorr(cfold,:) = {cfoldName, abfDatas};
%      cd ..;
% end
% 
%%
% NumSessions = size(laggedcorr,1);
% EPSCdats = zeros(NumSessions,4);
% IPSCdats = zeros(NumSessions,4);
% for cf = 1 : NumSessions
%     cf_disstrs = laggedcorr{cf,1};
%     [st, et] = regexp(cf_disstrs,'\d{2,3}.\d{2}');
%     
%     cfolderDis = str2double(cf_disstrs(st:et));
%     
%     withinfilenames = laggedcorr{cf,2}(:,2);
%     CorrAndlagdata = laggedcorr{cf,2}(:,1);
%     
%     EPSCinds = ~cellfun(@isempty,strfind(withinfilenames,'epsc'));
%     
%     EPSCdats(cf,:) = [cfolderDis, CorrAndlagdata{EPSCinds}];
%     IPSCdats(cf,:) = [cfolderDis, CorrAndlagdata{~EPSCinds}];
%     
% end
%     
% 
% %%
% % UsedCoefthres = 0.2;
% EPSCUsedInds = EPSCdats(:,2) > EPSCdats(:,4);
% IPSCUsedInds = IPSCdats(:,2) > IPSCdats(:,4);
% 
% EPSC_dis_Vec = EPSCdats(EPSCUsedInds, 1);
% EPSC_peaklag_Vec = abs(EPSCdats(EPSCUsedInds, 3)/10); % ms
% 
% IPSC_dis_Vec = IPSCdats(EPSCUsedInds, 1);
% IPSC_peaklag_Vec = abs(IPSCdats(EPSCUsedInds, 3)/10); % ms
% 
% % hf = figure('position',[100 100,1000,400]);
% [er, ep] = corrcoef(EPSC_dis_Vec, EPSC_peaklag_Vec);
% lmFunCalPlot(EPSC_dis_Vec,EPSC_peaklag_Vec);
% 
% title(sprintf('EPSC r=%.3f, p = %.2e',er(1,2), ep(1,2)));
% xlabel('Distance');
% ylabel('Time lag (ms)');
% % ipsc
% [ir, ip] = corrcoef(IPSC_dis_Vec, IPSC_peaklag_Vec);
% lmFunCalPlot(IPSC_dis_Vec,IPSC_peaklag_Vec);
% 
% title(sprintf('IPSC r=%.3f, p = %.2e',ir(1,2), ip(1,2)));
% xlabel('Distance');
% ylabel('Time lag (ms)');


