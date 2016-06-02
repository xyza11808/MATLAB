TrialNum = size(FChangeData,1);
ROINum = size(FChangeData,2);
TrialLen = size(FChangeData,3);
nSpikes = zeros(size(FChangeData));

V.Ncells = 1;
V.T = TrialLen;
V.Npixels = 1;
V.dt = 1/29;

for nr = 1 : ROINum
    cROIdata = squeeze(FChangeData(:,nr,:));
    cROIstd = 1.4826*mad(reshape(cROIdata',1,[]),1);
    P.sig = cROIstd;
    P.lam = 10;
    for nTrial = 1 : TrialNum
        cTrace = cROIdata(nTrial,:);
        cTrace(1:5) = mean(cTrace(1:5));
         [n_best,~,~,~]=fast_oopsi(cTrace,V,P);
         n_best(1:5) = 0;
         n_best = n_best / V.dt;
         nSpikes(nTrial,nr,:) = n_best;
    end
end

%%
%sort by stimOnset and plot it out
