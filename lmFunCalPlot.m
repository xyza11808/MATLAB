function varargout = lmFunCalPlot(x,y,varargin)
% using linear regression method to do the regression and plot the final
% result, extracting model data from linear regression output

isplot = 1;
if ~isempty(varargin)
    isplot = varargin{1};
end

if length(x) ~= length(y)
    error('Input data size isn''t match, please check your input.');
end

tb1 = fitlm(x,y);
fprintf('Model fit result.\n');
disp(tb1.Coefficients);
InterValue = tb1.Coefficients.Estimate(1);
CoefValue = tb1.Coefficients.Estimate(2);
Rsqr = tb1.Rsquared.Adjusted;
Coeffiall = tb1.Coefficients;

Fitx = linspace(min(x),max(x),500);
PredValue = predict(tb1,Fitx');
if isplot
    h_data = figure('position',[450 240 1050 750]);
    hold on;
    h1 = scatter(x,y,40,'ro');
    h2 = plot(Fitx,PredValue,'k','LineWidth',1.6);
    xlabel('predictor variables');
    ylabel('Response');
    title({'Linear regression result';sprintf('R-Squr = %.3f, Slope = %.3f',Rsqr,CoefValue)});
    legend([h1,h2],{'Real Data','Fit Data'},'Location','southeast');
    set(gca,'FontSize',18);
end
if nargout > 0
    varargout{1} = tb1;
    varargout{2} = [InterValue,CoefValue];
    varargout{3} = Rsqr;
    varargout{4} = Coeffiall;
    if isplot
        varargout{5} = h_data;
    end
    if nargout > 4
        if isplot
            varargout{6} = {Fitx,PredValue};
        else
            varargout{5} = {Fitx,PredValue};
        end
    end
end