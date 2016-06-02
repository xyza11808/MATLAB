
fq = [11192, 18820, 12445, 17600, 13177, 16800, 13707, 16300, 12767, 17200, 12605, 17400, 10000, 20000];
RWC= [10.84, 59.72, 25.29, 83.08, 50.6, 48.15, 53.01, 45.78, 76.62, 52.94, 14.89, 56.57, 9.89, 91.24];
plot(fq,RWC,'o');
fq_oct=log2(fq./min(fq));
figure;
plot(fq_oct,RWC,'o');


%%
figure;
b=glmfit(fq,RWC','binomial','link','logit');
[yfit,f_low,f_high]=glmval(b,fq,'logit');
 plot(x,yfit,'-','color','r');
 