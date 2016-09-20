
[fn,fp,fi] = uigetfile('AllRespDat.mat','Please select your ROI response data');
if fi
    xxx = load(fp,fn);
    DataMean = xxx.StimRespMeanData; % 4 dimensional data, nROI by nDB by nFrequency by nFrames
    DataAll = xxx.StimRespAllData; % 5 dimensional data, nROI by nDB by nFrequency by nRepeats by nFrames
end

%%
% Calculate signal correlation of different stimulus
[nROI,nDB,nFreq,nRepeats,nFrames] = size(DataAll);
if nDB > 1
%     TargetDBChar = input('Please selct the 70DB corresponded inds','s');
%     TargetDBInds = str2num(TargetDBChar);
    TargetDBInds = 2;
    DataMeanSelect = squeeze(DataMean(:,TargetDBInds,:,:));
    DataAllSelect = squeeze(DataAll(:,TargetDBInds,:,:,:));
else
    DataMeanSelect = squeeze(DataMean);
    DataAllSelect = squeeze(DataAll);
end

%%
% plot by different frequency type
AllStimCorrMatrix = zeros(nFreq,nROI,nROI);
for nf = 1 : nFreq
    cFreqData = squeeze(DataMeanSelect(:,nf,:));
    cCorrCoef = corrcoef(cFreqData');
    AllStimCorrMatrix(nf,:,:) = cCorrCoef; 
    h_cfreq = figure;
    imagesc(cCorrCoef,[-1,1]);
    colormap jet;
    colorbar;
    xlabel('# nROIs');
    ylabel('# nROIs');
    title(sprintf('Frequency #%d corrcoef plot',nf));
    set(gca,'FontSize',20);
    saveas(h_cfreq,sprintf('Frequency %d corrcoef value plot',nf));
    saveas(h_cfreq,sprintf('Frequency %d corrcoef value plot',nf),'png');
    close(h_cfreq);
end
MeanCorrcoef = squeeze(mean(AllStimCorrMatrix));
h_mean = figure;
imagesc(MeanCorrcoef,[-1 1]);
colormap jet;
colorbar;
xlabel('# nROIs');
ylabel('# nROIs');
title(sprintf('Mean corrcoef plot'));
set(gca,'FontSize',20);
saveas(h_mean,'Mean corrcoef signal correlation');
saveas(h_mean,'Mean corrcoef signal correlation','png');
close(h_mean);
