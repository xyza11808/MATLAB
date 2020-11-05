SPRespData = sum(SpikeAligned(:,:,(start_frame+1):(start_frame+frame_rate)), 3);
Freqs = behavResults.Stim_toneFreq(:);
FreqTypes = unique(Freqs);
FreqIndexMtx = double(repmat(Freqs(:), 1, numel(FreqTypes)) == repmat(FreqTypes', numel(Freqs), 1));
% figure;imagesc(FreqIndexMtx)
ZSSPData = zscore(SPRespData);
% figure;imagesc(ZSSPData)
% figure;imagesc(ZSSPData,[0 2])
RandIns = CusRandSample(Freqs,round(0.7*numel(Freqs)));
TrainingInds = false(numel(Freqs), 1);
TrainingInds(RandIns) = true;

Training_data = ZSSPData(TrainingInds,:);
Training_IndsMtx = FreqIndexMtx(TrainingInds,:);
Testing_data = ZSSPData(~TrainingInds,:);
Testing_IndsMtx = FreqIndexMtx(~TrainingInds,:);

%% training

[T,P,U,Q,B,W] = pls (Training_data,Training_IndsMtx);

%% testing
YPredTest = Testing_data * P * B * Q';





