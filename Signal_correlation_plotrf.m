
[fn,fp,fi] = uigetfile('AllRespDat.mat','Please select your ROI response data');
if fi
    xxx = load(fullfile(fp,fn));
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
    h_cfreq = figure('position',[200 150 1400 850],'paperpositionmode','auto');
    subplot(1,2,1);
    imagesc(cCorrCoef,[-1,1]);
    colormap jet;
    colorbar;
    xlabel('# nROIs');
    ylabel('# nROIs');
    title(sprintf('Frequency #%d corrcoef plot',nf));
    set(gca,'FontSize',20);
    axis square
    
    subplot(1,2,2)
    TriuMask = ones(size(cCorrCoef));
    TriuMask = logical(triu(TriuMask,1));
    AllCoefData = cCorrCoef(TriuMask);
    histogram(AllCoefData,30,'FaceColor','b','Normalization','probability','FaceAlpha',0.5);
    xlabel('Corrcoef value');
    ylabel('Paired-value fraction');
    title('Corrcoef value distribution');
    
    saveas(h_cfreq,sprintf('Frequency %d corrcoef value plot',nf));
    saveas(h_cfreq,sprintf('Frequency %d corrcoef value plot',nf),'png');
    close(h_cfreq);
end

%
MeanCorrcoef = squeeze(mean(AllStimCorrMatrix));
h_mean = figure('position',[200 150 1400 850],'paperpositionmode','auto');
subplot(1,2,1);
imagesc(MeanCorrcoef,[-1 1]);
colormap jet;
colorbar;
xlabel('# nROIs');
ylabel('# nROIs');
title(sprintf('Mean corrcoef plot'));
set(gca,'FontSize',20);
axis square

subplot(1,2,2)
TriuMask = ones(size(MeanCorrcoef));
TriuMask = logical(triu(TriuMask,1));
MeanCoefData = MeanCorrcoef(TriuMask);
subplot(1,2,2)
histogram(MeanCoefData,30,'FaceColor','b','Normalization','probability','FaceAlpha',0.5);
xlabel('Corrcoef value');
ylabel('Paired-value fraction');
title('Corrcoef value distribution');

saveas(h_mean,'Mean corrcoef signal correlation');
saveas(h_mean,'Mean corrcoef signal correlation','png');
close(h_mean);


%%
% plot signal correlation matrix
MeanDataTarget = DataMeanSelect(:,:,29:58);
AllDataTarget = DataAllSelect(:,:,:,29:58);
MeanDataTargetValue = max(MeanDataTarget,[],3);
AllDataTargetValue = max(AllDataTarget,[],4);

%%
% signal correlation plot
RFSignalmatrix = corrcoef(MeanDataTargetValue');
h_signalCoef = figure('position',[200 150 1400 850]);
subplot(1,2,1)
imagesc(RFSignalmatrix,[-1 1]);
axis square
colormap jet
colorbar
xlabel('# ROIs');
ylabel('# ROIs');
title('ROI paired signal correlation');
set(gca,'FontSize',20);

subplot(1,2,2)
TriuMask = ones(size(RFSignalmatrix));
TriuMask = logical(triu(TriuMask,1));
SigCoefData = RFSignalmatrix(TriuMask);
histogram(SigCoefData,30,'FaceColor','b','Normalization','probability','FaceAlpha',0.5);
xlabel('Corrcoef value');
ylabel('Paired-value fraction');
xlim([-1 1]);
title('Corrcoef value distribution');
set(gca,'FontSize',20);

saveas(h_signalCoef,'Signal CorrCoef matrix rf','png');
saveas(h_signalCoef,'Signal CorrCoef matrix rf');
close(h_signalCoef);

% calculate the noise correlation
FreqNoiseCoef = zeros(nFreq,nROI,nROI);

for nff = 1 : nFreq
    cFreqData = squeeze(AllDataTargetValue(:,nff,:));
    cfreqCoef = corrcoef(cFreqData');
    FreqNoiseCoef(nff,:,:) = cfreqCoef;
    h_noiseCoef = figure('position',[200 150 1400 850]);
    subplot(1,2,1)
    imagesc(cfreqCoef,[-1 1]);
    axis square
    colormap jet
    colorbar
    xlabel('# ROIs');
    ylabel('# ROIs');
    title('ROI noise correlation');
    set(gca,'FontSize',20);

    subplot(1,2,2)
    TriuMask = ones(size(cfreqCoef));
    TriuMask = logical(triu(TriuMask,1));
    NoiseCoefData = cfreqCoef(TriuMask);
    histogram(NoiseCoefData,30,'FaceColor','b','Normalization','probability','FaceAlpha',0.5);
    xlabel('Corrcoef value');
    ylabel('Paired-value fraction');
    title('Corrcoef value distribution');
    xlim([-1 1]);
    set(gca,'FontSize',20);
    saveas(h_noiseCoef,sprintf('Noise CorrCoef matrix rf ROI%d',nff),'png');
    saveas(h_noiseCoef,sprintf('Noise CorrCoef matrix rf ROI%d',nff));
    close(h_noiseCoef);
end

MeanNoiseCoef = squeeze(mean(FreqNoiseCoef));
 h_noiseCoef = figure('position',[200 150 1400 850]);
    subplot(1,2,1)
    imagesc(cfreqCoef,[-1 1]);
    axis square
    colormap jet
    colorbar
    xlabel('# ROIs');
    ylabel('# ROIs');
    title('ROI Mean noise correlation');
    set(gca,'FontSize',20);

    subplot(1,2,2)
    TriuMask = ones(size(cfreqCoef));
    TriuMask = logical(triu(TriuMask,1));
    NoiseCoefData = cfreqCoef(TriuMask);
    histogram(NoiseCoefData,30,'FaceColor','b','Normalization','probability','FaceAlpha',0.5);
    xlabel('Corrcoef value');
    ylabel('Paired-value fraction');
    title('Corrcoef value distribution');
    xlim([-1 1]);
    set(gca,'FontSize',20);
    saveas(h_noiseCoef,'MeanNoise CorrCoef matrix rf','png');
    saveas(h_noiseCoef,'MeanNoise CorrCoef matrix rf');
    close(h_noiseCoef);
