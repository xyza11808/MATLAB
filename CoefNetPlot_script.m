% scripts for network connection plot
% will call function ROIConnectNetPlot() for network connection plots
clear
clc
% load ROI position file
[fn,fp,fi] = uigetfile('*.mat','Please select the ROI position containing file');
if ~fi
    return;
else
    cDataPath = fullfile(fp,fn);
    cd(fp);
    ROIinfoDataStrc = load(cDataPath);
    if isfield(ROIinfoDataStrc,'ROIinfoBU')
        ROIinfoData = ROIinfoDataStrc.ROIinfoBU;
    elseif isfield(ROIinfoDataStrc,'ROIinfo')
        ROIinfoData = ROIinfoDataStrc.ROIinfo;
    else
        error('No ROIinfo data exists, please check you input file');
    end
end
%%
% load ROI Signal coefficient value file
[fn,fp,fi] = uigetfile('SignalCorrSave.mat','Please select you ROI signal correlation coefficient value file');
if ~fi
    return;
else
    cSCpath = fullfile(fp,fn);
    ROISCDataStrc = load(cSCpath);
    ROISCData = ROISCDataStrc.PairedROISigcorr;
end

%%
% load noise correlation coefficient value file data
[fn,fp,fi] = uigetfile('ROIModified_coefSaveMean.mat','Please select you ROI noise correlation coefficient value file');
if ~fi
    return;
else
    cSCpath = fullfile(fp,fn);
    ROISCDataStrc = load(cSCpath);
    ROISCData = ROISCDataStrc.PairedROIcorr;
end

%%
% plot the correlation matrix and try to sort it out
% load noise correlation coefficient value file data
clear
clc
[fn,fp,fi] = uigetfile('ROIModified_coefSaveMean.mat','Please select you ROI noise correlation coefficient value file');
if ~fi
    return;
else
    cNCpath = fullfile(fp,fn);
    ROINCDataStrc = load(cNCpath);
    ROINCData = ROINCDataStrc.PairedROIcorr;
end
cPath = pwd;
cd(fp);
ROINCMatrix = squareform(ROINCData);
AddMatrix = diag(ones(size(ROINCMatrix,1),1));
AddROINCMatrix = ROINCMatrix + AddMatrix;
h_matrixPlot = figure;
imagesc(AddROINCMatrix,[-1 1]);
colormap jet;
xlabel('# ROIs');
ylabel('# ROIs');
title('Noise Correlation Coefficient');
saveas(h_matrixPlot,'Noise correlation color plot');
saveas(h_matrixPlot,'Noise correlation color plot','png');
close(h_matrixPlot);

ROICoefSum = sum(AddROINCMatrix);
[~,ROIsortSeq] = sort(ROICoefSum);
h_matrixSort = figure;
imagesc(AddROINCMatrix(ROIsortSeq,ROIsortSeq),[-1 1]);
colormap jet;
xlabel('# ROIs');
ylabel('# ROIs');
title('Noise Correlation Coefficient');
saveas(h_matrixSort,'Noise correlation sorted color plot');
saveas(h_matrixSort,'Noise correlation sorted color plot','png');
close(h_matrixSort);

cd(cPath);

%%
% load ROI groups index
% save RespGroupNCData.mat LeftSigROIAUCIndex RightSigROIAUCIndex LeftROINCVector RightROINCvector betLRNoiseCorrVector -v7.3
[fn,fp,fi] = uigetfile('RespGroupNCData.mat','Please select your Groupwised signal correlation data');
if ~fi
    return;
else
    cGroupWiseDatapath = fullfile(fp,fn);
    GroupIndexStrc = load(cGroupWiseDatapath);
    LeftROIindex = GroupIndexStrc.LeftSigROIAUCIndex;
    RightROIindex = GroupIndexStrc.RightSigROIAUCIndex;
    
    nROIs = length(ROIinfoData(1).ROImask);
    % ROIindexAll = 1 : nROIs;
    ROIinputIndex = zeros(nROIs,1);
    ROIinputIndex(LeftROIindex) = -1; 
    ROIinputIndex(RightROIindex) = 1;
end

%%
% call plot function
CorrThres = 0.2;
if ~exist('ROIinputIndex','var')
    h_net = ROIConnectNetPlot(ROIinfoData,ROISCData,[],CorrThres);
else
    h_net = ROIConnectNetPlot(ROIinfoData,ROISCData,ROIinputIndex,CorrThres);
end
saveas(h_net,'Signal correlation connection network');
saveas(h_net,'Signal correlation connection network','png');
close(h_net);
%
% call plot function, 3d plot
if ~exist('ROIinputIndex','var')
    h_net = ROIConnectNetPlot(ROIinfoData,ROISCData,[],CorrThres,1);
else
    h_net = ROIConnectNetPlot(ROIinfoData,ROISCData,ROIinputIndex,CorrThres,1);
end
saveas(h_net,'Signal correlation 3d connection network');
saveas(h_net,'Signal correlation 3d connection network','png');
close(h_net);

%%
% call plot function
CorrThres = 0.5;
if ~exist('ROIinputIndex','var')
    h_net = ROIConnectNetPlot(ROIinfoData,ROISCData,[],CorrThres);
else
    h_net = ROIConnectNetPlot(ROIinfoData,ROISCData,ROIinputIndex,CorrThres);
end
saveas(h_net,'Noise correlation connection network');
saveas(h_net,'Noise correlation connection network','png');
close(h_net);
%
% call plot function, 3d plot
if ~exist('ROIinputIndex','var')
    h_net = ROIConnectNetPlot(ROIinfoData,ROISCData,[],CorrThres,1);
else
    h_net = ROIConnectNetPlot(ROIinfoData,ROISCData,ROIinputIndex,CorrThres,1);
end
saveas(h_net,'Noise correlation 3d connection network');
saveas(h_net,'Noise correlation 3d connection network','png');
close(h_net);