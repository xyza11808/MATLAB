
%%
trainLabel = [1;1;1;1;0;0;0;0];
trainFeature = [1,1,1,1;2,2,2,2;3,3,3,3;4,4,4,4;1,2,3,4;2,4,6,8;3,6,8,12;4,6,12,16];
model = svmtrain(trainLabel,trainFeature);  

%%
testLabel = [1;1;0;0];
testFeature = [1,1,1,1;2,2,2,2;1,2,3,4;2,4,6,8];
[predict_label] = svmpredict(testLabel,testFeature,model);  