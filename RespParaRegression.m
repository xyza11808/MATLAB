function [ROIcoefCell,ROIPvalueCell,ROICoefIsSig,ROIfitlmData] = RespParaRegression(DataInput,RespWin,OnsetF,Frate,BehvParaMtx,varargin)
% this function is tried to fit the response calcium value using behavior
% parameters given, then try to see whether there is significant
% coefficient values regarding to corresponded behavior parameters
[nBehavTrs, nBehavParas] = size(BehvParaMtx);
PredictorStr = cellstr(num2str((1:nBehavParas)','x%0.2d'));
if nargin > 5
    if ~isempty(varargin{1}) % input the describtion of all predictors
        PredictorStr = varargin{1};
    end
end
if length(RespWin) == 1
    FrameWin = sort([OnsetF,OnsetF+round(RespWin*Frate)]);
    ftimestr = num2str((RespWin*1000),'%dms');
elseif length(RespWin) == 2
    RespWin = sort(RespWin);
    FrameWin = sort([(OnsetF+round(RespWin(1)*Frate)),(OnsetF+round(RespWin(2)*Frate))]);
    WinLeng = diff(RespWin);
    ftimestr = [num2str(RespWin(1)*1000,'%d+'),num2str(WinLeng*1000,'%dms')];
else
    error('Timewin length is incorporated with current function.');
end
nFrame = size(DataInput,3);
nDataTrs = size(DataInput,1);
if FrameWin(1) < 1
    warning('Frame range is less than 1, reassign into 1');
    FrameWin(1) = 1;
end
if FrameWin(2) > nFrame
    warning('Frame range is out of index range, reassign into %d',nFrame);
    FrameWin(2) = nFrame;
end

MtxRespData = max(DataInput(:,:,(FrameWin(1):FrameWin(2))),[],3); % response matrix, nTrials by nROIs

fprintf('Number of input behavior parameters is %d, using %d coefficients for regression.\n',nBehavParas,nBehavParas);
if nBehavTrs ~= nDataTrs
    error('Input data should have same observations as behavior trials.');
end

% calculate the regression coefficient value for each ROI
nROIs = size(MtxRespData,2);
nObserResp = size(MtxRespData,1);
ROIcoefCell = cell(nROIs,2);
ROIPvalueCell = cell(nROIs,1);
ROICoefIsSig = zeros(nROIs, nBehavParas+1);
ROIfitlmData = cell(nROIs,1);
for nROI = 1 : nROIs
    cROIdata = MtxRespData(:,nROI);
%     [b,bint] = regress(cROIdata,BehvParaMtx);
%     ROIcoefCell{nROI,1} = b;
%     ROIcoefCell{nROI,2} = bint;
    lmdata = fitlm(BehvParaMtx,cROIdata,'linear','RobustOpts','on');
    CoefCIdata = coefCI(lmdata);
    CoefpValue = lmdata.Coefficients.pValue;
    ROIcoefCell{nROI,1} = lmdata.Coefficients.Estimate;
    ROIcoefCell{nROI,2} = CoefCIdata;
    ROIfitlmData{nROI} = lmdata;
    ROIPvalueCell{nROI} = CoefpValue;
    ROICoefIsSig(nROI,:) = double(CoefpValue < 0.05);
end
save(sprintf('LRcoefDatasave%s.mat',ftimestr), 'ROIcoefCell', 'ROIPvalueCell', 'ROICoefIsSig',...
    'MtxRespData', 'BehvParaMtx', 'PredictorStr', 'ROIfitlmData', '-v7.3');

