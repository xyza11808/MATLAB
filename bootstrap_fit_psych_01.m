tic
parpool('local', 8);
options = statset('UseParallel',true);
[bootstat_control, bootsam] = bootstrp(500, @(x, y) fit_logistic_psych_con(x, y,0), toneOct, frac_choice_right_Contr,'Options',options);
toc
%%
%
gof = [bootstat_control.gof];
rmse = [gof.rmse];
sse = [gof.sse];
rsq = [gof.rsquare];
adjrsquare = [gof.adjrsquare];

inds_use1 = find(rmse < prctile(rmse,50));
inds_use2 = find(rsq > prctile(rsq,50));

a1 = median([bootstat_control(inds_use1).a]);
b1 = median([bootstat_control(inds_use1).b]);
c1 = median([bootstat_control(inds_use1).c]);

%
% pct = 40;
% a1 = prctile([bootstat_control.a], pct);
% b1 = prctile([bootstat_control.b], pct);
% c1 = prctile([bootstat_control.c], pct);
%
% a1 = mode([bootstat_control.a]);
% b1 = mode([bootstat_control.b]);
% c1 = mode([bootstat_control.c]);

%
x1 = linspace(min(toneOct)-0.1, max(toneOct)+0.1, 100);

% c1 = prctile([bootstat_control.c],35);

y1 = a1./(1+exp(-(x1 - b1)/c1));
h_curve_1 = plot(x1,y1,'g','linewidth',2);
%%
fit_param.slope = 1/c1;
fit_param.bias = b1;
fit_param.lapse = a1;
fit_param.gof_bootstrap = gof;
%%
[bootstat_opto, bootsam] = bootstrp(1000, @(x, y) fit_logistic_psych_opto(x, y,0), toneOct, frac_choice_right_Opto);
%%
gof = [bootstat_control.gof];
rmse = [gof.rmse];
inds_use = find(rmse < prctile(rmse,50));

a2 = median([bootstat_control(inds_use).a]);
b2 = median([bootstat_control(inds_use).b]);
c2 = median([bootstat_control(inds_use).c]);


x2 = linspace(min(toneOct)-0.1, max(toneOct)+0.1, 100);

% c1 = prctile([bootstat_control.c],35);

y2 = a1./(1+exp(-(x2 - b2)/c2));
h_curve_2 = plot(x2, y2,'g','linewidth',2);