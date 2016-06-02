function Left_right_pca_New(InputData,TrialTypes,TrialOutcome,OnFrame,FrameRate,varargin)
%this function will using a new way to calcualte PC space seperation in
%visible three dimensional space
%the projection matrix will be find by the maxium seperation of left and
%right trials
%XIN Yu

[nTrials,nROIs,nTimes] = size(InputData);
iscorrectT = [];
if nargin > 5
    iscorrectT = varargin{1};
end
if isempty(iscorrectT) || ~iscorrectT
    UsingInds = true(length(TrialTypes));
else
    UsingInds = TrialOutcome == 1;
end

SelectData = InputData(UsingInds,:,:);
SelectTiType = TrialTypes(UsingInds);

LeftInds = SelectTiType == 0;
RightInds = SelectTiType == 1;
LeftDataMatrix = squeeze(mean(SelectData(LeftInds,:,OnFrame:OnFrame+round(1.5*FrameRate))));  % nROI by TimePoints for left trials
RightDataMatrix = squeeze(mean(SelectData(RightInds,:,OnFrame:OnFrame+round(1.5*FrameRate))));  % nROI by TimePoints for Right trials
LRDiff = RightDataMatrix - LeftDataMatrix;
[coeff,scoreT,~,~,explainedT,~]=pca(LRDiff);
fprintf('First three component explained %.3f of total variation.\n',sum(explainedT(1:3)));

ProjCoff = coeff(:,1:3)';

CorrInds = TrialOutcome == 1;
CorrTypes = TrialTypes(CorrInds);
CorrData = SelectData(CorrInds,:,:);
CorrLeftDataM = squeeze(mean(CorrData(CorrTypes == 0,:,:)));
CorrRightDataM = squeeze(mean(CorrData(CorrTypes == 1,:,:)));

TimeNum = size(CorrLeftDataM,2);
LeftTrace3 = zeros(TimeNum,3);
RightTrace3 = zeros(TimeNum,3);
for nT = 1 : TimeNum
    cTdataL = CorrLeftDataM(:,nT);
    cTdataR = CorrRightDataM(:,nT);
    LeftTrace3(nT,:) = (ProjCoff * (cTdataL - mean(cTdataL)))';
    RightTrace3(nT,:) = (ProjCoff * (cTdataR - mean(cTdataR)))';
end

h_Trace = figure;
hold on
plot3(LeftTrace3(:,1),LeftTrace3(:,2),LeftTrace3(:,3),'b-o','LineWidth',1.7);
plot3(RightTrace3(:,1),RightTrace3(:,2),RightTrace3(:,3),'r-o','LineWidth',1.7);
x_start = [LeftTrace3(1,:);RightTrace3(1,:)];
x_trigger = [LeftTrace3(OnFrame,:);RightTrace3(OnFrame,:)];
x_end = [LeftTrace3(end,:);RightTrace3(end,:)];
scatter3(x_trigger(:,1),x_trigger(:,2),x_trigger(:,3),'MarkerEdgeColor','r','MarkerFaceColor','c','LineWidth',2);
scatter3(x_start(:,1),x_start(:,2),x_start(:,3),'MarkerEdgeColor','c','MarkerFaceColor','g','LineWidth',1.5);
scatter3(x_end(:,1),x_end(:,2),x_end(:,3),'MarkerEdgeColor','c','MarkerFaceColor','y');
saveas(h_Trace,'Proj in Maxium Diff Space.png');
saveas(h_Trace,'Proj in Maxium Diff Space.fig');
close(h_Trace);
