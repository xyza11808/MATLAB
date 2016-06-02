function RF_NeuroMtestcontrol(RFdata,Sound,FrameRate,varargin)
%this function is used to test whether passive response to sound can exist
%an logistic classification of different sounds

freq_type=unique(Sound(:,1));
DB_type=unique(Sound(:,2));
frameScale=floor([1,2.5]*FrameRate);
OctTypes=log2(freq_type/(freq_type(1)));

SelectDBData=RFdata(Sound(:,2)==DB_type(2),:,:);
SIngleDBFreq=Sound(Sound(:,2)==DB_type(2),1);
MeanData=zeros(length(freq_type),size(RFdata,2),size(RFdata,3));
MeanDataNor=zeros(length(freq_type),size(RFdata,2),size(RFdata,3));
for n=1:length(freq_type)
    SingleFreqData=SelectDBData(SIngleDBFreq==freq_type(n),:,:);
    TempMean=squeeze(mean(SingleFreqData));
    MeanData(n,:,:)=TempMean;
%     MeanDataNor(n,:,:)=MeanData(n,:,:)/max(TempMean(:));
end

% for n=1:size(RFdata,2)   %ROI number
%     TempROIAll=squeeze(MeanData(:,n,:));
%     MeanDataNor(:,n,:) = MeanData(:,n,:)/max(TempROIAll(:));
% end

PcaMatrix=squeeze(max(MeanData(:,:,frameScale(1):frameScale(2)),[],3));  %freq by nROIs
[coeff,score,latent,~,explained,~]=pca(PcaMatrix);
if sum(explained(1:3))<80
    warning('The first three component explains less than 80 percents, the pca result may not acurate.');
end
save RandPcaResult.mat PcaMatrix coeff score latent explained -v7.3
hscore=figure;
hold on;
scatter3(score(1:ceil(length(freq_type)/2),1),score(1:ceil(length(freq_type)/2),2),score(1:ceil(length(freq_type)/2),3),'ro');
HighInds=1+ceil(length(freq_type)/2);
scatter3(score(HighInds:end,1),score(HighInds:end,2),score(HighInds:end,3),'go');
xlabel('pc1');
ylabel('pc2');
zlabel('pc3');
title('PCA score plot');
saveas(hscore,'PC_score_distribution_3d_space.png');
saveas(hscore,'PC_score_distribution_3d_space.fig');
% close(hscore);

% hsvm=figure;
labelType=[zeros(1,ceil(length(freq_type)/2)) ones(1,floor(length(freq_type)/2))];
svmmodel=fitcsvm(score(:,1:3),labelType);
sv=svmmodel.SupportVectors;
scatter3(sv(:,1),sv(:,2),sv(:,3),40,'*','p');
hold off;

[~,classscores]=predict(svmmodel,score(:,1:3));
difscore=classscores(:,2)-classscores(:,1);
fity=((difscore-min(difscore))./(max(difscore)-min(difscore)));  %rescale to [0 1]
h=figure;
hold on
scatter(OctTypes,fity,40,'r','o','LineWidth',2);
[~,bfit]=fit_logistic(OctTypes,fity);
Curve_x=linspace(min(OctTypes),max(OctTypes),500);
modelfun = @(p1,t)(p1(2)./(1 + exp(-p1(3).*(t-p1(1)))));
curve_fity=modelfun(bfit,Curve_x);
plot(Curve_x,curve_fity,'r','LineWidth',2);

%added linear fit and non-linear fit (logistic fitting) to the scatter plot
