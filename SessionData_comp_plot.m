
[fn,fp,fi] = uigetfile('ModelBehavComp.mat','Please select your sessions summary data of behav and model comparation');
cd(fp);
load(fn);
%%
TargRespInds = SessionCenter == 0.75;
TargRespData = InputData(TargRespInds,:);
BehavResult = cell2mat(TargRespData(:,1));
ModelResult = (reshape(cell2mat(TargRespData(:,2)),6,[]))';
BehavResult(:,1:3) = 1 - BehavResult(:,1:3);
ModelResult(:,1:3) = 1 - ModelResult(:,1:3);

%%
figure;
hold on;
LineColor = jet(size(BehavResult,1));
tbAll = cell(size(BehavResult,1),1);
RsqurAll = zeros(size(BehavResult,1),1);
CoefAll = zeros(size(BehavResult,1),2);
for nn = 1 : size(BehavResult,1)
    plot(BehavResult(nn,:),ModelResult(nn,:),'o','Color',LineColor(nn,:),'LineWidth',1.6);
    tbl = fitlm(BehavResult(nn,:),ModelResult(nn,:));
    tbAll(nn) = {tbl};
    RsqurAll(nn) = tbl.Rsquared.Adjusted;
    CoefAll(nn,:) = (tbl.Coefficients.Estimate)';
end
xlabel('Rightward choice (Behavior)');
ylabel('Rightward choice (Neuron)');
set(gca,'FontSize',16);
MeanSqr = mean(RsqurAll);
SemSqr = std(RsqurAll)/sqrt(length(RsqurAll));
AllSlope = CoefAll(:,2);
MeanSlope = mean(AllSlope);
SemSlope = std(AllSlope)/sqrt(length(AllSlope));
title(sprintf('Mean line slope %.3f, Mean square is %.3f',MeanSlope,MeanSqr));

%%
saveas(gcf,'Scatter Plot Behav vs Model');
saveas(gcf,'Scatter Plot Behav vs Model','png');
save ScatterPlotData.mat  BehavResult ModelResult tbAll RsqurAll CoefAll -v7.3

%%
StimType = [8000;10565;13929;18379;24251;32000];
h_colorPlot = figure;
hold on;
FreqNum = size(BehavResultAll,2);
ColorMap = jet(FreqNum);
for nn = 1 : size(BehavResultAll,1)
    scatter(BehavResultAll(nn,:),FitResultAll(nn,:),50,ColorMap,'o','filled','LineWidth',1.6);
end
set(gca,'xtick',0:0.2:1,'ytick',0:0.2:1);
colormap(ColorMap);
h = colorbar('southoutside');
set(h,'ytick',(1/FreqNum:1/FreqNum:1)-(0.5/FreqNum),'yticklabel',cellstr(num2str(StimType/1000,'%.2f')),...
    'Ticklength',0);
[mdl,CoefValue,Rsqur,~] = lmFunCalPlot(BehavResultAll(:),FitResultAll(:),0);
FitPlotx = linspace(min(BehavResultAll(:)),max(FitResultAll(:)),500);
FitPloty = predict(mdl,FitPlotx');
plot(FitPlotx,FitPloty,'k','LineWidth',1.8);
xlim([0 1]);ylim([0 1]);
xlabel('Rightward choice (Behavior)');
ylabel('Rightward choice (Neuron)');
title({'Behavior vs neuron compare plot',sprintf('R-Squr = %.3f, Slope = %.3f',Rsqur,CoefValue(2))});
set(gca,'FOntSize',20);
%%
saveas(h_colorPlot,'Scatter color plot save');
saveas(h_colorPlot,'Scatter color plot save','png');
close(h_colorPlot);
%%
[mdl,CoefValue,Rsqur,hF] = lmFunCalPlot(BehavResult(:),ModelResult(:));
[Coef,p_Coef] = corrcoef(BehavResult(:),ModelResult(:));
figure(hF);
title({'Linear regression result';sprintf('R-Squr = %.3f, Slope = %.3f',Rsqur,CoefValue(2));sprintf('Coef = %.3f, p_coef = %.4f',Coef(1,2),p_Coef(1,2))});
set(gca,'xtick',0:0.2:1,'ytick',0:0.2:1);
xlabel('Rightward choice (Behavior)');
ylabel('Rightward choice (Neuron)');
saveas(hF,'All Points scatter plot and linear regression');
saveas(hF,'All Points scatter plot and linear regression','png');


%%
figure;
ROIauc = SessionData.ROIauc;
ROIWeightNor = abs(ROIWeight)/max(abs(ROIWeight));
scatter(ROIWeightNor,ROIauc)
xlabel('SVM weight')
ylabel('ROI AUC')
xlabel('SVM weight(a.u.)')
[R,P] = corrcoef(ROIWeightNor,ROIauc);
title(sprintf('r = %.3f, p = %.2e',R(1,2),P(1,2)))
set(gca,'FontSize',20)
