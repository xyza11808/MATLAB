function [RepeatInfo,AllTimeBins] = PopuFI_Discrim_calFun(AlignedData,behavResults,frame_rate)

% https://journals.physiology.org/doi/pdf/10.1152/jn.00919.2005
% TrialUsedType
% RespDatas
TrialTypes = behavResults.Trial_Type;
RepeatInfo = cell(100,1);
AllTimeBins = 0:0.2:5;
for cRepeat = 1 : 100
    BinLength = numel(AllTimeBins);
    BinSets = round(0.2*frame_rate);
    TimeBinInfo = zeros(BinLength,3);
    for cTimeBinInds = 1 : BinLength
        cTimeBin = AllTimeBins(cTimeBinInds);
        cTimeBinStart = round(cTimeBin*frame_rate) + 1;
        cTimeBinend = BinSets + cTimeBinStart;
        cRespData = mean(AlignedData(behavResults.Action_choice ~= 2,:,cTimeBinStart:cTimeBinend),3);
        if sum(isnan(cRespData(:)))
            continue;
        end
%         cRespData = cRespData / 100;
        TrialUsedType = TrialTypes(behavResults.Action_choice ~= 2);
        RandSelectTrInds = randsample(numel(TrialUsedType),round(numel(TrialUsedType)*0.8));
        
        cRespData = cRespData(RandSelectTrInds,:);
        TrialUsedType = TrialUsedType(RandSelectTrInds);
        
        Type0_vectorMean = mean(cRespData(TrialUsedType == 0,:));
        Type1_vectorMean = mean(cRespData(TrialUsedType == 1,:));
        Type_mu_diff = (Type0_vectorMean - Type1_vectorMean)';
        Type0_covMtx = cov(cRespData(TrialUsedType == 0,:));
        Type1_covMtx = cov(cRespData(TrialUsedType == 1,:));
        
        % calculate the real data information, d^2
        Q = (Type0_covMtx+Type1_covMtx)/2;
%         Avg_cov_mtxInv = inv(Q);
        dd_raw = Type_mu_diff' * inv(Q) * Type_mu_diff;
        
        % calculate the correlation-free population information,
        % d_shuffle^2
        Qd = diag(diag(Q));
        dd_shuffle = Type_mu_diff' * inv(Qd) * Type_mu_diff;
        
        % calculate the diagnal population info, d_diag^2
        
        dd_diag = dd_shuffle.^2 / (Type_mu_diff' * inv(Qd) * Q * inv(Qd) * Type_mu_diff);
        
        if ~isnan(dd)
            TimeBinInfo(cTimeBinInds,:) = sqrt([dd_raw, dd_shuffle, dd_diag]);
        end
    end
    RepeatInfo{cRepeat} = TimeBinInfo;
end
% reshape into three dimensional matrix
% yy = cat(3,RepeatInfo{:});
