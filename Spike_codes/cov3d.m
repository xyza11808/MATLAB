function xy = cov3d(x)

[m,n,p] = size(x);
xy = zeros(n,n,p,class(x));
if m > 1
    xc = bsxfun(@minus,x,sum(x,1)/m);
    for i = 1:p
        xci = xc(:,:,i);
        xy(:,:,i) = xci'*xci;
    end
    xy = xy/(m-1);
end