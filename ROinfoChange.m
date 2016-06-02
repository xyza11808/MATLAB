function yy=ROinfoChange(xx,Inds)
yy=xx;
if length(xx) == length(Inds)
    yy(Inds) = [];
end