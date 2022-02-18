function Info = MutInfo(x,y,varargin)
pmin = 1e-6;

xTypes = unique(x);
yTypes = unique(y);
xTypeProb = zeros(length(xTypes),1);
yTypeProb = zeros(length(yTypes),1);
Joint_p = zeros(length(xTypes),length(yTypes));
InfoAll = zeros(length(xTypes),length(yTypes));
for cx = 1 : length(xTypes)
    xTypeProb(cx) = max(mean(x == xTypes(cx)),pmin);
    for cy = 1 : length(yTypes)
        if cx == 1
           yTypeProb(cy) = max(mean(y == yTypes(cy)),pmin);
        end
        Joint_p(cx,cy) = max(mean(x == xTypes(cx) & y == yTypes(cy)),pmin);
        InfoAll(cx,cy) = Joint_p(cx,cy)*log(Joint_p(cx,cy)/(xTypeProb(cx)*yTypeProb(cy)));
    end
end
Info = sum(InfoAll(:));