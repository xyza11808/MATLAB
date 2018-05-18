function ROIROC = TypeRespROC(DataAll,BehavStrc,ROIInds,TimeLen,StartF,FrameRate)
% this functiuon is used for calculation of choice ROC and sensory ROC
ROIROC = [];
if ~sum(ROIInds)
    return;
end
FrameScales = round(TimeLen * FrameRate)  + StartF;

cSessTrChoice = double(BehavStrc.Action_choice);
NMChoiceInds = cSessTrChoice ~= 2;
NMChoice = cSessTrChoice(NMChoiceInds);
cSessTrTypes = double(BehavStrc.Trial_Type(NMChoiceInds));
cSessTrTypes = cSessTrTypes(:);
cSessOutcomes = double(cSessTrTypes(:) == NMChoice(:));

TypeErrorNum = [sum(cSessTrTypes(:) == 0 & cSessOutcomes == 0),sum(cSessTrTypes(:) == 1 & cSessOutcomes == 0)];
if min(TypeErrorNum) < 13
    return;
end

RespDataAll = DataAll(NMChoiceInds,ROIInds,FrameScales(1):FrameScales(2));
RespData = max(RespDataAll,[],3);


nROI = size(RespData,2);
CorrRoc = zeros(nROI,1);
CorrRocThres = zeros(nROI,1);
CorrRocIsRevert = zeros(nROI,1);
ErroRoc = zeros(nROI,1);
ErroRocThres = zeros(nROI,1);
ErroRocIsRevert = zeros(nROI,1);
for cROI = 1 : nROI
    cROIData = RespData(:,cROI);
    % calculate correct Trial ROC
    CorrData = cROIData(cSessOutcomes == 1);
    CorrTypes = cSessTrTypes(cSessOutcomes == 1);
    
    [ROCSummary,LabelMeanS]=rocOnlineFoff([CorrData,CorrTypes]);
    CorrRoc(cROI)=ROCSummary;
    CorrRocIsRevert(cROI)=double(LabelMeanS);
    
    [~,~,sigvalue]=ROCSiglevelGene([CorrData,CorrTypes],500,1,0.01);
    CorrRocThres(cROI) = sigvalue;
    
    % calculate the error trials ROC
    ErroData = cROIData(cSessOutcomes == 0);
    ErroTypes = cSessTrTypes(cSessOutcomes == 0);
    
    [ROCSummary,LabelMeanS]=rocOnlineFoff([ErroData,ErroTypes]);
    ErroRoc(cROI)=ROCSummary;
    ErroRocIsRevert(cROI)=double(LabelMeanS);
    
    [~,~,sigvalue]=ROCSiglevelGene([ErroData,ErroTypes],500,1,0.01);
    ErroRocThres(cROI) = sigvalue;
end

ROIROC.CorrROCAll = [CorrRoc,CorrRocIsRevert,CorrRocThres];
ROIROC.ErroROCAll = [ErroRoc,ErroRocIsRevert,ErroRocThres];
