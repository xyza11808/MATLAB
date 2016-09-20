function SignalCorr2afc(AlignedData,Trialoutcome,TrialFreq,varargin)
% this function is just used for calculation of signal correlation matrix

if nargin > 3
    [AlignFrame,FrameRate,TimeWin] = deal(varargin{1:3});
    isAllFrames = 1;
else
    isAllFrames = 0;
end

if isAllFrames
    fprintf('time window is given, using given time window data for calculation.\n');
    if length(TimeWin) == 1
        FrameScale = sort([AlignFrame,AlignFrame+round(FrameRate*TimeWin)]);
    elseif length(TimeWin) == 2
        FrameScale = sort([AlignFrame + round(FrameRate*TimeWin(1)),AlignFrame + round(FrameRate*TimeWin(2))]);
    else
        error('Error time window input, quit analysis.');
    end
    DataSelected = AlignedData(:,:,FrameScale(1):FrameScale(2));
else
    fprintf('Using all frames to do calculation.\n');
    DataSelected = AlignedData;
end

CorrectInds = Trialoutcome == 1;
CorrDataSelect = DataSelected(CorrectInds,:,:);
CorrFreq = double(TrialFreq(CorrectInds));
if ~isdir('./Signal_corrcoef_plot/')
    mkdir('./Signal_corrcoef_plot/');
end
cd('./Signal_corrcoef_plot/');

%%
%summrizing different frequncies correct trials and calculate its mean
%trace
[~,nROI,nFrame] = size(CorrDataSelect);
FreqType = unique(CorrFreq);
nFreq = length(FreqType);
MeanFreqData = zeros(nFreq,nROI,nFrame);
RawFreqData = cell(nFreq,1);
FreqCorrcoef = zeros(nFreq,nROI,nROI);
for nff = 1 : nFreq
    cFreqvalue = FreqType(nff);
    cfreqInds = CorrFreq == cFreqvalue;
    cfreqData = CorrDataSelect(cfreqInds,:,:);
    RawFreqData(nff) = {cfreqData};
    meanData = squeeze(mean(cfreqData));
    MeanFreqData(nff,:,:) = meanData;
    %calculate the corrcoef of mean trace
    Corcoefvalue = corrcoef(meanData');
    FreqCorrcoef(nff,:,:) = Corcoefvalue;
    h_cfreq = figure('position',[200 150 1400 850],'paperpositionmode','auto');
    subplot(1,2,1)
    imagesc(Corcoefvalue,[-1 1]);
    colormap jet;
    colorbar;
    xlabel('# ROIs');
    ylabel('# ROIs');
    title(sprintf('Freq %d Corrcoef plot',FreqType(nff)));
    set(gca,'FontSize',20);
    axis square    %make the x y axis square
    
    TriuMask = ones(size(Corcoefvalue));
    TriuMask = logical(triu(TriuMask,1));
    AllCoefData = Corcoefvalue(TriuMask);
    subplot(1,2,2)
    h=histogram(AllCoefData,30,'FaceColor','b','Normalization','probability','FaceAlpha',0.5);
    xlabel('Corrcoef value');
    ylabel('Paired-value fraction');
    title('Corrcoef value distribution');
    
    saveas(h_cfreq,sprintf('Frequency %d corrcoef color plot',FreqType(nff)));
    saveas(h_cfreq,sprintf('Frequency %d corrcoef color plot',FreqType(nff)),'png');
    close(h_cfreq);
end
h_meanCoef = figure('position',[200 150 1400 850]);
MeanCoefValue = squeeze(mean(FreqCorrcoef));
subplot(1,2,1)
imagesc(MeanCoefValue,[-1 1]);
colormap jet;
colorbar;
xlabel('# ROIs');
ylabel('# ROIs');
title('Mean coef value');
set(gca,'FontSize',20);

TriuMask = ones(size(Corcoefvalue));
TriuMask = logical(triu(TriuMask,1));
MeanCoefData = MeanCoefValue(TriuMask);
subplot(1,2,2)
histogram(MeanCoefData,30,'FaceColor','r','Normalization','probability','FaceAlpha',0.5);
xlabel('Corrcoef value');
ylabel('Paired-value fraction');
title('Corrcoef value distribution');

saveas(h_meanCoef,'Mean Corrcoef color plot');
saveas(h_meanCoef,'Mean Corrcoef color plot','png');
close(h_meanCoef);

save SignalCoefSave.mat MeanFreqData RawFreqData FreqCorrcoef -v7.3
cd ..;

