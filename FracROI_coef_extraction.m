clear
clc

[coeffn,coeffp,coeffi] = uigetfile('*.mat','Please select the ROI correlation coefficient data save file');
if ~coeffi
    error('Please select the needed file');
else
    CoefData = load(fullfile(coeffp,coeffn));
    cd(coeffp);
    MatrixCoefData = squareform(CoefData.PairedROIcorr);
    MatrixCoefP = squareform(CoefData.PairedNCpvalue);
end

[ROIindsfn,ROIindsfp,ROIindsfi] = uigetfile('SessionSumData.mat','Please select the summary plot data save file');
if ~ROIindsfi
    error('ROI maxium response inds is needed.');
else
    SumRespData = load(fullfile(ROIindsfp,ROIindsfn));
    RespData = SumRespData.DataNor;
    [~,maxInds] = max(RespData,[],2);
    TaskAlignF = SumRespData.alignF;
    TaskFrate = SumRespData.FrameRate;
end

%
ROIinds = 1 : size(RespData,1);
FirstCompTimeScale = [0 1.5];
SecondCompTimeScale = [1.5 3];
FirstCompFScale = round(FirstCompTimeScale*TaskFrate) + TaskAlignF;
SecondCompFScale = round(SecondCompTimeScale*TaskFrate) + TaskAlignF;
FirstCompROIs = find((maxInds > (FirstCompFScale(1)+1)) & (maxInds < FirstCompFScale(2)));
SecondCompROIs = find((maxInds > (SecondCompFScale(1)+1)) & (maxInds < SecondCompFScale(2)));
fprintf('Total %d first response peak ROIs, and %d second response peak exist within current session.\n',...
    length(FirstCompROIs),length(SecondCompROIs));

if isempty(FirstCompROIs)
    FirstCCoef = [];
else
    FirstCCoef = MatrixCoefData(FirstCompROIs,FirstCompROIs);
end

if isempty(SecondCompROIs)
    SecondCCoef = [];
else
    SecondCCoef = MatrixCoefData(SecondCompROIs,SecondCompROIs);
end
%
save ComponentCoefSave.mat FirstCCoef FirstCompROIs SecondCCoef SecondCompROIs MatrixCoefData -v7.3

%
FirstCMaskRaw = ones(size(FirstCCoef));
FirstCMask = logical(triu(FirstCMaskRaw,1));
FirstCROIcorr = FirstCCoef(FirstCMask);

SecondCMaskRaw = ones(size(SecondCCoef));
SecondCMask = logical(triu(SecondCMaskRaw,1));
SecondCROIcorr = SecondCCoef(SecondCMask);

% hhf = figure('position',[300 350 1300 620]);
% subplot(1,2,1)
% hist(FirstCROIcorr,25);
% title(sprintf('First component mean coef = %.3f',mean(FirstCROIcorr)));
% 
% subplot(1,2,2)
% hist(SecondCROIcorr,25);
% title(sprintf('Second component mean coef = %.3f',mean(SecondCROIcorr)));

%
[Passcoeffn,Passcoeffp,Passcoeffi] = uigetfile('*.mat','Please select the Passive ROI correlation coefficient data save file');
if Passcoeffi
    PassDataStrc = load(fullfile(Passcoeffp,Passcoeffn));
    MatrixPCoefData = squareform(PassDataStrc.PairedROIcorr);
    MatrixPCoefP = squareform(PassDataStrc.PairedNCpvalue);
end

PassFirstCCoefM = MatrixPCoefData(FirstCompROIs,FirstCompROIs);
PassSecondCCoefM = MatrixPCoefData(SecondCompROIs,SecondCompROIs);
PassFirstCCoef = PassFirstCCoefM(FirstCMask);
PassSecondCCoef = PassSecondCCoefM(SecondCMask);

save CompCoefSavePassTask.mat FirstCCoef FirstCompROIs SecondCCoef SecondCompROIs ...
    SecondCROIcorr FirstCROIcorr MatrixCoefData PassFirstCCoef PassSecondCCoef -v7.3

hCompF = figure('position',[200 100 1550 900]);
subplot(2,2,1)
hist(FirstCROIcorr,25);
title(sprintf('First component mean coef = %.3f,Task',mean(FirstCROIcorr)));

subplot(2,2,2)
hist(SecondCROIcorr,25);
title(sprintf('Second component mean coef = %.3f, Task',mean(SecondCROIcorr)));

subplot(2,2,3)
hist(PassFirstCCoef,25);
title(sprintf('First component mean coef = %.3f,Pass',mean(PassFirstCCoef)));

subplot(2,2,4)
hist(PassSecondCCoef,25);
title(sprintf('Second component mean coef = %.3f,Pass',mean(PassSecondCCoef)));

saveas(hCompF,'Task and passive compare plot save');
saveas(hCompF,'Task and passive compare plot save','png');
% close(hCompF);
