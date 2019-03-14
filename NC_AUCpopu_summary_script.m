
cLine = PassPathline;

ROCPath = fullfile(tline,'Stim_time_Align','ROC_Left2Right_result');
% BaseSessionPath = strrep(tline,'\Group_NC_cumulativePlot\RespGroupNCData.mat;','\');
AUCFilePath = fullfile(ROCPath,'ROC_score.mat');
% % loading the AUC data, using to define left or right selectivity
% [fn,fp,fi] = uigetfile('ROC_score.mat','Please select your AUC saved data');
% if ~fi
%     return;
% else
%     FilePath = fullfile(fp,fn);
AUCDataStrc = load(AUCFilePath);
ROCData = AUCDataStrc.ROCarea;
ROCIsRevert = AUCDataStrc.ROCRevert;
ROCABS = ROCData;
ROCABS(ROCIsRevert == 1) = 1 - ROCABS(ROCIsRevert == 1);
SigROIInds = find(ROCABS > AUCDataStrc.ROCShufflearea);
AllSigROIAUCs = ROCData(SigROIInds);
LeftSigROIAUCs = AllSigROIAUCs < 0.5;
RightSigROIAUCs = AllSigROIAUCs > 0.5;
% ROI index for left and right population
LeftSigROIAUCIndex = SigROIInds(LeftSigROIAUCs);
RightSigROIAUCIndex = SigROIInds(RightSigROIAUCs);

NoiseRespROIInds = find(ROCABS <= AUCDataStrc.ROCShufflearea);
% cd(tline);
CoefDisDataPath = fullfile(cLine,'Correlation_distance_coefPlot\CoefDisSave.mat');
cFilePath = CoefDisDataPath;
%
% % load the noise correlation data
% [NCfn,NCfp,NCfi] = uigetfile('CoefDisSave.mat','Please select the correponded Noise correlation data save file');
% if ~NCfi
%     return;
% else
%     cFilePath = fullfile(NCfp,NCfn);
NCDataStrc = load(cFilePath);
NoiseCorrData = NCDataStrc.PairedNoiseCoef;
NCMatrix = squareform(NoiseCorrData);

% calculate the correlation matrix for left and right population
LeftROINCmatrix = NCMatrix(LeftSigROIAUCIndex,LeftSigROIAUCIndex);
RightROINCmatrix = NCMatrix(RightSigROIAUCIndex,RightSigROIAUCIndex);
NosRespNCmatrix = NCMatrix(NoiseRespROIInds,NoiseRespROIInds);

LeftMaskRaw = ones(size(LeftROINCmatrix));
LeftMask = logical(tril(LeftMaskRaw,-1));
LeftROINCVector = LeftROINCmatrix(LeftMask);

RightMaskRaw = ones(size(RightROINCmatrix));
RightMask = logical(tril(RightMaskRaw,-1));
RightROINCvector = RightROINCmatrix(RightMask);

betLRNoiseCorr = NCMatrix(LeftSigROIAUCIndex,RightSigROIAUCIndex);
betLRNoiseCorrVector = betLRNoiseCorr(:);

NosRespSigNoiseCorr = NCMatrix([LeftSigROIAUCIndex(:);RightSigROIAUCIndex(:)],NoiseRespROIInds);
NosRespSigNCvec = NosRespSigNoiseCorr(:);

NosRespMaskRaw = ones(size(NosRespNCmatrix));
NosRespMask = logical(tril(NosRespMaskRaw,-1));
NosRespNCvector = NosRespNCmatrix(NosRespMask);

%
cd(cLine);


if ~isdir('./Group_NC_cumulativePlot/')
    mkdir('./Group_NC_cumulativePlot/');
end
cd('./Group_NC_cumulativePlot/');
%
%         saveas(h_all,'Different Popu Noise correlation distribution');
%         saveas(h_all,'Different Popu Noise correlation distribution','png');
%         close(h_all);
save RespGroupNCData.mat LeftSigROIAUCIndex RightSigROIAUCIndex LeftROINCVector RightROINCvector NosRespSigNCvec ...
    betLRNoiseCorrVector NCDataStrc NosRespNCvector NoiseRespROIInds -v7.3
cd ..;

