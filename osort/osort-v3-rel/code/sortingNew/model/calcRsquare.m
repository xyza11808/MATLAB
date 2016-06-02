%
%calculates Rsquare value
%
%inputs:
%response -> as observed in the data
%predicted -> as predicted with some fit of a model
%
%
%returns Rsquare, SSR (sum of squares of the regression) and SST (total sum
%of squares)
%
%urut/jan05
function [Rsquare,SSR,SST,SSE] = calcRsquare( response, predicted )

%calculate Rsquare as square of correlation between predicted response and
%real response (same as R-square)
C=corrcoef([response' predicted']);
Rsquare = C(2,1).^2;

SSE=0;
SST=0;
SSR=0;

%------ the following doesn't work, unclear why
%SSE = sum( (response-predicted).^2 );
%SST = sum( (response-mean(resposnse)).^2 );
%SSR = sum( (predicted-mean(response)).^2 );
%Rsquare = SSR/SST;