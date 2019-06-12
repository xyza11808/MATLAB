[fn,fp,fi] = uigetfile('*.tif','Please select the tiff file for current analysis','MultiSelect','on');
if ~fi
    return;
end
cd(fp);
if ~iscell(fn)
    nf = 1;
    Usedfn = {fn};
else
    nf = length(fn);
    Usedfn = fn;
end

[ROIfn,ROIfp,ROIfi] = uigetfile('ROIinfoData.mat','Please select the ROI data');
if ~ROIfi
    return;
end

ROIInfoStrc = load(fullfile(ROIfp,ROIfn));
%%
% Extract ROI data from input tif file
TifFileDataAll = cell(nf,2);
for ccf = 1 : nf
    
    cfPath = fullfile(fp,Usedfn{ccf});
    
    TifFileDataAll{ccf,1} = cfPath;
    
    [IIm,~] = load_scim_data(cfPath);
    
    NumFrames = size(IIm,3);
    nROIs = length(ROIInfoStrc.ROIInfoDatas);
    ROIDataAlls = zeros(nROIs,NumFrames);
    for cR = 1 : nROIs
        cRMask = ROIInfoStrc.ROIInfoDatas(cR).ROIMask;
        cRPixelNum = sum(sum(cRMask));
        
        cMask3D = repmat(cRMask,1,1,NumFrames);
        cRDataMtx = reshape(IIm(cMask3D),cRPixelNum,NumFrames);
        
        ROIDataAlls(cR,:) = mean(double(cRDataMtx));
    end
    TifFileDataAll{ccf,2} = ROIDataAlls;
end

%%
save FileDataAll.mat TifFileDataAll -v7.3

