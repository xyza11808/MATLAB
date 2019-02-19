function [x,y]=findIntersect(x1,y1,x2,y2)
% find approximate intersection of two curves (x1,y1) (x2,y2),
% the first intersect point starting from x1(1) to x1(end)
x=nan; y=nan;
if ~isrow(x1) && ~iscolumn(y1) && ~isrow(x2) && ~iscolumn(y2)
    disp('error! x, y must be vectors');
    return;
end
if length(x1)~=length(y1) || length(x2)~=length(y2)
    disp('error! x, y must be same length');
    return;
end

minDistInd=1;
minDi=(x1(1)-x2(1))^2 + (y1(1)-y2(1))^2 ;
minD=minDi;
ind1=nan;ind2=nan;

for i=1:length(x1)
    xx=x1(i);
    yy=y1(i);
    vx=xx-x2;
    vy=yy-y2;
    dist=vx.*vx + vy.*vy;
    [minD_,minDistInd]=min(dist);
    
    if minD_<=minD
        minD=minD_;
        ind1=i;
        ind2=minDistInd(1);
    end
end

x=mean([x1(ind1),x2(ind2)]);
y=mean([y1(ind1),y2(ind2)]);

end