
fq = [12445, 17600, 13177, 16800, 13707, 16300, 12767, 17200, 12605, 17400, 10000, 20000];
RWC= [25.29, 83.08, 50.6, 48.15, 53.01, 45.78, 76.62, 52.94, 14.89, 56.57, 9.89, 91.24];

len=length(fq);

[fq_sorted,fq_s_I]=sort(fq);

RWC_sorted = RWC(fq_s_I);

fq0 = fq_sorted(1);
fq_oct = log2(fq_sorted/fq0);

[Qpre1,p1]=fit_logistic(fq_oct,RWC_sorted);

% psyc_fun = @(t)(p(2)/(1 + exp(-p(3)*(t-p(1))))); 

%% Plot using octave 
psyc_fun1 = @(t)(p1(2)./(1 + exp(-p1(3).*(t-p1(1)))));
t1=fq_oct(1):0.0001:fq_oct(len); 
fig1= figure;
plot(fq_oct,RWC_sorted,'k.',t1,psyc_fun1(t1),'markersize',20, 'linewidth',2);
title('Psychometric Func, Mouse2', 'fontsize',20);       
set(gca,'fontsize',15)
set(gcf, 'Color', 'w');
xlabel('Tone Frequency (octave)', 'fontsize', 20)
ylabel('Rightward choice', 'fontsize', 20)
%% Plot using frequency
[Qpre2,p2]=fit_logistic(fq_sorted,RWC_sorted);
psyc_fun2 = @(t)(p2(2)./(1 + exp(-p2(3).*(t-p2(1)))));
t2=fq_sorted(1):fq_sorted(len);
fig2=figure;
plot(fq_sorted,RWC_sorted,'k.',t2,psyc_fun2(t2),'markersize',20, 'linewidth',2);
title('Psychometric Func, Mouse2', 'fontsize',20);
set(gca,'fontsize',15)
set(gcf, 'Color', 'w');
xlabel('Tone Frequency', 'fontsize', 20)
ylabel('Rightward choice', 'fontsize', 20)


