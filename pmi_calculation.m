function [pmis,ProbSummary] = pmi_calculation(ROITypeInds,AreaTypesVec)
% calculate the pmi values
AreaTypes = unique(AreaTypesVec);
NumAreaType = numel(AreaTypes);
ROITypes = unique(ROITypeInds);
NumROIType = numel(ROITypes);

AreaTypeProb = zeros(NumAreaType,1);
ROITypeProb = zeros(NumROIType,1);
AreaROIJointTypeProb = zeros(NumAreaType,NumROIType);
pmis = zeros(NumAreaType,NumROIType);

for cAreaType = 1 : NumAreaType
    AreaTypeProb(cAreaType) = mean(AreaTypesVec == AreaTypes(cAreaType));
    for cROIType = 1 : NumROIType
        if cAreaType == 1
            ROITypeProb(cROIType) = mean(ROITypeInds == ROITypes(cROIType));
        end
        
        cJointProb = mean(AreaTypesVec == AreaTypes(cAreaType) & ROITypeInds == ROITypes(cROIType));
        AreaROIJointTypeProb(cAreaType,cROIType) = cJointProb;
        
        pmis(cAreaType,cROIType) = log2(cJointProb/(AreaTypeProb(cAreaType)*ROITypeProb(cROIType)));
    end
end

ProbSummary.AreaProb = AreaTypeProb;
ProbSummary.ROITypeProb = ROITypeProb;
ProbSummary.JointProb = AreaROIJointTypeProb;

        
        
