
TargetDir = 'E:\tempdata\zy_SPdata'; % this shoud be the matfile save path
TifDataPath = fullfile(TargetDir,'..'); 
TifFiles = dir(fullfile(TifDataPath,'*dftReg*.tif'));
NumTifFiles = length(TifFiles);

% load mat file data
CasigDataPath = dir(fullfile(TargetDir,'CaTrialsSIM*.mat'));
CasigDataFull = fullfile(TargetDir,CasigDataPath(1).name);
CasigDataStrc = load(CasigDataFull);

if length(CasigDataStrc.SavedCaTrials.f_raw) ~= NumTifFiles
    error('Inconsistant number of files in tif and mat file');
end

ROImasks = CasigDataStrc.SavedCaTrials.ROIinfo.ROImask;
ROIposs = CasigDataStrc.SavedCaTrials.ROIinfo.ROIpos;
Total_ROIs = CasigDataStrc.SavedCaTrials.nROIs;
ALLROImask = ROImasks{1};
for cR = 2 : Total_ROIs
    ALLROImask = ALLROImask + ROImasks{cR};
    ALLROImask(ALLROImask > 1) = 1;
end

FSize = size(ALLROImask);
[LabelNPmask,Labels]=SegNPGeneration(FSize,ROIposs,ROImasks,ALLROImask);


SegNPDataAll = cell(NumTifFiles,1);
for cR = 1 : NumTifFiles
    cTifFileName = TifFiles(cR).name;
    fprintf('Loading tif file %s...\n',cTifFileName);
    [im,~] = load_scim_data(fullfile(TifDataPath,cTifFileName));
    LabelSegNPData = SegNPdataExtraction(im,LabelNPmask);
    SegNPDataAll{cR} = LabelSegNPData;
end

% Copyfile(CasigDataFull,fullfile(CasigDataPath,[CasigDataPath(1).name(1 : end-4),'copy.mat']));
CasigDataStrc.SavedCaTrials.SegNPdataAll = SegNPDataAll;
 
 SavedCaTrials = CasigDataStrc;
 save([CasigDataPath(1).name(1 : end-4),'update.mat'],'SavedCaTrials','-v7.3');
 



