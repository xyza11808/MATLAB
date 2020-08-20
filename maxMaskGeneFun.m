function [closedMask, Bpos] = maxMaskGeneFun(RawMask, DiskRadius)
% this function is used to processing raw mask and return a processed mask,
% which is the largest connected mask in raw image and closed small gaps

% step 1, select largest connected mask in raw
[B,L,N,~]=bwboundaries(RawMask); 
if N>1
    labelCount=zeros(N,1);
    for m=1:N
        labelCount(m)=sum(sum(L==m));
    end
    [~,RealROIlbel]=max(labelCount);
%         RealROIlbel=I;
    RealMask=L==double(RealROIlbel);
    RealPos=B(RealROIlbel);
else
    RealMask=L;
    RealPos=B;
end
Bpos=RealPos{1};

% close gap within mask
se = strel('disk', DiskRadius);
closedMask = imclose(RealMask,se);

closedMask = closedMask > 0;



