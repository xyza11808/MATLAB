function act = drawTraj(W,b,layertypes,codeLayer)

h=imfreehand('Closed',false);
pTraj=getPosition(h);
delete(h)
hold on
scatter(pTraj(:,1),pTraj(:,2),25,1/size(pTraj,1):1/size(pTraj,1):1)
[act,~]=calcActivations(pTraj',W,b,layertypes,codeLayer);
figure,plot(act'),
hold on
scatter(1:size(pTraj,1),zeros(1,size(pTraj,1)),25,1:size(pTraj,1))