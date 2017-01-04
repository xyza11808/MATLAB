function varargout = SvmWeighsPlot(weightsAll,varargin)
% this function is used for plot SVM weights and returns ROIs with
% significant effects to population results

Northres = 0.2;
if nargin > 1
    if isempty(varargin{1})
        Northres = varargin{1};
    end
end
RealMean = mean(weightsAll);
WeightsSign = sign(RealMean);
MeanWegtAll = abs(RealMean);
MeanWegtAll = MeanWegtAll / max(MeanWegtAll);
STDWegtAll = std(weightsAll) / max(MeanWegtAll);
% disp(mean(STDWegtAll));
sigvalueInds = find((MeanWegtAll - STDWegtAll) > Northres);
sigValueSign = WeightsSign(sigvalueInds);
SignedROIs = sigValueSign .* sigvalueInds; %negtive value as contribute to left choice, positive for right choice
SIgROIweiValue = MeanWegtAll(sigvalueInds); %absolute weight value 
fprintf('%.3f of total ROIs have weights larger than given threshold.\n',length(sigvalueInds)/length(MeanWegtAll));
f_weights = figure('position',[250 180 1150 880]);
plot(MeanWegtAll,'k','LineWidth',1.7);
line([1 size(weightsAll,2)],[Northres Northres],'color',[.8 .8 .8],'LineWidth',1.6,'LineStyle','--');
xlim([0 size(weightsAll,2)+1]);
xlabel('nROIs');
ylabel('Nor. Weight');
title('Avg. Weight For every ROI');
saveas(f_weights,'Normalized ROI weight plot');
saveas(f_weights,'Normalized ROI weight plot','png');
close(f_weights);

save SigWeiROIinds.mat sigvalueInds sigValueSign SignedROIs MeanWegtAll SIgROIweiValue -v7.3

if nargout > 0
    varargout{1} = sigvalueInds;
end