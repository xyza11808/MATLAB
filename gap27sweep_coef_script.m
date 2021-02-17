% cclr
abffile1 = '2018_09_12_0053_before_-70mv.abf';
[d,si,h] = abfload(abffile1);
% cd(abffile1(1:end-4));
%%
fRate = 10000; % sample rate
excludedTime = 0.5; % seconds, the data before this time will be excluded
Used_datas = d(((excludedTime*fRate+1):end),:,:);
%%
Neu1Datas = squeeze(Used_datas(:,1,:));
Neu2Datas = squeeze(Used_datas(:,2,:));

Neu1Trace = Neu1Datas(:);
Neu2Trace = Neu2Datas(:);

%%
if mean(Neu1Trace) < 0
    IsEPSC = 1;
    [Neu1_SubtrendData,~]=BLSubStract(-Neu1Trace,8,20000);
    [Neu2_SubtrendData,~]=BLSubStract(-Neu2Trace,8,20000);
else
    IsEPSC = 0;
    [Neu1_SubtrendData,~]=BLSubStract(Neu1Trace,8,20000);
    [Neu2_SubtrendData,~]=BLSubStract(Neu2Trace,8,20000);
end 

%%
% spike event filter
cDes_spevent = designfilt('lowpassfir','PassbandFrequency',10,'StopbandFrequency',400,...
             'StopbandAttenuation', 60,'SampleRate',fRate,'DesignMethod','kaiserwin'); 

Neu1Tracefilt = filtfilt(cDes_spevent,Neu1_SubtrendData);
Neu2Tracefilt = filtfilt(cDes_spevent,Neu2_SubtrendData);
% SIC filter
cDes_SIC = designfilt('lowpassfir','PassbandFrequency',1,'StopbandFrequency',10,...
             'StopbandAttenuation', 60,'SampleRate',fRate,'DesignMethod','kaiserwin'); 

Neu1SICfilt = filtfilt(cDes_SIC,Neu1_SubtrendData);
Neu2SICfilt = filtfilt(cDes_SIC,Neu2_SubtrendData);

%% zscore the paired trace
if IsEPSC
    Neu1_zsData = zscore(-Neu1Tracefilt);
    Neu2_zsData = zscore(-Neu2Tracefilt);
    
    Neu1_SICData = zscore(-Neu1SICfilt);
    Neu2_SICData = zscore(-Neu2SICfilt);
    
    PeakThres_neu1 = prctile(Neu1_zsData,20);
    PeakThres_neu1SIC = prctile(Neu1_SICData,20);
else
    Neu1_zsData = zscore(Neu1Tracefilt);
    Neu2_zsData = zscore(Neu2Tracefilt);
    
    Neu1_SICData = zscore(Neu1SICfilt);
    Neu2_SICData = zscore(Neu2SICfilt);
    
    PeakThres_neu1 = prctile(Neu1_zsData,80);
    PeakThres_neu1SIC = prctile(Neu1_SICData,80);
end
save abfdatas.mat Neu1_SubtrendData Neu2_SubtrendData Neu1Trace Neu2Trace -v7.3

[r,lag] = xcorr(Neu1_zsData,Neu2_zsData,10000,'Coeff');
[r_SIC,lag_SIC] = xcorr(Neu1_SICData,Neu1_SICData,10000,'Coeff');

shufCorrs = Eventscaleshuf(Neu1_zsData, PeakThres_neu1, fRate*2,Neu2_zsData);
shufCorrsSIC = Eventscaleshuf(Neu1_SICData, PeakThres_neu1, fRate*2,Neu2_SICData);

SPEvent_shufcorrrs = prctile(shufCorrs,[2.5,97.5]);
SIC_shufcorrrs = prctile(shufCorrsSIC,[2.5,97.5]);

save laggedCorrDatas.mat r lag r_SIC lag_SIC shufCorrs shufCorrsSIC ...
    SPEvent_shufcorrrs SIC_shufcorrrs -v7.3

%% plot codes
patchlags = lag(:)/fRate;
huf = figure('position',[100 200 500 360]);
hold on
patch([patchlags;flipud(patchlags)],...
    [SPEvent_shufcorrrs(1,:),fliplr(SPEvent_shufcorrrs(2,:))],1,...
    'Facecolor',[1 0.4 0.4],'edgecolor','none','Facealpha',0.5);
patch([patchlags;flipud(patchlags)],...
    [SIC_shufcorrrs(1,:),fliplr(SIC_shufcorrrs(2,:))],1,...
    'Facecolor',[0.4 0.4 1],'edgecolor','none','Facealpha',0.5);
plot(lag,r,'r','linewidth',1.2);
plot(lag_SIC,r_SIC,'b','linewidth',1.2);
xlabel('Times(s)');
ylabel('Coefs');
title('time-lagged correlation');

saveas(huf,'Time lagged correlation and shuf plots');
saveas(huf,'Time lagged correlation and shuf plots','png');
saveas(huf,'Time lagged correlation and shuf plots','pdf');
close(huf);

%% batched codes

cclr
sourcefolderpath = '/Users/xinyu/Documents/dataAll/xnntest/neuron_distance_vs_laged_time';
cd(sourcefolderpath);
Folderswithin = dir(sourcefolderpath);
foldNameLens = arrayfun(@(x) length(x.name),Folderswithin);
isfolder = arrayfun(@(x) x.isdir,Folderswithin);
Usedfoldersinds = foldNameLens(:) > 2 & isfolder(:) > 0;
UsedfolderStrc = Folderswithin(Usedfoldersinds);
Numusedfolders = length(UsedfolderStrc);
%
laggedcorr = cell(Numusedfolders,2);
for cfold = 1 : Numusedfolders
    cfoldName = UsedfolderStrc(cfold).name;
    cd(cfoldName);
    
    abffiles = dir('*.abf');
    numabfs = length(abffiles);
    abfDatas = cell(numabfs,3);
    for cabf = 1 : numabfs
        cabfname = abffiles(cabf).name;
        if ~isdir(cabfname(1:end-4))
            mkdir(cabfname(1:end-4));
        end
        abffile1 = cabfname;
        gap27sweep_coef_script;
        
        abfDatas{cabf,1} = {r,lag,r_SIC,lag_SIC};
        abfDatas{cabf,2} = {SPEvent_shufcorrrs,SIC_shufcorrrs};
        abfDatas{cabf,3} = cabfname(1:end-4);
        
        clearvars r lag r_SIC lag_SIC SPEvent_shufcorrrs SIC_shufcorrrs
        
        cd ..;
    end
    
     laggedcorr(cfold,:) = {cfoldName, abfDatas};
     cd ..;
end



