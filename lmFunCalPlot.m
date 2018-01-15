function varargout = lmFunCalPlot(x,y,varargin)
% using linear regression method to do the regression and plot the final
% result, extracting model data from linear regression output

isplot = 1;
if ~isempty(varargin)
    isplot = varargin{1};
end
DefAlpha = 0.05;
if nargin > 3
    if ~isempty(varargin{2})
        DefAlpha = varargin{2};
    end
end
if length(x) ~= length(y)
    error('Input data size isn''t match, please check your input.');
end

tb1 = fitlm(x,y);
% fprintf('Model fit result.\n');
% disp(tb1.Coefficients);
% disp(tb1);
InterValue = tb1.Coefficients.Estimate(1);
CoefValue = tb1.Coefficients.Estimate(2);
Rsqr = tb1.Rsquared.Adjusted;
Coeffiall = tb1.Coefficients;

Fitx = linspace(min(x),max(x),500);
Fitx = Fitx(:);
PredValue = predict(tb1,Fitx);
MdCoefCI = coefCI(tb1,DefAlpha);
MdCoefData = [MdCoefCI(1,1)+MdCoefCI(2,1)*Fitx,MdCoefCI(1,2)+MdCoefCI(2,2)*Fitx];
if isplot
    h_data = figure('position',[100 100 550 420]);
    hold on;
    h1 = scatter(x,y,40,'ro');
    h2 = plot(Fitx,PredValue,'k','LineWidth',1.6);
    xlabel('predictor variables');
    ylabel('Response');
    title({'Linear regression result';sprintf('R-Squr = %.3f, Slope = %.3f',Rsqr,CoefValue)});
    legend([h1,h2],{'Real Data','Fit Data'});  %,'Location','southeast'
    set(gca,'FontSize',18);
end
if nargout > 0
    varargout{1} = tb1;
%     varargout{2} = [InterValue,CoefValue];
%     varargout{3} = Rsqr;
%     varargout{4} = Coeffiall;
    if isplot
        varargout{2} = h_data;
    else
        if nargout == 2
            varargout{2} = [Fitx,PredValue,MdCoefData];
        end
    end
    if nargout > 2
        if isplot
            varargout{3} = [Fitx,PredValue,MdCoefData];
        else
            varargout{2} = [Fitx,PredValue,MdCoefData];
        end
    end
end