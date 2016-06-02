
%demo code for factor analysis of population trajectory
% MeanLeftData is a nROI by nTime matrix

[lamda,Psi,T,stats,F]=factoran(MeanLeftData',6);

% calculate fraction of variance explained
SSAll = sum(lamda.^2);
SSfraction = SSAll/sum(SSAll);
F3explain = sum(SSfraction(1:3));  %fraction of variance explained by first three factors
fprintf('Variance explained by first three factors is %.4f',F3explain);


% factor score used for plot and calculation
First3Score = F(:,1:3);

% unrotate factor score
UnrotateF = F * T';
UFirst3Score = UnrotateF(:,1:3);

h_fscore = figure;
hold on
plot3(UnrotateF(:,1),UnrotateF(:,2),UnrotateF(:,3),'k','LineWidth',1.2);
plot3(UnrotateF(1,1),UnrotateF(1,2),UnrotateF(1,3),'go','LineWidth',1.2,'MarkerSize',10);
plot3(UnrotateF(AlignFrame,1),UnrotateF(AlignFrame,2),UnrotateF(AlignFrame,3),'go','LineWidth',1.2,'MarkerSize',10);


%%
% Euclidean distances
Type1Dis = UFirst3Score1;
Type2Dis = UFirst3Score2;
EDis = sqrt(sum((Type2Dis - Type1Dis).^2,2));
% calculate distance from left and right mean trace or shuffled mean trace
% plot the first three factors to plot the trace and variance explaination


%%
% rebuilding F score
n = size(X,1);  % ignore 'nobs' if raw data provided
stdev = std(X);
X0 = (X - repmat(mean(X),n,1)) ./ repmat(stdev,n,1); % standardize to cor matrix
sqrtPsi = sqrt(Psi);
invsqrtPsi = diag(1 ./ sqrtPsi);
