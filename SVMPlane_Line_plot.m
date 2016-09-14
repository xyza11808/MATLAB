
figure;
hold on;
PointScores = scoreT(:,1:3);
scatter3(PointScores(1:3,1),PointScores(1:3,2),PointScores(1:3,3),120,'p','MarkerEdgeColor','b','LineWidth',3);
scatter3(PointScores(4:6,1),PointScores(4:6,2),PointScores(4:6,3),120,'p','MarkerEdgeColor','r','LineWidth',3);
%%
% extract coefficients from svm model
VectorCoeff = CVsvmmodel.Beta;
BiasValue = CVsvmmodel.Bias;
% SufFunction = [x,y,z]'* VectorCoeff + BiasValue == 0;

%%
ProjectPoints = zeros(size(PointScores));
ModelFun = @(x,y,z) (VectorCoeff(1) * x + VectorCoeff(2) * y + VectorCoeff(3) * z + BiasValue)/(sum(VectorCoeff.^2));
for nPoints = 1 : size(PointScores,1)
    t_factor = ModelFun(PointScores(nPoints,1),PointScores(nPoints,2),PointScores(nPoints,3));
    ProjectPoints(nPoints,1) = PointScores(nPoints,1) - t_factor * VectorCoeff(1);
    ProjectPoints(nPoints,2) = PointScores(nPoints,2) - t_factor * VectorCoeff(2);
    ProjectPoints(nPoints,3) = PointScores(nPoints,3) - t_factor * VectorCoeff(3);
    LinePoints = [PointScores(nPoints,:);ProjectPoints(nPoints,:)];
    line(LinePoints(:,1),LinePoints(:,2),LinePoints(:,3),'color','k','LineStyle','--','LineWidth',3);
end

scatter3(ProjectPoints(:,1),ProjectPoints(:,2),ProjectPoints(:,3),100,'o','MarkerEdgeColor','m','LineWidth',3);

%%
xScales = get(gca,'xlim');
yScales = get(gca,'ylim');
[x,y] = meshgrid(xScales(1):xScales(2),yScales(1):yScales(2));
z = -1 * (BiasValue + x * VectorCoeff(1) + y * VectorCoeff(2)) / VectorCoeff(3);
surf(x,y,z,'LineStyle','none','FaceColor','c','FaceAlpha',0.4);  %,'Facecolor','interp'
alpha(0.4)
xlabel('PC1');
ylabel('PC2');
zlabel('PC3');

%%
PointsVector = PointScores - ProjectPoints;
xx = PointsVector/VectorCoeff';