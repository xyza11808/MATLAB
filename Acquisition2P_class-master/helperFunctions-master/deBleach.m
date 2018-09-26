function [f, stats] = deBleach(f, mode, varargin)
% f = deBleach(f, mode) removes bleaching 
% f = deBleach(f, 'runningAvg', FrameWidth) specifies width of avg window

[f_, stats] = getF_(f,mode);
f = f-f_+mean(f_);
% switch mode
%     case 'exponential'
%         % Robustly fit a straight line to log(fluorescence) and then
%         % subtract exp(straightLine).
%         f(f<0.1) = 0.1; % So that log() works without imaginary issues.
%         fl = log(f);
%         x = 1:numel(f);
%         b = robustfit(x, fl);
%         f_ = exp(b(1)+b(2)*x);
%         f = f-f_+mean(f_);
%         
%     case 'linear'
% %         f = detrend(f);
%         % Detrend is not robust to outliers, so we use robustfit instead:
%         x = 1:numel(f);
%         b = robustfit(x, f);
%         f_ = b(1)+b(2)*x;
%         f = f-f_+mean(f_);
%     
%     case 'runningAvg'
%         fWid = varargin{1};
%         avgFilt = ones(fWid,1)/fWid;
%         prePad = floor((fWid-1)/2);
%         postPad = ceil((fWid-1)/2);
%         f_ = conv(f,avgFilt,'valid');
%         f_ = [f_(1)*ones(prePad,1); f_(:); f_(end)*ones(postPad,1)]';
%         f = f-f_+mean(f_);        
% end