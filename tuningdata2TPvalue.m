sound=textread('H:\data\behavior\2p_data\behaviro_data\batch20\20151124\anm01\b20a01_test03_3x_rf_170um_20151124.txt');
freqType=unique(sound(:,1));
DB70data=c_save(:,:,2);  %saved data from RF analysis
[x_max,x_inds]=max(DB70data,[],2);

TuningFreq=zeros(1,length(x_inds));
for n=1:length(x_inds)
    Inds=x_inds(n);
    TuningFreq(n)=freqType(Inds);
end

%%
TuningOct=log2(freqType/4000);
labelType=[zeros(1,length(TuningOct)/2) ones(1,length(TuningOct)/2)]';
svmmodel=fitcsvm(DB70data',type);
[~,classscores]=predict(svmmodel,DB70data');
difscore=classscores(:,2)-classscores(:,1);
fity=((difscore-min(difscore))./(max(difscore)-min(difscore))); 
h3=figure;
scatter(TuningOct,fity,30,'MarkerEdgeColor','r','MarkerFaceColor','y');
saveas(h3,'RF data classification fit.png');
saveas(h3,'RF data classification fit.fig');


%%
TuningFreqOct=log2(TuningFreq/4000);
k=1;
for n=2:size(centers,1)
    for m=n:size(centers,1)
        OctDiff(k)=abs(TuningFreqOct(m)-TuningFreqOct(n));
        k=k+1;
    end
end

%%
ROIdis=pdist(centers);
[coef,p]=corrcoef(OctDiff,ROIdis);
coefValue=coef(1,2);
pValue=p(1,2);
figure;
scatter(OctDiff,ROIdis);
title(sprintf('Corr Coef = %.3f, P = %.3f',coefValue,pValue));
