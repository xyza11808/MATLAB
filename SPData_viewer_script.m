% load('P:\BatchData\batch52\20180425\anm01\test01\im_data_reg_cpu\result_save\plot_save\Type5_f0_calculation\NO_Correction\mode_f_change\EstimateSPsave.mat')
cROI = 90;
close all
cROIFluoData = squeeze(data_aligned(:,cROI,:));
cROISPData = squeeze(SpikeAligned(:,cROI,:));
hf = figure('position',[100 100 350 280]);
subplot(121)
imagesc(cROIFluoData,[0 100]);

subplot(122)
imagesc(cROISPData);


yy = cROISPData(cROISPData > 1e-6);
BinaryData = cROISPData > std(yy) * 3;

%
TrialStims = double(behavResults.Stim_toneFreq(:));
[~,SortTrInds] = sort(TrialStims);
figure('position',[500 100 350 280]);
imagesc(BinaryData(SortTrInds,:))

FreqTypes = unique(TrialStims);
nFreqs = length(FreqTypes);
FreqMeanTrace = zeros(nFreqs,size(BinaryData,2));
linecolor = jet(nFreqs);
Freqstrs = cellstr(num2str(FreqTypes(:)/1000,'%.1fkHz'));
hf = figure('position',[900 100 350 280]);
hold on
linehandle = [];
for cfreq = 1 : nFreqs
    cFreqInds = TrialStims == FreqTypes(cfreq);
    FreqMeanTrace(cfreq,:) = mean(BinaryData(cFreqInds,:));
    
    hl = plot(FreqMeanTrace(cfreq,:),'linewidth',1.6,'Color',linecolor(cfreq,:));
    linehandle = [linehandle,hl];
    
end
legend(linehandle,Freqstrs,'location','NorthEast','Box','off');
