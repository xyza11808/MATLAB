

cPassline = 'P:\BatchData\batch55\20180818\anm07\test03rf\im_data_reg_cpu\result_save\plot_save\NO_Correction';
PassiveTunROIStrc = load(fullfile(cPassline,'ROIglmCoefSave.mat'));
NumFreqs = length(PassiveTunROIStrc.FreqTypes);

PassRespROIInds = find(cellfun(@(x) ~isempty(x),PassiveTunROIStrc.ROIAboveThresSummary(:,1)));
RespNum = numel(PassRespROIInds);
PassRespCoefMtx = zeros(RespNum,NumFreqs);
for cR = 1 : RespNum
    cRCoefInds = PassiveTunROIStrc.ROIAboveThresSummary{PassRespROIInds(cR),1};
    cRCoefValue = PassiveTunROIStrc.ROIAboveThresSummary{PassRespROIInds(cR),2};
    if max(cRCoefInds) <= NumFreqs 
        % Only on response exists
        PassRespCoefMtx(cR,cRCoefInds) = cRCoefValue;
    elseif min(cRCoefInds) > NumFreqs
        % only off response exists
        PassRespCoefMtx(cR,cRCoefInds-NumFreqs) = cRCoefValue;
    else
        % both on and off response
        TempRespInds = zeros(2,NumFreqs);
        OnCoefIndex = cRCoefInds <= NumFreqs;
        TempRespInds(1,cRCoefInds(OnCoefIndex)) = cRCoefValue(OnCoefIndex);
        TempRespInds(2,cRCoefInds(~OnCoefIndex) - NumFreqs) = cRCoefValue(~OnCoefIndex);
        PassRespCoefMtx(cR,:) = max(TempRespInds);
    end
end


