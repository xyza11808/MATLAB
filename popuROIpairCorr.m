function PairedROIcorr = popuROIpairCorr(SmoothData,TrialStims,AlignedF,FrameRate,varargin)
% this function is used for calculation of the population noise correlation
% for each ROI pair, using methods proposed by Yanhe Liu and Ninglong Xu
% 2016-12-27

[TrNum,~,nFrame] = size(SmoothData);
if TrNum ~= length(TrialStims)
    error('Trial data is unequal from given stimulus number, quit analysis.');
end
TimeWin = 1.5;
if nargin > 4
    if ~isempty(varargin{1})
        TimeWin = varargin{1};
    end
end
RespCalFun = 'Mean';
if nargin > 5
    if ~isempty(varargin{2})
        RespCalFun = varargin{2};
    end
end
ZscoreMethod = 'Modified';
if nargin > 6
    if ~isempty(varargin{3})
        ZscoreMethod = varargin{3};
    end
end
if length(TimeWin) == 1
    FrameScale = sort([(AlignedF+1),(AlignedF + round(TimeWin*FrameRate))]);
elseif length(TimeWin) == 2
    FrameScale = sort([(AlignedF+round(TimeWin(1)*FrameRate)),(AlignedF + round(TimeWin(2)*FrameRate))]);
end
if FrameScale(1) < 1
    if FrameScale(2) < 1
        error('Error trial selection range.');
    end
    fprintf('Select frame scale lower bound less than 1, reset to 1.\n');
    FrameScale(1) = 1;
end
if FrameScale(2) > nFrame
    if FrameScale(1) > nFrame
        error('Error Triasl selection range.');
    end
    fprintf('Select frame scale upper bound larger than %d, reset to %d.\n',nFrame,nFrame);
    FrameScale(2) = nFrame;
end
switch RespCalFun
    case 'Mean'
        RespMatrix = mean(SmoothData(:,:,FrameScale(1):FrameScale(2)),3);
        RespMatrix = squeeze(RespMatrix);
    case 'Max'
        RespMatrix = max(SmoothData(:,:,FrameScale(1):FrameScale(2)),[],3);
    otherwise
        error('Error response calculation function.');
end

TrialStim = double(TrialStims);
StimTypes = unique(TrialStim);
nStimtype = length(StimTypes);
zNormData = zeros(size(RespMatrix));
k = 1;
for nST = 1 : nStimtype
    cStim = StimTypes(nST);
    cStimTrInds = TrialStims == cStim;
    nTrials = sum(cStimTrInds);
    cStimTrData = RespMatrix(cStimTrInds,:);   %nTrials-by-nROI matrix
    
    switch ZscoreMethod
        case 'Modified'
            % normalization using modified z-score
            ROImean = mean(cStimTrData);
            ROImad = mad(cStimTrData,1);
            ROIstdEstimate = repmat((ROImad*1.4826),nTrials,1);
            if sum(ROImad == 0)
                ZerosMADInds = ROImad == 0;
                ROIextraMAD = 1.253*mad(cStimTrData(:,ZerosMADInds));
                ROIstdEstimate(:,ZerosMADInds) = repmat(ROIextraMAD,nTrials,1);
            end   
            ZscoredData = (cStimTrData - repmat(ROImean,nTrials,1)) ./ ROIstdEstimate;
        case 'normal'
            ZscoredData = zscore(cStimTrData);
        otherwise
            error('Undefined zscore calculation method');
    end
    zNormData(k:(k+nTrials-1),:) = ZscoredData;
    k = k + nTrials;
end
%%
ROIcorrlation = corrcoef(zNormData);
MatrixmaskRaw = ones(size(ROIcorrlation));
Matrixmask = logical(triu(MatrixmaskRaw,1));
PairedROIcorr = ROIcorrlation(Matrixmask);
%%

if ~isdir('./Popu_Corrcoef_save/')
    mkdir('./Popu_Corrcoef_save/');
end
cd('./Popu_Corrcoef_save/');

h_PairedCorr = figure('position',[200 200 800 600]);
hist(PairedROIcorr,20);
xlabel('Coef value');
ylabel('Cell Count');
title(sprintf('Mean Corrcoef value = %.4f',mean(PairedROIcorr)));
set(gca,'FontSize',20);
saveas(h_PairedCorr,sprintf('Population modifired zscored %s corrcoef distribution',RespCalFun));
saveas(h_PairedCorr,sprintf('Population modifired zscored %s corrcoef distribution',RespCalFun),'png');
close(h_PairedCorr);

save(sprintf('ROIcoefSave%s.mat',RespCalFun), 'PairedROIcorr', '-v7.3');
cd ..;
