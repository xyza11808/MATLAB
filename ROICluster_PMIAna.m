function [pmi_value,pmi_shuf,TypeProb] = ROICluster_PMIAna(ROICenters,ROIRespType,IsSigROIs,varargin)
% using pmi analysis to test whether different types of ROI is clustered or
% not
% Ref: The Spatial Structure of Neural Encoding in Mouse Posterior Cortex during Navigation
AreaTypeVec = [];
if nargin > 3
    if ~isempty(varargin{1})
        % if area index was given
        AreaTypeVec = varargin{1};
    end
end

SigROIcenters = ROICenters(IsSigROIs,:);
SigROIROIRespType = ROIRespType(IsSigROIs);

if isempty(AreaTypeVec)
    % if no area type index was given, calculate the default 2-class area
    % classification
    
    if numel(unique(SigROIROIRespType)) ~= 2
        error('Only two class Classification problem can be handled by area type self-generation.');
    end
    mmdl = fitcsvm(SigROIcenters,SigROIROIRespType,'KernelFunction','rbf','BoxConstraint',1);
    AreaTypeVec = predict(mmdl,SigROIcenters);
end

[pmi_value,TypeProb] = pmi_calculation(SigROIROIRespType,AreaTypeVec);

NumShufRepeat = 1000;
pmishufValues = cell(NumShufRepeat,1);
parfor cShuf = 1 : NumShufRepeat
    cShufRespType = Vshuffle(SigROIROIRespType);
    [cpmi,~] = pmi_calculation(cShufRespType,AreaTypeVec);
    pmishufValues{cShuf} = cpmi;
end

pmi_shuf = cat(3,pmishufValues{:});

