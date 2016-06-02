function RandROIClassif(varargin)
%this functin is used to analysis the ROI response result from function
%AllDataExtraTest, using variable name ROITuning to do the classification

if nargin<1
    [filename,filepath,~]=uigetfile('*.mat','Select your two photon imaging data with alignment');
    cd(filepath);
    [im,~]=load_scim_data(filename);
    [filename,filepath,~]=uigetfile('*.mat','Select your ROI info data');
    load(fullfile(filepath,filename));
    [filename,filepath,~]=uigetfile('*.mat','Select your ROI t-test result data');
    load(fullfile(filepath,filename));
else
    im=varargin{1};
    ROIinfo=varargin{2};
    ROITuning=varargin{3};
end

    ROIPos=ROIinfo(1).ROIpos;
    EmptyROI=cellfun(@isempty,ROIPos);
    AllROImask=ROIinfo(1).ROImask;
    if ~isempty(EmptyROI)
        AllROImask(EmptyROI)=[];
    end

    if ndims(im)==3
        im=mean(im,3);
    end
    
%%
%only sound response will be considered for now
SoundTuning=ROITuning(:,1);
SingleFreqTV=zeros(size(SoundTuning));
%two maps will be generated, one if the only plot of single freq tuning plot, and the other one will be trial side tuning plot
SingleFreqTInds=SoundTuning>2;  %all the single tuning inds, value will be in frequency form (>8000)
SingleFreqTV(SingleFreqTInds)=SoundTuning(SingleFreqTInds);
ColormapGenerate(im,ROIinfo,SingleFreqTV);  %some modification might be needed to fit for this plot in this function

TrialTypeTV=zeros(size(SoundTuning));
TrialTypeInds=SoundTuning<=2;  %Trial type plots for trial type tuning ROIs
TrialTypeTV(TrialTypeInds)=SoundTuning(TrialTypeInds);
ColormapGenerate(im,ROIinfo,TrialTypeTV);  

%%
%performing some quatitive analysis
