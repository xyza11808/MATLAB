
cLine = PassPathline;

[~,EndInds] = regexp(cLine,'result_save');
ROIposfilePath = cLine(1:EndInds); 

    PosROIinfofiles = dir(fullfile(ROIposfilePath,'ROIinfoBU*.mat'));
    
    if ~isempty(PosROIinfofiles)
        PosInfoData = load(fullfile(ROIposfilePath,PosROIinfofiles.name));
        ROIposCell = cellfun(@mean,PosInfoData.ROIinfoBU.ROIpos,'UniformOutput',false);
        ROIposMatrix = cell2mat(ROIposCell');
        nROIs = length(PosInfoData.ROIinfoBU.ROImask);
    else
        PosROIinfofiles = dir(fullfile(ROIposfilePath,'ROIinfo*.mat'));
        PosInfoData = load(fullfile(ROIposfilePath,PosROIinfofiles.name));
        ROIinfoBU = PosInfoData.ROIinfo(1);
        ROIposCell = cellfun(@mean,ROIinfoBU.ROIpos,'UniformOutput',false);
        ROIposMatrix = cell2mat(ROIposCell');
        nROIs = length(ROIinfoBU.ROImask);
    end

%%
% MatrixmaskRaw = ones(size(PairedSigCoef));
% Matrixmask = logical(tril(MatrixmaskRaw,-1));
% 
% ReshapedVectorCoef = PairedSigCoef(Matrixmask);
% ReshapedVectorCoefP = PairedSigCoefp(Matrixmask);

ROIEucDis = pdist(ROIposMatrix); 


%%
NCDataPath = fullfile(cLine,'Popu_Corrcoef_save_NOS','TimeScale 0_1000ms noise correlation',...
    'ROIModified_coefSaveMean.mat');

NCdataStrc = load(NCDataPath);
PairedNoiseCoef = NCdataStrc.PairedROIcorr;
PairedNoiseCoefp = NCdataStrc.PairedNCpvalue;

cd(cLine);

if ~isdir('Correlation_distance_coefPlot')
    mkdir('Correlation_distance_coefPlot');
end
cd('Correlation_distance_coefPlot');

save CoefDisSave.mat PairedNoiseCoef ROIEucDis -v7.3
