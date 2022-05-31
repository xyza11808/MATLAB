function varargout = AUC_fast_utest(y_values,y_labels)
% Ref: https://johaupt.github.io/roc-auc/model%20evaluation/Area_under_ROC_curve.html
if ~exist('y_labels','var') && size(y_values,2) == 2
    y_labels = y_values(:,2);
    y_values = y_values(:,1);
end

n1 = sum(y_labels == 1);
n0 = numel(y_labels) - n1;

% get the order of real values
% [~,orders] = sort(y_trues);
% [~, ranks] = sort(orders);

% the upper two lines could be replaced with following line
ranks = tiedrank(y_values);

U1 = sum(ranks(y_labels == 1)) - n1*(n1 + 1)/2;
% U0 = sum(ranks(y_labels == 0)) - n0*(n0 + 1)/2;

AUC1 = U1/(n1 * n0);
% AUC0 = U0/(n1 * n0);
pos_yDatas = y_values(y_labels == 1);
neg_yDatas = y_values(y_labels == 0);
posLabel_mean = sum(pos_yDatas)/numel(pos_yDatas);
negLabel_mean = sum(neg_yDatas)/numel(neg_yDatas);

IsmeanRev = posLabel_mean < negLabel_mean;
if IsmeanRev
    AUC1 = 1 - AUC1;
end

if nargout == 1
    varargout = {[AUC1, IsmeanRev]};
elseif nargout == 2
    varargout = {AUC1, IsmeanRev};
end

