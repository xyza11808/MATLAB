function Info = MutInfo(x,y,varargin)

xTypes = unique(x);
yTypes = unique(y);
xTypeProb = zeros(length(xTypes),1);
yTypeProb = zeros(length(yTypes),1);
Joint_p = zeros(length(xTypes),length(yTypes));
InfoAll = zeros(length(xTypes),length(yTypes));
for cx = 1 : length(xTypes)
    xTypeProb(cx) = mean(x == xTypes(cx));
    for cy = 1 : length(yTypes)
        if cx == 1
           yTypeProb(cy) = mean(y == yTypes(cy));
        end
        Joint_p(cx,cy) = mean(x == xTypes(cx) & y == yTypes(cy));
        InfoAll(cx,cy) = Joint_p(cx,cy)*log2(Joint_p(cx,cy)/(xTypeProb(cx)*yTypeProb(cy)));
    end
end
Info = sum(InfoAll(:));