
%load rf active neuron inds from former analysis
[fn,fpath,~]=uigetfile('rfSigROis.mat','Select RF test ROI responsive inds');
xx=load(fullfile(fpath,fn));
testInds = sum(xx.rfRespInds,2) > 0;

%load 2afc active neuron inds
[fn,fpath,~]=uigetfile('ROI_response_summary.mat','Select 2afc test ROI responsive inds');
yy=load(fullfile(fpath,fn));
AFCSigInds = sum(yy.resp_inds,2) > 0;

%load image data for background plot
[fn,fp,~] = uigetfile('*.tif','Select one aligned tif file for background plot');
[InputData,~] = load_scim_data(fullfile(fp,fn));

%load sound stimluli file
[fn,fp,~] = uigetfile('*.mat','Select ROIinfo file');
zz = (fullfile(fp,fn));
if isfield(zz,'ROIinfo')
    ROImask = zz.ROIinfo(1).ROImask;
elseif isfield(zz,'ROIinfoBU')
    ROImask = zz.ROIinfoBU;
end
    
[sumNewMask,PlotMap] = RF_2afc_active_plot(ROImask,testInds,AFCSigInds);

ROI_graymap_label(InputData,sumNewMask,PlotMap);