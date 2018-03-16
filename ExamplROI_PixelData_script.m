
[fn,fp,fi] = uigetfile('*.tif','Please select your tif file path');
if ~fi
    return;
end
CurrentPath = pwd;
cd(fp);
files = dir('*.tif');
fnBase = fn(1:end-7);
nfs = length(files);
fprintf('Totally %d files will be processed.\n',nfs);
%%
cROI = 5;
[SessROIinfon,SessROIinfop,~] = uigetfile('*.mat','Please select ROI info file');
ROIinfoStrc = load(fullfile(SessROIinfop,SessROIinfon));
cROImask = ROIinfoStrc.ROIinfoBU{cROI};
nPixels = length(find(cROImask));

%%
ROIpixelData = cell(nfs,1);
parfor cf = 1 : nfs
    cfName = sprintf('%s%03d.tif',fnBase,cf);
    [IMdata, ~] = load_scim_data(cfName);
    nFrame = size(IMdata,3);
    CfnMask = repmat(cROImask,1,1,nFrame);
    cMaskData = reshape(IMdata(CfnMask),nPixels,nFrame);
    ROIpixelData{cf} = cMaskData;
end

