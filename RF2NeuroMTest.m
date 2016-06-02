function RF2NeuroMTest(RFdata,Soundarray,FrameRate,varargin)
%this function will be used for RF data analysis, and try to performing a
%neurometric function fit using given data
%since single trial type is not that much. so maybe neighboring frequenct
%can be binned together to increase single obeservation's trial number and
%reliability

if nargin<4 || isempty(varargin{1})
    AfterFrameScale=2*FrameRate;
else
    AfterFrameScale=floor(varargin{1}*FrameRate);
end
    

RFdataSize=size(RFdata);
SoundSize=size(Soundarray);

if RFdataSize(1)~=SoundSize(1)
    error('Sound types number is not the same as trial types, quit analysis.\n');
end

TrialFreqAll=Soundarray(:,1);
% TrialIntensity=Soundarray(:,2);
FreqTypes=unique(TrialFreqAll);
% IntensityTypes=unique(TrialIntensity);
TrialFreqNum=length(FreqTypes);
RFDataforPCA=zeros(TrialFreqNum,RFdataSize);

for n=1:TrialFreqNum
    SingleFreqTirals=TrialFreqAll==FreqTypes(n);
    SingleFreqData=RFdata(SingleFreqTirals,:,:);
    TrialMeanData=squeeze(mean(SingleFreqData));
    RFDataforPCA(n,:)=(max(TrialMeanData(:,FrameRate:AfterFrameScale),[],2))';
end

[~,score,~,~,explained,~]=pca(RFDataforPCA);
if sum(explained(1:3))<80
    warning('The first three component explains less than 80 percents, the pca result may not acurate.');
end

if mod(TrialFreqNum,2)
    warning('FreqType number is an odd number, will not using center freq score to do svm classification.\n');
    TrainingScore=score(:,1:3);
    TrainingScore(ceil(TrialFreqNum))=[];
    TrainingLabel=[zeros(1,floor(TrialFreqNum/2)) ones(1,floor(TrialFreqNum/2))];
    h3dPoints=figure;
    scatter3(TrainingScore(1:floor(TrialFreqNum/2),1),TrainingScore(1:floor(TrialFreqNum/2),2),TrainingScore(1:floor(TrialFreqNum/2),3),30,'ro');
    scatter3(TrainingScore(ceil(TrialFreqNum/2):end,1),TrainingScore(ceil(TrialFreqNum/2):end,2),TrainingScore(ceil(TrialFreqNum/2):end,3),30,'g*');
    legend('LeftScore','RightScore','location','northeastoutside');
    xlabel('pc1');
    ylabel('pc2');
    zlabel('pc3');
else
    TrainingScore=score(:,1:3);
    TrainingLabel=[zeros(1,TrialFreqNum/2) ones(1,TrialFreqNum/2)];
    h3dPoints=figure;
    scatter3(TrainingScore(1:(TrialFreqNum/2),1),TrainingScore(1:(TrialFreqNum/2),2),TrainingScore(1:(TrialFreqNum/2),3),30,'ro');
    scatter3(TrainingScore((1+TrialFreqNum/2):end,1),TrainingScore((1+TrialFreqNum/2):end,2),TrainingScore((1+TrialFreqNum/2):end,3),30,'g*');
    legend('LeftScore','RightScore','location','northeastoutside');
    xlabel('pc1');
    ylabel('pc2');
    zlabel('pc3');
end
saveas(h3dPoints,'PC scores scatter plot.png');
saveas(h3dPoints,'PC scores scatter plot.fig');
close(h3dPoints);

svmmodel=fitcsvm(TrainingScore(:,1:3),TrainingLabel);
[~,classscores]=predict(svmmodel,score(:,1:3));
difscore=classscores(:,2)-classscores(:,1);
fity=((difscore-min(difscore))./(max(difscore)-min(difscore)));  %rescale to [0 1]
CVSVMModel = crossval(svmmodel);  %performing cross-validation
ErrorRate=kfoldLoss(CVSVMModel);%disp kfold loss of validation
sprintf('SVM model false rate = %.2f',ErrorRate);
Octavex=log2(double(FreqTypes)/min(double(FreqTypes)));
% if mod(TrialFreqNum,2)
%     Octavex(ceil(TrialFreqNum/2))=[];
% end
hFitPoint=figure;
scatter(Octavex,fity,30,'MarkerEdgeColor','r','MarkerFaceColor','y');
title('Error Rate = %.2f',ErrorRate);
xlabel('Octave');
ylabel('Rightward Choice');
ylim([0 1]);
saveas(hFitPoint,'Fitted psycho data points.png');
saveas(hFitPoint,'Fitted psycho data points.fig');
close(hFitPoint);

save RFClassification_Result.mat svmmodel fity Octavex -v7.3
