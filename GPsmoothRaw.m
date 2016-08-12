function [SmoothRawData,UpdateROIStd] = GPsmoothRaw(RawData,varargin)
% this function is to using gaussian process regression analysis method to fit
% noise raw data and return a smooth curve compared with raw data
isSTDinput = 0;
[TrialNum,ROINum,FrameNum] = size(RawData);
if nargin > 1
    ROIstd = varargin{1}; % use given ROI's std if given additional input
    isSTDinput = 1;
end

SmoothData = zeros(TrialNum,ROINum,FrameNum);
NewROIstd = zeros(TrialNum,ROINum);
t_start = tic;
if ~isSTDinput
    
    parfor nROI = 1 : ROINum
        cData = squeeze(RawData(:,nROI,:));
        for nTr = 1 : TrialNum
            SmoothTrace = smooth(cData(nTr,:),5,'sgolay',3);
            ResdueNoise = (cData(nTr,:))' - SmoothTrace;
            Sigma0 = std(ResdueNoise);
            pgmodelNew = fitrgp((1:FrameNum)',cData(nTr,:),'Basis','linear','FitMethod','exact','PredictMethod','exact',...
                'Sigma',Sigma0);
            NewYNew = resubPredict(pgmodelNew);
            SmoothData(nTr,nROI,:) = NewYNew;
            NewROIstd(nTr,nROI) = pgmodelNew.Sigma;
        end
    end
else
    parfor nROI = 1 : ROINum
        cData = squeeze(RawData(:,nROI,:));
        for nTr = 1 : TrialNum
%             SmoothTrace = smooth(cData(nTr,:),5,'sgolay',3);
%             ResdueNoise = cData(nTr,:) - SmoothTrace;
            Sigma0 = ROIstd(nROI);
            pgmodelNew = fitrgp((1:FrameNum)',cData(nTr,:),'Basis','linear','FitMethod','exact','PredictMethod','exact',...
                'Sigma',Sigma0);
            NewYNew = resubPredict(pgmodelNew);
            SmoothData(nTr,nROI,:) = NewYNew;
            NewROIstd(nTr,nROI) = pgmodelNew.Sigma;
        end
    end
end
SmoothRawData = SmoothData;  % this smoothed data can be used for onset time estimation, peak duration and population analysis as denoised raw data
UpdateROIStd = mean(NewROIstd);
s_end = toc(t_start);
fprintf('Gaussian process regression analysis complete in %.4f seconds.\n',s_end);
