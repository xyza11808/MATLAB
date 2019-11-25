
% ts = linspace(847,1200,11)/1000;
NumTimes = 5;
ts = linspace(800,1200,NumTimes)/1000;

ts = ts(:);
wm = 0.1;
wp = 0.1;
%%
nRepeat = 1000;
AllDatas = zeros(nRepeat,4);
for cTr = 1 : nRepeat
    %
    TsInds = randsample(NumTimes,1);
    cTs = ts(TsInds);
    AllDatas(cTr,1) = cTs;
    
    Prob_tmMean = cTs;
    Prob_tmStd = wm*cTs;
    
    prob_tm_ts = normpdf(ts,Prob_tmMean,Prob_tmStd);
    f_BLS_tm = sum(prob_tm_ts .* ts)/sum(prob_tm_ts);
    f_MLE_tm = (Prob_tmMean + randn*Prob_tmStd) * (sqrt(1+4*wm^2)-1)/(2*wm^2);
    
    te = f_BLS_tm;
    AllDatas(cTr,2) = te;
    
    Prob_teMean = te;
    Prob_te_Std = wp*te;
    tp = Prob_teMean + randn*Prob_te_Std; % generate tp values from the distribution
    AllDatas(cTr,3) = tp;
   
    MLETe = f_MLE_tm;
    MLETp = MLETe + randn*wp*MLETe;
    AllDatas(cTr,4) = MLETp;
    %
end

%%
NumTs = length(ts);
TsSampleNum = zeros(NumTs,1);
TsSampleTpValues = cell(NumTs,2); % first col is BLS, second col is MLE
TsSampleCorrectRate = cell(NumTs,2); % first col is BLS, second col is MLE
hf = figure;
hold on;

for cTs = 1 : NumTs
    cTsInds = AllDatas(:,1) == ts(cTs);
    cTs_tp = AllDatas(cTsInds,3);
    cTsNum = sum(cTsInds);
    TsSampleNum(cTs) = cTsNum;
    
    plot(ts(cTs)*ones(cTsNum,1),cTs_tp,'ko');
    TsSampleTpValues{cTs,1} = cTs_tp;
    TsSampleTpValues{cTs,2} = AllDatas(cTsInds,4);
    
    cTpCorrInds = abs(cTs_tp - ts(cTs))/ts(cTs) <= 0.1;
    cTpMLECorrInds = abs(TsSampleTpValues{cTs,2} - ts(cTs))/ts(cTs) <= 0.1;
    
    TsSampleCorrectRate{cTs,1} = cTpCorrInds;
    TsSampleCorrectRate{cTs,2} = cTpMLECorrInds;
end
%%
TpMeans = cellfun(@mean,TsSampleTpValues(:,1));
plot(ts,TpMeans,'r','linewidth',1.4);
plot(ts,ts,'c','linewidth',1.4,'linestyle','--');
    
% set(gca,'xlim',[ts(1)-0.02 ts(end)+0.02],'ylim',[ts(1)-0.02 ts(end)+0.02]);


