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

%%
if ~isempty(ExSweepInds)
    Used_datas(:,:,ExSweepInds) = [];
end
SweepNum = size(Used_datas,3);
%%
NeuData_permu = permute(Used_datas, [1,3,2]);
Neu1Data = squeeze(NeuData_permu(:,:,1));
Neu2Data = squeeze(NeuData_permu(:,:,2));

Neu1Traceraw = Neu1Data(:);
Neu2Traceraw = Neu2Data(:);
Neu1ST_mtx = reshape();

Targetswinds = [27,29,30,35,39];



