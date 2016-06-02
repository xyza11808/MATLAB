function out = fit_logistic_psych_con(x, y, plot_flag)

% plot_opt.weights = [1   1    1   0.3   0.4  1  1  1];
% [xData, yData, weights_1] = prepareCurveData( x, y ,plot_opt.weights);
[xData, yData] = prepareCurveData( x, y);

% Set up fittype and options.
ft = fittype( 'a/(1+exp(-(x - b)/c))', 'independent', 'x', 'dependent', 'y' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.StartPoint = [0.9 13 1];
% opts.Weights = weights_1;

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );

out.a = fitresult.a;
out.b = fitresult.b;
out.c = fitresult.c;
out.gof = gof;

if plot_flag == 1
    h = plot( fitresult, xData, yData );
    delete(h(1))
    set(h(2),'Color',[.5 .5 .5],'linewidth',2);
    legend('')
end

%{
% Plot fit with data.
figure(fig1);
h2 = plot( fitresult, xData, yData );
set(h2(1),'Marker','o','markersize',15,'linewidth',2,'color', plot_opt(2).plt_color)
set(h2(2), 'color',plot_opt(2).plt_color,'linewidth',2)
% legend( h2(1), 'Control', 'Location', 'NorthEast' ,'fontsize',15);
% Label axes
% xlabel('Tone Frequency (kHz)');
% ylabel('Frac R-Choice');
set(gca,'fontsize',20)
xlabel('Tone Frequency (kHz)');
ylabel('Frac R-Choice');
% legend( h2, 'frac_choice_right_Opto vs. toneOct', 'untitled fit 1', 'Location', 'NorthEast' );
legend( [h1(2),h2(2)], 'Control', 'OptoStim', 'Location', 'SouthEast' ,'fontsize',15);
title(fn_str,'fontsize',20,'Interpreter','none');
%}