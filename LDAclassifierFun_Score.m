function [D_sqr,PerfAccu,TrainScores] = ...
    LDAclassifierFun_Score(X, y, beta, BoundScore)

[Alluniqlabel,~,Alltruelabels] = unique(y);

DataMtx = X;
%%
% ref from : https://www.youtube.com/watch?v=moqPyJQHR_s

NumberLabels = length(Alluniqlabel);
if NumberLabels > 2
    warning('Currently cannot handled with class more than 2 (%d)',NumberLabels);
    return;
end

C1DataInds = Alltruelabels == 1;
C2DataInds = Alltruelabels == 2;

C1_rawData = DataMtx(C1DataInds,:);
C2_rawData = DataMtx(C2DataInds,:);

C1_Avg = mean(C1_rawData);
C2_Avg = mean(C2_rawData);

C1_cov = cov(C1_rawData);
C2_cov = cov(C2_rawData);

% MtxStableTerm = 1e-6; % served to stabilize matrix inversion
% pooled_cov = (C1_SampleNum*C1_cov + C2_SampleNum*C2_cov)/(C1_SampleNum + C2_SampleNum);
% pooled_cov = pooled_cov + eye(size(pooled_cov))*MtxStableTerm; 
% % pooled_cov = (C1_cov + C2_cov)/2;
% 
% beta = (pooled_cov)\((C1_Avg - C2_Avg))'; % hyperplane normal to beta is the classification hyperplane

% similar to number of standard distance, a value of 3 indicates the mean
% differ by 3 standard deviations. the larger value, the smaller overlaps
% D_sqr = beta' * ((C1_Avg - C2_Avg))'; % effectiveness of the discrimination, or the Mahalanobis distance between groups
D_sqr = (beta' * ((C1_Avg - C2_Avg))')^2/(beta' * (C1_cov+C2_cov)/2 * beta)'; % another method from: https://www.nature.com/articles/s41586-022-04724-y#Sec8
% fprintf('The discrimination distance is %.3f.\n',D_sqr);

TrainScores = (DataMtx - (C1_Avg + C2_Avg)/2)*beta;  % training data score, sign indicates class label
% BoundScore = log(C1_SampleNum/C2_SampleNum);

Trainc1_scoreInds = TrainScores > BoundScore;
TrainClassLabels = nan(numel(Alltruelabels),1);
TrainClassLabels(Trainc1_scoreInds) = 1;
TrainClassLabels(~Trainc1_scoreInds) = 2;
PerfAccu = mean(Alltruelabels == TrainClassLabels)*100;



