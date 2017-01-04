function [DisErro,DisErroMean] = DistanceBasedError(Dis,Err)
% yhis function is used to calculate the distance dependence of error rate
% distribution
if length(Dis) ~= numel(Dis)
    Dis = Dis(:);
    Err = Err(:);
end
C = unique(Dis);
DisErro = cell(length(C),1);
DisErroMean = zeros(length(C),2);
for nn = 1 : length(C)
    DisErro(nn) = {Err(Dis == C(nn))};
    DisErroMean(nn,:) = [mean(DisErro{nn}),C(nn)];
end
