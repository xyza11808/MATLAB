
t1=tic;
parfor n=1:200
    h=figure;
    plot(rand(3,4));
%     set(h,'PaperUnits','inches','PaperPosition',[0 0 12 7]);
%     print(h,'-dpng',sprintf('test%d.png',n),'-r200');
    saveas(h,sprintf('test%d',n),'fig');
    close(h);
end
for n=1:200
    open(sprintf('test%d.fig',n));
    saveas(gcf,sprintf('test%d.png',n),'png');
    close(gcf);
end
T1_test=toc(t1);
disp(T1_test);


%%
t2=tic;
for n=1:200
    h=figure;
    plot(rand(3,4));
    saveas(h,sprintf('test%d',n),'png');
    close(h);
end
T2_test=toc(t2);
disp(T2_test);
print(gcf,'-dpng','-zbuffer','-r240',sprintf('test%d.png',n));

%%
