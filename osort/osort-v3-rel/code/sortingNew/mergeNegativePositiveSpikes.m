%
%merges negative and positive spikes together
%
%urut/april04
function [allSpikes,allTimestamps] = mergeNegativePositiveSpikes(OKspikesPositive, OKspikesNegative, OKtimestampsPositive, OKtimestampsNegative)

allSpikesAndTimestamps = zeros( length(OKtimestampsPositive)+length(OKtimestampsNegative), 257);

allSpikesAndTimestamps(1:length(OKtimestampsPositive),1) = OKtimestampsPositive';
allSpikesAndTimestamps(length(OKtimestampsPositive)+1:end,1) = OKtimestampsNegative';

allSpikesAndTimestamps(1:length(OKtimestampsPositive),2:end) = OKspikesPositive;
allSpikesAndTimestamps(length(OKtimestampsPositive)+1:end,2:end) = OKspikesNegative;


allSpikesAndTimestamps = sort(allSpikesAndTimestamps, 1);

allSpikes=allSpikesAndTimestamps(:,2:end);
allTimestamps=allSpikesAndTimestamps(:,1);
