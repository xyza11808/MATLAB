function [AUC1] = AUC_fast_utest(y_trues,y_labels)
% Ref: https://johaupt.github.io/roc-auc/model%20evaluation/Area_under_ROC_curve.html

n1 = sum(y_labels == 1);
n0 = numel(y_labels) - n1;

% get the order of real values
% [~,orders] = sort(y_trues);
% [~, ranks] = sort(orders);

% the upper two lines could be replaced with following line
ranks = tiedrank(y_trues);

U1 = sum(ranks(y_labels == 1)) - n1*(n1 + 1)/2;
% U0 = sum(ranks(y_labels == 0)) - n0*(n0 + 1)/2;

AUC1 = U1/(n1 * n0);
% AUC0 = U0/(n1 * n0);



