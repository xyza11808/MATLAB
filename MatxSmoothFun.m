function SmData = MatxSmoothFun(im,span)
Rows = size(im,1);
SmData = zeros(size(im));
for cR = 1 : Rows
    cRData = squeeze(im(cR,:,:));
    SmData(cR,:,:) = smoothdata(cRData,2,'movmean',span);
end