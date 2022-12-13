function [D_sqr,PerfAccu,TrainScores] = ...
    LDAclassifierFun_Score_3d(X, y, beta, varargin)
% have to make sure the labels are 1 and 2 while calling this function, so
% that we dont need to use unique function to increase time cost

% if ~exist('BoundScore','var')
%     BoundScore = 0;
% end
 BoundScore = 0;
if nargin > 3
    if ~isempty(varargin{1})
        BoundScore = varargin{1};
    end
end
% [Alluniqlabel,~,Alltruelabels] = unique(y);
Alltruelabels = y(:);
DataMtx = X;
%%
% ref from : https://www.youtube.com/watch?v=moqPyJQHR_s

% NumberLabels = length(Alluniqlabel);
% if NumberLabels > 2
%     warning('Currently cannot handled with class more than 2 (%d)',NumberLabels);
%     return;
% end

C1DataInds = Alltruelabels == 1;
C2DataInds = Alltruelabels == 2;

C1_SampleNum = sum(C1DataInds);
C2_SampleNum = sum(C2DataInds);

C1_rawData = DataMtx(C1DataInds,:,:);
C2_rawData = DataMtx(C2DataInds,:,:);

[NumTrainTrials,NumUnits,NumTimeBins] = size(DataMtx);

C1_Avg = squeeze(sum(C1_rawData)/size(C1_rawData,1));
C2_Avg = squeeze(sum(C2_rawData)/size(C2_rawData,1));
if NumUnits == 1
    C1_Avg = C1_Avg';
    C2_Avg = C2_Avg';
end
% UnitNum = size(DataMtx, 2);
C1_cov = zeros(NumUnits, NumUnits, NumTimeBins);
C2_cov = zeros(NumUnits, NumUnits, NumTimeBins);
for cBin = 1 : NumTimeBins
    C1_cov(:,:,cBin) = cov_cus(C1_rawData(:,:,cBin),[C1_SampleNum, NumUnits]);
    C2_cov(:,:,cBin) = cov_cus(C2_rawData(:,:,cBin),[C2_SampleNum, NumUnits]);
end
% MtxStableTerm = 1e-6; % served to stabilize matrix inversion
% pooled_cov = (C1_SampleNum*C1_cov + C2_SampleNum*C2_cov)/(C1_SampleNum + C2_SampleNum);
% pooled_cov = pooled_cov + eye(size(pooled_cov))*MtxStableTerm; 
% % pooled_cov = (C1_cov + C2_cov)/2;
% 
% beta = (pooled_cov)\((C1_Avg - C2_Avg))'; % hyperplane normal to beta is the classification hyperplane

% similar to number of standard distance, a value of 3 indicates the mean
% differ by 3 standard deviations. the larger value, the smaller overlaps
% D_sqr = beta' * ((C1_Avg - C2_Avg))'; % effectiveness of the discrimination, or the Mahalanobis distance between groups
Cov_test_Avg = (C1_cov+C2_cov)/2;
D_sqr = zeros(NumTimeBins,1);
TrainScores = zeros(NumTrainTrials, NumTimeBins);
for cBin = 1 : NumTimeBins
    % another method from: https://www.nature.com/articles/s41586-022-04724-y#Sec8
    D_sqr(cBin) = (beta(:,cBin)' * ((C1_Avg(:,cBin) - C2_Avg(:,cBin))))^2/(beta(:,cBin)' ...
        * Cov_test_Avg(:,:,cBin) * beta(:,cBin));
    % training data score, sign indicates class label
    TrainScores(:,cBin) = (DataMtx(:,:,cBin) - (C1_Avg(:,cBin) + C2_Avg(:,cBin))'/2)*beta(:,cBin);  
end
% fprintf('The discrimination distance is %.3f.\n',D_sqr);


% BoundScore = log(C1_SampleNum/C2_SampleNum);
Trainc1_scoreInds = TrainScores > BoundScore;
NumAlltruelabels = numel(Alltruelabels);
TrainClassLabels = nan(size(Trainc1_scoreInds));
TrainClassLabels(Trainc1_scoreInds) = 1;
TrainClassLabels(~Trainc1_scoreInds) = 2;
PerfAccu = (sum(repmat(Alltruelabels,1,NumTimeBins) == TrainClassLabels)/NumAlltruelabels*100)';



