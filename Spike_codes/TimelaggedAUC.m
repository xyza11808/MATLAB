function [LagsAll, AlgAUCAlls] = TimelaggedAUC(Data,Types,Maxlag)
% this function is used to calculate a time lagged AUC 
% If the lag value is non-zeros, a corresponded zero-shift AUC will also be
% calculated for comparison
Data = Data(:);
Types = Types(:);

% NumTrials = numel(Data);
NegLagAUCs = zeros(Maxlag+1,3); % Real AUC, threshold, shift AUC
for cLag = -Maxlag:0
    ShiftTypeVec = circshift(Types, cLag);
    NonShift_datas = Data(1:end+cLag);
    NonShift_types = Types(1:end+cLag);
    ShiftTypes = ShiftTypeVec(1:end+cLag);
    
    [NS_AUC, ~] = AUC_fast_utest(NonShift_datas, NonShift_types);
    [~,~,NS_SigValues] = ROCSiglevelGeneNew([NonShift_datas, NonShift_types],500,1,0.001);
    
    [ShiftAUC,~] = AUC_fast_utest(NonShift_datas, ShiftTypes);
    
    NegLagAUCs(cLag,:) = [NS_AUC, NS_SigValues, ShiftAUC];
end

PosLagAUCs = zeros(Maxlag,3); % Real AUC, threshold, shift AUC
for cLag = 1 : Maxlag
    ShiftTypeVec = circshift(Types, cLag);
    NonShift_datas = Data(1+cLag:end);
    NonShift_types = Types(1+cLag:end);
    ShiftTypes = ShiftTypeVec(1+cLag:end);
    
    [NS_AUC, ~] = AUC_fast_utest(NonShift_datas, NonShift_types);
    [~,~,NS_SigValues] = ROCSiglevelGeneNew([NonShift_datas, NonShift_types],500,1,0.001);
    
    [ShiftAUC,~] = AUC_fast_utest(NonShift_datas, ShiftTypes);
    PosLagAUCs(cLag,:) = [NS_AUC, NS_SigValues, ShiftAUC];
end

LagsAll = -Maxlag:Maxlag;
AlgAUCAlls = [NegLagAUCs;PosLagAUCs];


