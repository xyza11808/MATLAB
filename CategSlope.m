function slope = CategSlope(mdfit,xRange)
% used for sigmoidal function slope value calculation
CoefName = coeffnames(mdfit);
% % for g,l,u,v model slope calculation
% slope = (-1)*sqrt(2)*0.5*(mdfit.(CoefName{1})+mdfit.(CoefName{2})-1)/(sqrt(pi)*mdfit.(CoefName{4}));

% for (b1+b2./(1+exp(-(x-b3)./b4))) calculation
Data = feval(mdfit,xRange);
DataRange = max(Data) - min(Data);
slope = mdfit.(CoefName{2})/(mdfit.(CoefName{4})*4);
slope = slope/DataRange;