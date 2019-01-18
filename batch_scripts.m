clear
clc
if ismac
    GrandPath = '/Users/xinyu/Desktop/xnnData';
    xpath = genpath(GrandPath);
    nameSplit = (strsplit(xpath,':'))';
elseif ispc
    GrandPath = 'I:\ROI_data_figure';
    xpath = genpath(GrandPath);
    nameSplit = (strsplit(xpath,';'))';
end
if isempty(nameSplit{end})
    nameSplit(end) = [];
end
DirLength = length(nameSplit);
PossibleInds = cellfun(@(x) exist(fullfile(x,'ROIdataSummary.mat'),'file'),nameSplit);
PossDataPath = nameSplit(PossibleInds > 0);
nPosDirs = length(PossDataPath);



%%

for cpathid = 1 : nPosDirs
    cPath = PossDataPath{cpathid};
    cd(cPath);
    clearvars DeltaFROIData
    load('ROIdataSummary.mat');
    
    if ~isdir('Peak_ROI_plots')
        mkdir('Peak_ROI_plots');
    end
    cd('Peak_ROI_plots');
    %
    nROIs = size(DeltaFROIData,1);
    ROIPeakDataAll = cell(nROIs,1);
    for cROI = 1 : nROIs
        %
    %     cROI = 2;
    %     close
        cROIdata = DeltaFROIData(cROI,:);
        [hhf,PeakStrc] = CusLocalPeakSearchxnn(cROIdata,[],[],5);
        title(sprintf('ROI%d Trace',cROI));
        saveas(hhf,sprintf('ROI%d events finding plots',cROI));
        saveas(hhf,sprintf('ROI%d events finding plots',cROI),'png');
        close(hhf);

        ROIPeakDataAll{cROI} = PeakStrc;
        %%=
    end
    save ROIEventsSave.mat ROIPeakDataAll -v7.3
end
%%
for cpathid = 1 : nPosDirs
    cPath = PossDataPath{cpathid};
    cd(cPath);
    clearvars DeltaFROIData
    load('ROIdataSummary.mat');
    %%
    if ~isdir('Peak_ROI_plots')
        mkdir('Peak_ROI_plots');
    end
    cd('Peak_ROI_plots');
    %
    nROIs = size(DeltaFROIData,1);
    ROIPeakDataAll = cell(nROIs,1);
    for cROI = 1 : nROIs
        %
    %     cROI = 2;
    %     close
        cROIdata = DeltaFROIData(cROI,:);
        [hhf,PeakStrc] = CusLocalPeakSearchxnn(cROIdata,[],[],5);
        title(sprintf('ROI%d Trace',cROI));
        saveas(hhf,sprintf('ROI%d events finding plots',cROI));
        saveas(hhf,sprintf('ROI%d events finding plots',cROI),'png');
        close(hhf);

        ROIPeakDataAll{cROI} = PeakStrc;
        %%=
    end
    save ROIEventsSave.mat ROIPeakDataAll -v7.3
    %%
end

