
SumExplain=zeros(1,200);
figure;
for n=1:200
    x=rand(150,6)*100;
%     y=zscore(x');
    y=x';
    [coeff,score,latent,~,explained,~]=pca(y);
    SumExplain(n)=sum(explained(1:3));
    labelType=[0 0 0 1 1 1];
    svmmodel=fitcsvm(score(:,1:3),labelType);
    [~,classscores]=predict(svmmodel,score(:,1:3));
    difscore=classscores(:,2)-classscores(:,1);
    fity=((difscore-min(difscore))./(max(difscore)-min(difscore)));  %rescale to [0 1]
    scatter(1:6,fity);
    pause(1);
end
