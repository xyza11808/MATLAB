
[fn,fp,fi] = uigetfile('ModelBehavComp.mat','Please select your sessions summary data of behav and model comparation');
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
xlabel('Behav Rightward choice');
ylabel('Model Rightward choice');
set(gca,'FontSize',16);
MeanSqr = mean(RsqurAll);
SemSqr = std(RsqurAll)/sqrt(length(RsqurAll));
AllSlope = CoefAll(:,2);
MeanSlope = mean(AllSlope);
SemSlope = std(AllSlope)/sqrt(length(AllSlope));
title(sprintf('Mean line slope %.3f, Mean square is %.3f',MeanSlope,MeanSqr));
saveas(gcf,'Scatter Plot Behav vs Model');
saveas(gcf,'Scatter Plot Behav vs Model','png');
save ScatterPlotData.mat  BehavResult ModelResult tbAll RsqurAll CoefAll -v7.3

%%
figure;
scatter(BehavResult(:),ModelResult(:),30,'ro');

%%
[mdl,CoefValue,Rsqur,hF] = lmFunCalPlot(BehavResult(:),ModelResult(:));
[Coef,p_Coef] = corrcoef(BehavResult(:),ModelResult(:));
figure(hF);
title({'Linear regression result';sprintf('R-Squr = %.3f, Slope = %.3f',Rsqur,CoefValue(2));sprintf('Coef = %.3f, p_coef = %.4f',Coef(1,2),p_Coef(1,2))});
set(gca,'xtick',0:0.2:1,'ytick',0:0.2:1);
xlabel('Behav rightward choice');
ylabel('Model rightward choice');
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
